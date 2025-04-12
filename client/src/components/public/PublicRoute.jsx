import React from 'react';
import from './context/AuthContext';

// Composant PublicRoute qui rend son contenu indépendamment de l'état d'authentification
const PublicRoute = ({ children }) => {
  const { loading } = useAuth();

  if (loading) {
    return <div>Chargement...</div>;
  }
  
  return children;
};

export default PublicRoute;
