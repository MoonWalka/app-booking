import React, { useEffect } from 'react';
import { useParams, useLocation } from 'react-router-dom';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { concertId } = useParams();
  const location = useLocation();
  
  // Logs de débogage pour vérifier le chemin et les paramètres
  useEffect(() => {
    console.log("PublicFormPage - Chargée avec concertId:", concertId);
    console.log("PublicFormPage - Location:", location);
    console.log("PublicFormPage - Hash:", window.location.hash);
    console.log("PublicFormPage - Pathname:", window.location.pathname);
    console.log("PublicFormPage - URL complète:", window.location.href);
  }, [concertId, location]);
  
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
      <h2 style={{ color: "#4a90e2", marginBottom: "20px" }}>Formulaire Public Chargé avec Succès</h2>
      <p style={{ fontSize: "18px", marginBottom: "15px" }}>
        ID du Concert: <strong>{concertId}</strong>
      </p>
      <p style={{ fontSize: "16px", color: "#666" }}>
        Cette page est accessible sans authentification, ce qui confirme que le problème de routage a été résolu.
      </p>
      <div style={{ 
        marginTop: "30px", 
        padding: "15px", 
        backgroundColor: "#e8f4fd", 
        borderRadius: "5px", 
        border: "1px solid #c5e1f9" 
      }}>
        <p style={{ margin: "0", color: "#2c76c7" }}>
          Informations de débogage:
        </p>
        <p style={{ margin: "10px 0 0 0", color: "#2c76c7", fontSize: "14px", textAlign: "left" }}>
          Hash: {window.location.hash}<br />
          Pathname: {window.location.pathname}<br />
          URL complète: {window.location.href}
        </p>
      </div>
    </div>
  );
};

export default PublicFormPage;
