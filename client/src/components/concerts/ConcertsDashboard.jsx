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
