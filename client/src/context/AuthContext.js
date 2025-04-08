import React, { createContext, useState, useContext, useEffect } from 'react';
import axios from 'axios';
import jwt_decode from 'jwt-decode';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

// Configuration pour le mode bypass d'authentification
const BYPASS_AUTH = true; // Mettre à true pour désactiver l'authentification
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

  useEffect(() => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Authentification simulée');
      return;
    }

    const checkToken = async () => {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          // Vérifier si le token est expiré
          const decoded = jwt_decode(token);
          const currentTime = Date.now() / 1000;
          if (decoded.exp < currentTime) {
            // Token expiré
            localStorage.removeItem('token');
            setIsAuthenticated(false);
            setCurrentUser(null);
          } else {
            // Token valide
            setCurrentUser(decoded);
            setIsAuthenticated(true);
          }
        } catch (error) {
          // Token invalide
          localStorage.removeItem('token');
          setIsAuthenticated(false);
          setCurrentUser(null);
        }
      }
      setLoading(false);
    };

    checkToken();
  }, []);

  const login = async (email, password) => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Login simulé');
      setCurrentUser(TEST_USER);
      setIsAuthenticated(true);
      setError(null);
      return true;
    }

    try {
      const response = await axios.post('/api/auth/login', { email, password });
      const { token, user } = response.data;
      localStorage.setItem('token', token);
      setCurrentUser(user);
      setIsAuthenticated(true);
      setError(null);
      return true;
    } catch (error) {
      setError(error.response?.data?.message || 'Erreur de connexion');
      return false;
    }
  };

  const logout = () => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Logout ignoré');
      return;
    }

    localStorage.removeItem('token');
    setCurrentUser(null);
    setIsAuthenticated(false);
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
