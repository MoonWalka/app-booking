import React, { useState, useEffect, Suspense } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import './ConcertsList.css';

// Importation dynamique du tableau de bord
const ConcertsDashboard = React.lazy(() => import('./ConcertsDashboard'));

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [artists, setArtists] = useState({});
  const [loading, setLoading] = useState(true);
  const [showDashboard, setShowDashboard] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Récupérer les artistes et créer un mapping par ID
        const artistsData = await getArtists();
        const artistsMap = {};
        artistsData.forEach(artist => {
          artistsMap[artist.id] = artist;
        });
        setArtists(artistsMap);
        
        // Récupérer les concerts
        const concertsData = await getConcerts();
        
        // Enrichir les concerts avec les noms d'artistes
        const enrichedConcerts = concertsData.map(concert => {
          const artistId = concert.artistId;
          const artist = artistId && artistsMap[artistId] ? artistsMap[artistId].name : 'Artiste inconnu';
          
          // Formater la date correctement
          let formattedDate = 'Date non spécifiée';
          if (concert.date) {
            const date = new Date(concert.date);
            if (!isNaN(date.getTime())) {
              formattedDate = date.toLocaleDateString('fr-FR', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
              });
            }
          }
          
          return {
            ...concert,
            artist,
            formattedDate
          };
        });
        
        setConcerts(enrichedConcerts || []);
        setLoading(false);
      } catch (error) {
        console.error("Erreur lors du chargement des données:", error);
        setLoading(false);
      }
    };
    
    fetchData();
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
                    <td>{concert.formattedDate || concert.date || 'Non spécifiée'}</td>
                    <td>{concert.venue || 'Non spécifié'}</td>
                    <td>{concert.city || 'Non spécifiée'}</td>
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
