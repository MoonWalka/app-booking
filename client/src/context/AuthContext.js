# Dans votre GitHub Codespaces, créez une version de AuthContext.js sans Firebase
cat > client/src/context/AuthContext.js << 'EOL'
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
    localStorage.removeItem('token');
    setCurrentUser(null);
    setIsAuthenticated(false);
  };

  return (
    <React.Fragment>
      <AuthContext.Provider value={{ currentUser, isAuthenticated, loading, error, login, logout }}>
        {children}
      </AuthContext.Provider>
    </React.Fragment>
  );
};
EOL

# Commitez et poussez les changements
git add client/src/context/AuthContext.js
git commit -m "Revenir à la version originale de AuthContext.js sans Firebase"
git push origin main
