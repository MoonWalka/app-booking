#!/bin/bash

# Script pour corriger les problèmes de routing des formulaires publics
# dans l'application app-booking

echo "Début de la correction des problèmes de routing des formulaires publics..."

# Vérification de l'existence du répertoire client
if [ ! -d "./client" ]; then
  echo "Erreur: Le répertoire client n'existe pas. Assurez-vous d'exécuter ce script à la racine du projet."
  exit 1
fi

# Sauvegarde des fichiers qui seront modifiés
echo "Sauvegarde des fichiers qui seront modifiés..."
cp ./client/src/index.js ./client/src/index.js.backup
cp ./client/src/App.js ./client/src/App.js.backup
echo "Sauvegardes effectuées."

# Modification du index.js pour utiliser HashRouter au lieu de BrowserRouter
echo "Modification du index.js pour utiliser HashRouter..."
cat > ./client/src/index.js << 'EOL'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { HashRouter } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <HashRouter>
      <AuthProvider>
        <App />
      </AuthProvider>
    </HashRouter>
  </React.StrictMode>
);
EOL
echo "index.js modifié avec succès pour utiliser HashRouter."

# Modification du App.js pour s'assurer que les routes publiques sont correctement définies
echo "Modification du App.js pour corriger les routes publiques..."
cat > ./client/src/App.js << 'EOL'
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import './App.css';

// Composants
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

// Importation directe des composants publics pour éviter les problèmes d'importation conditionnelle
import PublicFormPage from './components/public/PublicFormPage';
import FormSubmittedPage from './components/public/FormSubmittedPage';

// Route protégée
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading, bypassEnabled } = useAuth();
  
  if (loading) {
    return <div>Chargement...</div>;
  }
  
  // Si le mode bypass est activé, on autorise l'accès même sans authentification
  if (bypassEnabled) {
    console.log('Mode bypass d\'authentification activé - Accès autorisé');
    return children;
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }
  
  return children;
};

function App() {
  const { bypassEnabled } = useAuth();

  console.log('App component rendered');

  return (
    <div className="App">
      <Routes>
        {/* Routes publiques pour les formulaires - HORS AUTHENTIFICATION */}
        {/* Ces routes doivent être définies AVANT les routes protégées pour éviter les conflits */}
        <Route path="/form/:token" element={<PublicFormPage />} />
        <Route path="/form-submitted" element={<FormSubmittedPage />} />
        
        {/* Si le mode bypass est activé, la page de login redirige vers le dashboard */}
        <Route path="/login" element={
          bypassEnabled ? <Navigate to="/" /> : <Login />
        } />
        
        {/* Routes protégées */}
        <Route path="/" element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }>
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
        
        {/* Route de fallback pour les URLs non reconnues */}
        <Route path="*" element={<NotFound />} />
      </Routes>
      
      {/* Bannière d'information sur le mode bypass */}
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
echo "App.js modifié avec succès."

# Vérification et création du répertoire public si nécessaire
echo "Vérification du répertoire des composants publics..."
if [ ! -d "./client/src/components/public" ]; then
  echo "Création du répertoire pour les composants publics..."
  mkdir -p ./client/src/components/public
fi

# Création ou mise à jour du composant PublicFormPage.jsx
echo "Création/mise à jour du composant PublicFormPage.jsx..."
cat > ./client/src/components/public/PublicFormPage.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getFormLinkByToken } from '../../services/formLinkService';
import { submitFormData } from '../../services/formSubmissionsService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { token } = useParams();
  const navigate = useNavigate();
  const [formLink, setFormLink] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [formData, setFormData] = useState({
    businessName: '',
    contact: '',
    role: '',
    address: '',
    venue: '',
    vatNumber: '',
    siret: '',
    email: '',
    phone: '',
    website: ''
  });
  
  // Ajout de logs pour le débogage
  console.log('PublicFormPage rendered, token:', token);
  
  useEffect(() => {
    const fetchFormLink = async () => {
      try {
        console.log('Fetching form link for token:', token);
        setLoading(true);
        const link = await getFormLinkByToken(token);
        console.log('Form link result:', link);
        
        if (!link) {
          console.error('No form link found for token:', token);
          setError('Ce lien de formulaire n\'est pas valide ou a expiré.');
        } else if (link.isSubmitted) {
          console.log('Form already submitted for token:', token);
          setError('Ce formulaire a déjà été soumis.');
        } else {
          console.log('Form link found and valid:', link);
          setFormLink(link);
        }
      } catch (err) {
        console.error('Error fetching form link:', err);
        setError('Une erreur est survenue lors du chargement du formulaire.');
      } finally {
        setLoading(false);
      }
    };
    
    if (token) {
      fetchFormLink();
    } else {
      console.error('No token provided in URL');
      setError('Aucun identifiant de formulaire fourni.');
      setLoading(false);
    }
  }, [token]);
  
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formLink) return;
    
    try {
      setLoading(true);
      console.log('Submitting form data:', formData);
      
      // Préparer les données à soumettre
      const submissionData = {
        ...formData,
        programmerId: formLink.programmerId,
        programmerName: formLink.programmerName,
        formLinkId: formLink.id,
        concertId: formLink.concertId,
        concertName: formLink.concertName,
        concertDate: formLink.concertDate,
        status: 'pending'
      };
      
      // Soumettre le formulaire
      const result = await submitFormData(submissionData, formLink.id);
      console.log('Form submission result:', result);
      
      if (result) {
        // Rediriger vers la page de confirmation
        console.log('Redirecting to form-submitted page');
        navigate('/form-submitted');
      } else {
        console.error('Form submission failed');
        setError('Une erreur est survenue lors de la soumission du formulaire.');
        setLoading(false);
      }
    } catch (err) {
      console.error('Error submitting form:', err);
      setError('Une erreur est survenue lors de la soumission du formulaire.');
      setLoading(false);
    }
  };
  
  if (loading) {
    return (
      <div className="public-form-container">
        <div className="public-form-card">
          <h2>Chargement...</h2>
          <p>Veuillez patienter pendant le chargement du formulaire.</p>
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
        {formLink && (
          <>
            <div className="form-header">
              <p><strong>Concert :</strong> {formLink.concertName}</p>
              {formLink.concertDate && (
                <p><strong>Date :</strong> {
                  formLink.concertDate.seconds 
                    ? new Date(formLink.concertDate.seconds * 1000).toLocaleDateString()
                    : new Date(formLink.concertDate).toLocaleDateString()
                }</p>
              )}
            </div>
            
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label htmlFor="businessName">Raison sociale *</label>
                <input
                  type="text"
                  id="businessName"
                  name="businessName"
                  value={formData.businessName}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="contact">Contact *</label>
                <input
                  type="text"
                  id="contact"
                  name="contact"
                  value={formData.contact}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="role">Qualité (président, programmateur, gérant...)</label>
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
                <label htmlFor="siret">SIRET</label>
                <input
                  type="text"
                  id="siret"
                  name="siret"
                  value={formData.siret}
                  onChange={handleChange}
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="email">Email *</label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
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
                <p>* Champs obligatoires</p>
                <button 
                  type="submit" 
                  className="form-button"
                  disabled={loading}
                >
                  {loading ? 'Envoi en cours...' : 'Envoyer'}
                </button>
              </div>
            </form>
          </>
        )}
      </div>
    </div>
  );
};

export default PublicFormPage;
EOL
echo "Composant PublicFormPage.jsx créé/mis à jour avec succès."

# Création ou mise à jour du style PublicFormPage.css
echo "Création/mise à jour du style PublicFormPage.css..."
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
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  padding: 30px;
  width: 100%;
  max-width: 600px;
}

.public-form-card h2 {
  color: #333;
  margin-bottom: 20px;
  text-align: center;
}

.public-form-card.error {
  border-left: 4px solid #dc3545;
}

.form-header {
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #555;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
}

.form-group textarea {
  resize: vertical;
}

.form-footer {
  margin-top: 30px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.form-footer p {
  margin-bottom: 15px;
  font-size: 14px;
  color: #666;
}

.form-button {
  background-color: #4a6da7;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 12px 24px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.form-button:hover {
  background-color: #3a5a8f;
}

.form-button:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .public-form-card {
    padding: 20px;
  }
  
  .form-group input,
  .form-group textarea {
    font-size: 14px;
  }
  
  .form-button {
    width: 100%;
  }
}
EOL
echo "Style PublicFormPage.css créé/mis à jour avec succès."

# Création ou mise à jour du composant FormSubmittedPage.jsx
echo "Création/mise à jour du composant FormSubmittedPage.jsx..."
cat > ./client/src/components/public/FormSubmittedPage.jsx << 'EOL'
import React from 'react';
import './FormSubmittedPage.css';

const FormSubmittedPage = () => {
  console.log('FormSubmittedPage rendered');
  
  return (
    <div className="form-submitted-container">
      <div className="form-submitted-card">
        <div className="success-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
          </svg>
        </div>
        <h2>Formulaire envoyé avec succès !</h2>
        <p>
          Merci d'avoir complété ce formulaire. Vos informations ont été enregistrées
          et seront traitées prochainement.
        </p>
        <p>
          Vous pouvez maintenant fermer cette page.
        </p>
        <button 
          className="back-button"
          onClick={() => window.location.href = window.location.origin}
        >
          Retour à l'accueil
        </button>
      </div>
    </div>
  );
};

export default FormSubmittedPage;
EOL
echo "Composant FormSubmittedPage.jsx créé/mis à jour avec succès."

# Création ou mise à jour du style FormSubmittedPage.css
echo "Création/mise à jour du style FormSubmittedPage.css..."
cat > ./client/src/components/public/FormSubmittedPage.css << 'EOL'
.form-submitted-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 20px;
  background-color: #f5f5f5;
}

.form-submitted-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  padding: 40px 30px;
  width: 100%;
  max-width: 500px;
  text-align: center;
}

.success-icon {
  color: #28a745;
  margin-bottom: 20px;
}

.form-submitted-card h2 {
  color: #333;
  margin-bottom: 20px;
}

.form-submitted-card p {
  color: #666;
  margin-bottom: 15px;
  line-height: 1.5;
}

.back-button {
  background-color: #4a6da7;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 12px 24px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
  margin-top: 20px;
}

.back-button:hover {
  background-color: #3a5a8f;
}

@media (max-width: 768px) {
  .form-submitted-card {
    padding: 30px 20px;
  }
  
  .back-button {
    width: 100%;
  }
}
EOL
echo "Style FormSubmittedPage.css créé/mis à jour avec succès."

# Création d'un fichier .env pour configurer React Router
echo "Création du fichier .env pour configurer React Router..."
cat > ./client/.env << 'EOL'
# Configuration pour React Router
REACT_APP_ROUTER_BASE_URL=.
EOL
echo "Fichier .env créé avec succès."

# Création d'un fichier _redirects pour Render
echo "Création du fichier _redirects pour Render..."
mkdir -p ./client/public
cat > ./client/public/_redirects << 'EOL'
/*    /index.html   200
EOL
echo "Fichier _redirects créé avec succès."

# Mise à jour du package.json pour ajouter "homepage": "."
echo "Mise à jour du package.json pour ajouter \"homepage\": \".\"..."
if [ -f "./client/package.json" ]; then
  # Vérifier si homepage est déjà défini
  if ! grep -q '"homepage":' ./client/package.json; then
    # Ajouter homepage après private
    sed -i 's/"private": true,/"private": true,\n  "homepage": ".",/g' ./client/package.json
    echo "\"homepage\": \".\" ajouté au package.json."
  else
    echo "homepage déjà défini dans package.json."
  fi
else
  echo "Avertissement: Le fichier package.json n'a pas été trouvé dans ./client/"
fi

echo "Toutes les corrections ont été appliquées avec succès."
echo ""
echo "Pour déployer ces modifications:"
echo "1. Exécutez: cd client && npm run build"
echo "2. Vérifiez que le build se termine sans erreur"
echo "3. Déployez sur Render en suivant votre processus habituel"
echo ""
echo "Fin du script de correction."
