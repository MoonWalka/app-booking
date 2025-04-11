import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts } from '../../services/concertsService';
import ConcertsDashboard from './ConcertsDashboard';
import './ConcertsList.css';

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showDashboard, setShowDashboard] = useState(false);

  useEffect(() => {
    const fetchConcerts = async () => {
      try {
        setLoading(true);
        setError(null);
        
        console.log('ConcertsList - Chargement des concerts...');
        
        // Simuler un chargement de données
        // Dans une vraie application, ces données viendraient d'un service
        setTimeout(() => {
          const mockConcerts = [
            {
              id: '1',
              title: 'Concert de Jazz',
              artist: 'Quartet Jazz',
              date: '2025-05-15',
              venue: 'Salle Apollo',
              city: 'Paris',
              status: 'confirmed'
            },
            {
              id: '2',
              title: 'Festival Rock',
              artist: 'Rock Band',
              date: '2025-06-20',
              venue: 'Stade Municipal',
              city: 'Lyon',
              status: 'pending'
            },
            {
              id: '3',
              title: 'Récital de Piano',
              artist: 'Marie Dumont',
              date: '2025-04-30',
              venue: 'Conservatoire',
              city: 'Bordeaux',
              status: 'confirmed'
            }
          ];
          
          setConcerts(mockConcerts);
          setLoading(false);
        }, 1000);
        
      } catch (error) {
        console.error('ConcertsList - Erreur lors du chargement des concerts:', error);
        setError('Erreur lors du chargement des concerts. Veuillez réessayer.');
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

  if (error) {
    return (
      <div className="error-container">
        <div className="error">{error}</div>
        <button className="refresh-button" onClick={() => window.location.reload()}>
          Rafraîchir la page
        </button>
      </div>
    );
  }

  return (
    <div className="concerts-container">
      <div className="concerts-header">
        <h1>Gestion des Concerts</h1>
        <div className="view-toggle">
          <button 
            className={`toggle-button ${!showDashboard ? 'active' : ''}`}
            onClick={() => setShowDashboard(false)}
          >
            Vue Liste
          </button>
          <button 
            className={`toggle-button ${showDashboard ? 'active' : ''}`}
            onClick={() => setShowDashboard(true)}
          >
            Vue Tableau de Bord
          </button>
        </div>
      </div>
      
      {showDashboard ? (
        <ConcertsDashboard concerts={concerts} />
      ) : (
        <>
          <div className="concerts-actions">
            <button className="add-concert-button">Ajouter un concert</button>
          </div>
          
          <div className="concerts-list">
            {concerts.length === 0 ? (
              <div className="no-concerts">
                <p>Aucun concert trouvé.</p>
              </div>
            ) : (
              <div className="concerts-grid">
                {concerts.map(concert => (
                  <div key={concert.id} className={`concert-card ${concert.status}`}>
                    <div className="concert-header">
                      <h3>{concert.title}</h3>
                      <span className={`status-badge ${concert.status}`}>
                        {concert.status === 'confirmed' ? 'Confirmé' : 'En attente'}
                      </span>
                    </div>
                    
                    <div className="concert-details">
                      <p><strong>Artiste:</strong> {concert.artist}</p>
                      <p><strong>Date:</strong> {new Date(concert.date).toLocaleDateString('fr-FR')}</p>
                      <p><strong>Lieu:</strong> {concert.venue}, {concert.city}</p>
                    </div>
                    
                    <div className="concert-actions">
                      <Link to={`/concerts/${concert.id}`} className="view-button">
                        Voir les détails
                      </Link>
                      <button className="form-link-button">
                        Générer lien formulaire
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
};

export default ConcertsList;
