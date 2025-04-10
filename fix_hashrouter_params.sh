#!/bin/bash

# Script pour corriger les problèmes d'extraction du paramètre concertId avec HashRouter
echo "Début de la correction des problèmes d'extraction du paramètre concertId avec HashRouter..."

# Créer des sauvegardes des fichiers originaux
echo "Création des sauvegardes..."
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)_hashrouter_fix"
mkdir -p $BACKUP_DIR

# Sauvegarde des fichiers existants
if [ -f "./client/src/components/public/PublicFormPage.jsx" ]; then
  cp ./client/src/components/public/PublicFormPage.jsx $BACKUP_DIR/PublicFormPage.jsx.backup
fi

if [ -f "./client/src/App.js" ]; then
  cp ./client/src/App.js $BACKUP_DIR/App.js.backup
fi

if [ -f "./client/src/index.js" ]; then
  cp ./client/src/index.js $BACKUP_DIR/index.js.backup
fi

# Mise à jour du fichier PublicFormPage.jsx pour extraire correctement le concertId avec HashRouter
echo "Mise à jour du fichier PublicFormPage.jsx..."
mkdir -p ./client/src/components/public
cat > ./client/src/components/public/PublicFormPage.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { createFormSubmission } from '../../services/formSubmissionsService';
import './PublicFormPage.css';

// Fonction utilitaire pour extraire le concertId de l'URL avec HashRouter
const extractConcertIdFromHash = () => {
  const hash = window.location.hash;
  console.log('extractConcertIdFromHash - hash brut:', hash);
  
  // Format attendu: /#/form/CONCERT_ID
  const match = hash.match(/\/#\/form\/([^\/\?]+)/);
  if (match && match[1]) {
    console.log('extractConcertIdFromHash - concertId extrait:', match[1]);
    return match[1];
  }
  
  // Essayer un autre format possible: #/form/CONCERT_ID
  const altMatch = hash.match(/#\/form\/([^\/\?]+)/);
  if (altMatch && altMatch[1]) {
    console.log('extractConcertIdFromHash - concertId extrait (format alt):', altMatch[1]);
    return altMatch[1];
  }
  
  console.log('extractConcertIdFromHash - aucun concertId trouvé dans le hash');
  return null;
};

const PublicFormPage = (props) => {
  // Extraction robuste du concertId
  const params = useParams();
  const [concertId, setConcertId] = useState(null);
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [submissionResult, setSubmissionResult] = useState(null);
  const [formData, setFormData] = useState({
    businessName: '',      // Raison sociale
    firstName: '',         // Prénom
    lastName: '',          // Nom
    role: '',              // Qualité
    address: '',           // Adresse de la raison sociale
    venue: '',             // Lieu ou festival
    venueAddress: '',      // Adresse du lieu ou festival
    vatNumber: '',         // Numéro intracommunautaire
    siret: '',             // Siret
    email: '',             // Mail
    phone: '',             // Téléphone
    website: ''            // Site web
  });
  
  // Déterminer le concertId de manière robuste
  useEffect(() => {
    // Priorité 1: Props passées directement
    if (props.concertId) {
      console.log('PublicFormPage - concertId depuis props:', props.concertId);
      setConcertId(props.concertId);
      return;
    }
    
    // Priorité 2: Paramètres de route via useParams()
    if (params.concertId) {
      console.log('PublicFormPage - concertId depuis useParams:', params.concertId);
      setConcertId(params.concertId);
      return;
    }
    
    // Priorité 3: Extraction directe depuis l'URL
    const extractedId = extractConcertIdFromHash();
    if (extractedId) {
      console.log('PublicFormPage - concertId extrait de l\'URL:', extractedId);
      setConcertId(extractedId);
      return;
    }
    
    console.log('PublicFormPage - AUCUN concertId trouvé!');
    setError("Erreur: ID du concert manquant. Veuillez accéder à ce formulaire via un lien valide.");
  }, [props.concertId, params.concertId]);
  
  // Logs de débogage détaillés
  useEffect(() => {
    console.log('PublicFormPage - CHARGÉE AVEC:');
    console.log('PublicFormPage - concertId final:', concertId);
    console.log('PublicFormPage - concertId depuis props:', props.concertId);
    console.log('PublicFormPage - concertId depuis useParams:', params.concertId);
    console.log('PublicFormPage - Hash brut:', window.location.hash);
    console.log('PublicFormPage - Hash nettoyé:', window.location.hash.replace(/^#/, ''));
    console.log('PublicFormPage - Pathname:', window.location.pathname);
    console.log('PublicFormPage - URL complète:', window.location.href);
    
    // Vérifier si nous sommes dans un contexte HashRouter
    const isHashRouter = window.location.hash.includes('/form/');
    console.log('PublicFormPage - Utilisation de HashRouter détectée:', isHashRouter);
  }, [concertId, props.concertId, params.concertId]);
  
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Vérifier que concertId est disponible
    if (!concertId) {
      setError("Erreur: ID du concert manquant. Veuillez accéder à ce formulaire via un lien valide.");
      return;
    }
    
    try {
      setLoading(true);
      setError(null);
      setSubmissionResult(null);
      
      console.log('PublicFormPage - Début de la soumission du formulaire');
      console.log('PublicFormPage - Données du formulaire:', formData);
      console.log('PublicFormPage - concertId utilisé pour la soumission:', concertId);
      
      // Préparer les données à soumettre avec tous les champs requis
      const submissionData = {
        ...formData,
        // Champs obligatoires pour la compatibilité avec le système existant
        programmerId: 'public-form-submission',
        programmerName: 'Formulaire Public',
        concertId: concertId, // S'assurer que concertId est explicitement inclus
        concertName: `Concert ID: ${concertId}`,
        // Créer un champ contact à partir du prénom et du nom
        contact: formData.firstName && formData.lastName 
          ? `${formData.firstName} ${formData.lastName}` 
          : formData.firstName || formData.lastName || 'Contact non spécifié',
        status: 'pending',
        // Ajouter un formLinkId fictif si nécessaire
        formLinkId: `public-form-${concertId}`
      };
      
      console.log('PublicFormPage - Données préparées pour la soumission:', submissionData);
      console.log('PublicFormPage - Vérification de la présence de concertId:', submissionData.concertId ? 'Présent' : 'Manquant');
      
      // Soumettre le formulaire avec un timeout pour éviter les blocages
      const timeoutPromise = new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Timeout de la soumission du formulaire')), 15000)
      );
      
      const submissionPromise = createFormSubmission(submissionData);
      
      // Utiliser Promise.race pour éviter les blocages
      const result = await Promise.race([submissionPromise, timeoutPromise]);
      
      console.log('PublicFormPage - Résultat de la soumission:', result);
      setSubmissionResult(result);
      
      // Attendre un peu pour que l'utilisateur puisse voir le résultat
      setTimeout(() => {
        setLoading(false);
        if (result && result.id) {
          // Rediriger vers la page de confirmation
          console.log('PublicFormPage - Redirection vers la page de confirmation');
          navigate('/form-submitted');
        } else {
          console.error('PublicFormPage - Échec de la soumission du formulaire');
          setError('Une erreur est survenue lors de la soumission du formulaire.');
        }
      }, 1000);
    } catch (err) {
      console.error('PublicFormPage - Erreur lors de la soumission du formulaire:', err);
      setError(`Une erreur est survenue lors de la soumission du formulaire: ${err.message}`);
      setLoading(false);
    }
  };
  
  if (loading) {
    return (
      <div className="public-form-container">
        <div className="public-form-card">
          <h2>Chargement...</h2>
          <p>Veuillez patienter pendant le traitement de votre demande.</p>
          {submissionResult && (
            <div style={{ 
              marginTop: "20px", 
              padding: "15px", 
              backgroundColor: "#e8f4fd", 
              borderRadius: "5px", 
              border: "1px solid #c5e1f9" 
            }}>
              <p style={{ margin: "0", color: "#2c76c7" }}>
                Soumission réussie! Redirection en cours...
              </p>
              <pre style={{ 
                margin: "10px 0 0 0", 
                color: "#2c76c7", 
                fontSize: "12px", 
                textAlign: "left",
                overflow: "auto",
                maxHeight: "200px"
              }}>
                {JSON.stringify(submissionResult, null, 2)}
              </pre>
            </div>
          )}
        </div>
      </div>
    );
  }
  
  if (error) {
    return (
      <div className="public-form-container">
        <div className="public-form-card error">
          <h2>Erreur</h2>
          <p>{error}</p>
          <button 
            className="form-button"
            onClick={() => {
              setError(null);
              setLoading(false);
            }}
          >
            Réessayer
          </button>
          <button 
            className="form-button secondary"
            onClick={() => window.location.href = window.location.origin}
            style={{ marginTop: "10px" }}
          >
            Retour à l'accueil
          </button>
          
          <div style={{ 
            marginTop: "30px", 
            padding: "15px", 
            backgroundColor: "#f9e8e8", 
            borderRadius: "5px", 
            border: "1px solid #f9c5c5" 
          }}>
            <p style={{ margin: "0", color: "#c72c2c" }}>
              Informations de débogage:
            </p>
            <p style={{ margin: "10px 0 0 0", color: "#c72c2c", fontSize: "14px", textAlign: "left" }}>
              Hash: {window.location.hash}<br />
              Pathname: {window.location.pathname}<br />
              URL complète: {window.location.href}<br />
              Concert ID: {concertId || "Non spécifié"}<br />
              Concert ID (props): {props.concertId || "Non spécifié"}<br />
              Concert ID (params): {params.concertId || "Non spécifié"}
            </p>
          </div>
        </div>
      </div>
    );
  }
  
  return (
    <div className="public-form-container">
      <div className="public-form-card">
        <h2>Formulaire de renseignements</h2>
        <div className="form-header">
          <p><strong>ID du Concert :</strong> {concertId || "Non spécifié"}</p>
        </div>
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="businessName">Raison sociale</label>
            <input
              type="text"
              id="businessName"
              name="businessName"
              value={formData.businessName}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="lastName">Nom</label>
            <input
              type="text"
              id="lastName"
              name="lastName"
              value={formData.lastName}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="firstName">Prénom</label>
            <input
              type="text"
              id="firstName"
              name="firstName"
              value={formData.firstName}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="role">Qualité</label>
            <input
              type="text"
              id="role"
              name="role"
              value={formData.role}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="address">Adresse de la raison sociale</label>
            <textarea
              id="address"
              name="address"
              value={formData.address}
              onChange={handleChange}
              rows="3"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="venue">Lieu ou festival</label>
            <input
              type="text"
              id="venue"
              name="venue"
              value={formData.venue}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="venueAddress">Adresse du lieu ou festival</label>
            <textarea
              id="venueAddress"
              name="venueAddress"
              value={formData.venueAddress}
              onChange={handleChange}
              rows="3"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="vatNumber">Numéro intracommunautaire</label>
            <input
              type="text"
              id="vatNumber"
              name="vatNumber"
              value={formData.vatNumber}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="siret">Siret</label>
            <input
              type="text"
              id="siret"
              name="siret"
              value={formData.siret}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="email">Mail</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="phone">Téléphone</label>
            <input
              type="tel"
              id="phone"
              name="phone"
              value={formData.phone}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="website">Site web</label>
            <input
              type="url"
              id="website"
              name="website"
              value={formData.website}
              onChange={handleChange}
            />
          </div>
          
          <div className="form-footer">
            <p>Tous les champs sont facultatifs</p>
            <button 
              type="submit" 
              className="form-button"
              disabled={loading || !concertId}
            >
              {loading ? 'Envoi en cours...' : 'Soumettre le formulaire'}
            </button>
          </div>
        </form>
        
        <div style={{ 
          marginTop: "30px", 
          padding: "15px", 
          backgroundColor: "#e8f4fd", 
          borderRadius: "5px", 
          border: "1px solid #c5e1f9" 
        }}>
          <p style={{ margin: "0", color: "#2c76c7" }}>
            Informations de débogage:
          </p>
          <p style={{ margin: "10px 0 0 0", color: "#2c76c7", fontSize: "14px", textAlign: "left" }}>
            Hash: {window.location.hash}<br />
            Pathname: {window.location.pathname}<br />
            URL complète: {window.location.href}<br />
            Concert ID: {concertId || "Non spécifié"}<br />
            Concert ID (props): {props.concertId || "Non spécifié"}<br />
            Concert ID (params): {params.concertId || "Non spécifié"}
          </p>
        </div>
      </div>
    </div>
  );
};

export default PublicFormPage;
EOL
echo "✅ Fichier PublicFormPage.jsx mis à jour pour extraire correctement le concertId avec HashRouter"

# Mise à jour du fichier FormSubmittedPage.jsx
echo "Mise à jour du fichier FormSubmittedPage.jsx..."
cat > ./client/src/components/public/FormSubmittedPage.jsx << 'EOL'
import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import './PublicFormPage.css';

const FormSubmittedPage = () => {
  // Logs de débogage détaillés
  useEffect(() => {
    console.log("FormSubmittedPage - CHARGÉE");
    console.log("FormSubmittedPage - Hash brut:", window.location.hash);
    console.log("FormSubmittedPage - Hash nettoyé:", window.location.hash.replace(/^#/, ''));
    console.log("FormSubmittedPage - Pathname:", window.location.pathname);
    console.log("FormSubmittedPage - URL complète:", window.location.href);
  }, []);
  
  return (
    <div className="public-form-container">
      <div className="public-form-card">
        <h2>Formulaire Soumis avec Succès</h2>
        <p>
          Merci d'avoir soumis le formulaire. Vos informations ont été enregistrées et seront traitées prochainement.
        </p>
        <div className="form-footer">
          <button 
            className="form-button"
            onClick={() => window.location.href = window.location.origin}
          >
            Retour à l'accueil
          </button>
        </div>
        
        <div style={{ 
          marginTop: "30px", 
          padding: "15px", 
          backgroundColor: "#e8f4fd", 
          borderRadius: "5px", 
          border: "1px solid #c5e1f9" 
        }}>
          <p style={{ margin: "0", color: "#2c76c7" }}>
            Informations de débogage:
          </p>
          <p style={{ margin: "10px 0 0 0", color: "#2c76c7", fontSize: "14px", textAlign: "left" }}>
            Hash: {window.location.hash}<br />
            Pathname: {window.location.pathname}<br />
            URL complète: {window.location.href}
          </p>
        </div>
      </div>
    </div>
  );
};

export default FormSubmittedPage;
EOL
echo "✅ Fichier FormSubmittedPage.jsx mis à jour"

# Mise à jour du fichier ConcertDetail.js pour générer des URL compatibles avec HashRouter
echo "Vérification du fichier ConcertDetail.js..."
if [ -f "./client/src/components/concerts/ConcertDetail.js" ]; then
  echo "Mise à jour du fichier ConcertDetail.js pour générer des URL compatibles avec HashRouter..."
  cp ./client/src/components/concerts/ConcertDetail.js $BACKUP_DIR/ConcertDetail.js.backup
  
  # Remplacer la génération d'URL pour qu'elle soit compatible avec HashRouter
  sed -i 's|const formUrl = `${window.location.origin}/form/${concert.id}`;|const formUrl = `${window.location.origin}/#/form/${concert.id}`;|g' ./client/src/components/concerts/ConcertDetail.js
  
  echo "✅ Fichier ConcertDetail.js mis à jour pour générer des URL compatibles avec HashRouter"
else
  echo "⚠️ Fichier ConcertDetail.js non trouvé, vérification manuelle requise"
fi

# Vérification du fichier CSS
echo "Vérification du fichier PublicFormPage.css..."
if [ ! -f "./client/src/components/public/PublicFormPage.css" ]; then
  echo "Création du fichier PublicFormPage.css..."
  cat > ./client/src/components/public/PublicFormPage.css << 'EOL'
.public-form-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 20px;
  background-color: #f5f5f5;
}

.public-form-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 30px;
  width: 100%;
  max-width: 600px;
}

.public-form-card h2 {
  text-align: center;
  margin-bottom: 20px;
  color: #333;
}

.form-header {
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #555;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-footer {
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.form-footer p {
  margin-bottom: 10px;
  font-size: 14px;
  color: #666;
}

.form-button {
  background-color: #4a90e2;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 20px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.form-button:hover {
  background-color: #3a7bc8;
}

.form-button:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.form-button.secondary {
  background-color: #6c757d;
  margin-top: 10px;
}

.form-button.secondary:hover {
  background-color: #5a6268;
}

.error {
  text-align: center;
}

.error h2 {
  color: #e74c3c;
}

.error p {
  margin-bottom: 20px;
}

/* Style pour le champ en lecture seule */
.readonly-field {
  background-color: #f0f0f0;
  color: #666;
  cursor: not-allowed;
  border: 1px solid #ddd;
}
EOL
  echo "✅ Fichier PublicFormPage.css créé"
fi

# Mise à jour du fichier App.js pour s'assurer que les routes sont correctement définies
echo "Vérification des routes dans App.js..."
if grep -q "form/:concertId" ./client/src/App.js; then
  echo "Route form/:concertId trouvée dans App.js"
else
  echo "⚠️ Route form/:concertId non trouvée dans App.js, vérification de la structure..."
  
  # Vérifier si App.js contient des routes
  if grep -q "<Route" ./client/src/App.js; then
    echo "Structure de routes trouvée dans App.js, ajout de la route form/:concertId..."
    
    # Sauvegarde du fichier App.js
    cp ./client/src/App.js $BACKUP_DIR/App.js.backup
    
    # Ajouter les routes pour le formulaire public
    sed -i '/\/\* Routes publiques/a \        <Route path="\/form\/:concertId" element={<PublicFormPage \/>} \/>\n        <Route path="\/form-submitted" element={<FormSubmittedPage \/>} \/>' ./client/src/App.js || \
    sed -i '/<Routes>/a \        <Route path="\/form\/:concertId" element={<PublicFormPage \/>} \/>\n        <Route path="\/form-submitted" element={<FormSubmittedPage \/>} \/>' ./client/src/App.js
    
    # Ajouter les imports si nécessaire
    if ! grep -q "import PublicFormPage" ./client/src/App.js; then
      sed -i '/import React/a import PublicFormPage from ".\/components\/public\/PublicFormPage";\nimport FormSubmittedPage from ".\/components\/public\/FormSubmittedPage";' ./client/src/App.js
    fi
    
    echo "✅ Routes ajoutées à App.js"
  else
    echo "⚠️ Structure de routes non trouvée dans App.js, vérification manuelle requise"
  fi
fi

# Création d'un fichier README pour expliquer les modifications
echo "Création d'un fichier README pour expliquer les modifications..."
cat > ./README_HASHROUTER_FIX.md << 'EOL'
# Correction des problèmes d'extraction du paramètre concertId avec HashRouter

## Problèmes identifiés et solutions apportées

1. **Extraction incorrecte du paramètre concertId avec HashRouter** :
   - Le paramètre concertId n'était pas correctement extrait via useParams() dans le contexte de HashRouter
   - Les URL générées n'incluaient pas le dièse (#) nécessaire pour HashRouter

2. **Solution implémentée** :
   - Extraction robuste du concertId via plusieurs méthodes (props, useParams, extraction directe de l'URL)
   - Fonction utilitaire extractConcertIdFromHash pour extraire le concertId directement depuis window.location.hash
   - Mise à jour de la génération d'URL pour inclure le dièse (#) et être compatible avec HashRouter

## Modifications techniques

### Dans PublicFormPage.jsx :
- Ajout d'une fonction utilitaire extractConcertIdFromHash pour extraire le concertId directement depuis l'URL
- Implémentation d'une logique de priorité pour déterminer le concertId :
  1. Props passées directement
  2. Paramètres de route via useParams()
  3. Extraction directe depuis l'URL
- Utilisation d'un état local (useState) pour stocker le concertId déterminé
- Ajout de logs détaillés pour suivre le processus d'extraction du concertId
- Amélioration de l'affichage des informations de débogage

### Dans ConcertDetail.js :
- Mise à jour de la génération d'URL pour inclure le dièse (#) :
  ```javascript
  const formUrl = `${window.location.origin}/#/form/${concert.id}`;
  ```

## Comment tester

1. Accédez à une URL du type `/#/form/<concertId>` (remplacez `<concertId>` par un ID de concert valide)
2. Vérifiez dans la console du navigateur que le concertId est correctement extrait
3. Remplissez le formulaire et soumettez-le
4. Vérifiez que les données apparaissent dans l'onglet "Validation de formulaire"

## Remarques importantes

- Cette solution est compatible avec HashRouter et BrowserRouter
- Le composant PublicFormPage peut maintenant recevoir le concertId de trois façons différentes :
  1. Via props : `<PublicFormPage concertId="XXXX" />`
  2. Via useParams() : `<Route path="/form/:concertId" element={<PublicFormPage />} />`
  3. Via l'extraction directe de l'URL : `/#/form/XXXX`
- Les URL générées incluent maintenant le dièse (#) pour être compatibles avec HashRouter
- Des logs détaillés ont été ajoutés pour faciliter le débogage
EOL
echo "✅ Fichier README_HASHROUTER_FIX.md créé"

echo "✅ Correction des problèmes d'extraction du paramètre concertId avec HashRouter terminée avec succès!"
echo "Pour tester la solution, accédez à /#/form/<concertId> et vérifiez que le concertId est correctement extrait."
echo ""
echo "Les fichiers originaux ont été sauvegardés dans: $BACKUP_DIR"
