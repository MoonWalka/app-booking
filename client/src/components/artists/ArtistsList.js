import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getArtists, addArtist } from '../../services/artistsService';


const ArtistsList = () => {
  const [artists, setArtists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [genreFilter, setGenreFilter] = useState('');
  const [showForm, setShowForm] = useState(false);
  
  // État pour le formulaire d'ajout d'artiste
  const [newArtist, setNewArtist] = useState({
    name: '',
    genre: 'Rock', // Valeur par défaut pour éviter le problème de sélection
    location: '',
    members: 1,
    contactEmail: '',
    contactPhone: '',
    bio: '',
    imageUrl: '',
    socialMedia: {
      spotify: '',
      instagram: ''
    }
  });
  
  // Genres musicaux pour le filtre et le formulaire
  const genres = [
    'Rock', 'Pop', 'Jazz', 'Électronique', 'Hip-Hop', 'Rap', 
    'Classique', 'Folk', 'Metal', 'Blues', 'Reggae', 'Soul', 
    'Funk', 'Country', 'World', 'Autre'
  ];

  useEffect(() => {
    const fetchArtists = async () => {
      try {
        setLoading(true);
        const data = await getArtists();
        console.log("Données d'artistes récupérées:", data); // Log pour le débogage
        setArtists(data);
        setLoading(false);
      } catch (err) {
        console.error("Erreur dans le composant lors de la récupération des artistes:", err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchArtists();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name.includes('.')) {
      const [parent, child] = name.split('.');
      setNewArtist({
        ...newArtist,
        [parent]: {
          ...newArtist[parent],
          [child]: value
        }
      });
    } else {
      setNewArtist({
        ...newArtist,
        [name]: value
      });
    }
    
    // Log pour le débogage
    console.log(`Champ ${name} mis à jour avec la valeur: ${value}`);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      // Convertir members en nombre
      const artistData = {
        ...newArtist,
        members: parseInt(newArtist.members, 10) || 1
      };
      
      console.log("Données de l'artiste à ajouter:", artistData); // Log pour le débogage
      
      await addArtist(artistData);
      
      // Réinitialiser le formulaire
      setNewArtist({
        name: '',
        genre: 'Rock', // Maintenir la valeur par défaut
        location: '',
        members: 1,
        contactEmail: '',
        contactPhone: '',
        bio: '',
        imageUrl: '',
        socialMedia: {
          spotify: '',
          instagram: ''
        }
      });
      
      // Masquer le formulaire
      setShowForm(false);
      
      // Rafraîchir la liste des artistes
      const updatedArtists = await getArtists();
      setArtists(updatedArtists);
      
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de l'ajout de l'artiste:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  // Filtrer les artistes en fonction de la recherche et du filtre de genre
  const filteredArtists = artists.filter(artist => {
    const matchesSearch = artist.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (artist.location && artist.location.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesGenre = genreFilter === '' || artist.genre === genreFilter;
    return matchesSearch && matchesGenre;
  });

  if (loading && artists.length === 0) return <div className="loading">Chargement des artistes...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  return (
    <div className="artists-list-container">
      <div className="artists-header">
        <h2>Liste des Artistes</h2>
        <button 
          className="add-artist-btn"
          onClick={() => setShowForm(!showForm)}
        >
          {showForm ? 'Annuler' : 'Ajouter un artiste'}
        </button>
      </div>
      
      {showForm && (
        <div className="add-artist-form-container">
          <h3>Ajouter un nouvel artiste</h3>
          <form onSubmit={handleSubmit} className="add-artist-form">
            <div className="form-group">
              <label htmlFor="name">Nom de l'artiste *</label>
              <input
                type="text"
                id="name"
                name="name"
                value={newArtist.name}
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
                value={newArtist.genre}
                onChange={handleInputChange}
                required
              >
                {genres.map(genre => (
                  <option key={genre} value={genre}>{genre}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group">
              <label htmlFor="location">Ville *</label>
              <input
                type="text"
                id="location"
                name="location"
                value={newArtist.location}
                onChange={handleInputChange}
                required
                placeholder="Ville d'origine"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="members">Nombre de membres</label>
              <input
                type="number"
                id="members"
                name="members"
                value={newArtist.members}
                onChange={handleInputChange}
                min="1"
                placeholder="Nombre de membres"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="contactEmail">Email de contact *</label>
              <input
                type="email"
                id="contactEmail"
                name="contactEmail"
                value={newArtist.contactEmail}
                onChange={handleInputChange}
                required
                placeholder="email@exemple.com"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="contactPhone">Téléphone</label>
              <input
                type="tel"
                id="contactPhone"
                name="contactPhone"
                value={newArtist.contactPhone}
                onChange={handleInputChange}
                placeholder="06 12 34 56 78"
              />
            </div>
            
            <div className="form-group full-width">
              <label htmlFor="bio">Biographie</label>
              <textarea
                id="bio"
                name="bio"
                value={newArtist.bio}
                onChange={handleInputChange}
                rows="4"
                placeholder="Biographie de l'artiste"
              ></textarea>
            </div>
            
            <div className="form-group">
              <label htmlFor="imageUrl">URL de l'image</label>
              <input
                type="url"
                id="imageUrl"
                name="imageUrl"
                value={newArtist.imageUrl}
                onChange={handleInputChange}
                placeholder="https://exemple.com/image.jpg"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="socialMedia.spotify">Spotify</label>
              <input
                type="url"
                id="socialMedia.spotify"
                name="socialMedia.spotify"
                value={newArtist.socialMedia.spotify}
                onChange={handleInputChange}
                placeholder="https://open.spotify.com/artist/..."
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="socialMedia.instagram">Instagram</label>
              <input
                type="url"
                id="socialMedia.instagram"
                name="socialMedia.instagram"
                value={newArtist.socialMedia.instagram}
                onChange={handleInputChange}
                placeholder="https://instagram.com/..."
              />
            </div>
            
            <div className="form-actions">
              <button type="button" className="cancel-btn" onClick={()  => setShowForm(false)}>
                Annuler
              </button>
              <button type="submit" className="submit-btn" disabled={loading}>
                {loading ? 'Ajout en cours...' : 'Ajouter l\'artiste'}
              </button>
            </div>
          </form>
        </div>
      )}
      
      <div className="artists-filters">
        <div className="search-container">
          <input
            type="text"
            placeholder="Rechercher un artiste..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
        
        <div className="filter-container">
          <select
            value={genreFilter}
            onChange={(e) => setGenreFilter(e.target.value)}
            className="genre-filter"
          >
            <option value="">Tous les genres</option>
            {genres.map(genre => (
              <option key={genre} value={genre}>{genre}</option>
            ))}
          </select>
        </div>
      </div>

      {filteredArtists.length === 0 ? (
        <p className="no-results">Aucun artiste trouvé.</p>
      ) : (
        <div className="artists-grid">
          {filteredArtists.map((artist) => (
            <div key={artist.id} className="artist-card">
              <div className="artist-image">
                {artist.imageUrl ? (
                  <img src={artist.imageUrl} alt={artist.name} />
                ) : (
                  <div className="placeholder-image">
                    {artist.name.charAt(0)}
                  </div>
                )}
              </div>
              <div className="artist-info">
                <h3 className="artist-name">{artist.name}</h3>
                <p className="artist-genre">{artist.genre || 'Genre non spécifié'}</p>
                <p className="artist-location">{artist.location || 'Lieu non spécifié'}</p>
                <Link to={`/artistes/${artist.id}`} className="view-details-btn">
                  Voir les détails
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default ArtistsList;
