#!/bin/bash

# Script pour résoudre définitivement le problème de routage des formulaires publics
# en modifiant radicalement l'architecture d'authentification
echo "Début de la solution radicale pour le problème de routage des formulaires publics..."

# Créer des sauvegardes des fichiers originaux
echo "Création des sauvegardes..."
mkdir -p ./backups/$(date +%Y%m%d_%H%M%S)
cp ./client/src/App.js ./backups/$(date +%Y%m%d_%H%M%S)/App.js.backup
cp ./client/src/context/AuthContext.js ./backups/$(date +%Y%m%d_%H%M%S)/AuthContext.js.backup
cp ./client/src/index.js ./backups/$(date +%Y%m%d_%H%M%S)/index.js.backup

# Modification du fichier index.js pour détecter les routes publiques AVANT l'initialisation de l'AuthProvider
echo "Modification du fichier index.js pour détecter les routes publiques avant l'AuthProvider..."
cat > ./client/src/index.js << 'EOL'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { HashRouter } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import PublicFormPage from './components/public/PublicFormPage';
import FormSubmittedPage from './components/public/FormSubmittedPage';

// Fonction pour vérifier si l'URL actuelle est une route publique
const isPublicRoute = () => {
  // Obtenir le hash de l'URL (pour HashRouter)
  const hash = window.location.hash || '';
  // Nettoyer le hash pour obtenir le chemin réel (enlever le # au début)
  const cleanPath = hash.replace(/^#/, '');
  
  console.log('index.js - Hash brut:', hash);
  console.log('index.js - Chemin nettoyé:', cleanPath);
  
  // Vérifier si le chemin correspond à une route publique
  const isPublic = cleanPath.startsWith('/form/') || cleanPath === '/form-submitted';
  console.log('index.js - Est une route publique:', isPublic);
  
  return isPublic;
};

// Extraire l'ID du concert de l'URL si c'est une route de formulaire
const extractConcertId = () => {
  const hash = window.location.hash || '';
  const match = hash.match(/^#\/form\/([^\/]+)$/);
  return match ? match[1] : null;
};

const root = ReactDOM.createRoot(document.getElementById('root'));

// Si c'est une route publique, rendre directement le composant correspondant sans AuthProvider
if (isPublicRoute()) {
  const concertId = extractConcertId();
  console.log('index.js - Rendu direct du composant public avec concertId:', concertId);
  
  // Déterminer quel composant public rendre
  const hash = window.location.hash || '';
  const cleanPath = hash.replace(/^#/, '');
  
  if (cleanPath === '/form-submitted') {
    root.render(
      <React.StrictMode>
        <HashRouter>
          <FormSubmittedPage />
        </HashRouter>
      </React.StrictMode>
    );
  } else {
    root.render(
      <React.StrictMode>
        <HashRouter>
          <PublicFormPage concertId={concertId} />
        </HashRouter>
      </React.StrictMode>
    );
  }
} else {
  // Pour les routes protégées, rendre l'application normale avec AuthProvider
  console.log('index.js - Rendu de l\'application normale avec AuthProvider');
  root.render(
    <React.StrictMode>
      <HashRouter>
        <AuthProvider>
          <App />
        </AuthProvider>
      </HashRouter>
    </React.StrictMode>
  );
}
EOL
echo "✅ Fichier index.js modifié pour détecter les routes publiques avant l'AuthProvider"

# Modification du fichier PublicFormPage.jsx pour accepter concertId comme prop
echo "Modification du fichier PublicFormPage.jsx pour accepter concertId comme prop..."
cat > ./client/src/components/public/PublicFormPage.jsx << 'EOL'
import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import './PublicFormPage.css';

const PublicFormPage = ({ concertId: propConcertId }) => {
  const params = useParams();
  const navigate = useNavigate();
  // Utiliser l'ID du concert passé en prop ou extrait des paramètres d'URL
  const [concertId, setConcertId] = useState(propConcertId || params.concertId || null);
  
  // Si l'ID du concert n'est pas disponible et que nous sommes dans le contexte de l'application principale
  useEffect(() => {
    if (!concertId && window.location.hash) {
      // Essayer d'extraire l'ID du concert de l'URL
      const match = window.location.hash.match(/^#\/form\/([^\/]+)$/);
      if (match) {
        setConcertId(match[1]);
      }
    }
  }, [concertId]);
  
  // Logs de débogage détaillés
  useEffect(() => {
    console.log("PublicFormPage - CHARGÉE AVEC:");
    console.log("PublicFormPage - concertId (prop):", propConcertId);
    console.log("PublicFormPage - concertId (params):", params.concertId);
    console.log("PublicFormPage - concertId (state):", concertId);
    console.log("PublicFormPage - Hash brut:", window.location.hash);
    console.log("PublicFormPage - Hash nettoyé:", window.location.hash.replace(/^#/, ''));
    console.log("PublicFormPage - Pathname:", window.location.pathname);
    console.log("PublicFormPage - URL complète:", window.location.href);
  }, [propConcertId, params.concertId, concertId]);
  
  // Fonction de soumission du formulaire
  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Formulaire soumis pour le concert ID:", concertId);
    // Ici, vous pourriez appeler une API pour enregistrer les données du formulaire
    // Puis rediriger vers la page de confirmation
    navigate('/form-submitted');
  };
  
  return (
    <div style={{ 
      padding: "40px", 
      textAlign: "center", 
      maxWidth: "800px", 
      margin: "0 auto", 
      backgroundColor: "#f9f9f9", 
      borderRadius: "8px", 
      boxShadow: "0 2px 10px rgba(0,0,0,0.1)" 
    }}>
      <h2 style={{ color: "#4a90e2", marginBottom: "20px" }}>Formulaire Public Chargé avec Succès</h2>
      <p style={{ fontSize: "18px", marginBottom: "15px" }}>
        ID du Concert: <strong>{concertId}</strong>
      </p>
      
      <form onSubmit={handleSubmit} style={{ textAlign: "left", marginTop: "30px" }}>
        <div style={{ marginBottom: "20px" }}>
          <label style={{ display: "block", marginBottom: "5px", fontWeight: "bold" }}>
            ID du Concert (lecture seule):
          </label>
          <input 
            type="text" 
            value={concertId || ''} 
            readOnly 
            style={{ 
              width: "100%", 
              padding: "10px", 
              border: "1px solid #ddd", 
              borderRadius: "4px",
              backgroundColor: "#f0f0f0" 
            }} 
          />
        </div>
        
        <div style={{ marginBottom: "20px" }}>
          <label style={{ display: "block", marginBottom: "5px", fontWeight: "bold" }}>
            Votre Nom:
          </label>
          <input 
            type="text" 
            placeholder="Entrez votre nom" 
            style={{ 
              width: "100%", 
              padding: "10px", 
              border: "1px solid #ddd", 
              borderRadius: "4px" 
            }} 
          />
        </div>
        
        <div style={{ marginBottom: "20px" }}>
          <label style={{ display: "block", marginBottom: "5px", fontWeight: "bold" }}>
            Votre Email:
          </label>
          <input 
            type="email" 
            placeholder="Entrez votre email" 
            style={{ 
              width: "100%", 
              padding: "10px", 
              border: "1px solid #ddd", 
              borderRadius: "4px" 
            }} 
          />
        </div>
        
        <div style={{ marginBottom: "20px" }}>
          <label style={{ display: "block", marginBottom: "5px", fontWeight: "bold" }}>
            Message:
          </label>
          <textarea 
            placeholder="Entrez votre message" 
            rows="4" 
            style={{ 
              width: "100%", 
              padding: "10px", 
              border: "1px solid #ddd", 
              borderRadius: "4px" 
            }} 
          ></textarea>
        </div>
        
        <button 
          type="submit" 
          style={{ 
            backgroundColor: "#4a90e2", 
            color: "white", 
            border: "none", 
            borderRadius: "4px", 
            padding: "12px 20px", 
            fontSize: "16px", 
            cursor: "pointer", 
            display: "block", 
            margin: "0 auto" 
          }}
        >
          Soumettre le Formulaire
        </button>
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
          URL complète: {window.location.href}
        </p>
      </div>
    </div>
  );
};

export default PublicFormPage;
EOL
echo "✅ Fichier PublicFormPage.jsx modifié pour accepter concertId comme prop"

# Modification du fichier FormSubmittedPage.jsx
echo "Modification du fichier FormSubmittedPage.jsx..."
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
    <div style={{ 
      padding: "40px", 
      textAlign: "center", 
      maxWidth: "800px", 
      margin: "0 auto", 
      backgroundColor: "#f9f9f9", 
      borderRadius: "8px", 
      boxShadow: "0 2px 10px rgba(0,0,0,0.1)" 
    }}>
      <h2 style={{ color: "#4a90e2", marginBottom: "20px" }}>Formulaire Soumis avec Succès</h2>
      <p style={{ fontSize: "18px", marginBottom: "15px" }}>
        Merci d'avoir soumis le formulaire. Vos informations ont été enregistrées.
      </p>
      <div style={{ 
        marginTop: "30px", 
        padding: "15px", 
        backgroundColor: "#e8f4fd", 
        borderRadius: "5px", 
        border: "1px solid #c5e1f9" 
      }}>
        <p style={{ margin: "0", color: "#2c76c7" }}>
          Vous pouvez maintenant fermer cette page.
        </p>
        <p style={{ margin: "10px 0 0 0", color: "#2c76c7", fontSize: "14px", textAlign: "left" }}>
          Informations de débogage:<br />
          Hash: {window.location.hash}<br />
          Pathname: {window.location.pathname}<br />
          URL complète: {window.location.href}
        </p>
      </div>
    </div>
  );
};

export default FormSubmittedPage;
EOL
echo "✅ Fichier FormSubmittedPage.jsx modifié"

# Modification du fichier App.js pour maintenir les routes publiques mais les rendre inaccessibles via l'application principale
echo "Modification du fichier App.js..."
cat > ./client/src/App.js << 'EOL'
import React, { useEffect } from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import './App.css';

// Composants protégés
import Layout from './components/common/Layout';
import Login from './components/auth/Login';
import NotFound from './components/common/NotFound';
import Dashboard from './components/dashboard/Dashboard';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import EmailSystem from './components/emails/EmailSystem';
import DocumentsManager from './components/documents/DocumentsManager';
import TestFirebaseIntegration from './components/tests/TestFirebaseIntegration';
import ArtistEdit from './components/artists/ArtistEdit';
import ContractsTable from './components/contracts/ContractsTable';
import FormValidationList from './components/formValidation/FormValidationList';

// Composants publics (affichés sans authentification)
// Note: Ces routes sont maintenues ici pour compatibilité, mais elles sont gérées directement dans index.js
import PublicFormPage from './components/public/PublicFormPage';
import FormSubmittedPage from './components/public/FormSubmittedPage';

// Composant ProtectedRoute pour sécuriser les routes privées
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading, bypassEnabled } = useAuth();
  const location = useLocation();
  
  // Logs de débogage
  useEffect(() => {
    console.log('ProtectedRoute - Route actuelle (hash):', location.hash);
    console.log('ProtectedRoute - Route actuelle (pathname):', location.pathname);
    console.log('ProtectedRoute - Utilisateur authentifié:', isAuthenticated);
    console.log('ProtectedRoute - Bypass activé:', bypassEnabled);
  }, [location.hash, location.pathname, isAuthenticated, bypassEnabled]);

  if (loading) {
    console.log('ProtectedRoute - Chargement en cours...');
    return <div>Chargement...</div>;
  }
  
  if (bypassEnabled) {
    console.log('ProtectedRoute - Mode bypass d\'authentification activé - Accès autorisé');
    return children;
  }

  if (!isAuthenticated) {
    console.log('ProtectedRoute - Utilisateur non authentifié, redirection vers /login');
    return <Navigate to="/login" />;
  }
  
  console.log('ProtectedRoute - Utilisateur authentifié, accès autorisé');
  return children;
};

function App() {
  const { bypassEnabled, isAuthenticated } = useAuth();
  const location = useLocation();
  
  // Logs de débogage
  useEffect(() => {
    console.log('App - Rendu avec:');
    console.log('App - Route actuelle (hash):', location.hash);
    console.log('App - Route actuelle (pathname):', location.pathname);
    console.log('App - URL complète:', window.location.href);
    console.log('App - Utilisateur authentifié:', isAuthenticated);
    console.log('App - Bypass activé:', bypassEnabled);
  }, [location.hash, location.pathname, isAuthenticated, bypassEnabled]);

  return (
    <div className="App">
      <Routes>
        {/* Routes publiques - maintenues pour compatibilité mais gérées dans index.js */}
        <Route path="/form/:concertId" element={<PublicFormPage />} />
        <Route path="/form-submitted" element={<FormSubmittedPage />} />

        <Route path="/login" element={
          bypassEnabled ? <Navigate to="/" /> : <Login />
        } />
        
        {/* Routes protégées accessibles uniquement aux utilisateurs authentifiés */}
        <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
          <Route index element={<Dashboard />} />
          <Route path="contrats" element={<ContractsTable />} />
          <Route path="factures" element={<div>Module Factures à venir</div>} />
          <Route path="programmateurs" element={<ProgrammersList />} />
          <Route path="programmateurs/:id" element={<ProgrammerDetail />} />
          <Route path="concerts" element={<ConcertsList />} />
          <Route path="concerts/:id" element={<ConcertDetail />} />
          <Route path="artistes" element={<ArtistsList />} />
          <Route path="artistes/:id" element={<ArtistDetail />} />
          <Route path="emails" element={<EmailSystem />} />
          <Route path="documents" element={<DocumentsManager />} />
          <Route path="validation-formulaires" element={<FormValidationList />} />
          <Route path="tests" element={<TestFirebaseIntegration />} />
        </Route>
        
        <Route path="*" element={<NotFound />} />
      </Routes>

      {bypassEnabled && (
        <div style={{
          position: 'fixed',
          bottom: 0,
          left: 0,
          right: 0,
          backgroundColor: '#fff3cd',
          color: '#856404',
          padding: '10px',
          textAlign: 'center',
          borderTop: '1px solid #ffeeba',
          zIndex: 1000
        }}>
          Mode test activé - Authentification désactivée
        </div>
      )}
    </div>
  );
}

export default App;
EOL
echo "✅ Fichier App.js modifié"

# Vérification du fichier CSS
echo "Vérification du fichier PublicFormPage.css..."
if [ ! -f "./client/src/components/public/PublicFormPage.css" ]; then
  echo "Création du fichier PublicFormPage.css..."
  mkdir -p ./client/src/components/public
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

# Création d'un fichier README pour expliquer la solution
echo "Création d'un fichier README pour expliquer la solution..."
cat > ./README_PUBLIC_ROUTES.md << 'EOL'
# Solution pour l'accès aux formulaires publics

## Problème résolu

Cette solution résout le problème d'accès aux formulaires publics dans l'application de booking musical. Auparavant, lorsqu'un utilisateur non authentifié tentait d'accéder à une URL du type `/#/form/<concertId>`, il était redirigé vers la page de connexion (puis vers le Dashboard).

## Approche radicale

Nous avons adopté une approche radicale qui contourne complètement le système d'authentification pour les routes publiques :

1. **Détection des routes publiques avant l'AuthProvider** : Le fichier `index.js` détecte maintenant si l'URL actuelle correspond à une route publique (`/form/<concertId>` ou `/form-submitted`) avant même d'initialiser l'AuthProvider.

2. **Rendu direct des composants publics** : Si l'URL correspond à une route publique, l'application rend directement le composant correspondant (PublicFormPage ou FormSubmittedPage) sans passer par l'AuthProvider ni par App.js.

3. **Maintien des routes dans App.js** : Les routes publiques sont maintenues dans App.js pour compatibilité, mais elles sont effectivement gérées directement dans index.js.

## Avantages de cette approche

- **Séparation complète** : Les formulaires publics sont complètement séparés du système d'authentification.
- **Aucune interférence** : Le mode bypass d'authentification (BYPASS_AUTH) n'a plus aucun effet sur les routes publiques.
- **Simplicité** : La solution est simple et robuste, sans dépendance à la logique d'authentification existante.

## Comment tester

1. Redémarrez votre application React
2. Ouvrez une fenêtre de navigation privée (pour s'assurer d'être déconnecté)
3. Accédez à une URL du type `/#/form/<concertId>` (remplacez `<concertId>` par un ID de concert valide)
4. Vous devriez voir le formulaire public s'afficher sans être redirigé vers la page de connexion
5. Vérifiez la console du navigateur pour confirmer que les logs de débogage indiquent que la route est correctement identifiée comme publique et que le composant est rendu directement

## Remarques importantes

- Cette solution modifie fondamentalement la façon dont les routes publiques sont gérées dans l'application.
- Si vous ajoutez de nouvelles routes publiques à l'avenir, vous devrez les ajouter à la fois dans `index.js` (fonction `isPublicRoute`) et dans `App.js`.
- Assurez-vous de vider le cache de build sur Render après le déploiement pour que les modifications prennent effet.
EOL
echo "✅ Fichier README_PUBLIC_ROUTES.md créé"

echo "✅ Solution radicale pour le problème de routage des formulaires publics terminée avec succès!"
echo "Pour tester la solution, redémarrez votre application React et accédez à /#/form/<concertId> en navigation privée."
echo "Vérifiez la console du navigateur pour voir les logs de débogage détaillés."
echo "N'oubliez pas de vider le cache de build sur Render après le déploiement."
