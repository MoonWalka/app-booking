import React, { createContext, useState, useContext, useEffect } from 'react';
import { auth, secureLog } from '../firebase';
import { onAuthStateChanged } from 'firebase/auth';

// Créer le contexte d'authentification
const AuthContext = createContext();

// Définir les routes publiques qui ne nécessitent pas d'authentification
const PUBLIC_ROUTES = [
  '/login',
  '/register',
  '/reset-password',
  '/public-form'
];

// Vérifier si une route est publique
const isPublicRoute = (path) => {
  // Nettoyer le chemin
  const cleanPath = path.split('?')[0].split('#')[0];
  // Normaliser le chemin
  const normalizedPath = cleanPath || '/';
  
  secureLog("AuthContext - isPublicRoute - chemin original:", path);
  secureLog("AuthContext - isPublicRoute - chemin nettoyé:", cleanPath);
  secureLog("AuthContext - isPublicRoute - chemin normalisé:", normalizedPath);
  
  // Vérifier si le chemin est dans la liste des routes publiques
  const isPublic = PUBLIC_ROUTES.some(route => normalizedPath.startsWith(route));
  secureLog("AuthContext - isPublicRoute - est une route publique:", isPublic);
  
  return isPublic;
};

// Hook personnalisé pour utiliser le contexte d'authentification
export const useAuth = () => {
  return useContext(AuthContext);
};

// Fournisseur du contexte d'authentification
export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Utilisateur de test pour le mode bypass
  const TEST_USER = {
    uid: 'test-user-id',
    email: 'test@example.com',
    name: 'Utilisateur Test',
    role: 'admin',
    isAuthenticated: true
  };
  
  useEffect(() => {
    // Récupérer la route actuelle
    const currentRoute = window.location.hash.substring(1); // Pour les applications avec HashRouter
    secureLog("AuthContext - Route actuelle (hash brut):", window.location.hash);
    secureLog("AuthContext - Route actuelle (hash nettoyé):", currentRoute);
    
    // Vérifier si la route actuelle est publique
    const isPublic = isPublicRoute(currentRoute);
    secureLog("AuthContext - Est une route publique:", isPublic);
    
    // Récupérer la valeur de BYPASS_AUTH depuis les variables d'environnement
    const bypassAuth = process.env.REACT_APP_BYPASS_AUTH === 'true';
    secureLog("AuthContext - BYPASS_AUTH global:", bypassAuth);
    
    // Déterminer si le bypass doit être activé pour cette route
    const shouldBypass = bypassAuth && !isPublic;
    secureLog("AuthContext - Bypass effectif pour cette route:", shouldBypass);
    
    // Si le bypass est activé et que la route n'est pas publique, utiliser l'utilisateur de test
    if (shouldBypass) {
      secureLog("AuthContext - Route protégée avec bypass activé, authentification simulée");
      setCurrentUser(TEST_USER);
      setLoading(false);
      return;
    }
    
    // Sinon, utiliser l'authentification Firebase normale
    const unsubscribe = onAuthStateChanged(auth, 
      (user) => {
        if (user) {
          // Utilisateur connecté
          const formattedUser = {
            uid: user.uid,
            email: user.email,
            name: user.displayName || 'Utilisateur',
            isAuthenticated: true
          };
          setCurrentUser(formattedUser);
        } else {
          // Utilisateur déconnecté
          setCurrentUser(null);
        }
        setLoading(false);
      },
      (error) => {
        console.error("Erreur d'authentification:", error);
        setError("Une erreur s'est produite lors de l'authentification.");
        setLoading(false);
      }
    );
    
    // Nettoyer l'abonnement lors du démontage du composant
    return () => unsubscribe();
  }, []);
  
  // Si le mode bypass est activé pour les routes protégées, afficher un message
  useEffect(() => {
    if (process.env.REACT_APP_BYPASS_AUTH === 'true') {
      const currentRoute = window.location.hash.substring(1);
      if (!isPublicRoute(currentRoute)) {
        console.log("AuthContext - Mode bypass d'authentification activé pour route protégée");
      }
    }
  }, []);
  
  // Valeur du contexte
  const value = {
    currentUser,
    loading,
    error,
    isAuthenticated: !!currentUser
  };
  
  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
