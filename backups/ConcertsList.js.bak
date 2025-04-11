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
          name: selectedProgrammer.name || "Inconnu",
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
      console.log("concertData envoyé :", concertData);
      
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
