// client/src/components/concerts/ConcertsList.js
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchConcerts = async () => {
      try {
        setLoading(true);
        const response = await fetch('/api/concerts');
        if (!response.ok) {
          throw new Error('Erreur lors de la récupération des concerts');
        }
        const data = await response.json();
        setConcerts(data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchConcerts();
  }, []);

  if (loading) return <div>Chargement des concerts...</div>;
  if (error) return <div>Erreur: {error}</div>;

  return (
    <div className="concerts-list-container">
      <h2>Liste des Concerts</h2>
      {concerts.length === 0 ? (
        <p>Aucun concert trouvé.</p>
      ) : (
        <div className="concerts-table-container">
          <table className="concerts-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Artiste</th>
                <th>Lieu</th>
                <th>Ville</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {concerts.map((concert) => (
                <tr key={concert._id}>
                  <td>{new Date(concert.date).toLocaleDateString()}</td>
                  <td>{concert.artist?.name || 'Non spécifié'}</td>
                  <td>{concert.venue}</td>
                  <td>{concert.city}</td>
                  <td>
                    <Link to={`/concerts/${concert._id}`} className="view-btn">
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
