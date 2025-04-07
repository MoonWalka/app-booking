// client/src/components/artists/ArtistDetail.js
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';

const ArtistDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [artist, setArtist] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchArtist = async () => {
      try {
        setLoading(true);
        const response = await fetch(`/api/artists/${id}`);
        if (!response.ok) {
          throw new Error('Erreur lors de la récupération des détails de l\'artiste');
        }
        const data = await response.json();
        setArtist(data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchArtist();
  }, [id]);

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cet artiste ?')) {
      try {
        const response = await fetch(`/api/artists/${id}`, {
          method: 'DELETE',
        });
        if (!response.ok) {
          throw new Error('Erreur lors de la suppression de l\'artiste');
        }
        navigate('/artistes');
      } catch (err) {
        setError(err.message);
      }
    }
  };

  if (loading) return <div>Chargement des détails de l'artiste...</div>;
  if (error) return <div>Erreur: {error}</div>;
  if (!artist) return <div>Artiste non trouvé</div>;

  return (
    <div className="artist-detail-container">
      <h2>{artist.name}</h2>
      <div className="artist-info">
        <p><strong>Genre:</strong> {artist.genre}</p>
        <p><strong>Origine:</strong> {artist.origin}</p>
        <p><strong>Biographie:</strong> {artist.bio}</p>
        {artist.website && (
          <p>
            <strong>Site web:</strong>{' '}
            <a href={artist.website} target="_blank" rel="noopener noreferrer">
              {artist.website}
            </a>
          </p>
        )}
      </div>

      <div className="concerts-section">
        <h3>Concerts programmés</h3>
        {artist.concerts && artist.concerts.length > 0 ? (
          <ul className="concerts-list">
            {artist.concerts.map((concert) => (
              <li key={concert._id}>
                <p><strong>Date:</strong> {new Date(concert.date).toLocaleDateString()}</p>
                <p><strong>Lieu:</strong> {concert.venue}</p>
                <p><strong>Ville:</strong> {concert.city}</p>
              </li>
            ))}
          </ul>
        ) : (
          <p>Aucun concert programmé pour cet artiste.</p>
        )}
      </div>

      <div className="artist-actions">
        <button
          onClick={() => navigate(`/artistes/modifier/${id}`)}
          className="edit-btn"
        >
          Modifier
        </button>
        <button onClick={handleDelete} className="delete-btn">
          Supprimer
        </button>
        <button onClick={() => navigate('/artistes')} className="back-btn">
          Retour à la liste
        </button>
      </div>
    </div>
  );
};

export default ArtistDetail;
