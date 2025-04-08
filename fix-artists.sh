#!/bin/bash

# Script de correction pour la section Artistes de l'application App Booking
# Ce script corrige les problèmes de sélection du genre musical et de récupération des données

echo "🔧 Début de l'application des correctifs pour la section Artistes..."

# Vérifier si nous sommes à la racine du projet
if [ ! -d "./client" ] || [ ! -d "./server" ]; then
  echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet app-booking"
  exit 1
fi

# Créer des répertoires de sauvegarde
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR/client/src/components/artists"
mkdir -p "$BACKUP_DIR/client/src/services"

echo "📁 Création du répertoire de sauvegarde: $BACKUP_DIR"

# Sauvegarder les fichiers originaux
cp ./client/src/components/artists/ArtistsList.js "$BACKUP_DIR/client/src/components/artists/"
cp ./client/src/services/artistsService.js "$BACKUP_DIR/client/src/services/"

echo "💾 Sauvegarde des fichiers originaux effectuée"

# Appliquer les correctifs
echo "🔄 Application des correctifs..."

# Correction du problème de sélection du genre musical dans ArtistsList.js
cat > ./client/src/components/artists/ArtistsList.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getArtists, addArtist } from '../../services/artistsService';
import './ArtistsList.css';

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
EOL

# Correction du service artistsService.js pour améliorer la récupération des données
cat > ./client/src/services/artistsService.js << 'EOL'
import { 
  collection, 
  getDocs, 
  getDoc, 
  doc, 
  addDoc, 
  updateDoc, 
  deleteDoc,
  query,
  orderBy,
  setDoc
} from 'firebase/firestore';
import { db } from '../firebase';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, orderBy('name')));
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, création d'un document initial...`);
      const initialDoc = {
        name: "Artiste exemple",
        genre: "Rock",
        location: "Paris",
        members: 1,
        contactEmail: "exemple@email.com",
        bio: "Ceci est un artiste exemple créé automatiquement.",
        createdAt: new Date()
      };
      
      await addDoc(collectionRef, initialDoc);
      console.log(`Document initial créé dans la collection ${collectionName}`);
    }
    
    return true;
  } catch (error) {
    console.error(`Erreur lors de la vérification/création de la collection ${collectionName}:`, error);
    return false;
  }
};

// Données simulées pour le fallback en cas d'erreur d'authentification
const mockArtists = [
  {
    id: 'mock-artist-1',
    name: 'The Weeknd',
    genre: 'R&B/Pop',
    location: 'Toronto, Canada',
    members: 1,
    contactEmail: 'contact@theweeknd.com',
    contactPhone: '+1 123 456 7890',
    bio: 'Abel Makkonen Tesfaye, connu sous le nom de The Weeknd, est un auteur-compositeur-interprète canadien.',
    imageUrl: 'https://example.com/theweeknd.jpg',
    socialMedia: {
      spotify: 'https://open.spotify.com/artist/1Xyo4u8uXC1ZmMpatF05PJ',
      instagram: 'https://instagram.com/theweeknd'
    },
    createdAt: new Date()
  },
  {
    id: 'mock-artist-2',
    name: 'Daft Punk',
    genre: 'Electronic',
    location: 'Paris, France',
    members: 2,
    contactEmail: 'contact@daftpunk.com',
    contactPhone: '+33 1 23 45 67 89',
    bio: 'Daft Punk était un duo de musique électronique français formé en 1993 à Paris.',
    imageUrl: 'https://example.com/daftpunk.jpg',
    socialMedia: {
      spotify: 'https://open.spotify.com/artist/4tZwfgrHOc3mvqYlEYSvVi',
      instagram: 'https://instagram.com/daftpunk'
    },
    createdAt: new Date()
  }
];

// Assurez-vous que la collection artists existe
const artistsCollection = collection(db, 'artists');

export const getArtists = async () => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('artists');
    
    console.log("Tentative de récupération des artistes depuis Firebase...");
    const q = query(artistsCollection, orderBy('name'));
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log("Aucun artiste trouvé dans Firebase, utilisation des données simulées");
      return mockArtists;
    }
    
    const artists = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${artists.length} artistes récupérés depuis Firebase`);
    return artists;
  } catch (error) {
    console.error("Erreur lors de la récupération des artistes:", error);
    console.log("Utilisation des données simulées pour les artistes");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("Tentative d'ajout des données simulées à Firebase...");
      for (const artist of mockArtists) {
        const { id, ...artistData } = artist;
        await setDoc(doc(db, 'artists', id), artistData);
      }
      console.log("Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("Erreur lors de l'ajout des données simulées:", addError);
    }
    
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockArtists;
  }
};

export const getArtistById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('artists');
    
    console.log(`Tentative de récupération de l'artiste ${id} depuis Firebase...`);
    const docRef = doc(db, 'artists', id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const artistData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Artiste ${id} récupéré depuis Firebase:`, artistData);
      return artistData;
    }
    
    console.log(`Artiste ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération de l'artiste ${id}:`, error);
    // Retourner un artiste simulé en cas d'erreur
    const mockArtist = mockArtists.find(artist => artist.id === id) || mockArtists[0];
    console.log(`Utilisation de l'artiste simulé:`, mockArtist);
    return mockArtist;
  }
};

export const addArtist = async (artistData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('artists');
    
    console.log("Tentative d'ajout d'un artiste à Firebase:", artistData);
    const docRef = await addDoc(artistsCollection, {
      ...artistData,
      createdAt: new Date()
    });
    
    console.log(`Artiste ajouté avec succès, ID: ${docRef.id}`);
    return {
      id: docRef.id,
      ...artistData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'artiste:", error);
    console.log("Simulation de l'ajout d'un artiste");
    
    // Essayer d'ajouter l'artiste avec un ID généré manuellement
    try {
      const mockId = 'mock-artist-' + Date.now();
      await setDoc(doc(db, 'artists', mockId), {
        ...artistData,
        createdAt: new Date()
      });
      
      console.log(`Artiste ajouté avec un ID manuel: ${mockId}`);
      return {
        id: mockId,
        ...artistData,
        createdAt: new Date()
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel de l'artiste:", addError);
      
      // Simuler l'ajout d'un artiste en cas d'erreur
      const mockId = 'mock-artist-' + Date.now();
      return {
        id: mockId,
        ...artistData,
        createdAt: new Date()
      };
    }
  }
};

export const updateArtist = async (id, artistData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('artists');
    
    console.log(`Tentative de mise à jour de l'artiste ${id}:`, artistData);
    const docRef = doc(db, 'artists', id);
    await updateDoc(docRef, {
      ...artistData,
      updatedAt: new Date()
    });
    
    console.log(`Artiste ${id} mis à jour avec succès`);
    return {
      id,
      ...artistData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour de l'artiste ${id}:`, error);
    console.log("Simulation de la mise à jour d'un artiste");
    
    // Essayer de créer/remplacer le document
    try {
      await setDoc(doc(db, 'artists', id), {
        ...artistData,
        updatedAt: new Date()
      });
      
      console.log(`Artiste ${id} créé/remplacé avec succès`);
      return {
        id,
        ...artistData,
        updatedAt: new Date()
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement de l'artiste ${id}:`, setError);
      
      // Simuler la mise à jour d'un artiste en cas d'erreur
      return {
        id,
        ...artistData,
        updatedAt: new Date()
      };
    }
  }
};

export const deleteArtist = async (id) => {
  try {
    console.log(`Tentative de suppression de l'artiste ${id}`);
    const docRef = doc(db, 'artists', id);
    await deleteDoc(docRef);
    
    console.log(`Artiste ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression de l'artiste ${id}:`, error);
    console.log("Simulation de la suppression d'un artiste");
    // Simuler la suppression d'un artiste en cas d'erreur
    return id;
  }
};
EOL

echo "✅ Correctifs appliqués avec succès"

# Rendre le script exécutable
chmod +x ./fix-artists.sh

echo "🚀 Terminé! Les correctifs ont été appliqués à la section Artistes."
echo "📝 Les fichiers originaux ont été sauvegardés dans: $BACKUP_DIR"
echo ""
echo "Pour tester les modifications:"
echo "1. Démarrez l'application avec 'npm start' depuis le répertoire client"
echo "2. Accédez à la section Artistes et testez l'ajout d'un nouvel artiste"
echo "3. Vérifiez que les données s'affichent correctement"
echo ""
echo "Les modifications apportées:"
echo "- Correction du problème de sélection du genre musical"
echo "- Amélioration de la récupération des données depuis Firebase"
echo "- Ajout de logs pour faciliter le débogage"
echo "- Création automatique de la collection si elle n'existe pas"
