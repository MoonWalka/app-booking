import React, { createContext, useState, useContext } from 'react';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

// Utilisateur factice toujours considéré comme connecté
const PUBLIC_USER = {
  id: 'public-user-id',
  email: 'public@example.com',
  name: 'Utilisateur Public',
  role: 'admin'
};

export const AuthProvider = ({ children }) => {
  // Toujours authentifié, jamais en chargement, pas d'erreur
  const [currentUser] = useState(PUBLIC_USER);
  const [isAuthenticated] = useState(true);
  const [loading] = useState(false);
  const [error] = useState(null);
  
  console.log('AuthContext - Mode public activé - Authentification désactivée');
  console.log('AuthContext - Utilisateur public:', PUBLIC_USER);

  // Fonctions factices qui ne font rien
  const login = async () => {
    console.log('AuthContext - Fonction login appelée (désactivée)');
    return true;
  };

  const logout = async () => {
    console.log('AuthContext - Fonction logout appelée (désactivée)');
  };

  // Fonction pour vérifier si une route est publique (toujours true maintenant)
  const isPublicRoute = () => {
    console.log('AuthContext - Fonction isPublicRoute appelée (toujours true)');
    return true;
  };

  return (
    <AuthContext.Provider value={{ 
      currentUser, 
      isAuthenticated, 
      loading, 
      error, 
      login, 
      logout,
      bypassEnabled: true,
      isPublicRoute: isPublicRoute,
      isCurrentRoutePublic: true
    }}>
      {children}
    </AuthContext.Provider>
  );
};
