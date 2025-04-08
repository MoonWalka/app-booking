#!/bin/bash

# Script de correction pour les fonctionnalités d'ajout de concerts, programmateurs et affichage dynamique du dashboard
# Ce script corrige les problèmes d'ajout et d'affichage dans l'application App Booking

echo "🔧 Début de l'application des correctifs pour les fonctionnalités d'ajout et d'affichage..."

# Vérifier si nous sommes à la racine du projet
if [ ! -d "./client" ] || [ ! -d "./server" ]; then
  echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet app-booking"
  exit 1
fi

# Créer des répertoires de sauvegarde
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR/client/src/components/concerts"
mkdir -p "$BACKUP_DIR/client/src/components/programmers"
mkdir -p "$BACKUP_DIR/client/src/components/dashboard"

echo "📁 Création du répertoire de sauvegarde: $BACKUP_DIR"

# Sauvegarder les fichiers originaux
cp ./client/src/components/concerts/ConcertsList.js "$BACKUP_DIR/client/src/components/concerts/"
cp ./client/src/components/programmers/ProgrammersList.jsx "$BACKUP_DIR/client/src/components/programmers/"
cp ./client/src/components/dashboard/Dashboard.js "$BACKUP_DIR/client/src/components/dashboard/"

echo "💾 Sauvegarde des fichiers originaux effectuée"

# Créer les fichiers CSS s'ils n'existent pas
if [ ! -f "./client/src/components/concerts/ConcertsList.css" ]; then
  echo "/* Styles pour la liste des concerts */
.concerts-list-container {
  padding: 20px;
}

.concerts-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.add-concert-btn {
  display: inline-block;
  padding: 8px 16px;
  background-color: #28a745;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-weight: 500;
  border: none;
  cursor: pointer;
}

.add-concert-btn:hover {
  background-color: #218838;
}

.add-concert-form-container {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 20px;
  margin-bottom: 30px;
}

.add-concert-form {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.form-group {
  flex: 1 0 calc(50% - 15px);
  margin-bottom: 15px;
}

.form-group.full-width {
  flex: 1 0 100%;
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

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
  width: 100%;
}

.cancel-btn {
  padding: 8px 16px;
  background-color: #6c757d;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.cancel-btn:hover {
  background-color: #5a6268;
}

.submit-btn {
  padding: 8px 16px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.submit-btn:hover {
  background-color: #0069d9;
}

.submit-btn:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
}

.concerts-table-container {
  margin-top: 20px;
  overflow-x: auto;
}

.concerts-table {
  width: 100%;
  border-collapse: collapse;
}

.concerts-table th,
.concerts-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.concerts-table th {
  background-color: #f8f9fa;
  font-weight: 600;
}

.concerts-table tr:hover {
  background-color: #f5f5f5;
}

.view-details-btn {
  display: inline-block;
  padding: 6px 12px;
  background-color: #007bff;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-size: 14px;
}

.view-details-btn:hover {
  background-color: #0069d9;
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

.no-results {
  text-align: center;
  padding: 30px;
  color: #6c757d;
  font-style: italic;
}" > ./client/src/components/concerts/ConcertsList.css
  echo "✅ Fichier ConcertsList.css créé"
fi

if [ ! -f "./client/src/components/programmers/ProgrammersList.css" ]; then
  echo "/* Styles pour la liste des programmateurs */
.programmers-list-container {
  padding: 20px;
}

.programmers-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.add-programmer-btn {
  display: inline-block;
  padding: 8px 16px;
  background-color: #28a745;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-weight: 500;
  border: none;
  cursor: pointer;
}

.add-programmer-btn:hover {
  background-color: #218838;
}

.add-programmer-form-container {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 20px;
  margin-bottom: 30px;
}

.add-programmer-form {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.form-group {
  flex: 1 0 calc(50% - 15px);
  margin-bottom: 15px;
}

.form-group.full-width {
  flex: 1 0 100%;
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

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
  width: 100%;
}

.cancel-btn {
  padding: 8px 16px;
  background-color: #6c757d;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.cancel-btn:hover {
  background-color: #5a6268;
}

.submit-btn {
  padding: 8px 16px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.submit-btn:hover {
  background-color: #0069d9;
}

.submit-btn:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
}

.programmers-table-container {
  margin-top: 20px;
  overflow-x: auto;
}

.programmers-table {
  width: 100%;
  border-collapse: collapse;
}

.programmers-table th,
.programmers-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.programmers-table th {
  background-color: #f8f9fa;
  font-weight: 600;
}

.programmers-table tr:hover {
  background-color: #f5f5f5;
}

.view-details-btn {
  display: inline-block;
  padding: 6px 12px;
  background-color: #007bff;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-size: 14px;
}

.view-details-btn:hover {
  background-color: #0069d9;
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

.no-results {
  text-align: center;
  padding: 30px;
  color: #6c757d;
  font-style: italic;
}" > ./client/src/components/programmers/ProgrammersList.css
  echo "✅ Fichier ProgrammersList.css créé"
fi

# Appliquer les correctifs
echo "🔄 Application des correctifs..."

# 1. Correction du problème d'ajout de concerts
cat > ./client/src/components/concerts/ConcertsList.js << 'EOL'
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

# 2. Correction du problème d'ajout de programmateurs
cat > ./client/src/components/programmers/ProgrammersList.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getProgrammers, addProgrammer } from '../../services/programmersService';
import './ProgrammersList.css';

const ProgrammersList = () => {
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  
  // État pour le formulaire d'ajout de programmateur
  const [newProgrammer, setNewProgrammer] = useState({
    name: '',
    structure: '',
    email: '',
    phone: '',
    city: '',
    region: '',
    website: '',
    notes: ''
  });
  
  // Régions françaises pour le formulaire
  const regions = [
    'Auvergne-Rhône-Alpes',
    'Bourgogne-Franche-Comté',
    'Bretagne',
    'Centre-Val de Loire',
    'Corse',
    'Grand Est',
    'Hauts-de-France',
    'Île-de-France',
    'Normandie',
    'Nouvelle-Aquitaine',
    'Occitanie',
    'Pays de la Loire',
    'Provence-Alpes-Côte d\'Azur',
    'Guadeloupe',
    'Martinique',
    'Guyane',
    'La Réunion',
    'Mayotte',
    'Autre'
  ];

  useEffect(() => {
    const fetchProgrammers = async () => {
      try {
        setLoading(true);
        console.log("Tentative de récupération des programmateurs via Firebase...");
        const data = await getProgrammers();
        console.log("Programmateurs récupérés:", data);
        setProgrammers(data);
        setLoading(false);
      } catch (err) {
        console.error("Erreur dans le composant lors de la récupération des programmateurs:", err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchProgrammers();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewProgrammer({
      ...newProgrammer,
      [name]: value
    });
    
    // Log pour le débogage
    console.log(`Champ ${name} mis à jour avec la valeur: ${value}`);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      console.log("Données du programmateur à ajouter:", newProgrammer);
      
      await addProgrammer(newProgrammer);
      
      // Réinitialiser le formulaire
      setNewProgrammer({
        name: '',
        structure: '',
        email: '',
        phone: '',
        city: '',
        region: '',
        website: '',
        notes: ''
      });
      
      // Masquer le formulaire
      setShowForm(false);
      
      // Rafraîchir la liste des programmateurs
      const updatedProgrammers = await getProgrammers();
      setProgrammers(updatedProgrammers);
      
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de l'ajout du programmateur:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  if (loading && programmers.length === 0) return <div className="loading">Chargement des programmateurs...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  return (
    <div className="programmers-list-container">
      <div className="programmers-header">
        <h2>Liste des Programmateurs</h2>
        <button 
          className="add-programmer-btn"
          onClick={() => setShowForm(!showForm)}
        >
          {showForm ? 'Annuler' : 'Ajouter un programmateur'}
        </button>
      </div>
      
      {showForm && (
        <div className="add-programmer-form-container">
          <h3>Ajouter un nouveau programmateur</h3>
          <form onSubmit={handleSubmit} className="add-programmer-form">
            <div className="form-group">
              <label htmlFor="name">Nom du programmateur *</label>
              <input
                type="text"
                id="name"
                name="name"
                value={newProgrammer.name}
                onChange={handleInputChange}
                required
                placeholder="Nom du programmateur"
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
                placeholder="Nom de la salle, festival, association..."
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="email">Email *</label>
              <input
                type="email"
                id="email"
                name="email"
                value={newProgrammer.email}
                onChange={handleInputChange}
                required
                placeholder="email@exemple.com"
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
                placeholder="06 12 34 56 78"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="city">Ville *</label>
              <input
                type="text"
                id="city"
                name="city"
                value={newProgrammer.city}
                onChange={handleInputChange}
                required
                placeholder="Ville"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="region">Région</label>
              <select
                id="region"
                name="region"
                value={newProgrammer.region}
                onChange={handleInputChange}
              >
                <option value="">Sélectionner une région</option>
                {regions.map(region => (
                  <option key={region} value={region}>{region}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group">
              <label htmlFor="website">Site web</label>
              <input
                type="url"
                id="website"
                name="website"
                value={newProgrammer.website}
                onChange={handleInputChange}
                placeholder="https://www.exemple.com"
              />
            </div>
            
            <div className="form-group full-width">
              <label htmlFor="notes">Notes</label>
              <textarea
                id="notes"
                name="notes"
                value={newProgrammer.notes}
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
                {loading ? 'Ajout en cours...' : 'Ajouter le programmateur'}
              </button>
            </div>
          </form>
        </div>
      )}
      
      {programmers.length === 0 ? (
        <p className="no-results">Aucun programmateur trouvé.</p>
      ) : (
        <div className="programmers-table-container">
          <table className="programmers-table">
            <thead>
              <tr>
                <th>Nom</th>
                <th>Structure</th>
                <th>Ville</th>
                <th>Email</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {programmers.map((programmer) => (
                <tr key={programmer.id}>
                  <td>{programmer.name || 'Non spécifié'}</td>
                  <td>{programmer.structure || 'Non spécifié'}</td>
                  <td>{programmer.city || 'Non spécifié'}</td>
                  <td>{programmer.email || 'Non spécifié'}</td>
                  <td>
                    <Link to={`/programmateurs/${programmer.id}`} className="view-details-btn">
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

export default ProgrammersList;
EOL

# 3. Correction de l'affichage dynamique des concerts sur le dashboard
cat > ./client/src/components/dashboard/Dashboard.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts } from '../../services/concertsService';
import './Dashboard.css';

const Dashboard = () => {
  const [loading, setLoading] = useState(true);
  const [dashboardData, setDashboardData] = useState({
    upcomingConcerts: [],
    unpaidInvoices: [],
    followupBookings: [],
    missingContracts: []
  });
  const [view, setView] = useState('list'); // 'list' ou 'calendar'

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        // Récupérer les concerts depuis Firebase
        console.log("Tentative de récupération des concerts pour le dashboard...");
        const allConcerts = await getConcerts();
        console.log("Concerts récupérés pour le dashboard:", allConcerts);
        
        // Filtrer les concerts à venir (30 prochains jours)
        const today = new Date();
        const thirtyDaysLater = new Date();
        thirtyDaysLater.setDate(today.getDate() + 30);
        
        const upcomingConcerts = allConcerts
          .filter(concert => {
            if (!concert.date) return false;
            const concertDate = new Date(concert.date);
            return concertDate >= today && concertDate <= thirtyDaysLater;
          })
          .sort((a, b) => new Date(a.date) - new Date(b.date));
        
        console.log("Concerts à venir filtrés:", upcomingConcerts);

        // Simuler des données pour les autres sections du dashboard
        const mockData = {
          upcomingConcerts: upcomingConcerts, // Utiliser les données réelles de Firebase
          unpaidInvoices: [
            {
              id: '1',
              concert: { artist: { name: 'Les Harmonies Urbaines' } },
              type: 'balance',
              dueDate: '2025-04-30',
              amount: 1500
            },
            {
              id: '2',
              concert: { artist: { name: 'Échos Poétiques' } },
              type: 'deposit',
              dueDate: '2025-04-15',
              amount: 800
            },
            {
              id: '3',
              concert: { artist: { name: 'Rythmes Solaires' } },
              type: 'balance',
              dueDate: '2025-05-10',
              amount: 1200
            },
            {
              id: '4',
              concert: { artist: { name: 'Jazz Fusion Quartet' } },
              type: 'deposit',
              dueDate: '2025-04-20',
              amount: 600
            },
            {
              id: '5',
              concert: { artist: { name: 'Électro Symphonie' } },
              type: 'balance',
              dueDate: '2025-05-05',
              amount: 2000
            }
          ],
          followupBookings: [
            {
              id: '1',
              artist: { name: 'Mélodies Nocturnes' },
              venue: 'L\'Olympia',
              lastContact: '2025-03-15',
              status: 'en_attente'
            },
            {
              id: '2',
              artist: { name: 'Voix Cristallines' },
              venue: 'Zénith',
              lastContact: '2025-03-20',
              status: 'négociation'
            },
            {
              id: '3',
              artist: { name: 'Percussions Urbaines' },
              venue: 'La Cigale',
              lastContact: '2025-03-10',
              status: 'proposition_envoyée'
            },
            {
              id: '4',
              artist: { name: 'Cordes Sensibles' },
              venue: 'Bataclan',
              lastContact: '2025-03-25',
              status: 'relance_nécessaire'
            },
            {
              id: '5',
              artist: { name: 'Vents d\'Est' },
              venue: 'Théâtre de la Ville',
              lastContact: '2025-03-18',
              status: 'en_attente'
            },
            {
              id: '6',
              artist: { name: 'Quatuor Lumineux' },
              venue: 'Philharmonie',
              lastContact: '2025-03-22',
              status: 'négociation'
            },
            {
              id: '7',
              artist: { name: 'Trio Jazz' },
              venue: 'New Morning',
              lastContact: '2025-03-12',
              status: 'proposition_envoyée'
            },
            {
              id: '8',
              artist: { name: 'Électro Fusion' },
              venue: 'Rex Club',
              lastContact: '2025-03-28',
              status: 'relance_nécessaire'
            }
          ],
          missingContracts: [
            {
              id: '1',
              artist: { name: 'Électro Symphonie' },
              venue: 'Palais des Congrès',
              date: '2025-06-10',
              time: '20:00'
            },
            {
              id: '2',
              artist: { name: 'Jazz Fusion Quartet' },
              venue: 'Duc des Lombards',
              date: '2025-06-15',
              time: '21:30'
            },
            {
              id: '3',
              artist: { name: 'Voix Cristallines' },
              venue: 'Théâtre du Châtelet',
              date: '2025-06-20',
              time: '19:00'
            }
          ]
        };

        setDashboardData(mockData);
        setLoading(false);
      } catch (error) {
        console.error('Erreur de chargement des données du tableau de bord', error);
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const formatPrice = (price) => {
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(price);
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR');
  };

  if (loading) {
    return <div>Chargement...</div>;
  }

  return (
    <div className="dashboard-container">
      <h1 className="dashboard-title">Tableau de bord</h1>

      <div className="dashboard-view-toggle">
        <button 
          className={`view-toggle-btn ${view === 'list' ? 'active' : ''}`}
          onClick={() => setView('list')}
        >
          Vue Liste
        </button>
        <button 
          className={`view-toggle-btn ${view === 'calendar' ? 'active' : ''}`}
          onClick={() => setView('calendar')}
        >
          Vue Calendrier
        </button>
      </div>

      <div className="dashboard-stats">
        <div className="stat-card">
          <div className="stat-icon concerts-icon">
            <i className="fas fa-calendar-alt"></i>
          </div>
          <div className="stat-content">
            <h3>Concerts à venir</h3>
            <p className="stat-number">{dashboardData.upcomingConcerts.length}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon invoices-icon">
            <i className="fas fa-file-invoice-dollar"></i>
          </div>
          <div className="stat-content">
            <h3>Factures impayées</h3>
            <p className="stat-number">{dashboardData.unpaidInvoices.length}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon bookings-icon">
            <i className="fas fa-exclamation-triangle"></i>
          </div>
          <div className="stat-content">
            <h3>Réservations en attente</h3>
            <p className="stat-number">{dashboardData.followupBookings.length}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon contracts-icon">
            <i className="fas fa-file-contract"></i>
          </div>
          <div className="stat-content">
            <h3>Contrats manquants</h3>
            <p className="stat-number">{dashboardData.missingContracts.length}</p>
          </div>
        </div>
      </div>

      {view === 'calendar' ? (
        <div className="dashboard-calendar">
          <p>Vue calendrier à implémenter</p>
        </div>
      ) : (
        <div className="dashboard-lists">
          {/* Concerts à venir */}
          <div className="dashboard-section">
            <div className="section-card">
              <div className="section-header">
                <h2>
                  <i className="fas fa-calendar-alt"></i>
                  Concerts à venir (30 prochains jours)
                </h2>
                <div className="section-content">
                  {dashboardData.upcomingConcerts.length === 0 ? (
                    <p className="empty-message">Aucun concert à venir</p>
                  ) : (
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Date</th>
                          <th>Artiste</th>
                          <th>Lieu</th>
                          <th>Ville</th>
                          <th>Programmateur</th>
                          <th>Statut</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {dashboardData.upcomingConcerts.map(concert => (
                          <tr key={concert.id}>
                            <td>{formatDate(concert.date)} | {concert.time}</td>
                            <td>{concert.artist.name}</td>
                            <td>{concert.venue}</td>
                            <td>{concert.city}</td>
                            <td>{concert.programmer.name}</td>
                            <td>
                              <span className={`status-badge status-${concert.status}`}>
                                {concert.status}
                              </span>
                            </td>
                            <td className="actions-cell">
                              <Link to={`/concerts/${concert.id}`} className="action-btn view-btn">
                                <i className="fas fa-eye"></i>
                              </Link>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
                <div className="section-footer">
                  <Link to="/concerts" className="add-btn">
                    <i className="fas fa-plus"></i> Gérer les concerts
                  </Link>
                </div>
              </div>
            </div>
          </div>

          {/* Factures impayées */}
          <div className="dashboard-section">
            <div className="section-card">
              <div className="section-header">
                <h2>
                  <i className="fas fa-file-invoice-dollar"></i>
                  Factures impayées
                </h2>
                <div className="section-content">
                  {dashboardData.unpaidInvoices.length === 0 ? (
                    <p className="empty-message">Aucune facture impayée</p>
                  ) : (
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Artiste</th>
                          <th>Type</th>
                          <th>Date d'échéance</th>
                          <th>Montant</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {dashboardData.unpaidInvoices.map(invoice => (
                          <tr key={invoice.id}>
                            <td>{invoice.concert.artist.name}</td>
                            <td>{invoice.type === 'deposit' ? 'Acompte' : 'Solde'}</td>
                            <td>{formatDate(invoice.dueDate)}</td>
                            <td>{formatPrice(invoice.amount)}</td>
                            <td className="actions-cell">
                              <button className="action-btn edit-btn">
                                <i className="fas fa-edit"></i>
                              </button>
                              <button className="action-btn view-btn">
                                <i className="fas fa-eye"></i>
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Réservations nécessitant un suivi */}
          <div className="dashboard-section">
            <div className="section-card">
              <div className="section-header">
                <h2>
                  <i className="fas fa-exclamation-triangle"></i>
                  Réservations en attente
                </h2>
                <div className="section-content">
                  {dashboardData.followupBookings.length === 0 ? (
                    <p className="empty-message">Aucune réservation en attente</p>
                  ) : (
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Artiste</th>
                          <th>Lieu</th>
                          <th>Dernier contact</th>
                          <th>Statut</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {dashboardData.followupBookings.map(booking => (
                          <tr key={booking.id}>
                            <td>{booking.artist.name}</td>
                            <td>{booking.venue}</td>
                            <td>{formatDate(booking.lastContact)}</td>
                            <td>
                              <span className={`status-badge status-${booking.status}`}>
                                {booking.status.charAt(0).toUpperCase() + booking.status.slice(1).replace('_', ' ')}
                              </span>
                            </td>
                            <td className="actions-cell">
                              <button className="action-btn edit-btn">
                                <i className="fas fa-edit"></i>
                              </button>
                              <button className="action-btn view-btn">
                                <i className="fas fa-eye"></i>
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Contrats manquants */}
          <div className="dashboard-section">
            <div className="section-card">
              <div className="section-header">
                <h2>
                  <i className="fas fa-file-contract"></i>
                  Contrats manquants
                </h2>
                <div className="section-content">
                  {dashboardData.missingContracts.length === 0 ? (
                    <p className="empty-message">Aucun contrat manquant</p>
                  ) : (
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Artiste</th>
                          <th>Lieu</th>
                          <th>Date</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {dashboardData.missingContracts.map(contract => (
                          <tr key={contract.id}>
                            <td>{contract.artist.name}</td>
                            <td>{contract.venue}</td>
                            <td>{formatDate(contract.date)} | {contract.time}</td>
                            <td className="actions-cell">
                              <button className="action-btn edit-btn">
                                <i className="fas fa-edit"></i>
                              </button>
                              <button className="action-btn view-btn">
                                <i className="fas fa-eye"></i>
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Dashboard;
EOL

echo "✅ Correctifs appliqués avec succès"

echo "🚀 Terminé! Les correctifs ont été appliqués aux fonctionnalités d'ajout et d'affichage."
echo "📝 Les fichiers originaux ont été sauvegardés dans: $BACKUP_DIR"
echo ""
echo "Les modifications apportées:"
echo "1. Ajout de concerts:"
echo "   - Intégration d'un formulaire d'ajout directement dans la liste des concerts"
echo "   - Sélection des artistes et programmateurs existants dans des menus déroulants"
echo "   - Validation des champs obligatoires"
echo "   - Gestion des erreurs et des données manquantes"
echo ""
echo "2. Ajout de programmateurs:"
echo "   - Intégration d'un formulaire d'ajout directement dans la liste des programmateurs"
echo "   - Validation des champs obligatoires"
echo "   - Gestion des erreurs et des données manquantes"
echo ""
echo "3. Affichage dynamique des concerts sur le dashboard:"
echo "   - Récupération des concerts depuis Firebase"
echo "   - Filtrage des concerts des 30 prochains jours"
echo "   - Tri par date"
echo "   - Affichage des données réelles au lieu des données statiques"
echo ""
echo "Pour tester les modifications:"
echo "1. Démarrez l'application avec 'npm start' depuis le répertoire client"
echo "2. Accédez aux sections Concerts et Programmateurs pour ajouter des données"
echo "3. Vérifiez que les concerts ajoutés apparaissent sur le dashboard"
echo ""
echo "Si vous rencontrez des problèmes, consultez les logs de la console du navigateur"
echo "pour obtenir des informations de débogage détaillées."
