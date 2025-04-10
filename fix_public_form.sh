#!/bin/bash

# Script pour mettre à jour le formulaire public avec les nouveaux champs et corriger la logique de soumission
echo "Début de la mise à jour du formulaire public..."

# Créer des sauvegardes des fichiers originaux
echo "Création des sauvegardes..."
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)_public_form"
mkdir -p $BACKUP_DIR

# Sauvegarde des fichiers existants
if [ -f "./client/src/components/public/PublicFormPage.jsx" ]; then
  cp ./client/src/components/public/PublicFormPage.jsx $BACKUP_DIR/PublicFormPage.jsx.backup
fi

if [ -f "./client/src/components/public/FormSubmittedPage.jsx" ]; then
  cp ./client/src/components/public/FormSubmittedPage.jsx $BACKUP_DIR/FormSubmittedPage.jsx.backup
fi

# Mise à jour du fichier PublicFormPage.jsx avec les nouveaux champs
echo "Mise à jour du fichier PublicFormPage.jsx avec les nouveaux champs..."
mkdir -p ./client/src/components/public
cat > ./client/src/components/public/PublicFormPage.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getFormLinkByToken } from '../../services/formLinkService';
import { createFormSubmission } from '../../services/formSubmissionsService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { concertId } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
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
  
  // Logs de débogage
  useEffect(() => {
    console.log('PublicFormPage - CHARGÉE AVEC:');
    console.log('PublicFormPage - concertId:', concertId);
    console.log('PublicFormPage - Hash brut:', window.location.hash);
    console.log('PublicFormPage - Hash nettoyé:', window.location.hash.replace(/^#/, ''));
    console.log('PublicFormPage - Pathname:', window.location.pathname);
    console.log('PublicFormPage - URL complète:', window.location.href);
  }, [concertId]);
  
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      console.log('Soumission du formulaire avec les données:', formData);
      
      // Préparer les données à soumettre
      const submissionData = {
        ...formData,
        concertId: concertId,
        // Ajouter des champs supplémentaires pour la compatibilité avec le service existant
        contact: formData.firstName && formData.lastName 
          ? `${formData.firstName} ${formData.lastName}` 
          : formData.firstName || formData.lastName || '',
        status: 'pending',
        // Ajouter des informations de concert fictives si nécessaire
        concertName: `Concert ID: ${concertId}`
      };
      
      // Soumettre le formulaire
      const result = await createFormSubmission(submissionData);
      console.log('Résultat de la soumission du formulaire:', result);
      
      if (result) {
        // Rediriger vers la page de confirmation
        console.log('Redirection vers la page de confirmation');
        navigate('/form-submitted');
      } else {
        console.error('Échec de la soumission du formulaire');
        setError('Une erreur est survenue lors de la soumission du formulaire.');
        setLoading(false);
      }
    } catch (err) {
      console.error('Erreur lors de la soumission du formulaire:', err);
      setError('Une erreur est survenue lors de la soumission du formulaire.');
      setLoading(false);
    }
  };
  
  if (loading) {
    return (
      <div className="public-form-container">
        <div className="public-form-card">
          <h2>Chargement...</h2>
          <p>Veuillez patienter pendant le traitement de votre demande.</p>
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
            onClick={() => window.location.href = window.location.origin}
          >
            Retour à l'accueil
          </button>
        </div>
      </div>
    );
  }
  
  return (
    <div className="public-form-container">
      <div className="public-form-card">
        <h2>Formulaire de renseignements</h2>
        <div className="form-header">
          <p><strong>ID du Concert :</strong> {concertId}</p>
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
              disabled={loading}
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
            Concert ID: {concertId}
          </p>
        </div>
      </div>
    </div>
  );
};

export default PublicFormPage;
EOL
echo "✅ Fichier PublicFormPage.jsx mis à jour avec les nouveaux champs"

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
cat > ./README_PUBLIC_FORM.md << 'EOL'
# Mise à jour du formulaire public

## Modifications apportées

1. **Mise à jour du composant PublicFormPage.jsx** :
   - Ajout de tous les champs demandés (Raison sociale, Nom, Prénom, Qualité, Adresse de la raison sociale, Lieu ou festival, Adresse du lieu ou festival, Numéro intracommunautaire, Siret, Mail, Téléphone, Site web)
   - Tous les champs sont rendus facultatifs
   - Correction de la logique de soumission pour envoyer les données à Firebase

2. **Mise à jour du composant FormSubmittedPage.jsx** :
   - Amélioration de la page de confirmation après soumission du formulaire
   - Ajout de logs de débogage

3. **Vérification des routes dans App.js** :
   - Ajout des routes pour le formulaire public si nécessaire

## Comment tester

1. Accédez à une URL du type `/#/form/<concertId>` (remplacez `<concertId>` par un ID de concert valide)
2. Remplissez le formulaire avec les informations souhaitées
3. Cliquez sur "Soumettre le formulaire"
4. Vous devriez être redirigé vers la page de confirmation
5. Les données soumises devraient apparaître dans l'onglet "Validation de formulaire" de l'application

## Structure des données

Les données soumises sont structurées comme suit :
- businessName: Raison sociale
- firstName: Prénom
- lastName: Nom
- role: Qualité
- address: Adresse de la raison sociale
- venue: Lieu ou festival
- venueAddress: Adresse du lieu ou festival
- vatNumber: Numéro intracommunautaire
- siret: Siret
- email: Mail
- phone: Téléphone
- website: Site web
- concertId: ID du concert
- status: État de la soumission (toujours "pending" initialement)
- submittedAt: Date de soumission (ajoutée automatiquement)

## Remarques importantes

- Tous les champs du formulaire sont facultatifs
- Le formulaire utilise maintenant le paramètre concertId de l'URL
- Les données sont envoyées à Firebase via la fonction createFormSubmission()
- Des logs de débogage ont été ajoutés pour faciliter le suivi du comportement du formulaire
EOL
echo "✅ Fichier README_PUBLIC_FORM.md créé"

echo "✅ Mise à jour du formulaire public terminée avec succès!"
echo "Pour tester la solution, accédez à /#/form/<concertId> et soumettez le formulaire."
echo "Les données soumises devraient apparaître dans l'onglet 'Validation de formulaire'."
echo ""
echo "Les fichiers originaux ont été sauvegardés dans: $BACKUP_DIR"
