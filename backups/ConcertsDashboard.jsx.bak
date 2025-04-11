import React, { useState, useEffect } from 'react';
import { FaMusic, FaCalendarAlt, FaEye, FaPencilAlt, FaEuroSign } from 'react-icons/fa';
import { BsClockHistory } from 'react-icons/bs';
import './ConcertsDashboard.css';

// Composant principal du tableau de bord des concerts
const ConcertsDashboard = ({ concerts = [], onViewConcert, onEditConcert }) => {
  const [filteredConcerts, setFilteredConcerts] = useState([]);
  const [activeFilter, setActiveFilter] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  
  // Statistiques calculées
  const [stats, setStats] = useState({
    total: 0,
    past: 0,
    current: 0,
    upcoming: 0,
    totalRevenue: 0
  });
  
  // Calculer les statistiques à partir des concerts
  useEffect(() => {
    if (!concerts || concerts.length === 0) return;
    
    const now = new Date();
    const pastCount = concerts.filter(concert => new Date(concert.date) < now && concert.status !== 'current').length;
    const currentCount = concerts.filter(concert => concert.status === 'current').length;
    const upcomingCount = concerts.filter(concert => new Date(concert.date) > now && concert.status !== 'current').length;
    
    // Calculer le revenu total (convertir les montants en nombres)
    const totalRevenue = concerts.reduce((sum, concert) => {
      const amount = parseFloat(concert.amount?.toString().replace(/[^\d.-]/g, '') || 0);
      return sum + amount;
    }, 0);
    
    setStats({
      total: concerts.length,
      past: pastCount,
      current: currentCount,
      upcoming: upcomingCount,
      totalRevenue
    });
  }, [concerts]);
  
  // Filtrer les concerts en fonction du filtre actif et du terme de recherche
  useEffect(() => {
    if (!concerts || concerts.length === 0) {
      setFilteredConcerts([]);
      return;
    }
    
    let filtered = [...concerts];
    const now = new Date();
    
    // Appliquer le filtre
    if (activeFilter === 'past') {
      filtered = filtered.filter(concert => new Date(concert.date) < now && concert.status !== 'current');
    } else if (activeFilter === 'current') {
      filtered = filtered.filter(concert => concert.status === 'current');
    } else if (activeFilter === 'upcoming') {
      filtered = filtered.filter(concert => new Date(concert.date) > now && concert.status !== 'current');
    }
    
    // Appliquer la recherche
    if (searchTerm.trim() !== '') {
      const term = searchTerm.toLowerCase();
      filtered = filtered.filter(concert => 
        (concert.artist && concert.artist.toLowerCase().includes(term)) ||
        (concert.venue && concert.venue.toLowerCase().includes(term)) ||
        (concert.programmer && concert.programmer.toLowerCase().includes(term))
      );
    }
    
    setFilteredConcerts(filtered);
    setCurrentPage(1); // Réinitialiser à la première page lors du filtrage
  }, [concerts, activeFilter, searchTerm]);
  
  // Gérer le changement de filtre
  const handleFilterChange = (filter) => {
    setActiveFilter(filter);
  };
  
  // Gérer le changement de terme de recherche
  const handleSearchChange = (e) => {
    setSearchTerm(e.target.value);
  };
  
  // Gérer le changement de page
  const handlePageChange = (page) => {
    setCurrentPage(page);
  };
  
  // Gérer le changement du nombre d'éléments par page
  const handleItemsPerPageChange = (e) => {
    setItemsPerPage(parseInt(e.target.value));
    setCurrentPage(1); // Réinitialiser à la première page
  };
  
  // Calculer les indices de début et de fin pour la pagination
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredConcerts.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(filteredConcerts.length / itemsPerPage);
  
  // Formater un montant en euros
  const formatAmount = (amount) => {
    if (!amount) return '0 €';
    
    // Si amount est déjà une chaîne formatée avec €, la retourner telle quelle
    if (typeof amount === 'string' && amount.includes('€')) {
      return amount;
    }
    
    // Sinon, formater le nombre
    const numAmount = parseFloat(amount.toString().replace(/[^\d.-]/g, '') || 0);
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' })
      .format(numAmount)
      .replace(',00', ''); // Supprimer les centimes si c'est un nombre entier
  };
  
  // Formater une date
  const formatDate = (dateString) => {
    if (!dateString) return '';
    
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    }).format(date);
  };
  
  // Obtenir la classe CSS pour le statut
  const getStatusClass = (concert) => {
    const now = new Date();
    const concertDate = new Date(concert.date);
    
    if (concert.status === 'current' || (concertDate <= now && concertDate >= new Date(now - 7 * 24 * 60 * 60 * 1000))) {
      return 'status-current';
    } else if (concertDate < now) {
      return 'status-past';
    } else {
      return 'status-upcoming';
    }
  };
  
  // Obtenir le texte du statut
  const getStatusText = (concert) => {
    const now = new Date();
    const concertDate = new Date(concert.date);
    
    if (concert.status === 'current' || (concertDate <= now && concertDate >= new Date(now - 7 * 24 * 60 * 60 * 1000))) {
      return 'En cours';
    } else if (concertDate < now) {
      return 'Passé';
    } else {
      return 'À venir';
    }
  };
  
  return (
    <div className="concerts-dashboard">
      <h1 className="dashboard-title">Gestion des concerts</h1>
      
      {/* Widgets statistiques */}
      <div className="stats-widgets">
        <div className="stat-card total">
          <div className="stat-icon">
            <FaMusic />
          </div>
          <div className="stat-content">
            <h3>Total des concerts</h3>
            <p className="stat-value">{stats.total}</p>
          </div>
        </div>
        
        <div className="stat-card past">
          <div className="stat-icon">
            <BsClockHistory />
          </div>
          <div className="stat-content">
            <h3>Concerts passés</h3>
            <p className="stat-value">{stats.past}</p>
          </div>
        </div>
        
        <div className="stat-card current">
          <div className="stat-icon">
            <FaCalendarAlt />
          </div>
          <div className="stat-content">
            <h3>En cours</h3>
            <p className="stat-value">{stats.current}</p>
          </div>
        </div>
        
        <div className="stat-card upcoming">
          <div className="stat-icon">
            <FaCalendarAlt />
          </div>
          <div className="stat-content">
            <h3>À venir</h3>
            <p className="stat-value">{stats.upcoming}</p>
          </div>
        </div>
        
        <div className="stat-card revenue">
          <div className="stat-icon">
            <FaEuroSign />
          </div>
          <div className="stat-content">
            <h3>Revenu total</h3>
            <p className="stat-value">{formatAmount(stats.totalRevenue)}</p>
          </div>
        </div>
      </div>
      
      {/* Filtres et recherche */}
      <div className="filters-container">
        <div className="filter-buttons">
          <button 
            className={`filter-button ${activeFilter === 'all' ? 'active' : ''}`}
            onClick={() => handleFilterChange('all')}
          >
            Tous
          </button>
          <button 
            className={`filter-button ${activeFilter === 'past' ? 'active' : ''}`}
            onClick={() => handleFilterChange('past')}
          >
            Passés
          </button>
          <button 
            className={`filter-button ${activeFilter === 'current' ? 'active' : ''}`}
            onClick={() => handleFilterChange('current')}
          >
            En cours
          </button>
        </div>
        
        <div className="search-container">
          <input
            type="text"
            placeholder="Rechercher..."
            value={searchTerm}
            onChange={handleSearchChange}
            className="search-input"
          />
        </div>
      </div>
      
      {/* Tableau des concerts */}
      <div className="concerts-table-container">
        <table className="concerts-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>Lieu</th>
              <th>Artiste</th>
              <th>Programmateur</th>
              <th>Statut</th>
              <th>Montant</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {currentItems.length === 0 ? (
              <tr>
                <td colSpan="7" className="no-data">Aucun concert trouvé</td>
              </tr>
            ) : (
              currentItems.map((concert, index) => (
                <tr key={concert.id || index}>
                  <td>{formatDate(concert.date)}</td>
                  <td>{concert.venue || 'Non spécifié'}</td>
                  <td>{concert.artist || 'Non spécifié'}</td>
                  <td>{concert.programmer || 'Non spécifié'}</td>
                  <td>
                    <span className={`status-badge ${getStatusClass(concert)}`}>
                      {getStatusText(concert)}
                    </span>
                  </td>
                  <td>{formatAmount(concert.amount)}</td>
                  <td className="actions-cell">
                    <button 
                      className="action-button view"
                      onClick={() => onViewConcert && onViewConcert(concert)}
                      title="Voir la fiche"
                    >
                      <FaEye />
                    </button>
                    <button 
                      className="action-button edit"
                      onClick={() => onEditConcert && onEditConcert(concert)}
                      title="Modifier"
                    >
                      <FaPencilAlt />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
      
      {/* Pagination */}
      <div className="pagination-container">
        <div className="items-per-page">
          <span>Afficher</span>
          <select value={itemsPerPage} onChange={handleItemsPerPageChange}>
            <option value={5}>5</option>
            <option value={10}>10</option>
            <option value={25}>25</option>
            <option value={50}>50</option>
          </select>
          <span>par page</span>
        </div>
        
        <div className="pagination-controls">
          <button 
            className="pagination-button"
            onClick={() => handlePageChange(1)}
            disabled={currentPage === 1}
          >
            &laquo;
          </button>
          <button 
            className="pagination-button"
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1}
          >
            &lsaquo;
          </button>
          
          <span className="pagination-info">
            Page {currentPage} sur {totalPages || 1}
          </span>
          
          <button 
            className="pagination-button"
            onClick={() => handlePageChange(currentPage + 1)}
            disabled={currentPage === totalPages || totalPages === 0}
          >
            &rsaquo;
          </button>
          <button 
            className="pagination-button"
            onClick={() => handlePageChange(totalPages)}
            disabled={currentPage === totalPages || totalPages === 0}
          >
            &raquo;
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConcertsDashboard;
