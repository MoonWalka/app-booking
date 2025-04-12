import React from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import from './context/AuthContext';
import { getUserName, isUserAuthenticated } from '../../utils/userUtils';
import Sidebar from '../layout/Sidebar';
import './Layout.css';

const Layout = () => {
  const { currentUser } = useAuth();
  const location = useLocation();
  
  // Utilisation sécurisée de currentUser avec l'utilitaire userUtils
  const userName = getUserName(currentUser, "Utilisateur");
  const isAuthenticated = isUserAuthenticated(currentUser);
  
  // Log sécurisé après avoir récupéré currentUser
  console.log("Layout - currentUser:", currentUser);
  
  return (
    <div className="app-container">
      {isAuthenticated && (
        <Sidebar />
      )}
      
      <div className="main-content">
        {isAuthenticated && (
          <div className="user-info">
            <p>{userName}</p>
            {process.env.REACT_APP_BYPASS_AUTH === 'true' && (
              <p className="test-mode">Mode test activé - Authentification simulée</p>
            )}
          </div>
        )}
        
        <Outlet />
      </div>
    </div>
  );
};

export default Layout;
