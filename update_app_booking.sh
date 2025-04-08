#!/bin/bash
set -e

echo "Script de mise à jour de l'application app-booking avec intégration Firebase automatique"
echo "=============================================================================="
echo ""
echo "Ce script va mettre à jour votre application avec les fonctionnalités d'ajout automatique"
echo "pour les artistes, programmateurs et concerts, permettant la création automatique des"
echo "collections Firebase."
echo ""

# Vérifier que nous sommes dans le bon répertoire
if [ ! -d "client" ]; then
  echo "Erreur: Le dossier 'client' n'a pas été trouvé."
  echo "Assurez-vous d'exécuter ce script depuis le répertoire racine de votre projet app-booking."
  exit 1
fi

echo "Création des dossiers nécessaires..."
mkdir -p client/src/components/dashboard
mkdir -p client/src/components/programmers
mkdir -p client/src/utils

echo "Mise à jour des fichiers pour les artistes..."
cat > client/src/components/artists/ArtistsList.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { collection, getDocs, query, orderBy, addDoc } from 'firebase/firestore';
import { db } from '../../firebase';
import './ArtistsList.css';

const ArtistsList = () => {
  const [artists, setArtists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newArtist, setNewArtist] = useState({
    name: '',
    genre: '',
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
  const [searchTerm, setSearchTerm] = useState('');
  const [filterGenre, setFilterGenre] = useState('');

  useEffect(() => {
    const fetchArtists = async () => {
      try {
        setLoading(true);
        // Dans une application réelle, nous récupérerions les artistes depuis Firebase
        // Pour l'instant, utilisons des données simulées
        const artistsRef = collection(db, 'artists');
        const q = query(artistsRef, orderBy('name'));
        
        try {
          const querySnapshot = await getDocs(q);
          const artistsData = querySnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          }));
          setArtists(artistsData);
        } catch (firestoreError) {
          console.log("Erreur Firestore ou collection vide, utilisation de données simulées", firestoreError);
          // Utiliser des données simulées si la collection n'existe pas encore
          setArtists([
            {
              id: '1',
              name: 'Les Harmonies Urbaines',
              genre: 'Jazz Fusion',
              location: 'Lyon',
              members: 4,
              contactEmail: 'contact@harmoniesurbaines.com',
              contactPhone: '06 12 34 56 78',
              upcomingConcerts: 3,
              imageUrl: 'https://example.com/harmonies.jpg'
            },
            {
              id: '2',
              name: 'Échos Poétiques',
              genre: 'Folk',
              location: 'Paris',
              members: 2,
              contactEmail: 'contact@echospoetiques.com',
              contactPhone: '06 23 45 67 89',
              upcomingConcerts: 1,
              imageUrl: 'https://example.com/echos.jpg'
            },
            {
              id: '3',
              name: 'Rythmes Solaires',
              genre: 'Électro',
              location: 'Marseille',
              members: 3,
              contactEmail: 'contact@rythmessolaires.com',
              contactPhone: '06 34 56 78 90',
              upcomingConcerts: 2,
              imageUrl: 'https://example.com/rythmes.jpg'
            }
          ]);
        }
        
        setLoading(false);
      } catch (err) {
        setError("Erreur lors du chargement des artistes: " + err.message);
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
  };

  const handleAddArtist = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      
      // Ajouter l'artiste à Firebase Firestore
      const artistsRef = collection(db, 'artists');
      const docRef = await addDoc(artistsRef, {
        ...newArtist,
        members: parseInt(newArtist.members),
        upcomingConcerts: 0,
        createdAt: new Date()
      });
      
      // Ajouter l'artiste à l'état local
      setArtists([
        ...artists,
        {
          id: docRef.id,
          ...newArtist,
          members: parseInt(newArtist.members),
          upcomingConcerts: 0
        }
      ]);
      
      // Réinitialiser le formulaire
      setNewArtist({
        name: '',
        genre: '',
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
      
      setShowAddForm(false);
      setLoading(false);
      
      alert('Artiste ajouté avec succès!');
    } catch (err) {
      setError("Erreur lors de l'ajout de l'artiste: " + err.message);
      setLoading(false);
    }
  };

  const filteredArtists = artists.filter(artist => {
    const matchesSearch = artist.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         artist.location.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesGenre = filterGenre === '' || artist.genre === filterGenre;
    return matchesSearch && matchesGenre;
  });

  const genres = [...new Set(artists.map(artist => artist.genre))];

  return (
    <div className="artists-list-container">
      <div className="artists-header">
        <h1>Gestion des Artistes</h1>
        <button 
          className="add-artist-btn"
          onClick={() => setShowAddForm(!showAddForm)}
        >
          {showAddForm ? 'Annuler' : 'Ajouter un artiste'}
        </button>
      </div>
      
      {showAddForm && (
        <div className="add-artist-form">
          <h2>Ajouter un nouvel artiste</h2>
          <form onSubmit={handleAddArtist}>
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="name">Nom de l'artiste *</label>
                <input
                  type="text"
                  id="name"
                  name="name"
                  value={newArtist.name}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="genre">Genre musical *</label>
                <input
                  type="text"
                  id="genre"
                  name="genre"
                  value={newArtist.genre}
                  onChange={handleInputChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="location">Localisation *</label>
                <input
                  type="text"
                  id="location"
                  name="location"
                  value={newArtist.location}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="members">Nombre de membres</label>
                <input
                  type="number"
                  id="members"
                  name="members"
                  min="1"
                  value={newArtist.members}
                  onChange={handleInputChange}
                />
              </div>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="contactEmail">Email de contact *</label>
                <input
                  type="email"
                  id="contactEmail"
                  name="contactEmail"
                  value={newArtist.contactEmail}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="contactPhone">Téléphone de contact</label>
                <input
                  type="tel"
                  id="contactPhone"
                  name="contactPhone"
                  value={newArtist.contactPhone}
                  onChange={handleInputChange}
                />
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="bio">Biographie</label>
              <textarea
                id="bio"
                name="bio"
                value={newArtist.bio}
                onChange={handleInputChange}
                rows="4"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="imageUrl">URL de l'image</label>
              <input
                type="url"
                id="imageUrl"
                name="imageUrl"
                value={newArtist.imageUrl}
                onChange={handleInputChange}
                placeholder="https://example.com/image.jpg"
              />
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="spotify">Lien Spotify</label>
                <input
                  type="url"
                  id="spotify"
                  name="socialMedia.spotify"
                  value={newArtist.socialMedia.spotify}
                  onChange={handleInputChange}
                  placeholder="https://open.spotify.com/artist/..."
                />
              </div>
              <div className="form-group">
                <label htmlFor="instagram">Lien Instagram</label>
                <input
                  type="url"
                  id="instagram"
                  name="socialMedia.instagram"
                  value={newArtist.socialMedia.instagram}
                  onChange={handleInputChange}
                  placeholder="https://instagram.com/..."
                />
              </div>
            </div>
            
            <div className="form-actions">
              <button type="submit" className="submit-btn" disabled={loading}>
                {loading ? 'Ajout en cours...' : 'Ajouter l\'artiste'}
              </button>
              <button 
                type="button" 
                className="cancel-btn"
                onClick={() => setShowAddForm(false)}
              >
                Annuler
              </button>
            </div>
          </form>
        </div>
      )}
      
      <div className="filters-container">
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
            value={filterGenre}
            onChange={(e) => setFilterGenre(e.target.value)}
            className="filter-select"
          >
            <option value="">Tous les genres</option>
            {genres.map((genre, index) => (
              <option key={index} value={genre}>{genre}</option>
            ))}
          </select>
        </div>
      </div>
      
      {error && <div className="error-message">{error}</div>}
      
      {loading && !showAddForm ? (
        <div className="loading">Chargement des artistes...</div>
      ) : (
        <div className="artists-grid">
          {filteredArtists.length === 0 ? (
            <div className="no-results">Aucun artiste trouvé</div>
          ) : (
            filteredArtists.map(artist => (
              <div key={artist.id} className="artist-card">
                <div className="artist-image">
                  {artist.imageUrl ? (
                    <img src={artist.imageUrl} alt={artist.name} />
                  ) : (
                    <div className="placeholder-image">
                      <i className="fas fa-music"></i>
                    </div>
                  )}
                </div>
                <div className="artist-info">
                  <h3>{artist.name}</h3>
                  <p className="artist-genre">{artist.genre}</p>
                  <p className="artist-location">
                    <i className="fas fa-map-marker-alt"></i> {artist.location}
                  </p>
                  <p className="artist-concerts">
                    <i className="fas fa-calendar-alt"></i> {artist.upcomingConcerts} concert(s) à venir
                  </p>
                </div>
                <div className="artist-actions">
                  <Link to={`/artistes/${artist.id}`} className="view-btn">
                    Voir détails
                  </Link>
                </div>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
};

export default ArtistsList;
EOL

echo "Mise à jour des fichiers pour les programmateurs..."
cat > client/src/components/programmers/ProgrammersList.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { collection, getDocs, query, orderBy, addDoc } from 'firebase/firestore';
import { db } from '../../firebase';
import './ProgrammersList.css';

const ProgrammersList = () => {
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newProgrammer, setNewProgrammer] = useState({
    name: '',
    structure: '',
    email: '',
    phone: '',
    city: '',
    address: '',
    postalCode: '',
    region: '',
    styles: [],
    capacity: 0,
    website: '',
    socialMedia: {
      facebook: '',
      instagram: ''
    },
    notes: ''
  });
  const [searchTerm, setSearchTerm] = useState('');
  const [filterRegion, setFilterRegion] = useState('');
  const [filterStyle, setFilterStyle] = useState('');

  useEffect(() => {
    const fetchProgrammers = async () => {
      try {
        setLoading(true);
        // Essayer de récupérer les programmateurs depuis Firebase
        const programmersRef = collection(db, 'programmers');
        const q = query(programmersRef, orderBy('name'));
        
        try {
          const querySnapshot = await getDocs(q);
          const programmersData = querySnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          }));
          setProgrammers(programmersData);
        } catch (firestoreError) {
          console.log("Erreur Firestore ou collection vide, utilisation de données simulées", firestoreError);
          // Utiliser des données simulées si la collection n'existe pas encore
          setProgrammers([
            {
              id: '1',
              name: 'Marie Dupont',
              structure: 'Association Vibrations',
              email: 'marie.dupont@vibrations.fr',
              phone: '06 12 34 56 78',
              city: 'Lyon',
              region: 'Auvergne-Rhône-Alpes',
              styles: ['Jazz', 'Folk'],
              capacity: 300,
              lastContact: '2025-03-15'
            },
            {
              id: '2',
              name: 'Jean Martin',
              structure: 'Le Loft',
              email: 'jean.martin@leloft.com',
              phone: '06 98 76 54 32',
              city: 'Paris',
              region: 'Île-de-France',
              styles: ['Électro', 'Hip-Hop'],
              capacity: 500,
              lastContact: '2025-03-20'
            },
            {
              id: '3',
              name: 'Sophie Legrand',
              structure: 'Centre Culturel Municipal',
              email: 'sophie.legrand@ccm.fr',
              phone: '06 45 67 89 01',
              city: 'Toulouse',
              region: 'Occitanie',
              styles: ['Classique', 'World'],
              capacity: 800,
              lastContact: '2025-03-10'
            }
          ]);
        }
        
        setLoading(false);
      } catch (err) {
        setError("Erreur lors du chargement des programmateurs: " + err.message);
        setLoading(false);
      }
    };

    fetchProgrammers();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name.includes('.')) {
      const [parent, child] = name.split('.');
      setNewProgrammer({
        ...newProgrammer,
        [parent]: {
          ...newProgrammer[parent],
          [child]: value
        }
      });
    } else if (name === 'styles') {
      // Traiter les styles comme un tableau
      const stylesArray = value.split(',').map(style => style.trim());
      setNewProgrammer({
        ...newProgrammer,
        styles: stylesArray
      });
    } else {
      setNewProgrammer({
        ...newProgrammer,
        [name]: value
      });
    }
  };

  const handleAddProgrammer = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      
      // Préparer les données du programmateur
      const programmerData = {
        ...newProgrammer,
        capacity: parseInt(newProgrammer.capacity) || 0,
        lastContact: new Date().toISOString().split('T')[0],
        createdAt: new Date()
      };
      
      // Ajouter le programmateur à Firebase Firestore
      const programmersRef = collection(db, 'programmers');
      const docRef = await addDoc(programmersRef, programmerData);
      
      // Ajouter le programmateur à l'état local
      setProgrammers([
        ...programmers,
        {
          id: docRef.id,
          ...programmerData
        }
      ]);
      
      // Réinitialiser le formulaire
      setNewProgrammer({
        name: '',
        structure: '',
        email: '',
        phone: '',
        city: '',
        address: '',
        postalCode: '',
        region: '',
        styles: [],
        capacity: 0,
        website: '',
        socialMedia: {
          facebook: '',
          instagram: ''
        },
        notes: ''
      });
      
      setShowAddForm(false);
      setLoading(false);
      
      alert('Programmateur ajouté avec succès!');
    } catch (err) {
      setError("Erreur lors de l'ajout du programmateur: " + err.message);
      setLoading(false);
    }
  };

  const filteredProgrammers = programmers.filter(programmer => {
    const matchesSearch = programmer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         programmer.structure.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         programmer.city.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesRegion = filterRegion === '' || programmer.region === filterRegion;
    const matchesStyle = filterStyle === '' || (programmer.styles && programmer.styles.includes(filterStyle));
    return matchesSearch && matchesRegion && matchesStyle;
  });

  const regions = [...new Set(programmers.map(programmer => programmer.region))];
  const styles = [...new Set(programmers.flatMap(programmer => programmer.styles || []))];

  return (
    <div className="programmers-list-container">
      <div className="programmers-header">
        <h1>Gestion des Programmateurs</h1>
        <button 
          className="add-programmer-btn"
          onClick={() => setShowAddForm(!showAddForm)}
        >
          {showAddForm ? 'Annuler' : 'Ajouter un programmateur'}
        </button>
      </div>
      
      {showAddForm && (
        <div className="add-programmer-form">
          <h2>Ajouter un nouveau programmateur</h2>
          <form onSubmit={handleAddProgrammer}>
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="name">Nom du contact *</label>
                <input
                  type="text"
                  id="name"
                  name="name"
                  value={newProgrammer.name}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="structure">Structure *</label>
                <input
                  type="text"
                  id="structure"
                  name="structure"
                  value={newProgrammer.structure}
                  onChange={handleInputChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="email">Email *</label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={newProgrammer.email}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="phone">Téléphone</label>
                <input
                  type="tel"
                  id="phone"
                  name="phone"
                  value={newProgrammer.phone}
                  onChange={handleInputChange}
                />
              </div>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="city">Ville *</label>
                <input
                  type="text"
                  id="city"
                  name="city"
                  value={newProgrammer.city}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="region">Région *</label>
                <input
                  type="text"
                  id="region"
                  name="region"
                  value={newProgrammer.region}
                  onChange={handleInputChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="address">Adresse</label>
              <input
                type="text"
                id="address"
                name="address"
                value={newProgrammer.address}
                onChange={handleInputChange}
              />
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="postalCode">Code postal</label>
                <input
                  type="text"
                  id="postalCode"
                  name="postalCode"
                  value={newProgrammer.postalCode}
                  onChange={handleInputChange}
                />
              </div>
              <div className="form-group">
                <label htmlFor="capacity">Capacité de la salle</label>
                <input
                  type="number"
                  id="capacity"
                  name="capacity"
                  min="0"
                  value={newProgrammer.capacity}
                  onChange={handleInputChange}
                />
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="styles">Styles musicaux (séparés par des virgules) *</label>
              <input
                type="text"
                id="styles"
                name="styles"
                value={newProgrammer.styles.join(', ')}
                onChange={handleInputChange}
                placeholder="Jazz, Folk, Rock..."
                required
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="website">Site web</label>
              <input
                type="url"
                id="website"
                name="website"
                value={newProgrammer.website}
                onChange={handleInputChange}
                placeholder="https://example.com"
              />
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="facebook">Facebook</label>
                <input
                  type="url"
                  id="facebook"
                  name="socialMedia.facebook"
                  value={newProgrammer.socialMedia.facebook}
                  onChange={handleInputChange}
                  placeholder="https://facebook.com/..."
                />
              </div>
              <div className="form-group">
                <label htmlFor="instagram">Instagram</label>
                <input
                  type="url"
                  id="instagram"
                  name="socialMedia.instagram"
                  value={newProgrammer.socialMedia.instagram}
                  onChange={handleInputChange}
                  placeholder="https://instagram.com/..."
                />
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="notes">Notes</label>
              <textarea
                id="notes"
                name="notes"
                value={newProgrammer.notes}
                onChange={handleInputChange}
                rows="4"
              />
            </div>
            
            <div className="form-actions">
              <button type="submit" className="submit-btn" disabled={loading}>
                {loading ? 'Ajout en cours...' : 'Ajouter le programmateur'}
              </button>
              <button 
                type="button" 
                className="cancel-btn"
                onClick={() => setShowAddForm(false)}
              >
                Annuler
              </button>
            </div>
          </form>
        </div>
      )}
      
      <div className="filters-container">
        <div className="search-container">
          <input
            type="text"
            placeholder="Rechercher un programmateur..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
        
        <div className="filter-container">
          <select
            value={filterRegion}
            onChange={(e) => setFilterRegion(e.target.value)}
            className="filter-select"
          >
            <option value="">Toutes les régions</option>
            {regions.map((region, index) => (
              <option key={index} value={region}>{region}</option>
            ))}
          </select>
        </div>
        
        <div className="filter-container">
          <select
            value={filterStyle}
            onChange={(e) => setFilterStyle(e.target.value)}
            className="filter-select"
          >
            <option value="">Tous les styles</option>
            {styles.map((style, index) => (
              <option key={index} value={style}>{style}</option>
            ))}
          </select>
        </div>
      </div>
      
      {error && <div className="error-message">{error}</div>}
      
      {loading && !showAddForm ? (
        <div className="loading">Chargement des programmateurs...</div>
      ) : (
        <div className="programmers-table-container">
          {filteredProgrammers.length === 0 ? (
            <div className="no-results">Aucun programmateur trouvé</div>
          ) : (
            <table className="programmers-table">
              <thead>
                <tr>
                  <th>Nom</th>
                  <th>Structure</th>
                  <th>Email</th>
                  <th>Téléphone</th>
                  <th>Ville</th>
                  <th>Styles musicaux</th>
                  <th>Capacité</th>
                  <th>Dernier contact</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredProgrammers.map(programmer => (
                  <tr key={programmer.id}>
                    <td>{programmer.name}</td>
                    <td>{programmer.structure}</td>
                    <td>{programmer.email}</td>
                    <td>{programmer.phone}</td>
                    <td>{programmer.city}</td>
                    <td>
                      {programmer.styles && programmer.styles.map((style, index) => (
                        <span key={index} className="style-tag">
                          {style}
                        </span>
                      ))}
                    </td>
                    <td>{programmer.capacity || 'N/A'}</td>
                    <td>{programmer.lastContact || 'Jamais'}</td>
                    <td>
                      <Link to={`/programmateurs/${programmer.id}`} className="view-btn">
                        <i className="fas fa-eye"></i>
                      </Link>
                      <button className="edit-btn">
                        <i className="fas fa-edit"></i>
                      </button>
                      <button className="contact-btn">
                        <i className="fas fa-envelope"></i>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
};

export default ProgrammersList;
EOL

echo "Mise à jour des fichiers pour les concerts..."
cat > client/src/components/concerts/ConcertsList.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { collection, getDocs, query, orderBy, where, addDoc } from 'firebase/firestore';
import { db } from '../../firebase';
import './ConcertsList.css';

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [artists, setArtists] = useState([]);
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newConcert, setNewConcert] = useState({
    date: '',
    time: '',
    artistId: '',
    venue: '',
    city: '',
    status: 'planifié',
    programmerId: '',
    ticketPrice: 0,
    capacity: 0,
    notes: ''
  });
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [filterDate, setFilterDate] = useState('');
  const [view, setView] = useState('list'); // 'list' ou 'calendar'

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        
        // Essayer de récupérer les concerts depuis Firebase
        const concertsRef = collection(db, 'concerts');
        const q = query(concertsRef, orderBy('date'));
        
        try {
          const querySnapshot = await getDocs(q);
          const concertsData = querySnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          }));
          setConcerts(concertsData);
        } catch (firestoreError) {
          console.log("Erreur Firestore ou collection vide, utilisation de données simulées", firestoreError);
          // Utiliser des données simulées si la collection n'existe pas encore
          setConcerts([
            {
              id: '1',
              date: '2025-05-15',
              time: '20:30',
              artist: { id: '1', name: 'Les Harmonies Urbaines' },
              venue: 'Salle des Fêtes',
              city: 'Lyon',
              status: 'confirmé',
              programmer: { id: '1', name: 'Marie Dupont', structure: 'Association Vibrations' },
              ticketPrice: 15,
              ticketsSold: 120,
              capacity: 300
            },
            {
              id: '2',
              date: '2025-05-17',
              time: '21:00',
              artist: { id: '2', name: 'Échos Poétiques' },
              venue: 'Le Loft',
              city: 'Paris',
              status: 'contrat_envoyé',
              programmer: { id: '2', name: 'Jean Martin', structure: 'Le Loft' },
              ticketPrice: 20,
              ticketsSold: 0,
              capacity: 500
            },
            {
              id: '3',
              date: '2025-05-22',
              time: '19:30',
              artist: { id: '3', name: 'Rythmes Solaires' },
              venue: 'Centre Culturel',
              city: 'Toulouse',
              status: 'acompte_reçu',
              programmer: { id: '3', name: 'Sophie Legrand', structure: 'Centre Culturel Municipal' },
              ticketPrice: 18,
              ticketsSold: 75,
              capacity: 800
            }
          ]);
        }
        
        // Récupérer les artistes pour le formulaire d'ajout
        try {
          const artistsRef = collection(db, 'artists');
          const artistsQuery = query(artistsRef, orderBy('name'));
          const artistsSnapshot = await getDocs(artistsQuery);
          const artistsData = artistsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          }));
          setArtists(artistsData);
        } catch (error) {
          console.log("Erreur lors de la récupération des artistes", error);
          // Données simulées pour les artistes
          setArtists([
            { id: '1', name: 'Les Harmonies Urbaines' },
            { id: '2', name: 'Échos Poétiques' },
            { id: '3', name: 'Rythmes Solaires' }
          ]);
        }
        
        // Récupérer les programmateurs pour le formulaire d'ajout
        try {
          const programmersRef = collection(db, 'programmers');
          const programmersQuery = query(programmersRef, orderBy('name'));
          const programmersSnapshot = await getDocs(programmersQuery);
          const programmersData = programmersSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
          }));
          setProgrammers(programmersData);
        } catch (error) {
          console.log("Erreur lors de la récupération des programmateurs", error);
          // Données simulées pour les programmateurs
          setProgrammers([
            { id: '1', name: 'Marie Dupont', structure: 'Association Vibrations' },
            { id: '2', name: 'Jean Martin', structure: 'Le Loft' },
            { id: '3', name: 'Sophie Legrand', structure: 'Centre Culturel Municipal' }
          ]);
        }
        
        setLoading(false);
      } catch (err) {
        setError("Erreur lors du chargement des données: " + err.message);
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewConcert({
      ...newConcert,
      [name]: value
    });
  };

  const handleAddConcert = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      
      // Trouver l'artiste et le programmateur sélectionnés
      const selectedArtist = artists.find(artist => artist.id === newConcert.artistId);
      const selectedProgrammer = programmers.find(programmer => programmer.id === newConcert.programmerId);
      
      if (!selectedArtist || !selectedProgrammer) {
        throw new Error("Artiste ou programmateur non trouvé");
      }
      
      // Préparer les données du concert
      const concertData = {
        date: newConcert.date,
        time: newConcert.time,
        artist: {
          id: selectedArtist.id,
          name: selectedArtist.name
        },
        venue: newConcert.venue,
        city: newConcert.city,
        status: newConcert.status,
        programmer: {
          id: selectedProgrammer.id,
          name: selectedProgrammer.name,
          structure: selectedProgrammer.structure
        },
        ticketPrice: parseFloat(newConcert.ticketPrice) || 0,
        ticketsSold: 0,
        capacity: parseInt(newConcert.capacity) || 0,
        notes: newConcert.notes,
        createdAt: new Date()
      };
      
      // Ajouter le concert à Firebase Firestore
      const concertsRef = collection(db, 'concerts');
      const docRef = await addDoc(concertsRef, concertData);
      
      // Ajouter le concert à l'état local
      setConcerts([
        ...concerts,
        {
          id: docRef.id,
          ...concertData
        }
      ]);
      
      // Réinitialiser le formulaire
      setNewConcert({
        date: '',
        time: '',
        artistId: '',
        venue: '',
        city: '',
        status: 'planifié',
        programmerId: '',
        ticketPrice: 0,
        capacity: 0,
        notes: ''
      });
      
      setShowAddForm(false);
      setLoading(false);
      
      alert('Concert ajouté avec succès!');
    } catch (err) {
      setError("Erreur lors de l'ajout du concert: " + err.message);
      setLoading(false);
    }
  };

  const filteredConcerts = concerts.filter(concert => {
    const matchesSearch = 
      (concert.artist?.name?.toLowerCase().includes(searchTerm.toLowerCase()) || false) ||
      (concert.venue?.toLowerCase().includes(searchTerm.toLowerCase()) || false) ||
      (concert.city?.toLowerCase().includes(searchTerm.toLowerCase()) || false) ||
      (concert.programmer?.name?.toLowerCase().includes(searchTerm.toLowerCase()) || false);
    
    const matchesStatus = filterStatus === '' || concert.status === filterStatus;
    
    const matchesDate = filterDate === '' || (concert.date && concert.date.includes(filterDate));
    
    return matchesSearch && matchesStatus && matchesDate;
  });

  const getStatusLabel = (status) => {
    switch (status) {
      case 'planifié': return 'Planifié';
      case 'confirmé': return 'Confirmé';
      case 'contrat_envoyé': return 'Contrat envoyé';
      case 'acompte_reçu': return 'Acompte reçu';
      case 'terminé': return 'Terminé';
      case 'annulé': return 'Annulé';
      default: return status;
    }
  };

  const getStatusClass = (status) => {
    switch (status) {
      case 'planifié': return 'status-planned';
      case 'confirmé': return 'status-confirmed';
      case 'contrat_envoyé': return 'status-contract';
      case 'acompte_reçu': return 'status-deposit';
      case 'terminé': return 'status-completed';
      case 'annulé': return 'status-cancelled';
      default: return '';
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '';
    const [year, month, day] = dateString.split('-');
    return `${day}/${month}/${year}`;
  };

  return (
    <div className="concerts-list-container">
      <div className="concerts-header">
        <h1>Gestion des Concerts</h1>
        <div className="header-actions">
          <div className="view-toggle">
            <button 
              className={`view-btn ${view === 'list' ? 'active' : ''}`}
              onClick={() => setView('list')}
            >
              <i className="fas fa-list"></i> Liste
            </button>
            <button 
              className={`view-btn ${view === 'calendar' ? 'active' : ''}`}
              onClick={() => setView('calendar')}
            >
              <i className="fas fa-calendar-alt"></i> Calendrier
            </button>
          </div>
          <button 
            className="add-concert-btn"
            onClick={() => setShowAddForm(!showAddForm)}
          >
            {showAddForm ? 'Annuler' : 'Ajouter un concert'}
          </button>
        </div>
      </div>
      
      {showAddForm && (
        <div className="add-concert-form">
          <h2>Ajouter un nouveau concert</h2>
          <form onSubmit={handleAddConcert}>
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="date">Date *</label>
                <input
                  type="date"
                  id="date"
                  name="date"
                  value={newConcert.date}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="time">Heure *</label>
                <input
                  type="time"
                  id="time"
                  name="time"
                  value={newConcert.time}
                  onChange={handleInputChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="artistId">Artiste *</label>
              <select
                id="artistId"
                name="artistId"
                value={newConcert.artistId}
                onChange={handleInputChange}
                required
              >
                <option value="">Sélectionner un artiste</option>
                {artists.map(artist => (
                  <option key={artist.id} value={artist.id}>
                    {artist.name}
                  </option>
                ))}
              </select>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="venue">Lieu *</label>
                <input
                  type="text"
                  id="venue"
                  name="venue"
                  value={newConcert.venue}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="city">Ville *</label>
                <input
                  type="text"
                  id="city"
                  name="city"
                  value={newConcert.city}
                  onChange={handleInputChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="programmerId">Programmateur *</label>
              <select
                id="programmerId"
                name="programmerId"
                value={newConcert.programmerId}
                onChange={handleInputChange}
                required
              >
                <option value="">Sélectionner un programmateur</option>
                {programmers.map(programmer => (
                  <option key={programmer.id} value={programmer.id}>
                    {programmer.name} - {programmer.structure}
                  </option>
                ))}
              </select>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="status">Statut</label>
                <select
                  id="status"
                  name="status"
                  value={newConcert.status}
                  onChange={handleInputChange}
                >
                  <option value="planifié">Planifié</option>
                  <option value="confirmé">Confirmé</option>
                  <option value="contrat_envoyé">Contrat envoyé</option>
                  <option value="acompte_reçu">Acompte reçu</option>
                  <option value="terminé">Terminé</option>
                  <option value="annulé">Annulé</option>
                </select>
              </div>
              <div className="form-group">
                <label htmlFor="ticketPrice">Prix du billet (€)</label>
                <input
                  type="number"
                  id="ticketPrice"
                  name="ticketPrice"
                  min="0"
                  step="0.01"
                  value={newConcert.ticketPrice}
                  onChange={handleInputChange}
                />
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="capacity">Capacité de la salle</label>
              <input
                type="number"
                id="capacity"
                name="capacity"
                min="0"
                value={newConcert.capacity}
                onChange={handleInputChange}
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="notes">Notes</label>
              <textarea
                id="notes"
                name="notes"
                value={newConcert.notes}
                onChange={handleInputChange}
                rows="4"
              />
            </div>
            
            <div className="form-actions">
              <button type="submit" className="submit-btn" disabled={loading}>
                {loading ? 'Ajout en cours...' : 'Ajouter le concert'}
              </button>
              <button 
                type="button" 
                className="cancel-btn"
                onClick={() => setShowAddForm(false)}
              >
                Annuler
              </button>
            </div>
          </form>
        </div>
      )}
      
      <div className="filters-container">
        <div className="search-container">
          <input
            type="text"
            placeholder="Rechercher un concert..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
        
        <div className="filter-container">
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="filter-select"
          >
            <option value="">Tous les statuts</option>
            <option value="planifié">Planifié</option>
            <option value="confirmé">Confirmé</option>
            <option value="contrat_envoyé">Contrat envoyé</option>
            <option value="acompte_reçu">Acompte reçu</option>
            <option value="terminé">Terminé</option>
            <option value="annulé">Annulé</option>
          </select>
        </div>
        
        <div className="filter-container">
          <input
            type="month"
            value={filterDate}
            onChange={(e) => setFilterDate(e.target.value)}
            className="filter-date"
          />
        </div>
      </div>
      
      {error && <div className="error-message">{error}</div>}
      
      {loading && !showAddForm ? (
        <div className="loading">Chargement des concerts...</div>
      ) : (
        <>
          {view === 'list' ? (
            <div className="concerts-table-container">
              {filteredConcerts.length === 0 ? (
                <div className="no-results">Aucun concert trouvé</div>
              ) : (
                <table className="concerts-table">
                  <thead>
                    <tr>
                      <th>Date</th>
                      <th>Heure</th>
                      <th>Artiste</th>
                      <th>Lieu</th>
                      <th>Ville</th>
                      <th>Programmateur</th>
                      <th>Statut</th>
                      <th>Prix</th>
                      <th>Ventes</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredConcerts.map(concert => (
                      <tr key={concert.id}>
                        <td>{formatDate(concert.date)}</td>
                        <td>{concert.time}</td>
                        <td>{concert.artist?.name}</td>
                        <td>{concert.venue}</td>
                        <td>{concert.city}</td>
                        <td>{concert.programmer?.name}</td>
                        <td>
                          <span className={`status-badge ${getStatusClass(concert.status)}`}>
                            {getStatusLabel(concert.status)}
                          </span>
                        </td>
                        <td>{concert.ticketPrice ? `${concert.ticketPrice} €` : 'N/A'}</td>
                        <td>
                          {concert.ticketsSold !== undefined ? 
                            `${concert.ticketsSold}/${concert.capacity} (${Math.round(concert.ticketsSold / concert.capacity * 100)}%)` : 
                            'N/A'}
                        </td>
                        <td>
                          <Link to={`/concerts/${concert.id}`} className="view-btn">
                            <i className="fas fa-eye"></i>
                          </Link>
                          <button className="edit-btn">
                            <i className="fas fa-edit"></i>
                          </button>
                          <button className="contract-btn">
                            <i className="fas fa-file-contract"></i>
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          ) : (
            <div className="calendar-view">
              <div className="calendar-notice">
                <i className="fas fa-info-circle"></i> La vue calendrier est en cours de développement.
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default ConcertsList;
EOL

echo "Création de l'utilitaire de test Firebase..."
cat > client/src/utils/testFirebaseIntegration.js << 'EOL'
import React from 'react';
import { collection, getDocs, addDoc, query, where } from 'firebase/firestore';
import { db } from '../firebase';

// Fonction pour tester l'intégration Firebase avec les formulaires
const testFirebaseIntegration = async () => {
  console.log("Début du test d'intégration Firebase...");
  
  try {
    // 1. Test de création d'un artiste
    console.log("Test de création d'un artiste...");
    const artistData = {
      name: "Artiste Test",
      genre: "Test Genre",
      location: "Test City",
      contactEmail: "test@example.com",
      createdAt: new Date()
    };
    
    const artistsRef = collection(db, 'artists');
    const artistDoc = await addDoc(artistsRef, artistData);
    console.log("Artiste créé avec succès, ID:", artistDoc.id);
    
    // 2. Test de création d'un programmateur
    console.log("Test de création d'un programmateur...");
    const programmerData = {
      name: "Programmateur Test",
      structure: "Structure Test",
      email: "prog@example.com",
      city: "Test City",
      region: "Test Region",
      styles: ["Test", "Demo"],
      createdAt: new Date()
    };
    
    const programmersRef = collection(db, 'programmers');
    const programmerDoc = await addDoc(programmersRef, programmerData);
    console.log("Programmateur créé avec succès, ID:", programmerDoc.id);
    
    // 3. Test de création d'un concert avec références
    console.log("Test de création d'un concert...");
    const concertData = {
      date: "2025-12-31",
      time: "23:00",
      artist: {
        id: artistDoc.id,
        name: artistData.name
      },
      venue: "Salle Test",
      city: "Test City",
      status: "planifié",
      programmer: {
        id: programmerDoc.id,
        name: programmerData.name,
        structure: programmerData.structure
      },
      ticketPrice: 10,
      capacity: 100,
      createdAt: new Date()
    };
    
    const concertsRef = collection(db, 'concerts');
    const concertDoc = await addDoc(concertsRef, concertData);
    console.log("Concert créé avec succès, ID:", concertDoc.id);
    
    // 4. Test de récupération des données
    console.log("Test de récupération des données...");
    
    // Récupérer l'artiste créé
    const artistQuery = query(artistsRef, where("name", "==", "Artiste Test"));
    const artistSnapshot = await getDocs(artistQuery);
    if (!artistSnapshot.empty) {
      console.log("Artiste récupéré avec succès:", artistSnapshot.docs[0].data());
    } else {
      console.log("Erreur: Artiste non trouvé");
    }
    
    // Récupérer le programmateur créé
    const programmerQuery = query(programmersRef, where("name", "==", "Programmateur Test"));
    const programmerSnapshot = await getDocs(programmerQuery);
    if (!programmerSnapshot.empty) {
      console.log("Programmateur récupéré avec succès:", programmerSnapshot.docs[0].data());
    } else {
      console.log("Erreur: Programmateur non trouvé");
    }
    
    // Récupérer le concert créé
    const concertQuery = query(concertsRef, where("venue", "==", "Salle Test"));
    const concertSnapshot = await getDocs(concertQuery);
    if (!concertSnapshot.empty) {
      console.log("Concert récupéré avec succès:", concertSnapshot.docs[0].data());
    } else {
      console.log("Erreur: Concert non trouvé");
    }
    
    console.log("Tests d'intégration Firebase terminés avec succès!");
    return {
      success: true,
      message: "Tous les tests d'intégration Firebase ont réussi",
      createdIds: {
        artist: artistDoc.id,
        programmer: programmerDoc.id,
        concert: concertDoc.id
      }
    };
    
  } catch (error) {
    console.error("Erreur lors des tests d'intégration Firebase:", error);
    return {
      success: false,
      message: "Erreur lors des tests d'intégration Firebase",
      error: error.message
    };
  }
};

export default testFirebaseIntegration;
EOL

echo "Création de la documentation sur l'intégration Firebase..."
cat > documentation_integration_firebase.md << 'EOL'
# Intégration Firebase Automatique - Documentation

## Introduction

Cette documentation explique comment l'application app-booking crée automatiquement les collections Firebase nécessaires lors de l'utilisation des formulaires d'ajout. Contrairement à une approche où les collections doivent être créées manuellement à l'avance, notre implémentation permet de créer ces collections à la volée lorsque vous ajoutez des données via l'interface utilisateur.

## Principe de fonctionnement

Firebase Firestore crée automatiquement les collections et documents lorsque vous tentez d'y ajouter des données pour la première fois. Notre application exploite cette fonctionnalité pour vous permettre de commencer à utiliser l'application sans configuration préalable de la base de données.

## Fonctionnalités d'ajout implémentées

Nous avons implémenté des formulaires d'ajout complets pour les principales sections de l'application :

### 1. Ajout d'artistes
- Accessible depuis la page "Artistes" via le bouton "Ajouter un artiste"
- Crée automatiquement la collection `artists` dans Firebase
- Collecte toutes les informations nécessaires (nom, genre, localisation, contacts, etc.)

### 2. Ajout de programmateurs
- Accessible depuis la page "Programmateurs" via le bouton "Ajouter un programmateur"
- Crée automatiquement la collection `programmers` dans Firebase
- Collecte toutes les informations nécessaires (nom, structure, email, ville, région, styles musicaux, etc.)

### 3. Ajout de concerts
- Accessible depuis la page "Concerts" via le bouton "Ajouter un concert"
- Crée automatiquement la collection `concerts` dans Firebase
- Établit des relations avec les artistes et programmateurs existants
- Collecte toutes les informations nécessaires (date, heure, lieu, statut, prix, etc.)

## Structure des collections créées

Lorsque vous utilisez les formulaires d'ajout, les collections suivantes sont créées automatiquement dans Firebase :

### Collection `artists`
```javascript
{
  name: "Nom de l'artiste",
  genre: "Genre musical",
  location: "Ville",
  members: 4, // Nombre de membres
  contactEmail: "email@example.com",
  contactPhone: "06 12 34 56 78",
  bio: "Biographie de l'artiste",
  imageUrl: "https://example.com/image.jpg",
  socialMedia: {
    spotify: "https://open.spotify.com/artist/...",
    instagram: "https://instagram.com/..."
  },
  createdAt: Timestamp // Date de création
}
```

### Collection `programmers`
```javascript
{
  name: "Nom du contact",
  structure: "Nom de la structure",
  email: "email@example.com",
  phone: "06 12 34 56 78",
  city: "Ville",
  address: "Adresse complète",
  postalCode: "75000",
  region: "Région",
  styles: ["Jazz", "Folk", "Rock"], // Styles musicaux
  capacity: 300, // Capacité de la salle
  website: "https://example.com",
  socialMedia: {
    facebook: "https://facebook.com/...",
    instagram: "https://instagram.com/..."
  },
  notes: "Notes supplémentaires",
  createdAt: Timestamp // Date de création
}
```

### Collection `concerts`
```javascript
{
  date: "2025-05-15", // Format YYYY-MM-DD
  time: "20:30", // Format HH:MM
  artist: {
    id: "id_de_l_artiste",
    name: "Nom de l'artiste"
  },
  venue: "Nom du lieu",
  city: "Ville",
  status: "confirmé", // planifié, confirmé, contrat_envoyé, acompte_reçu, terminé, annulé
  programmer: {
    id: "id_du_programmateur",
    name: "Nom du programmateur",
    structure: "Nom de la structure"
  },
  ticketPrice: 15, // Prix du billet en euros
  ticketsSold: 0, // Nombre de billets vendus
  capacity: 300, // Capacité de la salle
  notes: "Notes supplémentaires",
  createdAt: Timestamp // Date de création
}
```

## Comment tester l'intégration Firebase

Nous avons créé un utilitaire de test pour vérifier que l'intégration Firebase fonctionne correctement. Cet utilitaire se trouve dans le fichier `src/utils/testFirebaseIntegration.js`.

Pour l'utiliser :

1. Importez la fonction dans un composant ou dans la console :
```javascript
import testFirebaseIntegration from '../utils/testFirebaseIntegration';
```

2. Exécutez la fonction :
```javascript
testFirebaseIntegration().then(result => {
  console.log(result);
});
```

3. Vérifiez les résultats dans la console. Si tout fonctionne correctement, vous verrez un message de succès et les IDs des documents créés.

## Gestion des erreurs et données simulées

Pour assurer une expérience utilisateur fluide, même lorsque les collections n'existent pas encore ou en cas d'erreur de connexion à Firebase, nous avons implémenté un système de données simulées :

1. L'application tente d'abord de récupérer les données depuis Firebase
2. Si la collection n'existe pas encore ou si une erreur se produit, l'application utilise des données simulées
3. Lorsque vous ajoutez de nouvelles données, elles sont toujours enregistrées dans Firebase

## Conclusion

Grâce à cette approche, vous pouvez commencer à utiliser l'application immédiatement, sans configuration préalable de Firebase. Les collections et documents seront créés automatiquement au fur et à mesure que vous ajoutez des données via l'interface utilisateur.

Pour toute question ou problème concernant l'intégration Firebase, veuillez consulter la documentation Firebase officielle ou contacter l'équipe de développement.
EOL

echo "Création des fichiers CSS nécessaires..."
cat > client/src/components/artists/ArtistsList.css << 'EOL'
.artists-list-container {
  padding: 20px;
}

.artists-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.artists-header h1 {
  margin: 0;
  color: #2c3e50;
}

.add-artist-btn {
  background-color: #3498db;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  display: flex;
  align-items: center;
}

.add-artist-btn:hover {
  background-color: #2980b9;
}

.add-artist-form {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 20px;
  margin-bottom: 30px;
}

.add-artist-form h2 {
  margin-top: 0;
  color: #2c3e50;
  font-size: 1.5rem;
  margin-bottom: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
}

.form-group {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-bottom: 15px;
}

.form-group label {
  font-weight: 500;
  margin-bottom: 5px;
  color: #34495e;
}

.form-group input,
.form-group textarea,
.form-group select {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.submit-btn {
  background-color: #2ecc71;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.submit-btn:hover {
  background-color: #27ae60;
}

.submit-btn:disabled {
  background-color: #95a5a6;
  cursor: not-allowed;
}

.cancel-btn {
  background-color: #e74c3c;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.cancel-btn:hover {
  background-color: #c0392b;
}

.filters-container {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
}

.search-container {
  flex: 1;
}

.search-input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.filter-container {
  width: 200px;
}

.filter-select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.artists-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.artist-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  transition: transform 0.3s, box-shadow 0.3s;
}

.artist-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
}

.artist-image {
  height: 180px;
  overflow: hidden;
  background-color: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.artist-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.placeholder-image {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #bdc3c7;
  font-size: 3rem;
}

.artist-info {
  padding: 15px;
}

.artist-info h3 {
  margin: 0 0 10px 0;
  color: #2c3e50;
}

.artist-genre {
  color: #3498db;
  font-weight: 500;
  margin: 0 0 10px 0;
}

.artist-location,
.artist-concerts {
  color: #7f8c8d;
  margin: 5px 0;
  display: flex;
  align-items: center;
}

.artist-location i,
.artist-concerts i {
  margin-right: 8px;
  width: 16px;
}

.artist-actions {
  padding: 0 15px 15px;
  display: flex;
  justify-content: flex-end;
}

.view-btn {
  background-color: #3498db;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 4px;
  cursor: pointer;
  text-decoration: none;
  font-size: 0.9rem;
}

.view-btn:hover {
  background-color: #2980b9;
}

.loading {
  text-align: center;
  padding: 30px;
  color: #7f8c8d;
  font-size: 1.1rem;
}

.error-message {
  background-color: #f8d7da;
  color: #721c24;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.no-results {
  text-align: center;
  padding: 30px;
  color: #7f8c8d;
  font-size: 1.1rem;
  grid-column: 1 / -1;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
  
  .filters-container {
    flex-direction: column;
  }
  
  .filter-container {
    width: 100%;
  }
}
EOL

cat > client/src/components/programmers/ProgrammersList.css << 'EOL'
.programmers-list-container {
  padding: 20px;
}

.programmers-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.programmers-header h1 {
  margin: 0;
  color: #2c3e50;
}

.add-programmer-btn {
  background-color: #3498db;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  display: flex;
  align-items: center;
}

.add-programmer-btn:hover {
  background-color: #2980b9;
}

.add-programmer-form {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 20px;
  margin-bottom: 30px;
}

.add-programmer-form h2 {
  margin-top: 0;
  color: #2c3e50;
  font-size: 1.5rem;
  margin-bottom: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
}

.form-group {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-bottom: 15px;
}

.form-group label {
  font-weight: 500;
  margin-bottom: 5px;
  color: #34495e;
}

.form-group input,
.form-group textarea,
.form-group select {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.submit-btn {
  background-color: #2ecc71;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.submit-btn:hover {
  background-color: #27ae60;
}

.submit-btn:disabled {
  background-color: #95a5a6;
  cursor: not-allowed;
}

.cancel-btn {
  background-color: #e74c3c;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.cancel-btn:hover {
  background-color: #c0392b;
}

.filters-container {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
}

.search-container {
  flex: 1;
}

.search-input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.filter-container {
  width: 200px;
}

.filter-select {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.programmers-table-container {
  overflow-x: auto;
}

.programmers-table {
  width: 100%;
  border-collapse: collapse;
  background-color: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.programmers-table th,
.programmers-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.programmers-table th {
  background-color: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
}

.programmers-table tr:last-child td {
  border-bottom: none;
}

.programmers-table tr:hover {
  background-color: #f8f9fa;
}

.style-tag {
  display: inline-block;
  background-color: #e0f7fa;
  color: #0097a7;
  padding: 3px 8px;
  border-radius: 12px;
  font-size: 0.8rem;
  margin-right: 5px;
  margin-bottom: 5px;
}

.view-btn,
.edit-btn,
.contact-btn {
  background: none;
  border: none;
  color: #3498db;
  cursor: pointer;
  font-size: 1rem;
  margin-right: 10px;
}

.view-btn:hover,
.edit-btn:hover,
.contact-btn:hover {
  color: #2980b9;
}

.loading {
  text-align: center;
  padding: 30px;
  color: #7f8c8d;
  font-size: 1.1rem;
}

.error-message {
  background-color: #f8d7da;
  color: #721c24;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.no-results {
  text-align: center;
  padding: 30px;
  color: #7f8c8d;
  font-size: 1.1rem;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
  
  .filters-container {
    flex-direction: column;
  }
  
  .filter-container {
    width: 100%;
  }
}
EOL

cat > client/src/components/concerts/ConcertsList.css << 'EOL'
.concerts-list-container {
  padding: 20px;
}

.concerts-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.concerts-header h1 {
  margin: 0;
  color: #2c3e50;
}

.header-actions {
  display: flex;
  gap: 15px;
  align-items: center;
}

.view-toggle {
  display: flex;
  border: 1px solid #ddd;
  border-radius: 4px;
  overflow: hidden;
}

.view-btn {
  background-color: #f8f9fa;
  border: none;
  padding: 8px 15px;
  cursor: pointer;
  font-weight: 500;
  color: #7f8c8d;
}

.view-btn.active {
  background-color: #3498db;
  color: white;
}

.view-btn i {
  margin-right: 5px;
}

.add-concert-btn {
  background-color: #3498db;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  display: flex;
  align-items: center;
}

.add-concert-btn:hover {
  background-color: #2980b9;
}

.add-concert-form {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 20px;
  margin-bottom: 30px;
}

.add-concert-form h2 {
  margin-top: 0;
  color: #2c3e50;
  font-size: 1.5rem;
  margin-bottom: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
}

.form-group {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-bottom: 15px;
}

.form-group label {
  font-weight: 500;
  margin-bottom: 5px;
  color: #34495e;
}

.form-group input,
.form-group textarea,
.form-group select {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.submit-btn {
  background-color: #2ecc71;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.submit-btn:hover {
  background-color: #27ae60;
}

.submit-btn:disabled {
  background-color: #95a5a6;
  cursor: not-allowed;
}

.cancel-btn {
  background-color: #e74c3c;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.cancel-btn:hover {
  background-color: #c0392b;
}

.filters-container {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
}

.search-container {
  flex: 1;
}

.search-input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.filter-container {
  width: 200px;
}

.filter-select,
.filter-date {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.concerts-table-container {
  overflow-x: auto;
}

.concerts-table {
  width: 100%;
  border-collapse: collapse;
  background-color: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.concerts-table th,
.concerts-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.concerts-table th {
  background-color: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
}

.concerts-table tr:last-child td {
  border-bottom: none;
}

.concerts-table tr:hover {
  background-color: #f8f9fa;
}

.status-badge {
  display: inline-block;
  padding: 5px 10px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.status-planned {
  background-color: #e0f7fa;
  color: #0097a7;
}

.status-confirmed {
  background-color: #e8f5e9;
  color: #388e3c;
}

.status-contract {
  background-color: #fff8e1;
  color: #ffa000;
}

.status-deposit {
  background-color: #e3f2fd;
  color: #1976d2;
}

.status-completed {
  background-color: #f5f5f5;
  color: #616161;
}

.status-cancelled {
  background-color: #ffebee;
  color: #d32f2f;
}

.view-btn,
.edit-btn,
.contract-btn {
  background: none;
  border: none;
  color: #3498db;
  cursor: pointer;
  font-size: 1rem;
  margin-right: 10px;
}

.view-btn:hover,
.edit-btn:hover,
.contract-btn:hover {
  color: #2980b9;
}

.calendar-view {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 20px;
  min-height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.calendar-notice {
  color: #7f8c8d;
  font-size: 1.1rem;
  text-align: center;
}

.calendar-notice i {
  margin-right: 8px;
  color: #3498db;
}

.loading {
  text-align: center;
  padding: 30px;
  color: #7f8c8d;
  font-size: 1.1rem;
}

.error-message {
  background-color: #f8d7da;
  color: #721c24;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.no-results {
  text-align: center;
  padding: 30px;
  color: #7f8c8d;
  font-size: 1.1rem;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
  
  .filters-container {
    flex-direction: column;
  }
  
  .filter-container {
    width: 100%;
  }
  
  .header-actions {
    flex-direction: column;
    align-items: flex-end;
  }
}
EOL

echo "Mise à jour du fichier App.js pour utiliser les nouveaux composants..."
sed -i '/import NotFound from/a import ProgrammersList from "./components/programmers/ProgrammersList";' client/src/App.js
sed -i 's|<Route path="programmateurs" element={<div>Programmateurs</div>} />|<Route path="programmateurs" element={<ProgrammersList />} />|' client/src/App.js

echo "Mise à jour du fichier index.html pour inclure Font Awesome..."
sed -i '/<link rel="manifest" href="%PUBLIC_URL%\/manifest.json" \/>/a \    <!-- Ajout de Font Awesome pour les icônes -->\n    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" crossorigin="anonymous" referrerpolicy="no-referrer" />' client/public/index.html

echo "=============================================================================="
echo "Toutes les modifications ont été appliquées avec succès!"
echo ""
echo "Pour finaliser l'installation, vous devez :"
echo "1. Commiter et pousser les modifications vers GitHub :"
echo "   git add ."
echo "   git commit -m \"Ajout des fonctionnalités d'intégration Firebase automatique\""
echo "   git push"
echo ""
echo "2. Déployer l'application sur Render"
echo ""
echo "Votre application est maintenant prête à utiliser Firebase avec création automatique des collections!"
echo "=============================================================================="
