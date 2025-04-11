import React, { useState, useEffect } from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { auth } from './firebase';
import './App.css';

// Composants
import Sidebar from './components/layout/Sidebar';
import Dashboard from './components/dashboard/Dashboard';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetails from './components/artists/ArtistDetails';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetails from './components/programmers/ProgrammerDetails';
import ContractsList from './components/contracts/ContractsList';
import ContractDetails from './components/contracts/ContractDetails';
import InvoicesList from './components/invoices/InvoicesList';
import InvoiceDetails from './components/invoices/InvoiceDetails';
import EmailsList from './components/emails/EmailsList';
import DocumentsList from './components/documents/DocumentsList';
import Settings from './components/settings/Settings';
import PublicFormPage from './components/public/PublicFormPage';
import FormValidationList from './components/formValidation/FormValidationList';
import ErrorBoundary from './components/common/ErrorBoundary';

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [testMode] = useState(true); // Mode test pour le développement

  useEffect(() => {
    console.log("App - Initialisation de l'application...");
    
    try {
      // Vérifier l'authentification
      const unsubscribe = auth.onAuthStateChanged(user => {
        console.log("App - État d'authentification changé:", user ? "Utilisateur connecté" : "Utilisateur non connecté");
        setUser(user);
        setLoading(false);
      }, error => {
        console.error("App - Erreur d'authentification:", error);
        setError("Erreur lors de la vérification de l'authentification. Veuillez réessayer.");
        setLoading(false);
      });
      
      return () => unsubscribe();
    } catch (error) {
      console.error("App - Erreur lors de l'initialisation:", error);
      setError("Erreur lors de l'initialisation de l'application. Veuillez réessayer.");
      setLoading(false);
    }
  }, []);

  // Gestion des erreurs globales
  if (error) {
    return (
      <div className="error-container">
        <h1>Erreur</h1>
        <p>{error}</p>
        <button onClick={() => window.location.reload()}>Rafraîchir la page</button>
      </div>
    );
  }

  // Afficher un message de chargement pendant l'initialisation
  if (loading && !testMode) {
    return <div className="loading-container">Chargement de l'application...</div>;
  }

  // Vérifier si l'utilisateur est authentifié ou si le mode test est activé
  const isAuthenticated = user || testMode;

  return (
    <Router>
      <div className="app-container">
        {isAuthenticated && (
          <Sidebar />
        )}
        
        <div className="main-content">
          {isAuthenticated && (
            <div className="user-info">
              <p>Utilisateur Test</p>
              {testMode && <p className="test-mode">Mode test activé - Authentification désactivée</p>}
            </div>
          )}
          
          <ErrorBoundary>
            <Routes>
              {/* Routes publiques */}
              <Route path="/public-form" element={<PublicFormPage />} />
              
              {/* Routes protégées */}
              {isAuthenticated ? (
                <>
                  <Route path="/" element={<Dashboard />} />
                  <Route path="/dashboard" element={<Dashboard />} />
                  <Route path="/concerts" element={<ConcertsList />} />
                  <Route path="/concerts/:id" element={<ConcertDetail />} />
                  <Route path="/artists" element={<ArtistsList />} />
                  <Route path="/artists/:id" element={<ArtistDetails />} />
                  <Route path="/programmers" element={<ProgrammersList />} />
                  <Route path="/programmers/:id" element={<ProgrammerDetails />} />
                  <Route path="/contracts" element={<ContractsList />} />
                  <Route path="/contracts/:id" element={<ContractDetails />} />
                  <Route path="/invoices" element={<InvoicesList />} />
                  <Route path="/invoices/:id" element={<InvoiceDetails />} />
                  <Route path="/emails" element={<EmailsList />} />
                  <Route path="/documents" element={<DocumentsList />} />
                  <Route path="/settings" element={<Settings />} />
                  <Route path="/form-validation" element={<FormValidationList />} />
                  <Route path="/validation-formulaire" element={<FormValidationList />} />
                  <Route path="*" element={<Navigate to="/" replace />} />
                </>
              ) : (
                // Rediriger vers la page de connexion si non authentifié
                <Route path="*" element={<Navigate to="/login" replace />} />
              )}
            </Routes>
          </ErrorBoundary>
        </div>
      </div>
    </Router>
  );
}

export default App;
