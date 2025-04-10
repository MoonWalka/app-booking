import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import './PublicFormPage.css';

const PublicFormPage = ({ concertId: propConcertId }) => {
  const params = useParams();
  const navigate = useNavigate();
  // Utiliser l'ID du concert passé en prop ou extrait des paramètres d'URL
  const [concertId, setConcertId] = useState(propConcertId || params.concertId || null);
  
  // Si l'ID du concert n'est pas disponible et que nous sommes dans le contexte de l'application principale
  useEffect(() => {
    if (!concertId && window.location.hash) {
      // Essayer d'extraire l'ID du concert de l'URL
      const match = window.location.hash.match(/^#\/form\/([^\/]+)$/);
      if (match) {
        setConcertId(match[1]);
      }
    }
  }, [concertId]);
  
  // Logs de débogage détaillés
  useEffect(() => {
    console.log("PublicFormPage - CHARGÉE AVEC:");
    console.log("PublicFormPage - concertId (prop):", propConcertId);
    console.log("PublicFormPage - concertId (params):", params.concertId);
    console.log("PublicFormPage - concertId (state):", concertId);
    console.log("PublicFormPage - Hash brut:", window.location.hash);
    console.log("PublicFormPage - Hash nettoyé:", window.location.hash.replace(/^#/, ''));
    console.log("PublicFormPage - Pathname:", window.location.pathname);
    console.log("PublicFormPage - URL complète:", window.location.href);
  }, [propConcertId, params.concertId, concertId]);
  
  // Fonction de soumission du formulaire
  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Formulaire soumis pour le concert ID:", concertId);
    // Ici, vous pourriez appeler une API pour enregistrer les données du formulaire
    // Puis rediriger vers la page de confirmation
    navigate('/form-submitted');
  };
  
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
      
      <form onSubmit={handleSubmit} style={{ textAlign: "left", marginTop: "30px" }}>
        <div style={{ marginBottom: "20px" }}>
          <label style={{ display: "block", marginBottom: "5px", fontWeight: "bold" }}>
            ID du Concert (lecture seule):
          </label>
          <input 
            type="text" 
            value={concertId || ''} 
            readOnly 
            style={{ 
              width: "100%", 
              padding: "10px", 
              border: "1px solid #ddd", 
              borderRadius: "4px",
              backgroundColor: "#f0f0f0" 
            }} 
          />
        </div>
        
        <div style={{ marginBottom: "20px" }}>
          <label style={{ display: "block", marginBottom: "5px", fontWeight: "bold" }}>
            Votre Nom:
          </label>
          <input 
            type="text" 
            placeholder="Entrez votre nom" 
            style={{ 
              width: "100%", 
              padding: "10px", 
              border: "1px solid #ddd", 
              borderRadius: "4px" 
            }} 
          />
        </div>
        
        <div style={{ marginBottom: "20px" }}>
          <label style={{ display: "block", marginBottom: "5px", fontWeight: "bold" }}>
            Votre Email:
          </label>
          <input 
            type="email" 
            placeholder="Entrez votre email" 
            style={{ 
              width: "100%", 
              padding: "10px", 
              border: "1px solid #ddd", 
              borderRadius: "4px" 
            }} 
          />
        </div>
        
        <div style={{ marginBottom: "20px" }}>
          <label style={{ display: "block", marginBottom: "5px", fontWeight: "bold" }}>
            Message:
          </label>
          <textarea 
            placeholder="Entrez votre message" 
            rows="4" 
            style={{ 
              width: "100%", 
              padding: "10px", 
              border: "1px solid #ddd", 
              borderRadius: "4px" 
            }} 
          ></textarea>
        </div>
        
        <button 
          type="submit" 
          style={{ 
            backgroundColor: "#4a90e2", 
            color: "white", 
            border: "none", 
            borderRadius: "4px", 
            padding: "12px 20px", 
            fontSize: "16px", 
            cursor: "pointer", 
            display: "block", 
            margin: "0 auto" 
          }}
        >
          Soumettre le Formulaire
        </button>
      </form>
      
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
