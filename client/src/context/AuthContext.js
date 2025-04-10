import React, { createContext, useState, useContext, useEffect } from 'react';
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'firebase/auth';
import { app } from '../firebase';
import { useLocation } from 'react-router-dom';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

// Configuration pour le mode bypass d'authentification
const BYPASS_AUTH = true; // Mettre à false pour activer l'authentification réelle
const TEST_USER = {
  id: 'test-user-id',
  email: 'test@example.com',
  name: 'Utilisateur Test',
  role: 'admin'
};

// Fonction pour vérifier si une route est publique - adaptée pour HashRouter
const isPublicRoute = (path) => {
  // Nettoyer le chemin pour HashRouter (enlever le # au début si présent)
  const cleanPath = path.replace(/^#/, '');
  
  // Si le chemin commence par un slash, l'utiliser tel quel, sinon ajouter un slash
  const normalizedPath = cleanPath.startsWith('/') ? cleanPath : `/${cleanPath}`;
  
  console.log('AuthContext - isPublicRoute - chemin original:', path);
  console.log('AuthContext - isPublicRoute - chemin nettoyé:', cleanPath);
  console.log('AuthContext - isPublicRoute - chemin normalisé:', normalizedPath);
  
  const isPublic = normalizedPath.startsWith('/form/') || normalizedPath === '/form-submitted';
  console.log('AuthContext - isPublicRoute - est une route publique:', isPublic);
  
  return isPublic;
};

export const AuthProvider = ({ children }) => {
  const location = useLocation();
  
  // Obtenir le chemin actuel à partir du hash (pour HashRouter)
  const currentHash = location.hash || '';
  // Nettoyer le hash pour obtenir le chemin réel (enlever le # au début)
  const cleanHash = currentHash.replace(/^#/, '');
  // Vérifier si la route actuelle est une route publique
  const isCurrentRoutePublic = isPublicRoute(currentHash);
  
  console.log('AuthContext - Route actuelle (hash brut):', currentHash);
  console.log('AuthContext - Route actuelle (hash nettoyé):', cleanHash);
  console.log('AuthContext - Est une route publique:', isCurrentRoutePublic);
  
  // Désactiver le bypass d'authentification pour les routes publiques
  const effectiveBypass = BYPASS_AUTH && !isCurrentRoutePublic;
  console.log('AuthContext - BYPASS_AUTH global:', BYPASS_AUTH);
  console.log('AuthContext - Bypass effectif pour cette route:', effectiveBypass);
  
  const [currentUser, setCurrentUser] = useState(effectiveBypass ? TEST_USER : null);
  const [isAuthenticated, setIsAuthenticated] = useState(effectiveBypass);
  const [loading, setLoading] = useState(!effectiveBypass);
  const [error, setError] = useState(null);
  const auth = getAuth(app);

  useEffect(() => {
    // Mettre à jour l'état d'authentification lorsque la route change
    if (isCurrentRoutePublic) {
      console.log('AuthContext - Route publique détectée, désactivation du bypass d\'authentification');
      setIsAuthenticated(false);
      setCurrentUser(null);
    } else if (BYPASS_AUTH) {
      console.log('AuthContext - Route protégée avec bypass activé, authentification simulée');
      setIsAuthenticated(true);
      setCurrentUser(TEST_USER);
    }
    
    if (BYPASS_AUTH && !isCurrentRoutePublic) {
      console.log('AuthContext - Mode bypass d\'authentification activé pour route protégée');
      return;
    }

    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        // Utilisateur connecté
        console.log('AuthContext - Utilisateur connecté:', user.email);
        setCurrentUser({
          id: user.uid,
          email: user.email,
          name: user.displayName || user.email.split('@')[0],
          role: 'admin' // Par défaut, tous les utilisateurs sont admin pour l'instant
        });
        setIsAuthenticated(true);
      } else {
        // Utilisateur déconnecté
        console.log('AuthContext - Utilisateur déconnecté');
        setCurrentUser(null);
        setIsAuthenticated(false);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, [auth, isCurrentRoutePublic, BYPASS_AUTH, location]);

  const login = async (email, password) => {
    if (BYPASS_AUTH) {
      console.log('AuthContext - Mode bypass d\'authentification activé - Login simulé');
      setCurrentUser(TEST_USER);
      setIsAuthenticated(true);
      setError(null);
      return true;
    }

    try {
      setLoading(true);
      await signInWithEmailAndPassword(auth, email, password);
      setError(null);
      return true;
    } catch (error) {
      console.error('AuthContext - Erreur de connexion:', error);
      setError(error.message);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const logout = async () => {
    if (BYPASS_AUTH) {
      console.log('AuthContext - Mode bypass d\'authentification activé - Logout ignoré');
      return;
    }

    try {
      await signOut(auth);
    } catch (error) {
      console.error('AuthContext - Erreur lors de la déconnexion:', error);
    }
  };

  return (
    <React.Fragment>
      <AuthContext.Provider value={{ 
        currentUser, 
        isAuthenticated, 
        loading, 
        error, 
        login, 
        logout,
        bypassEnabled: BYPASS_AUTH,
        isPublicRoute: isPublicRoute,
        isCurrentRoutePublic: isCurrentRoutePublic
      }}>
        {children}
      </AuthContext.Provider>
    </React.Fragment>
  );
};
