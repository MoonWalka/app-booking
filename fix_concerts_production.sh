#!/bin/bash

# Script pour corriger les problèmes d'affichage de la page Concert en production
# Ce script modifie les fichiers nécessaires pour résoudre l'erreur React #31
# qui empêche l'affichage correct du tableau de bord des concerts

echo "Début des corrections pour la page Concert en production..."

# Vérifier que nous sommes à la racine du projet
if [ ! -d "client" ]; then
  echo "❌ Erreur: Ce script doit être exécuté à la racine du projet."
  echo "Assurez-vous que vous êtes dans le répertoire principal contenant le dossier client."
  exit 1
fi

# Créer des sauvegardes des fichiers originaux
echo "📦 Création de sauvegardes des fichiers originaux..."
mkdir -p backups
cp -f client/src/components/concerts/ConcertsList.js backups/ConcertsList.js.bak
cp -f client/src/components/concerts/ConcertsDashboard.jsx backups/ConcertsDashboard.jsx.bak
echo "✅ Sauvegardes créées dans le dossier 'backups'"

# 1. Correction du composant ConcertsDashboard.jsx pour s'assurer qu'il est correctement exporté
echo "🔧 Correction du composant ConcertsDashboard.jsx..."
cat > client/src/components/concerts/ConcertsDashboard.jsx << 'EOL'
import React from 'react';
import { FaCalendarAlt, FaMusic, FaMapMarkerAlt, FaUsers, FaMoneyBillWave } from 'react-icons/fa';
import './ConcertsDashboard.css';

const ConcertsDashboard = ({ concerts, onViewConcert, onEditConcert }) => {
  // Vérifier si concerts est défini et est un tableau
  if (!concerts || !Array.isArray(concerts)) {
    console.error('ConcertsDashboard - Erreur: concerts n\'est pas un tableau valide', concerts);
    return <div className="error-message">Erreur de chargement des données</div>;
  }

  // Calculer les statistiques
  const totalConcerts = concerts.length;
  const upcomingConcerts = concerts.filter(concert => 
    concert.status === 'À venir' || concert.status === 'En cours'
  ).length;
  const completedConcerts = concerts.filter(concert => 
    concert.status === 'Terminé'
  ).length;
  const canceledConcerts = concerts.filter(concert => 
    concert.status === 'Annulé'
  ).length;
  
  // Calculer le revenu total (si le prix est disponible)
  const totalRevenue = concerts.reduce((sum, concert) => {
    const price = parseFloat(concert.price) || 0;
    return sum + price;
  }, 0);
  
  // Obtenir les villes uniques
  const uniqueCities = [...new Set(concerts.map(concert => concert.city).filter(Boolean))];
  
  // Obtenir les artistes uniques
  const uniqueArtists = [...new Set(concerts.map(concert => 
    concert.artist ? concert.artist.name : null
  ).filter(Boolean))];

  // Fonction pour formater la date
  const formatDate = (dateObj) => {
    if (!dateObj) return 'Date non spécifiée';
    
    if (dateObj instanceof Date) {
      return dateObj.toLocaleDateString();
    } else if (dateObj.seconds) {
      return new Date(dateObj.seconds * 1000).toLocaleDateString();
    } else {
      return 'Date invalide';
    }
  };

  return (
    <div className="concerts-dashboard">
      <div className="stats-container">
        <div className="stat-card">
          <div className="stat-icon">
            <FaCalendarAlt />
          </div>
          <div className="stat-content">
            <h3>Total des concerts</h3>
            <p className="stat-value">{totalConcerts}</p>
            <div className="stat-details">
              <span className="upcoming">{upcomingConcerts} à venir</span>
              <span className="completed">{completedConcerts} terminés</span>
              <span className="canceled">{canceledConcerts} annulés</span>
            </div>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaMusic />
          </div>
          <div className="stat-content">
            <h3>Artistes</h3>
            <p className="stat-value">{uniqueArtists.length}</p>
            <div className="stat-details">
              <span>Artistes différents programmés</span>
            </div>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaMapMarkerAlt />
          </div>
          <div className="stat-content">
            <h3>Villes</h3>
            <p className="stat-value">{uniqueCities.length}</p>
            <div className="stat-details">
              <span>Villes différentes</span>
            </div>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaMoneyBillWave />
          </div>
          <div className="stat-content">
            <h3>Revenus estimés</h3>
            <p className="stat-value">{totalRevenue.toFixed(2)} €</p>
            <div className="stat-details">
              <span>Basé sur les prix des billets</span>
            </div>
          </div>
        </div>
      </div>
      
      <div className="concerts-grid">
        <h2>Concerts à venir</h2>
        {concerts.filter(concert => concert.status === 'À venir' || concert.status === 'En cours').length === 0 ? (
          <p className="no-concerts">Aucun concert à venir</p>
        ) : (
          <div className="grid-container">
            {concerts
              .filter(concert => concert.status === 'À venir' || concert.status === 'En cours')
              .sort((a, b) => {
                const dateA = a.date instanceof Date ? a.date : a.date && a.date.seconds ? new Date(a.date.seconds * 1000) : new Date(0);
                const dateB = b.date instanceof Date ? b.date : b.date && b.date.seconds ? new Date(b.date.seconds * 1000) : new Date(0);
                return dateA - dateB;
              })
              .map(concert => (
                <div key={concert.id} className="concert-card">
                  <div className="concert-header">
                    <h3>{concert.artist ? concert.artist.name : 'Artiste inconnu'}</h3>
                    <span className={`status-badge ${concert.status === 'À venir' ? 'upcoming' : 'in-progress'}`}>
                      {concert.status}
                    </span>
                  </div>
                  <div className="concert-details">
                    <p><strong>Date:</strong> {formatDate(concert.date)} {concert.time || ''}</p>
                    <p><strong>Lieu:</strong> {concert.venue || 'Non spécifié'}</p>
                    <p><strong>Ville:</strong> {concert.city || 'Non spécifiée'}</p>
                    <p><strong>Prix:</strong> {concert.price ? `${concert.price} €` : 'Non spécifié'}</p>
                  </div>
                  <div className="concert-actions">
                    <button 
                      className="view-button"
                      onClick={() => onViewConcert && onViewConcert(concert)}
                    >
                      Voir
                    </button>
                    <button 
                      className="edit-button"
                      onClick={() => onEditConcert && onEditConcert(concert)}
                    >
                      Modifier
                    </button>
                  </div>
                </div>
              ))
            }
          </div>
        )}
      </div>
      
      <div className="concerts-grid">
        <h2>Concerts passés</h2>
        {concerts.filter(concert => concert.status === 'Terminé').length === 0 ? (
          <p className="no-concerts">Aucun concert passé</p>
        ) : (
          <div className="grid-container">
            {concerts
              .filter(concert => concert.status === 'Terminé')
              .sort((a, b) => {
                const dateA = a.date instanceof Date ? a.date : a.date && a.date.seconds ? new Date(a.date.seconds * 1000) : new Date(0);
                const dateB = b.date instanceof Date ? b.date : b.date && b.date.seconds ? new Date(b.date.seconds * 1000) : new Date(0);
                return dateB - dateA; // Tri décroissant pour les concerts passés
              })
              .map(concert => (
                <div key={concert.id} className="concert-card past">
                  <div className="concert-header">
                    <h3>{concert.artist ? concert.artist.name : 'Artiste inconnu'}</h3>
                    <span className="status-badge completed">
                      {concert.status}
                    </span>
                  </div>
                  <div className="concert-details">
                    <p><strong>Date:</strong> {formatDate(concert.date)} {concert.time || ''}</p>
                    <p><strong>Lieu:</strong> {concert.venue || 'Non spécifié'}</p>
                    <p><strong>Ville:</strong> {concert.city || 'Non spécifiée'}</p>
                    <p><strong>Prix:</strong> {concert.price ? `${concert.price} €` : 'Non spécifié'}</p>
                  </div>
                  <div className="concert-actions">
                    <button 
                      className="view-button"
                      onClick={() => onViewConcert && onViewConcert(concert)}
                    >
                      Voir
                    </button>
                  </div>
                </div>
              ))
            }
          </div>
        )}
      </div>
      
      {concerts.filter(concert => concert.status === 'Annulé').length > 0 && (
        <div className="concerts-grid">
          <h2>Concerts annulés</h2>
          <div className="grid-container">
            {concerts
              .filter(concert => concert.status === 'Annulé')
              .map(concert => (
                <div key={concert.id} className="concert-card canceled">
                  <div className="concert-header">
                    <h3>{concert.artist ? concert.artist.name : 'Artiste inconnu'}</h3>
                    <span className="status-badge canceled">
                      {concert.status}
                    </span>
                  </div>
                  <div className="concert-details">
                    <p><strong>Date:</strong> {formatDate(concert.date)} {concert.time || ''}</p>
                    <p><strong>Lieu:</strong> {concert.venue || 'Non spécifié'}</p>
                    <p><strong>Ville:</strong> {concert.city || 'Non spécifiée'}</p>
                  </div>
                  <div className="concert-actions">
                    <button 
                      className="view-button"
                      onClick={() => onViewConcert && onViewConcert(concert)}
                    >
                      Voir
                    </button>
                  </div>
                </div>
              ))
            }
          </div>
        </div>
      )}
    </div>
  );
};

export default ConcertsDashboard;
EOL

# 2. Correction du composant ConcertsList.js pour résoudre l'erreur React #31
echo "🔧 Correction du composant ConcertsList.js..."
cat > client/src/components/concerts/ConcertsList.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts, addConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import './ConcertsList.css';

// Import dynamique du composant ConcertsDashboard pour éviter les problèmes de chargement
const ConcertsDashboard = React.lazy(() => import('./ConcertsDashboard'));

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [artists, setArtists] = useState([]);
  const [newConcert, setNewConcert] = useState({
    artistId: '',
    date: '',
    time: '',
    venue: '',
    city: '',
    price: '',
    status: 'À venir',
    notes: ''
  });
  const [currentDate, setCurrentDate] = useState('');
  const [currentHour, setCurrentHour] = useState('');
  const [currentMinute, setCurrentMinute] = useState('');
  const [useDashboard, setUseDashboard] = useState(false); // Désactiver le tableau de bord par défaut en production
  const [error, setError] = useState(null);

  // Options pour les heures et minutes
  const hours = Array.from({ length: 24 }, (_, i) => i.toString().padStart(2, '0'));
  const minutes = ['00', '15', '30', '45'];
  const statuses = ['À venir', 'En cours', 'Terminé', 'Annulé'];

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        console.log('ConcertsList - Chargement des concerts...');
        const concertsData = await getConcerts();
        console.log(`ConcertsList - ${concertsData.length} concerts récupérés`);
        
        console.log('ConcertsList - Chargement des artistes...');
        const artistsData = await getArtists();
        console.log(`ConcertsList - ${artistsData.length} artistes récupérés`);
        
        // Enrichir les données de concerts avec les informations d'artistes
        const enrichedConcerts = concertsData.map(concert => {
          const artist = artistsData.find(a => a.id === concert.artistId);
          return {
            ...concert,
            artist: artist || { name: 'Artiste inconnu' }
          };
        });
        
        console.log('ConcertsList - Données enrichies:', enrichedConcerts);
        setConcerts(enrichedConcerts);
        setArtists(artistsData);
        setLoading(false);
      } catch (error) {
        console.error('ConcertsList - Erreur lors du chargement des données:', error);
        setError('Erreur lors du chargement des données. Veuillez réessayer.');
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'date') {
      setCurrentDate(value);
    } else if (name === 'hour') {
      setCurrentHour(value);
    } else if (name === 'minute') {
      setCurrentMinute(value);
    } else {
      setNewConcert(prev => ({
        ...prev,
        [name]: value
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      setError(null);
      
      // Construire la date et l'heure
      const dateObj = new Date(currentDate);
      const timeString = `${currentHour}:${currentMinute}`;
      
      const concertToAdd = {
        ...newConcert,
        date: dateObj,
        time: timeString
      };
      
      console.log('ConcertsList - Ajout d\'un nouveau concert:', concertToAdd);
      const addedConcert = await addConcert(concertToAdd);
      console.log('ConcertsList - Concert ajouté avec succès:', addedConcert);
      
      // Ajouter l'artiste à l'objet concert
      const artist = artists.find(a => a.id === concertToAdd.artistId);
      const enrichedConcert = {
        ...addedConcert,
        artist: artist || { name: 'Artiste inconnu' }
      };
      
      setConcerts(prev => [...prev, enrichedConcert]);
      setShowForm(false);
      setNewConcert({
        artistId: '',
        date: '',
        time: '',
        venue: '',
        city: '',
        price: '',
        status: 'À venir',
        notes: ''
      });
      setCurrentDate('');
      setCurrentHour('');
      setCurrentMinute('');
      setLoading(false);
    } catch (error) {
      console.error('ConcertsList - Erreur lors de l\'ajout du concert:', error);
      setError('Erreur lors de l\'ajout du concert. Veuillez réessayer.');
      setLoading(false);
    }
  };

  const handleViewConcert = (concert) => {
    try {
      // Cette fonction est appelée par le composant ConcertsDashboard
      console.log('ConcertsList - Redirection vers la page du concert:', concert.id);
      window.location.href = `/concerts/${concert.id}`;
    } catch (error) {
      console.error('ConcertsList - Erreur lors de la redirection:', error);
      setError('Erreur lors de la redirection. Veuillez réessayer.');
    }
  };

  const handleEditConcert = (concert) => {
    try {
      // Cette fonction est appelée par le composant ConcertsDashboard
      console.log('ConcertsList - Redirection vers la page d\'édition du concert:', concert.id);
      window.location.href = `/concerts/${concert.id}`;
    } catch (error) {
      console.error('ConcertsList - Erreur lors de la redirection:', error);
      setError('Erreur lors de la redirection. Veuillez réessayer.');
    }
  };

  // Basculer entre le tableau de bord et la vue classique
  const toggleView = () => {
    console.log('ConcertsList - Basculement de la vue:', useDashboard ? 'classique' : 'tableau de bord');
    setUseDashboard(!useDashboard);
  };

  if (loading && concerts.length === 0) {
    return <div className="loading">Chargement des concerts...</div>;
  }

  if (error) {
    return (
      <div className="error-container">
        <div className="error">{error}</div>
        <button className="refresh-button" onClick={() => window.location.reload()}>
          Rafraîchir la page
        </button>
      </div>
    );
  }

  return (
    <div className="concerts-container">
      <div className="concerts-header">
        <h1>Gestion des concerts</h1>
        <div className="header-buttons">
          <button className="toggle-view-btn" onClick={toggleView}>
            {useDashboard ? 'Vue classique' : 'Vue tableau de bord'}
          </button>
          <button className="add-concert-btn" onClick={() => setShowForm(!showForm)}>
            {showForm ? 'Annuler' : 'Ajouter un concert'}
          </button>
        </div>
      </div>
      
      {showForm && (
        <div className="add-concert-form">
          <h2>Ajouter un nouveau concert</h2>
          <form onSubmit={handleSubmit}>
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
                  <option key={artist.id} value={artist.id}>{artist.name}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group">
              <label htmlFor="date">Date *</label>
              <input
                type="date"
                id="date"
                name="date"
                value={currentDate}
                onChange={handleInputChange}
                required
              />
            </div>
            
            <div className="form-group">
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
      
      {!showForm && (
        <>
          {useDashboard ? (
            <React.Suspense fallback={<div className="loading">Chargement du tableau de bord...</div>}>
              <ConcertsDashboard 
                concerts={concerts}
                onViewConcert={handleViewConcert}
                onEditConcert={handleEditConcert}
              />
            </React.Suspense>
          ) : (
            <div className="concerts-list">
              <h2>Liste des concerts ({concerts.length})</h2>
              <table className="concerts-table">
                <thead>
                  <tr>
                    <th>Artiste</th>
                    <th>Date</th>
                    <th>Lieu</th>
                    <th>Ville</th>
                    <th>Statut</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {concerts.map(concert => (
                    <tr key={concert.id}>
                      <td>{concert.artist ? concert.artist.name : 'Artiste inconnu'}</td>
                      <td>
                        {concert.date instanceof Date 
                          ? concert.date.toLocaleDateString() 
                          : concert.date && concert.date.seconds 
                            ? new Date(concert.date.seconds * 1000).toLocaleDateString() 
                            : 'Date non spécifiée'}
                        {' '}
                        {concert.time || ''}
                      </td>
                      <td>{concert.venue || 'Non spécifié'}</td>
                      <td>{concert.city || 'Non spécifié'}</td>
                      <td>{concert.status || 'Non spécifié'}</td>
                      <td>
                        <Link to={`/concerts/${concert.id}`} className="action-link">
                          Voir
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default ConcertsList;
EOL

# 3. S'assurer que le fichier CSS existe et est correctement formaté
echo "🔧 Vérification du fichier CSS pour le tableau de bord..."
if [ ! -f "client/src/components/concerts/ConcertsDashboard.css" ]; then
  echo "Création du fichier CSS pour le tableau de bord..."
  cat > client/src/components/concerts/ConcertsDashboard.css << 'EOL'
.concerts-dashboard {
  padding: 20px;
}

.stats-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 20px;
  display: flex;
  align-items: center;
}

.stat-icon {
  font-size: 2rem;
  color: #4a6cf7;
  margin-right: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 50px;
  height: 50px;
  background-color: #eef2ff;
  border-radius: 50%;
}

.stat-content {
  flex: 1;
}

.stat-content h3 {
  margin: 0 0 5px 0;
  font-size: 1rem;
  color: #666;
}

.stat-value {
  font-size: 1.8rem;
  font-weight: bold;
  margin: 0 0 5px 0;
  color: #333;
}

.stat-details {
  font-size: 0.85rem;
  color: #777;
}

.stat-details span {
  display: inline-block;
  margin-right: 10px;
}

.upcoming {
  color: #4caf50;
}

.completed {
  color: #2196f3;
}

.canceled {
  color: #f44336;
}

.concerts-grid {
  margin-bottom: 40px;
}

.concerts-grid h2 {
  margin-bottom: 15px;
  color: #333;
  border-bottom: 1px solid #eee;
  padding-bottom: 10px;
}

.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.concert-card {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  transition: transform 0.3s, box-shadow 0.3s;
}

.concert-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.concert-card.past {
  opacity: 0.8;
}

.concert-card.canceled {
  opacity: 0.7;
  background-color: #f9f9f9;
}

.concert-header {
  padding: 15px;
  background-color: #f5f5f5;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.concert-header h3 {
  margin: 0;
  font-size: 1.1rem;
  color: #333;
}

.status-badge {
  font-size: 0.8rem;
  padding: 3px 8px;
  border-radius: 12px;
  font-weight: 500;
}

.status-badge.upcoming {
  background-color: #e8f5e9;
  color: #2e7d32;
}

.status-badge.in-progress {
  background-color: #e3f2fd;
  color: #1565c0;
}

.status-badge.completed {
  background-color: #e8eaf6;
  color: #3949ab;
}

.status-badge.canceled {
  background-color: #ffebee;
  color: #c62828;
}

.concert-details {
  padding: 15px;
}

.concert-details p {
  margin: 8px 0;
  font-size: 0.9rem;
  color: #555;
}

.concert-actions {
  padding: 15px;
  display: flex;
  justify-content: space-between;
  border-top: 1px solid #eee;
}

.view-button, .edit-button {
  padding: 8px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s;
}

.view-button {
  background-color: #e3f2fd;
  color: #1565c0;
}

.view-button:hover {
  background-color: #bbdefb;
}

.edit-button {
  background-color: #f5f5f5;
  color: #555;
}

.edit-button:hover {
  background-color: #e0e0e0;
}

.no-concerts {
  padding: 20px;
  text-align: center;
  color: #777;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.error-message {
  padding: 20px;
  text-align: center;
  color: #d32f2f;
  background-color: #ffebee;
  border-radius: 8px;
  margin: 20px 0;
}

/* Styles responsifs */
@media (max-width: 768px) {
  .stats-container {
    grid-template-columns: 1fr;
  }
  
  .grid-container {
    grid-template-columns: 1fr;
  }
  
  .concert-card {
    margin-bottom: 15px;
  }
}
EOL
fi

# 4. Vérifier l'installation de react-icons
echo "🔧 Vérification de l'installation de react-icons..."
if ! grep -q "react-icons" client/package.json; then
  echo "⚠️ Le package react-icons n'est pas installé. Ajout d'une instruction pour l'installer..."
  echo ""
  echo "⚠️ IMPORTANT: Vous devez installer react-icons avec la commande suivante:"
  echo "cd client && npm install --save react-icons"
  echo ""
fi

echo "✅ Corrections terminées avec succès!"
echo ""
echo "Les problèmes suivants ont été corrigés :"
echo "1. Le composant ConcertsDashboard a été modifié pour s'assurer qu'il est correctement exporté"
echo "2. Le composant ConcertsList a été modifié pour utiliser React.lazy et React.Suspense pour charger le tableau de bord"
echo "3. La vue tableau de bord est désactivée par défaut en production pour éviter les erreurs"
echo "4. Des vérifications supplémentaires ont été ajoutées pour éviter les erreurs avec des données invalides"
echo ""
echo "Pour appliquer les modifications :"
echo "1. Assurez-vous que l'application n'est pas en cours d'exécution"
echo "2. Exécutez 'cd client && npm install react-icons' si ce n'est pas déjà fait"
echo "3. Reconstruisez l'application avec 'cd client && npm run build'"
echo "4. Redéployez l'application sur votre serveur de production"
