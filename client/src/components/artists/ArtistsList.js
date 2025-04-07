// client/src/components/artists/ArtistsList.js
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const ArtistsList = () => {
  const [artists, setArtists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchArtists = async () => {
      try {
        setLoading(true);
        const response = await fetch('/api/artists');
        if (!response.ok) {
          throw new Error('Erreur lors de la récupération des artistes');
        }
        const data = await response.json();
        setArtists(data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchArtists();
  }, []);

  if (loading) return <div>Chargement des artistes...</div>;
  if (error) return <div>Erreur: {error}</div>;

  return (
    <div className="artists-list-container">
      <h2>Liste des Artistes</h2>
      {artists.length === 0 ? (
        <p>Aucun artiste trouvé.</p>
      ) : (
        <div className="artists-grid">
          {artists.map((artist) => (
            <div key={artist._id} className="artist-card">
              <h3>{artist.name}</h3>
              <p>{artist.genre}</p>
              <Link to={`/artistes/${artist._id}`} className="view-details-btn">
                Voir détails
              </Link>
            </div>
          ))}
        </div>
      )}
      <div className="add-artist-container">
        <Link to="/artistes/nouveau" className="add-artist-btn">
          Ajouter un artiste
        </Link>
      </div>
    </div>
  );
};

export default ArtistsList;
