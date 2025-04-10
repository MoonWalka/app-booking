import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

const Login = () => {
  const navigate = useNavigate();
  
  // Logs de débogage
  useEffect(() => {
    console.log("Login - CHARGÉ");
    console.log("Login - Hash brut:", window.location.hash);
    console.log("Login - Hash nettoyé:", window.location.hash.replace(/^#/, ''));
    console.log("Login - Pathname:", window.location.pathname);
    console.log("Login - URL complète:", window.location.href);
    console.log("Login - Mode public activé, redirection vers Dashboard");
    
    // Rediriger automatiquement vers le Dashboard après 2 secondes
    const timer = setTimeout(() => {
      navigate('/');
    }, 2000);
    
    return () => clearTimeout(timer);
  }, [navigate]);
  
  return (
    <div style={{ 
      display: 'flex', 
      flexDirection: 'column', 
      alignItems: 'center', 
      justifyContent: 'center', 
      minHeight: '100vh', 
      padding: '20px',
      backgroundColor: '#f8f9fa'
    }}>
      <div style={{ 
        backgroundColor: 'white', 
        borderRadius: '8px', 
        boxShadow: '0 2px 10px rgba(0, 0, 0, 0.1)', 
        padding: '30px',
        width: '100%',
        maxWidth: '400px',
        textAlign: 'center'
      }}>
        <h2 style={{ color: '#4a90e2', marginBottom: '20px' }}>Page de Connexion</h2>
        
        <div style={{ 
          backgroundColor: '#d4edda', 
          color: '#155724', 
          padding: '15px', 
          borderRadius: '5px', 
          marginBottom: '20px',
          border: '1px solid #c3e6cb'
        }}>
          <p style={{ margin: '0' }}>
            <strong>Mode public activé</strong>
          </p>
          <p style={{ margin: '10px 0 0 0' }}>
            L'authentification est désactivée. Vous allez être redirigé vers le Dashboard automatiquement.
          </p>
        </div>
        
        <div style={{ 
          marginTop: '30px', 
          padding: '15px', 
          backgroundColor: '#e8f4fd', 
          borderRadius: '5px', 
          border: '1px solid #c5e1f9',
          textAlign: 'left'
        }}>
          <p style={{ margin: '0', color: '#2c76c7' }}>
            Informations de débogage:
          </p>
          <p style={{ margin: '10px 0 0 0', color: '#2c76c7', fontSize: '14px' }}>
            Hash: {window.location.hash}<br />
            Pathname: {window.location.pathname}<br />
            URL complète: {window.location.href}
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
