#!/bin/bash

# Script de correction pour les fonctionnalités de l'application App Booking
# Ce script corrige les problèmes suivants :
# 1. Accès à la fiche du programmateur lors du clic sur "Voir"
# 2. Menu déroulant pour le champ "heure" lors de la création d'une fiche concert
# 3. Accès à la fiche concert avec possibilité de modifier ou supprimer

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
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
print_message "📁 Création du répertoire de sauvegarde: $BACKUP_DIR"

# Sauvegarder les fichiers originaux
mkdir -p "$BACKUP_DIR/client/src/components/programmers"
mkdir -p "$BACKUP_DIR/client/src/components/concerts"

# Vérifier et sauvegarder les fichiers existants
if [ -f "./client/src/components/programmers/ProgrammerDetail.jsx" ]; then
  cp "./client/src/components/programmers/ProgrammerDetail.jsx" "$BACKUP_DIR/client/src/components/programmers/"
fi

if [ -f "./client/src/components/programmers/ProgrammerDetail.css" ]; then
  cp "./client/src/components/programmers/ProgrammerDetail.css" "$BACKUP_DIR/client/src/components/programmers/"
else
  touch "$BACKUP_DIR/client/src/components/programmers/ProgrammerDetail.css"
fi

if [ -f "./client/src/components/concerts/ConcertsList.js" ]; then
  cp "./client/src/components/concerts/ConcertsList.js" "$BACKUP_DIR/client/src/components/concerts/"
fi

if [ -f "./client/src/components/concerts/ConcertDetail.js" ]; then
  cp "./client/src/components/concerts/ConcertDetail.js" "$BACKUP_DIR/client/src/components/concerts/"
fi

if [ -f "./client/src/components/concerts/ConcertDetail.css" ]; then
  cp "./client/src/components/concerts/ConcertDetail.css" "$BACKUP_DIR/client/src/components/concerts/"
else
  touch "$BACKUP_DIR/client/src/components/concerts/ConcertDetail.css"
fi

print_success "💾 Sauvegarde des fichiers originaux effectuée"

# Appliquer les correctifs
print_message "🔄 Application des correctifs..."

# 1. Correction de la fiche programmateur
cat > "./client/src/components/programmers/ProgrammerDetail.jsx" << 'EOL'
// client/src/components/programmers/ProgrammerDetail.jsx
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getProgrammerById, deleteProgrammer, updateProgrammer } from '../../services/programmersService';
import './ProgrammerDetail.css';

const ProgrammerDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [programmer, setProgrammer] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    structure: '',
    email: '',
    phone: '',
    city: '',
    region: '',
    website: '',
    notes: ''
  });

  useEffect(() => {
    const fetchProgrammer = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération du programmateur avec l'ID: ${id}`);
        
        // Utiliser le service Firebase au lieu de fetch
        const data = await getProgrammerById(id);
        
        if (!data) {
          throw new Error('Programmateur non trouvé');
        }
        
        console.log('Programmateur récupéré:', data);
        setProgrammer(data);
        setFormData({
          name: data.name || '',
          structure: data.structure || '',
          email: data.email || '',
          phone: data.phone || '',
          city: data.city || '',
          region: data.region || '',
          website: data.website || '',
          notes: data.notes || ''
        });
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération du programmateur:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchProgrammer();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      // Utiliser le service Firebase pour mettre à jour le programmateur
      await updateProgrammer(id, formData);
      
      // Récupérer les données mises à jour
      const updatedData = await getProgrammerById(id);
      setProgrammer(updatedData);
      
      setIsEditing(false);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce programmateur ?')) {
      try {
        setLoading(true);
        
        // Utiliser le service Firebase pour supprimer le programmateur
        await deleteProgrammer(id);
        
        navigate('/programmateurs');
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    }
  };

  if (loading) return <div className="loading">Chargement des détails du programmateur...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;
  if (!programmer) return <div className="not-found">Programmateur non trouvé</div>;

  return (
    <div className="programmer-detail-container">
      <h2>Détails du programmateur</h2>
      
      {isEditing ? (
        <form onSubmit={handleSubmit} className="edit-form">
          <div className="form-group">
            <label htmlFor="name">Nom du programmateur *</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
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
              value={formData.structure}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="email">Email *</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
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
              value={formData.phone}
              onChange={handleInputChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="city">Ville *</label>
            <input
              type="text"
              id="city"
              name="city"
              value={formData.city}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="region">Région</label>
            <input
              type="text"
              id="region"
              name="region"
              value={formData.region}
              onChange={handleInputChange}
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="website">Site web</label>
            <input
              type="url"
              id="website"
              name="website"
              value={formData.website}
              onChange={handleInputChange}
              placeholder="https://www.exemple.com"
            />
          </div>
          
          <div className="form-group full-width">
            <label htmlFor="notes">Notes</label>
            <textarea
              id="notes"
              name="notes"
              value={formData.notes}
              onChange={handleInputChange}
              rows="4"
            ></textarea>
          </div>
          
          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={() => setIsEditing(false)}>
              Annuler
            </button>
            <button type="submit" className="save-btn" disabled={loading}>
              {loading ? 'Enregistrement...' : 'Enregistrer'}
            </button>
          </div>
        </form>
      ) : (
        <>
          <div className="programmer-info">
            <div className="info-row">
              <span className="info-label">Nom:</span>
              <span className="info-value">{programmer.name}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Structure:</span>
              <span className="info-value">{programmer.structure}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Email:</span>
              <span className="info-value">{programmer.email}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Téléphone:</span>
              <span className="info-value">{programmer.phone || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Ville:</span>
              <span className="info-value">{programmer.city}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Région:</span>
              <span className="info-value">{programmer.region || 'Non spécifiée'}</span>
            </div>
            
            {programmer.website && (
              <div className="info-row">
                <span className="info-label">Site web:</span>
                <span className="info-value">
                  <a href={programmer.website} target="_blank" rel="noopener noreferrer">
                    {programmer.website}
                  </a>
                </span>
              </div>
            )}
            
            <div className="info-row notes">
              <span className="info-label">Notes:</span>
              <span className="info-value">{programmer.notes || 'Aucune note'}</span>
            </div>
          </div>
          
          <div className="programmer-actions">
            <button onClick={() => setIsEditing(true)} className="edit-btn">
              Modifier
            </button>
            <button onClick={handleDelete} className="delete-btn">
              Supprimer
            </button>
            <button onClick={() => navigate('/programmateurs')} className="back-btn">
              Retour à la liste
            </button>
          </div>
        </>
      )}
    </div>
  );
};

export default ProgrammerDetail;
EOL

# 2. Ajout du CSS pour la fiche programmateur
cat > "./client/src/components/programmers/ProgrammerDetail.css" << 'EOL'
/* Styles pour la fiche détaillée du programmateur */
.programmer-detail-container {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.programmer-detail-container h2 {
  margin-bottom: 20px;
  color: #333;
  border-bottom: 1px solid #ddd;
  padding-bottom: 10px;
}

.programmer-info {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 20px;
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #eee;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-weight: 600;
  width: 120px;
  flex-shrink: 0;
}

.info-value {
  flex-grow: 1;
}

.info-value a {
  color: #007bff;
  text-decoration: none;
}

.info-value a:hover {
  text-decoration: underline;
}

.notes {
  flex-direction: column;
}

.notes .info-label {
  margin-bottom: 8px;
}

.notes .info-value {
  white-space: pre-line;
}

.programmer-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.edit-btn, .delete-btn, .back-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.edit-btn {
  background-color: #007bff;
  color: white;
}

.edit-btn:hover {
  background-color: #0069d9;
}

.delete-btn {
  background-color: #dc3545;
  color: white;
}

.delete-btn:hover {
  background-color: #c82333;
}

.back-btn {
  background-color: #6c757d;
  color: white;
}

.back-btn:hover {
  background-color: #5a6268;
}

/* Styles pour le formulaire d'édition */
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

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
  font-size: 18px;
  color: #6c757d;
}

.error-message {
  padding: 15px;
  background-color: #f8d7da;
  color: #721c24;
  border-radius: 4px;
  margin-top: 20px;
}

.not-found {
  text-align: center;
  padding: 30px;
  color: #6c757d;
  font-style: italic;
}
EOL

# 3. Correction de la liste des concerts avec menu déroulant pour l'heure
cat > "./client/src/components/concerts/ConcertsList.js" << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts, addConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import { getProgrammers } from '../../services/programmersService';
import './ConcertsList.css';

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [artists, setArtists] = useState([]);
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  
  // État pour le formulaire d'ajout de concert
  const [newConcert, setNewConcert] = useState({
    artist: { id: '', name: '' },
    programmer: { id: '', name: '', structure: '' },
    date: '',
    time: '',
    venue: '',
    city: '',
    price: '',
    status: 'En attente',
    notes: ''
  });
  
  // Statuts possibles pour un concert
  const statuses = [
    'En attente',
    'Confirmé',
    'Contrat envoyé',
    'Contrat signé',
    'Acompte reçu',
    'Soldé',
    'Annulé'
  ];
  
  // Générer les options pour les heures (00h à 23h)
  const hours = Array.from({ length: 24 }, (_, i) => 
    i < 10 ? `0${i}` : `${i}`
  );
  
  // Générer les options pour les minutes (00 à 59)
  const minutes = Array.from({ length: 60 }, (_, i) => 
    i < 10 ? `0${i}` : `${i}`
  );

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        
        // Récupérer les concerts
        console.log("Tentative de récupération des concerts via Firebase...");
        const concertsData = await getConcerts();
        console.log("Concerts récupérés:", concertsData);
        setConcerts(concertsData);
        
        // Récupérer les artistes pour le formulaire
        console.log("Tentative de récupération des artistes...");
        const artistsData = await getArtists();
        console.log("Artistes récupérés:", artistsData);
        setArtists(artistsData);
        
        // Récupérer les programmateurs pour le formulaire
        console.log("Tentative de récupération des programmateurs...");
        const programmersData = await getProgrammers();
        console.log("Programmateurs récupérés:", programmersData);
        setProgrammers(programmersData);
        
        setLoading(false);
      } catch (err) {
        console.error("Erreur dans le composant lors de la récupération des données:", err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'artist') {
      const selectedArtist = artists.find(artist => artist.id === value);
      setNewConcert({
        ...newConcert,
        artist: {
          id: selectedArtist.id,
          name: selectedArtist.name
        }
      });
    } else if (name === 'programmer') {
      const selectedProgrammer = programmers.find(programmer => programmer.id === value);
      setNewConcert({
        ...newConcert,
        programmer: {
          id: selectedProgrammer.id,
          name: selectedProgrammer.name,
          structure: selectedProgrammer.structure || ''
        }
      });
    } else if (name === 'hour' || name === 'minute') {
      // Gérer les sélections d'heure et de minute
      const currentTime = newConcert.time ? newConcert.time.split(':') : ['00', '00'];
      const hour = name === 'hour' ? value : currentTime[0];
      const minute = name === 'minute' ? value : currentTime[1];
      
      setNewConcert({
        ...newConcert,
        time: `${hour}:${minute}`
      });
    } else {
      setNewConcert({
        ...newConcert,
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
      
      // Convertir price en nombre
      const concertData = {
        ...newConcert,
        price: parseFloat(newConcert.price) || 0
      };
      
      console.log("Données du concert à ajouter:", concertData);
      
      await addConcert(concertData);
      
      // Réinitialiser le formulaire
      setNewConcert({
        artist: { id: '', name: '' },
        programmer: { id: '', name: '', structure: '' },
        date: '',
        time: '',
        venue: '',
        city: '',
        price: '',
        status: 'En attente',
        notes: ''
      });
      
      // Masquer le formulaire
      setShowForm(false);
      
      // Rafraîchir la liste des concerts
      const updatedConcerts = await getConcerts();
      setConcerts(updatedConcerts);
      
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de l'ajout du concert:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  if (loading && concerts.length === 0) return <div className="loading">Chargement des concerts...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  // Extraire l'heure et les minutes du temps actuel
  const currentTime = newConcert.time ? newConcert.time.split(':') : ['', ''];
  const currentHour = currentTime[0];
  const currentMinute = currentTime[1];

  return (
    <div className="concerts-list-container">
      <div className="concerts-header">
        <h2>Liste des Concerts</h2>
        <button 
          className="add-concert-btn"
          onClick={() => setShowForm(!showForm)}
        >
          {showForm ? 'Annuler' : 'Ajouter un concert'}
        </button>
      </div>
      
      {showForm && (
        <div className="add-concert-form-container">
          <h3>Ajouter un nouveau concert</h3>
          <form onSubmit={handleSubmit} className="add-concert-form">
            <div className="form-group">
              <label htmlFor="artist">Artiste *</label>
              <select
                id="artist"
                name="artist"
                value={newConcert.artist.id}
                onChange={handleInputChange}
                required
              >
                <option value="">Sélectionner un artiste</option>
                {artists.map(artist => (
                  <option key={artist.id} value={artist.id}>{artist.name}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group">
              <label htmlFor="programmer">Programmateur *</label>
              <select
                id="programmer"
                name="programmer"
                value={newConcert.programmer.id}
                onChange={handleInputChange}
                required
              >
                <option value="">Sélectionner un programmateur</option>
                {programmers.map(programmer => (
                  <option key={programmer.id} value={programmer.id}>
                    {programmer.name} ({programmer.structure || 'Structure non spécifiée'})
                  </option>
                ))}
              </select>
            </div>
            
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
            
            <div className="form-group time-selects">
              <label>Heure *</label>
              <div className="time-inputs">
                <select
                  id="hour"
                  name="hour"
                  value={currentHour}
                  onChange={handleInputChange}
                  required
                  aria-label="Heure"
                >
                  <option value="">Heure</option>
                  {hours.map(hour => (
                    <option key={hour} value={hour}>{hour}h</option>
                  ))}
                </select>
                
                <select
                  id="minute"
                  name="minute"
                  value={currentMinute}
                  onChange={handleInputChange}
                  required
                  aria-label="Minute"
                >
                  <option value="">Minute</option>
                  {minutes.map(minute => (
                    <option key={minute} value={minute}>{minute}</option>
                  ))}
                </select>
              </div>
            </div>
            
            <div className="form-group">
              <label htmlFor="venue">Lieu *</label>
              <input
                type="text"
                id="venue"
                name="venue"
                value={newConcert.venue}
                onChange={handleInputChange}
                required
                placeholder="Nom de la salle ou du lieu"
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
                placeholder="Ville"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="price">Prix (€)</label>
              <input
                type="number"
                id="price"
                name="price"
                value={newConcert.price}
                onChange={handleInputChange}
                min="0"
                step="0.01"
                placeholder="Prix en euros"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="status">Statut</label>
              <select
                id="status"
                name="status"
                value={newConcert.status}
                onChange={handleInputChange}
              >
                {statuses.map(status => (
                  <option key={status} value={status}>{status}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group full-width">
              <label htmlFor="notes">Notes</label>
              <textarea
                id="notes"
                name="notes"
                value={newConcert.notes}
                onChange={handleInputChange}
                rows="4"
                placeholder="Informations complémentaires"
              ></textarea>
            </div>
            
            <div className="form-actions">
              <button type="button" className="cancel-btn" onClick={() => setShowForm(false)}>
                Annuler
              </button>
              <button type="submit" className="submit-btn" disabled={loading}>
                {loading ? 'Ajout en cours...' : 'Ajouter le concert'}
              </button>
            </div>
          </form>
        </div>
      )}
      
      {concerts.length === 0 ? (
        <p className="no-results">Aucun concert trouvé.</p>
      ) : (
        <div className="concerts-table-container">
          <table className="concerts-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Heure</th>
                <th>Artiste</th>
                <th>Lieu</th>
                <th>Ville</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {concerts.map((concert) => (
                <tr key={concert.id}>
                  <td>{concert.date ? new Date(concert.date).toLocaleDateString() : 'Non spécifié'}</td>
                  <td>{concert.time || 'Non spécifié'}</td>
                  <td>{concert.artist?.name || 'Non spécifié'}</td>
                  <td>{concert.venue || 'Non spécifié'}</td>
                  <td>{concert.city || 'Non spécifié'}</td>
                  <td>{concert.status || 'Non spécifié'}</td>
                  <td>
                    <Link to={`/concerts/${concert.id}`} className="view-details-btn">
                      Voir
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default ConcertsList;
EOL

# 4. Correction de la fiche concert
cat > "./client/src/components/concerts/ConcertDetail.js" << 'EOL'
// client/src/components/concerts/ConcertDetail.js
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getConcertById, updateConcert, deleteConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import { getProgrammers } from '../../services/programmersService';
import './ConcertDetail.css';

const ConcertDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [concert, setConcert] = useState(null);
  const [artists, setArtists] = useState([]);
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    artist: { id: '', name: '' },
    programmer: { id: '', name: '', structure: '' },
    date: '',
    time: '',
    venue: '',
    city: '',
    price: '',
    status: 'En attente',
    notes: ''
  });

  // Statuts possibles pour un concert
  const statuses = [
    'En attente',
    'Confirmé',
    'Contrat envoyé',
    'Contrat signé',
    'Acompte reçu',
    'Soldé',
    'Annulé'
  ];
  
  // Générer les options pour les heures (00h à 23h)
  const hours = Array.from({ length: 24 }, (_, i) => 
    i < 10 ? `0${i}` : `${i}`
  );
  
  // Générer les options pour les minutes (00 à 59)
  const minutes = Array.from({ length: 60 }, (_, i) => 
    i < 10 ? `0${i}` : `${i}`
  );

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération du concert avec l'ID: ${id}`);
        
        // Utiliser le service Firebase au lieu de fetch
        const concertData = await getConcertById(id);
        
        if (!concertData) {
          throw new Error('Concert non trouvé');
        }
        
        console.log('Concert récupéré:', concertData);
        setConcert(concertData);
        
        // Initialiser le formulaire avec les données du concert
        setFormData({
          artist: concertData.artist || { id: '', name: '' },
          programmer: concertData.programmer || { id: '', name: '', structure: '' },
          date: concertData.date || '',
          time: concertData.time || '',
          venue: concertData.venue || '',
          city: concertData.city || '',
          price: concertData.price ? concertData.price.toString() : '',
          status: concertData.status || 'En attente',
          notes: concertData.notes || ''
        });
        
        // Récupérer les artistes pour le formulaire d'édition
        console.log("Tentative de récupération des artistes...");
        const artistsData = await getArtists();
        console.log("Artistes récupérés:", artistsData);
        setArtists(artistsData);
        
        // Récupérer les programmateurs pour le formulaire d'édition
        console.log("Tentative de récupération des programmateurs...");
        const programmersData = await getProgrammers();
        console.log("Programmateurs récupérés:", programmersData);
        setProgrammers(programmersData);
        
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération du concert:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'artist') {
      const selectedArtist = artists.find(artist => artist.id === value);
      setFormData({
        ...formData,
        artist: {
          id: selectedArtist.id,
          name: selectedArtist.name
        }
      });
    } else if (name === 'programmer') {
      const selectedProgrammer = programmers.find(programmer => programmer.id === value);
      setFormData({
        ...formData,
        programmer: {
          id: selectedProgrammer.id,
          name: selectedProgrammer.name,
          structure: selectedProgrammer.structure || ''
        }
      });
    } else if (name === 'hour' || name === 'minute') {
      // Gérer les sélections d'heure et de minute
      const currentTime = formData.time ? formData.time.split(':') : ['00', '00'];
      const hour = name === 'hour' ? value : currentTime[0];
      const minute = name === 'minute' ? value : currentTime[1];
      
      setFormData({
        ...formData,
        time: `${hour}:${minute}`
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
      
      // Convertir price en nombre
      const concertData = {
        ...formData,
        price: parseFloat(formData.price) || 0
      };
      
      console.log("Données du concert à mettre à jour:", concertData);
      
      // Utiliser le service Firebase pour mettre à jour le concert
      await updateConcert(id, concertData);
      
      // Récupérer les données mises à jour
      const updatedData = await getConcertById(id);
      setConcert(updatedData);
      
      setIsEditing(false);
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de la mise à jour du concert:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce concert ?')) {
      try {
        setLoading(true);
        
        // Utiliser le service Firebase pour supprimer le concert
        await deleteConcert(id);
        
        navigate('/concerts');
      } catch (err) {
        console.error("Erreur lors de la suppression du concert:", err);
        setError(err.message);
        setLoading(false);
      }
    }
  };

  if (loading && !concert) return <div className="loading">Chargement des détails du concert...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;
  if (!concert) return <div className="not-found">Concert non trouvé</div>;

  // Extraire l'heure et les minutes du temps actuel pour le formulaire d'édition
  const currentTime = formData.time ? formData.time.split(':') : ['', ''];
  const currentHour = currentTime[0];
  const currentMinute = currentTime[1];

  return (
    <div className="concert-detail-container">
      <h2>Détails du Concert</h2>
      
      {isEditing ? (
        <form onSubmit={handleSubmit} className="edit-form">
          <div className="form-group">
            <label htmlFor="artist">Artiste *</label>
            <select
              id="artist"
              name="artist"
              value={formData.artist.id}
              onChange={handleInputChange}
              required
            >
              <option value="">Sélectionner un artiste</option>
              {artists.map(artist => (
                <option key={artist.id} value={artist.id}>{artist.name}</option>
              ))}
            </select>
          </div>
          
          <div className="form-group">
            <label htmlFor="programmer">Programmateur *</label>
            <select
              id="programmer"
              name="programmer"
              value={formData.programmer.id}
              onChange={handleInputChange}
              required
            >
              <option value="">Sélectionner un programmateur</option>
              {programmers.map(programmer => (
                <option key={programmer.id} value={programmer.id}>
                  {programmer.name} ({programmer.structure || 'Structure non spécifiée'})
                </option>
              ))}
            </select>
          </div>
          
          <div className="form-group">
            <label htmlFor="date">Date *</label>
            <input
              type="date"
              id="date"
              name="date"
              value={formData.date}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group time-selects">
            <label>Heure *</label>
            <div className="time-inputs">
              <select
                id="hour"
                name="hour"
                value={currentHour}
                onChange={handleInputChange}
                required
                aria-label="Heure"
              >
                <option value="">Heure</option>
                {hours.map(hour => (
                  <option key={hour} value={hour}>{hour}h</option>
                ))}
              </select>
              
              <select
                id="minute"
                name="minute"
                value={currentMinute}
                onChange={handleInputChange}
                required
                aria-label="Minute"
              >
                <option value="">Minute</option>
                {minutes.map(minute => (
                  <option key={minute} value={minute}>{minute}</option>
                ))}
              </select>
            </div>
          </div>
          
          <div className="form-group">
            <label htmlFor="venue">Lieu *</label>
            <input
              type="text"
              id="venue"
              name="venue"
              value={formData.venue}
              onChange={handleInputChange}
              required
              placeholder="Nom de la salle ou du lieu"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="city">Ville *</label>
            <input
              type="text"
              id="city"
              name="city"
              value={formData.city}
              onChange={handleInputChange}
              required
              placeholder="Ville"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="price">Prix (€)</label>
            <input
              type="number"
              id="price"
              name="price"
              value={formData.price}
              onChange={handleInputChange}
              min="0"
              step="0.01"
              placeholder="Prix en euros"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="status">Statut</label>
            <select
              id="status"
              name="status"
              value={formData.status}
              onChange={handleInputChange}
            >
              {statuses.map(status => (
                <option key={status} value={status}>{status}</option>
              ))}
            </select>
          </div>
          
          <div className="form-group full-width">
            <label htmlFor="notes">Notes</label>
            <textarea
              id="notes"
              name="notes"
              value={formData.notes}
              onChange={handleInputChange}
              rows="4"
              placeholder="Informations complémentaires"
            ></textarea>
          </div>
          
          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={() => setIsEditing(false)}>
              Annuler
            </button>
            <button type="submit" className="save-btn" disabled={loading}>
              {loading ? 'Enregistrement...' : 'Enregistrer'}
            </button>
          </div>
        </form>
      ) : (
        <>
          <div className="concert-info">
            <div className="info-row">
              <span className="info-label">Artiste:</span>
              <span className="info-value">{concert.artist?.name || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Programmateur:</span>
              <span className="info-value">
                {concert.programmer?.name || 'Non spécifié'}
                {concert.programmer?.structure && ` (${concert.programmer.structure})`}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Date:</span>
              <span className="info-value">
                {concert.date ? new Date(concert.date).toLocaleDateString() : 'Non spécifiée'}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Heure:</span>
              <span className="info-value">{concert.time || 'Non spécifiée'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Lieu:</span>
              <span className="info-value">{concert.venue || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Ville:</span>
              <span className="info-value">{concert.city || 'Non spécifiée'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Prix:</span>
              <span className="info-value">
                {concert.price ? `${concert.price} €` : 'Non spécifié'}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Statut:</span>
              <span className="info-value">{concert.status || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row notes">
              <span className="info-label">Notes:</span>
              <span className="info-value">{concert.notes || 'Aucune note'}</span>
            </div>
          </div>
          
          <div className="concert-actions">
            <button onClick={() => setIsEditing(true)} className="edit-btn">
              Modifier
            </button>
            <button onClick={handleDelete} className="delete-btn">
              Supprimer
            </button>
            <button onClick={() => navigate('/concerts')} className="back-btn">
              Retour à la liste
            </button>
          </div>
        </>
      )}
    </div>
  );
};

export default ConcertDetail;
EOL

# 5. Ajout du CSS pour la fiche concert
cat > "./client/src/components/concerts/ConcertDetail.css" << 'EOL'
/* Styles pour la fiche détaillée du concert */
.concert-detail-container {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.concert-detail-container h2 {
  margin-bottom: 20px;
  color: #333;
  border-bottom: 1px solid #ddd;
  padding-bottom: 10px;
}

.concert-info {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 20px;
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #eee;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-weight: 600;
  width: 120px;
  flex-shrink: 0;
}

.info-value {
  flex-grow: 1;
}

.notes {
  flex-direction: column;
}

.notes .info-label {
  margin-bottom: 8px;
}

.notes .info-value {
  white-space: pre-line;
}

.concert-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.edit-btn, .delete-btn, .back-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.edit-btn {
  background-color: #007bff;
  color: white;
}

.edit-btn:hover {
  background-color: #0069d9;
}

.delete-btn {
  background-color: #dc3545;
  color: white;
}

.delete-btn:hover {
  background-color: #c82333;
}

.back-btn {
  background-color: #6c757d;
  color: white;
}

.back-btn:hover {
  background-color: #5a6268;
}

/* Styles pour le formulaire d'édition */
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

.time-selects .time-inputs {
  display: flex;
  gap: 10px;
}

.time-selects .time-inputs select {
  flex: 1;
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

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
  font-size: 18px;
  color: #6c757d;
}

.error-message {
  padding: 15px;
  background-color: #f8d7da;
  color: #721c24;
  border-radius: 4px;
  margin-top: 20px;
}

.not-found {
  text-align: center;
  padding: 30px;
  color: #6c757d;
  font-style: italic;
}
EOL

# Ajouter des styles pour le menu déroulant de l'heure dans ConcertsList.css
if [ -f "./client/src/components/concerts/ConcertsList.css" ]; then
  # Vérifier si les styles pour time-selects existent déjà
  if ! grep -q "time-selects" "./client/src/components/concerts/ConcertsList.css"; then
    cat >> "./client/src/components/concerts/ConcertsList.css" << 'EOL'

/* Styles pour les sélecteurs d'heure */
.time-selects .time-inputs {
  display: flex;
  gap: 10px;
}

.time-selects .time-inputs select {
  flex: 1;
}
EOL
  fi
fi

print_success "✅ Correctifs appliqués avec succès"

# Résumé des modifications
print_message "🚀 Terminé! Les correctifs ont été appliqués aux fonctionnalités demandées."
print_message "📝 Les fichiers originaux ont été sauvegardés dans: $BACKUP_DIR"

cat << 'EOL'
Les modifications apportées:

1. Accès à la fiche du programmateur:
   - Utilisation directe des services Firebase au lieu des appels API REST
   - Ajout d'un formulaire d'édition pour modifier les informations
   - Ajout de la fonctionnalité de suppression
   - Styles CSS pour une présentation claire et professionnelle

2. Menu déroulant pour le champ "heure" des concerts:
   - Remplacement du champ de type "time" par deux menus déroulants (heures et minutes)
   - Heures de 00h à 23h et minutes de 00 à 59
   - Implémentation dans le formulaire d'ajout et d'édition des concerts
   - Styles CSS pour une présentation claire

3. Accès à la fiche concert:
   - Utilisation directe des services Firebase au lieu des appels API REST
   - Ajout d'un formulaire d'édition pour modifier les informations
   - Ajout de la fonctionnalité de suppression
   - Styles CSS pour une présentation claire et professionnelle

Pour tester les modifications:
1. Démarrez l'application avec 'npm start' depuis le répertoire client
2. Testez l'accès aux fiches programmateurs en cliquant sur "Voir" dans la liste
3. Testez l'ajout de concerts avec le nouveau menu déroulant pour l'heure
4. Testez l'accès aux fiches concerts en cliquant sur "Voir" dans la liste

Si vous rencontrez des problèmes, consultez les logs de la console du navigateur
pour obtenir des informations de débogage détaillées.
EOL

exit 0
