#!/bin/bash

# Script pour implémenter la solution au problème de routage dans app-booking
echo "Début de l'implémentation de la solution..."

# Création du composant PublicRoute
mkdir -p ./client/src/components/public
cat > ./client/src/components/public/PublicRoute.jsx << 'EOL'
import React from 'react';
import { useAuth } from '../../context/AuthContext';

// Composant PublicRoute qui rend son contenu indépendamment de l'état d'authentification
const PublicRoute = ({ children }) => {
  const { loading } = useAuth();

  if (loading) {
    return <div>Chargement...</div>;
  }
  
  return children;
};

export default PublicRoute;
EOL

echo "✅ Composant PublicRoute.jsx créé"

# Sauvegarde de l'App.js original
cp ./client/src/App.js ./client/src/App.js.backup
echo "✅ Sauvegarde de App.js créée"

# Modification du fichier App.js
cat > ./client/src/App.js << 'EOL'
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
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
import PublicFormPage from './components/public/PublicFormPage';
import FormSubmittedPage from './components/public/FormSubmittedPage';
import PublicRoute from './components/public/PublicRoute';

// Composant ProtectedRoute pour sécuriser les routes privées
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading, bypassEnabled } = useAuth();

  if (loading) {
    return <div>Chargement...</div>;
  }
  
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
  const { bypassEnabled, isAuthenticated } = useAuth();

  // Fonction pour vérifier si l'utilisateur est sur une route publique
  const isPublicRoute = (pathname) => {
    return pathname.startsWith('/form/') || pathname === '/form-submitted';
  };

  // Vérifier si l'URL actuelle est une route publique
  const currentPath = window.location.hash.substring(1); // Pour HashRouter
  const isOnPublicRoute = isPublicRoute(currentPath);

  // Si l'utilisateur est authentifié et tente d'accéder à une route publique,
  // ne pas rediriger vers le dashboard
  console.log('Current path:', currentPath, 'Is public route:', isOnPublicRoute);

  return (
    <div className="App">
      <Routes>
        {/* Routes publiques accessibles sans authentification */}
        <Route path="/form/:token" element={<PublicRoute><PublicFormPage /></PublicRoute>} />
        <Route path="/form-submitted" element={<PublicRoute><FormSubmittedPage /></PublicRoute>} />

        <Route path="/login" element={ bypassEnabled ? <Navigate to="/" /> : <Login /> } />
        
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

# Création d'un fichier de test pour vérifier la logique de détection des routes publiques
cat > ./client/src/test_public_route.js << 'EOL'
// Script de test pour vérifier le fonctionnement des routes publiques
console.log("Test de la route publique /form/:token");

// Simuler une navigation vers une route publique
const testPublicRoute = () => {
  // Vérifier si la route actuelle est une route publique
  const isPublicRoute = (pathname) => {
    return pathname.startsWith('/form/') || pathname === '/form-submitted';
  };

  // Tester avec différentes routes
  const testRoutes = [
    '/form/abc123',
    '/form-submitted',
    '/',
    '/login'
  ];

  testRoutes.forEach(route => {
    console.log(`Route: ${route}, Est une route publique: ${isPublicRoute(route)}`);
  });

  console.log("\nTest de la logique de détection des routes publiques terminé.");
};

testPublicRoute();
EOL

echo "✅ Fichier de test créé"

echo "✅ Implémentation terminée avec succès!"
echo "Pour tester la solution, redémarrez votre application React."
