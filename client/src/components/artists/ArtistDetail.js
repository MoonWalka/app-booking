import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getArtistById, deleteArtist } from '../../services/artistsService';
import { getConcertsByArtist } from '../../services/concertsService';
import './ArtistDetail.css';

const ArtistDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [artist, setArtist] = useState(null);
  const [concerts, setConcerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchArtistAndConcerts = async () => {
      try {
        setLoading(true);
        
        // Récupérer les détails de l'artiste
        const artistData = await getArtistById(id);
        if (!artistData) {
          throw new Error('Artiste non trouvé');
        }
        setArtist(artistData);
        
        // Récupérer les concerts associés à cet artiste
        const concertsData = await getConcertsByArtist(id);
        setConcerts(concertsData);
        
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchArtistAndConcerts();
  }, [id]);

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cet artiste ?')) {
      try {
        await deleteArtist(id);
        navigate('/artistes');
      } catch (err) {
        setError(err.message);
      }
    }
  };

  if (loading) return <div className="loading">Chargement des détails de l'artiste...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;
  if (!artist) return <div className="not-found">Artiste non trouvé</div>;

  return (
    <div className="artist-detail-container">
      <div className="artist-header">
        <div className="artist-header-info">
          <h2>{artist.name}</h2>
          <div className="artist-genre">{artist.genre || 'Genre non spécifié'}</div>
        </div>
        {artist.imageUrl && (
          <div className="artist-header-image">
            <img src={artist.imageUrl} alt={artist.name} />
          </div>
        )}
      </div>
      
      <div className="artist-info">
        <div className="info-section">
          <h3>Informations générales</h3>
          <div className="info-grid">
            <div className="info-item">
              <span className="info-label">Ville:</span>
              <span className="info-value">{artist.location || 'Non spécifiée'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">Nombre de membres:</span>
              <span className="info-value">{artist.members || 'Non spécifié'}</span>
            </div>
          </div>
        </div>
        
        <div className="info-section">
          <h3>Contact</h3>
          <div className="info-grid">
            <div className="info-item">
              <span className="info-label">Email:</span>
              <span className="info-value">{artist.contactEmail}</span>
            </div>
            <div className="info-item">
              <span className="info-label">Téléphone:</span>
              <span className="info-value">{artist.contactPhone || 'Non spécifié'}</span>
            </div>
          </div>
        </div>
        
        {artist.bio && (
          <div className="info-section">
            <h3>Biographie</h3>
            <p className="artist-bio">{artist.bio}</p>
          </div>
        )}
        
        <div className="info-section">
          <h3>Présence web</h3>
          <div className="web-links">
            {artist.socialMedia?.spotify && (
              <a href={artist.socialMedia.spotify} target="_blank" rel="noopener noreferrer" className="web-link">
                <i className="fab fa-spotify"></i> Spotify
              </a>
            )}
            {artist.socialMedia?.instagram && (
              <a href={artist.socialMedia.instagram} target="_blank" rel="noopener noreferrer" className="web-link">
                <i className="fab fa-instagram"></i> Instagram
              </a>
            )}
            {(!artist.socialMedia?.spotify && !artist.socialMedia?.instagram) && (
              <p>Aucune présence web renseignée</p>
            )}
          </div>
        </div>
      </div>

      <div className="concerts-section">
        <h3>Concerts programmés</h3>
        {concerts.length > 0 ? (
          <ul className="concerts-list">
            {concerts.map((concert) => (
              <li key={concert.id} className="concert-item">
                <div className="concert-date">
                  {new Date(concert.date).toLocaleDateString()} | {concert.time}
                </div>
                <div className="concert-venue">{concert.venue}</div>
                <div className="concert-city">{concert.city}</div>
                <div className="concert-status">
                  <span className={`status-badge status-${concert.status}`}>
                    {concert.status.charAt(0).toUpperCase() + concert.status.slice(1).replace('_', ' ')}
                  </span>
                </div>
                <div className="concert-actions">
                  <button 
                    onClick={() => navigate(`/concerts/${concert.id}`)} 
                    className="view-concert-btn"
                  >
                    Détails
                  </button>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <p className="no-concerts">Aucun concert programmé pour cet artiste.</p>
        )}
      </div>

      <div className="artist-actions">
        <button
          onClick={() => navigate(`/artistes/modifier/${id}`)}
          className="edit-btn"
        >
          <i className="fas fa-edit"></i> Modifier
        </button>
        <button onClick={handleDelete} className="delete-btn">
          <i className="fas fa-trash"></i> Supprimer
        </button>
        <button onClick={() => navigate('/artistes')} className="back-btn">
          <i className="fas fa-arrow-left"></i> Retour à la liste
        </button>
      </div>
    </div>
  );
};

export default ArtistDetail;
