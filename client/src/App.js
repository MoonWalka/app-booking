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
