import React, { useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import './PublicFormPage.css';

const FormSubmittedPage = () => {
  const location = useLocation();
  const { isAuthenticated, currentUser, isCurrentRoutePublic } = useAuth();
  
  // Logs de débogage détaillés pour vérifier le chemin
  useEffect(() => {
    console.log("FormSubmittedPage - CHARGÉE AVEC:");
    console.log("FormSubmittedPage - Location:", location);
    console.log("FormSubmittedPage - Hash brut:", window.location.hash);
    console.log("FormSubmittedPage - Hash nettoyé:", window.location.hash.replace(/^#/, ''));
    console.log("FormSubmittedPage - Pathname:", window.location.pathname);
    console.log("FormSubmittedPage - URL complète:", window.location.href);
    console.log("FormSubmittedPage - Est une route publique:", isCurrentRoutePublic);
    console.log("FormSubmittedPage - Utilisateur authentifié:", isAuthenticated);
    console.log("FormSubmittedPage - Utilisateur actuel:", currentUser);
  }, [location, isAuthenticated, currentUser, isCurrentRoutePublic]);
  
  return (
    <div style={{ 
      padding: "40px", 
      textAlign: "center", 
      maxWidth: "800px", 
      margin: "0 auto", 
      backgroundColor: "#f9f9f9", 
      borderRadius: "8px", 
      boxShadow: "0 2px 10px rgba(0,0,0,0.1)" 
    }}>
      <h2 style={{ color: "#4a90e2", marginBottom: "20px" }}>Formulaire Soumis avec Succès</h2>
      <p style={{ fontSize: "18px", marginBottom: "15px" }}>
        Merci d'avoir soumis le formulaire. Vos informations ont été enregistrées.
      </p>
      <div style={{ 
        marginTop: "30px", 
        padding: "15px", 
        backgroundColor: "#e8f4fd", 
        borderRadius: "5px", 
        border: "1px solid #c5e1f9" 
      }}>
        <p style={{ margin: "0", color: "#2c76c7" }}>
          Vous pouvez maintenant fermer cette page.
        </p>
        <p style={{ margin: "10px 0 0 0", color: "#2c76c7", fontSize: "14px", textAlign: "left" }}>
          Informations de débogage:<br />
          Hash: {window.location.hash}<br />
          Pathname: {window.location.pathname}<br />
          URL complète: {window.location.href}<br />
          Est authentifié: {isAuthenticated ? "Oui" : "Non"}<br />
          Utilisateur: {currentUser ? currentUser.name : "Aucun"}
        </p>
      </div>
    </div>
  );
};

export default FormSubmittedPage;
