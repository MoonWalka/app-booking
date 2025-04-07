import React, { createContext, useState, useContext, useEffect } from 'react';
import axios from 'axios';
import jwt_decode from 'jwt-decode';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
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
            setIsAuthenticated(true);
            setCurrentUser(decoded);
            // Configurer le header par défaut pour les requêtes axios
            axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
          }
        } catch (error) {
          console.error('Erreur de décodage du token', error);
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
    try {
      setError(null);
      const response = await axios.post('/api/auth/login', { email, password });
      const { token, user } = response.data;
      
      localStorage.setItem('token', token);
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      
      setIsAuthenticated(true);
      setCurrentUser(user);
      
      return true;
    } catch (error) {
      console.error('Erreur de connexion', error);
      setError(error.response?.data?.message || 'Erreur de connexion');
      return false;
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    delete axios.defaults.headers.common['Authorization'];
    setIsAuthenticated(false);
    setCurrentUser(null);
  };

  const value = {
    currentUser,
    isAuthenticated,
    loading,
    error,
    login,
    logout
  };

  return (
    <React.Fragment>
      {children}
    </React.Fragment>
  );
};
