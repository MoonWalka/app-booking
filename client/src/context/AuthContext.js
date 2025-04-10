import React, { createContext, useState, useContext, useEffect } from 'react';
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'firebase/auth';
import { app } from '../firebase';

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

export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(BYPASS_AUTH ? TEST_USER : null);
  const [isAuthenticated, setIsAuthenticated] = useState(BYPASS_AUTH);
  const [loading, setLoading] = useState(!BYPASS_AUTH);
  const [error, setError] = useState(null);
  const auth = getAuth(app);

  useEffect(() => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Authentification simulée');
      return;
    }

    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        // Utilisateur connecté
        setCurrentUser({
          id: user.uid,
          email: user.email,
          name: user.displayName || user.email.split('@')[0],
          role: 'admin' // Par défaut, tous les utilisateurs sont admin pour l'instant
        });
        setIsAuthenticated(true);
      } else {
        // Utilisateur déconnecté
        setCurrentUser(null);
        setIsAuthenticated(false);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, [auth]);

  const login = async (email, password) => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Login simulé');
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
      console.error('Erreur de connexion:', error);
      setError(error.message);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const logout = async () => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Logout ignoré');
      return;
    }

    try {
      await signOut(auth);
    } catch (error) {
      console.error('Erreur lors de la déconnexion:', error);
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
        bypassEnabled: BYPASS_AUTH
      }}>
        {children}
      </AuthContext.Provider>
    </React.Fragment>
  );
};
