import React from 'react';
import { useParams } from 'react-router-dom';
import './PublicFormPage.css';

const PublicFormPage = () => {
  console.log('PublicFormPage - pathname:', window.location.pathname);
  const { concertId } = useParams();
  console.log("PublicFormPage chargée avec concertId:", concertId);
  
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
          Pour implémenter le formulaire complet, remplacez ce composant par la version complète de PublicFormPage.
        </p>
      </div>
    </div>
  );
};

export default PublicFormPage;
