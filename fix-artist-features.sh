#!/bin/bash

# Script de correction pour les fonctionnalités liées aux artistes dans l'application App Booking
# Ce script corrige les problèmes suivants :
# 1. Page de modification d'artiste non fonctionnelle
# 2. Affichage des dates de concerts reliées à un artiste

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
  echo -e "${BLUE}$1${NC}"
}

print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}"
}

print_warning() {
  echo -e "${YELLOW}$1${NC}"
}

# Vérifier si nous sommes dans le répertoire du projet
if [ ! -d "./client" ]; then
  print_error "Erreur: Ce script doit être exécuté depuis la racine du projet app-booking"
  exit 1
fi

# Créer un répertoire de sauvegarde avec horodatage
BACKUP_DIR="./backups/artists_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR/client/src/components/artists"
mkdir -p "$BACKUP_DIR/client/src/App"
print_message "📁 Création du répertoire de sauvegarde: $BACKUP_DIR"

# Sauvegarder les fichiers originaux
if [ -f "./client/src/components/artists/ArtistDetail.js" ]; then
  cp "./client/src/components/artists/ArtistDetail.js" "$BACKUP_DIR/client/src/components/artists/"
fi

if [ -f "./client/src/App.js" ]; then
  cp "./client/src/App.js" "$BACKUP_DIR/client/src/App/"
fi

print_success "💾 Sauvegarde des fichiers originaux effectuée"

# Appliquer les correctifs
print_message "🔄 Application des correctifs..."

# 1. Créer le composant ArtistEdit.js pour la modification d'artiste
cat > "./client/src/components/artists/ArtistEdit.js" << 'EOL'
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
EOL

# 2. Améliorer l'affichage des concerts liés à un artiste
cat > "./client/src/components/artists/ArtistDetail.js" << 'EOL'
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
EOL

# 3. Ajouter des styles CSS pour les tableaux de concerts
cat >> "./client/src/components/artists/ArtistDetail.css" << 'EOL'

/* Styles pour le tableau des concerts */
.concerts-table-container {
  overflow-x: auto;
  margin-bottom: 20px;
}

.concerts-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}

.concerts-table th,
.concerts-table td {
  padding: 10px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.concerts-table th {
  background-color: #f5f5f5;
  font-weight: 600;
  color: #444;
}

.concerts-table tr:hover {
  background-color: #f9f9f9;
}

.concert-row td {
  vertical-align: middle;
}

/* Styles pour les badges de statut */
.status-badge {
  display: inline-block;
  padding: 5px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.status-en-attente {
  background-color: #e3f2fd;
  color: #1565c0;
}

.status-confirme {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.status-contrat-envoye {
  background-color: #fff8e1;
  color: #f57f17;
}

.status-contrat-signe {
  background-color: #e0f7fa;
  color: #00838f;
}

.status-acompte-recu {
  background-color: #e8eaf6;
  color: #3949ab;
}

.status-solde {
  background-color: #e0f2f1;
  color: #00796b;
}

.status-annule {
  background-color: #ffebee;
  color: #c62828;
}

.status-non-specifie {
  background-color: #f5f5f5;
  color: #757575;
}

/* Styles pour le formulaire d'édition d'artiste */
.artist-edit-container {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.artist-edit-container h2 {
  margin-bottom: 20px;
  color: #333;
  border-bottom: 1px solid #ddd;
  padding-bottom: 10px;
}

.edit-form {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 20px;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 16px;
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.cancel-btn, .save-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.cancel-btn {
  background-color: #6c757d;
  color: white;
}

.cancel-btn:hover {
  background-color: #5a6268;
}

.save-btn {
  background-color: #28a745;
  color: white;
}

.save-btn:hover {
  background-color: #218838;
}

.save-btn:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .concerts-table th,
  .concerts-table td {
    padding: 8px 5px;
    font-size: 12px;
  }
  
  .status-badge {
    padding: 3px 6px;
    font-size: 10px;
  }
  
  .view-concert-btn {
    padding: 3px 6px;
    font-size: 10px;
  }
}
EOL

# 4. Mettre à jour App.js pour ajouter la route de modification d'artiste
# D'abord, lire le fichier App.js existant
APP_JS=$(cat "./client/src/App.js")

# Vérifier si la route pour la modification d'artiste existe déjà
if ! grep -q "/artistes/modifier/:id" "./client/src/App.js"; then
  # Ajouter l'import pour ArtistEdit
  if ! grep -q "import ArtistEdit from" "./client/src/App.js"; then
    # Trouver la dernière ligne d'import et ajouter l'import après
    LAST_IMPORT=$(grep -n "import.*from" "./client/src/App.js" | tail -1 | cut -d: -f1)
    sed -i "${LAST_IMPORT}a import ArtistEdit from './components/artists/ArtistEdit';" "./client/src/App.js"
  fi
  
  # Ajouter la route pour la modification d'artiste
  # Trouver la route pour les détails d'artiste et ajouter la route de modification après
  ARTIST_DETAIL_ROUTE=$(grep -n "<Route path=\"/artistes/:id\"" "./client/src/App.js" | cut -d: -f1)
  if [ -n "$ARTIST_DETAIL_ROUTE" ]; then
    sed -i "${ARTIST_DETAIL_ROUTE}a \              <Route path=\"/artistes/modifier/:id\" element={<ArtistEdit />} />" "./client/src/App.js"
  else
    print_warning "⚠️ Route pour les détails d'artiste non trouvée dans App.js. Vérifiez manuellement les routes."
  fi
else
  print_message "✅ Route pour la modification d'artiste déjà présente dans App.js"
fi

print_success "✅ Correctifs appliqués avec succès"

# Résumé des modifications
print_message "🚀 Terminé! Les correctifs ont été appliqués aux fonctionnalités liées aux artistes."
print_message "📝 Les fichiers originaux ont été sauvegardés dans: $BACKUP_DIR"

cat << 'EOL'
Les modifications apportées:

1. Fonctionnalité de modification d'artiste:
   - Création du composant ArtistEdit.js pour éditer les informations d'un artiste
   - Ajout de la route "/artistes/modifier/:id" dans App.js
   - Styles CSS pour le formulaire d'édition

2. Affichage des concerts liés à un artiste:
   - Amélioration de l'affichage des concerts dans ArtistDetail.js
   - Remplacement de la liste par un tableau plus structuré
   - Ajout d'une fonction formatStatus pour gérer correctement les différents statuts
   - Styles CSS pour le tableau des concerts et les badges de statut

Pour tester les modifications:
1. Démarrez l'application avec 'npm start' depuis le répertoire client
2. Accédez à la fiche d'un artiste et cliquez sur "Modifier"
3. Vérifiez que vous pouvez modifier les informations et les enregistrer
4. Vérifiez que les concerts liés à l'artiste s'affichent correctement dans un tableau

Si vous rencontrez des problèmes, consultez les logs de la console du navigateur
pour obtenir des informations de débogage détaillées.
EOL

exit 0
