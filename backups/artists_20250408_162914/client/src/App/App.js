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

  return (
    <div className="App">
      <Routes>
        {/* Si le mode bypass est activé, la page de login redirige vers le dashboard */}
        <Route path="/login" element={
          bypassEnabled ? <Navigate to="/" /> : <Login />
        } />
        
        <Route path="/" element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }>
          <Route index element={<Dashboard />} />
          <Route path="programmateurs" element={<ProgrammersList />} />
          <Route path="programmateurs/:id" element={<ProgrammerDetail />} />
          <Route path="concerts" element={<ConcertsList />} />
          <Route path="concerts/:id" element={<ConcertDetail />} />
          <Route path="artistes" element={<ArtistsList />} />
          <Route path="artistes/:id" element={<ArtistDetail />} />
          <Route path="emails" element={<EmailSystem />} />
          <Route path="documents" element={<DocumentsManager />} />
          <Route path="tests" element={<TestFirebaseIntegration />} />
        </Route>
        
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
