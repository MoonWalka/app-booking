import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getArtistById, deleteArtist } from '../../services/artistsService';
import { getConcertsByArtist } from '../../services/concertsService';


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
        console.log(`Récupération des concerts pour l'artiste ID: ${id}`);
        const concertsData = await getConcertsByArtist(id);
        console.log('Concerts récupérés:', concertsData);
        setConcerts(concertsData);
        
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération des données:', err);
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

  // Fonction pour formater le statut du concert pour l'affichage et les classes CSS
  const formatStatus = (status) => {
    if (!status) return { text: 'Non spécifié', className: 'status-non-specifie' };
    
    // Convertir le statut en format compatible avec les classes CSS
    const statusLower = status.toLowerCase().replace(/ /g, '_');
    
    // Mapper les statuts aux classes CSS et textes d'affichage
    const statusMap = {
      'en_attente': { text: 'En attente', className: 'status-en-attente' },
      'confirmé': { text: 'Confirmé', className: 'status-confirme' },
      'contrat_envoyé': { text: 'Contrat envoyé', className: 'status-contrat-envoye' },
      'contrat_signé': { text: 'Contrat signé', className: 'status-contrat-signe' },
      'acompte_reçu': { text: 'Acompte reçu', className: 'status-acompte-recu' },
      'soldé': { text: 'Soldé', className: 'status-solde' },
      'annulé': { text: 'Annulé', className: 'status-annule' }
    };
    
    // Retourner le texte et la classe correspondant au statut, ou une valeur par défaut
    return statusMap[statusLower] || { 
      text: status.charAt(0).toUpperCase() + status.slice(1).replace('_', ' '), 
      className: `status-${statusLower}` 
    };
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
        <h3>Concerts programmés ({concerts.length})</h3>
        {concerts && concerts.length > 0 ? (
          <div className="concerts-table-container">
            <table className="concerts-table">
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Heure</th>
                  <th>Lieu</th>
                  <th>Ville</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {concerts.map((concert) => {
                  const status = formatStatus(concert.status);
                  return (
                    <tr key={concert.id} className="concert-row">
                      <td>{concert.date ? new Date(concert.date).toLocaleDateString() : 'Non spécifiée'}</td>
                      <td>{concert.time || 'Non spécifiée'}</td>
                      <td>{concert.venue || 'Non spécifié'}</td>
                      <td>{concert.city || 'Non spécifiée'}</td>
                      <td>
                        <span className={`status-badge ${status.className}`}>
                          {status.text}
                        </span>
                      </td>
                      <td>
                        <button 
                          onClick={() => navigate(`/concerts/${concert.id}`)} 
                          className="view-concert-btn"
                        >
                          Détails
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
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
