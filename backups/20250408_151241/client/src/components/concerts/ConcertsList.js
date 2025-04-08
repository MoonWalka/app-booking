// client/src/components/concerts/ConcertsList.js
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts } from '../../services/concertsService';

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchConcerts = async () => {
      try {
        setLoading(true);
        console.log("Tentative de récupération des concerts...");
        const data = await getConcerts();
        console.log("Concerts récupérés:", data);
        setConcerts(data);
        setLoading(false);
      } catch (err) {
        console.error("Erreur dans le composant lors de la récupération des concerts:", err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchConcerts();
  }, []);

  if (loading) return <div className="loading">Chargement des concerts...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  return (
    <div className="concerts-list-container">
      <h2>Liste des Concerts</h2>
      {concerts.length === 0 ? (
        <p className="no-results">Aucun concert trouvé.</p>
      ) : (
        <div className="concerts-table-container">
          <table className="concerts-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Heure</th>
                <th>Artiste</th>
                <th>Lieu</th>
                <th>Ville</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {concerts.map((concert) => (
                <tr key={concert.id}>
                  <td>{concert.date ? new Date(concert.date).toLocaleDateString() : 'Non spécifié'}</td>
                  <td>{concert.time || 'Non spécifié'}</td>
                  <td>{concert.artist?.name || 'Non spécifié'}</td>
                  <td>{concert.venue || 'Non spécifié'}</td>
                  <td>{concert.city || 'Non spécifié'}</td>
                  <td>{concert.status || 'Non spécifié'}</td>
                  <td>
                    <Link to={`/concerts/${concert.id}`} className="view-details-btn">
                      Voir
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <div className="add-concert-container">
        <Link to="/concerts/nouveau" className="add-concert-btn">
          Ajouter un concert
        </Link>
      </div>
    </div>
  );
};

export default ConcertsList;
