import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getArtistById, updateArtist } from '../../services/artistsService';
import './ArtistDetail.css';

const ArtistEdit = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    genre: '',
    location: '',
    members: '',
    contactEmail: '',
    contactPhone: '',
    bio: '',
    socialMedia: {
      spotify: '',
      instagram: ''
    }
  });

  // Liste des genres musicaux
  const genres = [
    'Rock',
    'Pop',
    'Hip-Hop',
    'Rap',
    'R&B',
    'Jazz',
    'Blues',
    'Électronique',
    'Folk',
    'Country',
    'Métal',
    'Punk',
    'Classique',
    'Reggae',
    'Soul',
    'Funk',
    'Disco',
    'Techno',
    'House',
    'Ambient',
    'Indie',
    'Alternative',
    'World',
    'Latino',
    'Autre'
  ];

  useEffect(() => {
    const fetchArtist = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération de l'artiste avec l'ID: ${id}`);
        
        const artistData = await getArtistById(id);
        if (!artistData) {
          throw new Error('Artiste non trouvé');
        }
        
        console.log('Artiste récupéré:', artistData);
        
        // Initialiser le formulaire avec les données de l'artiste
        setFormData({
          name: artistData.name || '',
          genre: artistData.genre || '',
          location: artistData.location || '',
          members: artistData.members ? artistData.members.toString() : '',
          contactEmail: artistData.contactEmail || '',
          contactPhone: artistData.contactPhone || '',
          bio: artistData.bio || '',
          socialMedia: {
            spotify: artistData.socialMedia?.spotify || '',
            instagram: artistData.socialMedia?.instagram || ''
          }
        });
        
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération de l\'artiste:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchArtist();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name.startsWith('socialMedia.')) {
      const socialMediaField = name.split('.')[1];
      setFormData({
        ...formData,
        socialMedia: {
          ...formData.socialMedia,
          [socialMediaField]: value
        }
      });
    } else {
      setFormData({
        ...formData,
        [name]: value
      });
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      // Préparer les données pour la mise à jour
      const artistData = {
        ...formData,
        members: formData.members ? parseInt(formData.members, 10) : 1
      };
      
      console.log("Données de l'artiste à mettre à jour:", artistData);
      
      // Mettre à jour l'artiste
      await updateArtist(id, artistData);
      
      setLoading(false);
      
      // Rediriger vers la page de détail de l'artiste
      navigate(`/artistes/${id}`);
    } catch (err) {
      console.error("Erreur lors de la mise à jour de l'artiste:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  if (loading) return <div className="loading">Chargement des données de l'artiste...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  return (
    <div className="artist-edit-container">
      <h2>Modifier l'artiste</h2>
      
      <form onSubmit={handleSubmit} className="edit-form">
        <div className="form-group">
          <label htmlFor="name">Nom de l'artiste *</label>
          <input
            type="text"
            id="name"
            name="name"
            value={formData.name}
            onChange={handleInputChange}
            required
            placeholder="Nom de l'artiste ou du groupe"
          />
        </div>
        
        <div className="form-group">
          <label htmlFor="genre">Genre musical *</label>
          <select
            id="genre"
            name="genre"
            value={formData.genre}
            onChange={handleInputChange}
            required
          >
            <option value="">Sélectionner un genre</option>
            {genres.map(genre => (
              <option key={genre} value={genre}>{genre}</option>
            ))}
          </select>
        </div>
        
        <div className="form-group">
          <label htmlFor="location">Ville/Région</label>
          <input
            type="text"
            id="location"
            name="location"
            value={formData.location}
            onChange={handleInputChange}
            placeholder="Ville ou région d'origine"
          />
        </div>
        
        <div className="form-group">
          <label htmlFor="members">Nombre de membres</label>
          <input
            type="number"
            id="members"
            name="members"
            value={formData.members}
            onChange={handleInputChange}
            min="1"
            placeholder="Nombre de personnes dans le groupe"
          />
        </div>
        
        <div className="form-group">
          <label htmlFor="contactEmail">Email de contact *</label>
          <input
            type="email"
            id="contactEmail"
            name="contactEmail"
            value={formData.contactEmail}
            onChange={handleInputChange}
            required
            placeholder="Email de contact"
          />
        </div>
        
        <div className="form-group">
          <label htmlFor="contactPhone">Téléphone de contact</label>
          <input
            type="tel"
            id="contactPhone"
            name="contactPhone"
            value={formData.contactPhone}
            onChange={handleInputChange}
            placeholder="Numéro de téléphone"
          />
        </div>
        
        <div className="form-group full-width">
          <label htmlFor="bio">Biographie</label>
          <textarea
            id="bio"
            name="bio"
            value={formData.bio}
            onChange={handleInputChange}
            rows="4"
            placeholder="Biographie de l'artiste"
          ></textarea>
        </div>
        
        <div className="form-group">
          <label htmlFor="socialMedia.spotify">Lien Spotify</label>
          <input
            type="url"
            id="socialMedia.spotify"
            name="socialMedia.spotify"
            value={formData.socialMedia.spotify}
            onChange={handleInputChange}
            placeholder="https://open.spotify.com/artist/..."
          />
        </div>
        
        <div className="form-group">
          <label htmlFor="socialMedia.instagram">Lien Instagram</label>
          <input
            type="url"
            id="socialMedia.instagram"
            name="socialMedia.instagram"
            value={formData.socialMedia.instagram}
            onChange={handleInputChange}
            placeholder="https://instagram.com/..."
          />
        </div>
        
        <div className="form-actions">
          <button type="button" className="cancel-btn" onClick={() => navigate(`/artistes/${id}`)}>
            Annuler
          </button>
          <button type="submit" className="save-btn" disabled={loading}>
            {loading ? 'Enregistrement...' : 'Enregistrer'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default ArtistEdit;
