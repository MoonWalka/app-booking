import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import './InvoiceDetails.css';

const InvoiceDetails = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [data, setData] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        console.log('InvoiceDetails - Chargement des données...');
        
        // Simuler un chargement de données
        // Remplacer par le vrai code de chargement
        setTimeout(() => {
          setData({
            id: id || '1',
            name: 'Exemple de données',
            description: 'Ce composant a été généré automatiquement pour résoudre un problème d\'importation.'
          });
          setLoading(false);
        }, 1000);
        
      } catch (error) {
        console.error('InvoiceDetails - Erreur lors du chargement des données:', error);
        setError('Erreur lors du chargement des données. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  const handleBack = () => {
    navigate(-1);
  };

  if (loading) {
    return <div className="loading">Chargement des données...</div>;
  }

  if (error) {
    return (
      <div className="error-container">
        <div className="error">{error}</div>
        <button className="back-button" onClick={handleBack}>
          Retour
        </button>
      </div>
    );
  }

  return (
    <div className="InvoiceDetails-container">
      <h1>Détails</h1>
      
      {data && (
        <div className="details-card">
          <h2>{data.name}</h2>
          <p>{data.description}</p>
          {/* Ajouter d'autres champs selon les besoins */}
        </div>
      )}
      
      <div className="actions">
        <button className="back-button" onClick={handleBack}>
          Retour
        </button>
      </div>
    </div>
  );
};

export default InvoiceDetails;
