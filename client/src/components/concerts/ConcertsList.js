import React, { useState, useEffect, Suspense } from 'react';
import { Link } from 'react-router-dom';
import { getAllConcerts } from '../../services/concertsService';
import './ConcertsList.css';

// Importation dynamique du tableau de bord
const ConcertsDashboard = React.lazy(() => import('./ConcertsDashboard'));

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showDashboard, setShowDashboard] = useState(false);

  useEffect(() => {
    const fetchConcerts = async () => {
      try {
        const concertsData = await getAllConcerts();
        setConcerts(concertsData || []);
        setLoading(false);
      } catch (error) {
        console.error("Erreur lors du chargement des concerts:", error);
        setLoading(false);
      }
    };

    fetchConcerts();
  }, []);

  const toggleView = () => {
    setShowDashboard(!showDashboard);
  };

  if (loading) {
    return <div className="loading">Chargement des concerts...</div>;
  }

  return (
    <div className="concerts-container">
      <h1>Gestion des concerts</h1>
      
      <div className="concerts-actions">
        <button 
          className={`view-toggle-btn ${showDashboard ? 'active' : ''}`} 
          onClick={toggleView}
        >
          {showDashboard ? 'Vue liste' : 'Vue tableau de bord'}
        </button>
        
        <Link to="/concerts/add" className="add-concert-btn">
          Ajouter un concert
        </Link>
      </div>
      
      {showDashboard ? (
        <Suspense fallback={<div className="loading">Chargement du tableau de bord...</div>}>
          <ConcertsDashboard concerts={concerts} />
        </Suspense>
      ) : (
        <div className="concerts-list">
          <h2>Liste des concerts ({concerts.length})</h2>
          
          <table className="concerts-table">
            <thead>
              <tr>
                <th>Artiste</th>
                <th>Date</th>
                <th>Lieu</th>
                <th>Ville</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {concerts.length > 0 ? (
                concerts.map((concert) => (
                  <tr key={concert.id}>
                    <td>{concert.artist || 'Artiste inconnu'}</td>
                    <td>{concert.date || ''}</td>
                    <td>{concert.venue || 'th'}</td>
                    <td>{concert.city || 'th'}</td>
                    <td>{concert.status || 'En attente'}</td>
                    <td>
                      <Link to={`/concerts/${concert.id}`} className="view-btn">
                        Voir
                      </Link>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" className="no-data">Aucun concert trouvé</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default ConcertsList;
