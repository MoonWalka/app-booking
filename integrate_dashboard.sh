#!/bin/bash

# Script d'intégration du tableau de bord des concerts amélioré
# Ce script modifie le fichier ConcertsList.js pour utiliser le composant ConcertsDashboard

echo "Intégration du tableau de bord des concerts amélioré..."

# Vérifier que nous sommes à la racine du projet
if [ ! -d "client" ] || [ ! -d "client/src" ]; then
  echo "❌ Erreur: Ce script doit être exécuté à la racine du projet."
  echo "Assurez-vous que vous êtes dans le répertoire principal de votre application."
  exit 1
fi

# Vérifier que les fichiers nécessaires existent
if [ ! -f "ConcertsDashboard.jsx" ] || [ ! -f "ConcertsDashboard.css" ]; then
  echo "❌ Erreur: Les fichiers ConcertsDashboard.jsx et/ou ConcertsDashboard.css sont manquants."
  echo "Assurez-vous que ces fichiers sont présents à la racine du projet."
  exit 1
fi

# Créer une sauvegarde des fichiers existants
echo "📦 Création de sauvegardes des fichiers existants..."
mkdir -p backups
cp -f client/src/components/concerts/ConcertsList.js backups/ConcertsList.js.bak
cp -f client/src/components/concerts/ConcertsDashboard.jsx backups/ConcertsDashboard.jsx.bak 2>/dev/null
cp -f client/src/components/concerts/ConcertsDashboard.css backups/ConcertsDashboard.css.bak 2>/dev/null
echo "✅ Sauvegardes créées dans le dossier 'backups'"

# Copier les nouveaux fichiers
echo "📋 Copie des nouveaux fichiers..."
cp -f ConcertsDashboard.jsx client/src/components/concerts/
cp -f ConcertsDashboard.css client/src/components/concerts/
echo "✅ Fichiers copiés"

# Installer react-icons si nécessaire
if ! grep -q "react-icons" package.json; then
  echo "📦 Installation de la dépendance react-icons..."
  npm install --save react-icons
  echo "✅ react-icons installé"
else
  echo "✅ react-icons est déjà installé"
fi

# Modifier le fichier ConcertsList.js pour utiliser ConcertsDashboard
echo "🔄 Modification du fichier ConcertsList.js..."

# Créer un nouveau fichier temporaire
cat > temp_ConcertsList.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts, addConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import ConcertsDashboard from './ConcertsDashboard';
import './ConcertsList.css';

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

  // Options pour les heures et minutes
  const hours = Array.from({ length: 24 }, (_, i) => i.toString().padStart(2, '0'));
  const minutes = ['00', '15', '30', '45'];
  const statuses = ['À venir', 'En cours', 'Terminé', 'Annulé'];

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const concertsData = await getConcerts();
        const artistsData = await getArtists();
        
        // Enrichir les données de concerts avec les informations d'artistes
        const enrichedConcerts = concertsData.map(concert => {
          const artist = artistsData.find(a => a.id === concert.artistId);
          return {
            ...concert,
            artist: artist || null
          };
        });
        
        setConcerts(enrichedConcerts);
        setArtists(artistsData);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors du chargement des données:', error);
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
      
      // Construire la date et l'heure
      const dateObj = new Date(currentDate);
      const timeString = `${currentHour}:${currentMinute}`;
      
      const concertToAdd = {
        ...newConcert,
        date: dateObj,
        time: timeString
      };
      
      const addedConcert = await addConcert(concertToAdd);
      
      // Ajouter l'artiste à l'objet concert
      const artist = artists.find(a => a.id === concertToAdd.artistId);
      const enrichedConcert = {
        ...addedConcert,
        artist: artist || null
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
      console.error('Erreur lors de l\'ajout du concert:', error);
      setLoading(false);
    }
  };

  const handleViewConcert = (concert) => {
    // Cette fonction est appelée par le composant ConcertsDashboard
    // Nous utilisons simplement la navigation existante
    window.location.href = `/concerts/${concert.id}`;
  };

  const handleEditConcert = (concert) => {
    // Cette fonction est appelée par le composant ConcertsDashboard
    // Nous utilisons simplement la navigation existante
    window.location.href = `/concerts/${concert.id}`;
  };

  if (loading && concerts.length === 0) {
    return <div className="loading">Chargement des concerts...</div>;
  }

  return (
    <div className="concerts-container">
      <div className="concerts-header">
        <h1>Gestion des concerts</h1>
        <button className="add-concert-btn" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Annuler' : 'Ajouter un concert'}
        </button>
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
      
      {/* Utilisation du nouveau composant ConcertsDashboard */}
      {!showForm && (
        <ConcertsDashboard 
          concerts={concerts}
          onViewConcert={handleViewConcert}
          onEditConcert={handleEditConcert}
        />
      )}
    </div>
  );
};

export default ConcertsList;
EOL

# Remplacer le fichier original par le nouveau
mv temp_ConcertsList.js client/src/components/concerts/ConcertsList.js
echo "✅ Fichier ConcertsList.js modifié"

echo ""
echo "✅ Intégration terminée avec succès!"
echo ""
echo "Le tableau de bord des concerts amélioré est maintenant intégré à votre application."
echo "Pour voir les changements, démarrez votre application avec 'npm start'."
echo ""
echo "Si vous souhaitez revenir à la version précédente, les fichiers de sauvegarde"
echo "sont disponibles dans le dossier 'backups'."
