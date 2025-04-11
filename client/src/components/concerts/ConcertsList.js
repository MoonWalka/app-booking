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
  const [useDashboard, setUseDashboard] = useState(true); // Activer le tableau de bord par défaut
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
            <ConcertsDashboard 
              concerts={concerts}
              onViewConcert={handleViewConcert}
              onEditConcert={handleEditConcert}
            />
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
