// ConcertsDashboard.jsx
import React, { useState, useEffect } from 'react';
import { 
  MdMusicNote, 
  MdHistory, 
  MdPlayCircleFilled, 
  MdEvent, 
  MdEuroSymbol,
  MdVisibility,
  MdEdit
} from 'react-icons/md';
import './ConcertsDashboard.css';

// Composant pour les cartes statistiques
const StatCard = ({ title, value, icon, color }) => (
  <div className="stat-card" style={{ backgroundColor: color }}>
    <div className="stat-icon">{icon}</div>
    <div className="stat-content">
      <h3 className="stat-title">{title}</h3>
      <p className="stat-value">{value}</p>
    </div>
  </div>
);

// Composant pour les filtres rapides
const FilterButtons = ({ activeFilter, onFilterChange }) => (
  <div className="filter-buttons">
    <button 
      className={`filter-button ${activeFilter === 'all' ? 'active' : ''}`}
      onClick={() => onFilterChange('all')}
    >
      Tous
    </button>
    <button 
      className={`filter-button ${activeFilter === 'past' ? 'active' : ''}`}
      onClick={() => onFilterChange('past')}
    >
      Passés
    </button>
    <button 
      className={`filter-button ${activeFilter === 'current' ? 'active' : ''}`}
      onClick={() => onFilterChange('current')}
    >
      En cours
    </button>
  </div>
);

// Composant pour le badge de statut
const StatusBadge = ({ status }) => {
  let badgeClass = '';
  
  switch(status) {
    case 'Passé':
      badgeClass = 'status-past';
      break;
    case 'En cours':
      badgeClass = 'status-current';
      break;
    case 'À venir':
      badgeClass = 'status-upcoming';
      break;
    default:
      badgeClass = '';
  }
  
  return <span className={`status-badge ${badgeClass}`}>{status}</span>;
};

// Composant principal du tableau de bord des concerts
const ConcertsDashboard = () => {
  // États pour gérer les données et les filtres
  const [concerts, setConcerts] = useState([]);
  const [filteredConcerts, setFilteredConcerts] = useState([]);
  const [activeFilter, setActiveFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Statistiques calculées
  const [stats, setStats] = useState({
    total: 0,
    past: 0,
    current: 0,
    upcoming: 0,
    revenue: 0
  });
  
  // Simuler le chargement des données (à remplacer par l'appel API réel)
  useEffect(() => {
    // Exemple de données (à remplacer par les données réelles de l'application)
    const sampleConcerts = [
      {
        id: 1,
        date: '15/01/2023',
        venue: 'La Cigale, Paris',
        artist: 'Groupe Harmony',
        programmer: 'Jean Dupont',
        status: 'Passé',
        amount: '2 500 €'
      },
      {
        id: 2,
        date: '25/02/2023',
        venue: 'Le Bikini, Toulouse',
        artist: 'DJ Electronic',
        programmer: 'Sophie Martin',
        status: 'Passé',
        amount: '1 800 €'
      },
      {
        id: 3,
        date: '10/06/2023',
        venue: 'L\'Olympia, Paris',
        artist: 'Les Rockers',
        programmer: 'François Leblanc',
        status: 'En cours',
        amount: '3 200 €'
      },
      {
        id: 4,
        date: '22/07/2023',
        venue: 'La Belle Électrique, Grenoble',
        artist: 'Melodic Sisters',
        programmer: 'Marie Dubois',
        status: 'À venir',
        amount: '2 200 €'
      },
      {
        id: 5,
        date: '18/08/2023',
        venue: 'Le Transbordeur, Lyon',
        artist: 'Jazz Quartet',
        programmer: 'Pierre Moreau',
        status: 'En cours',
        amount: '1 950 €'
      }
    ];
    
    setConcerts(sampleConcerts);
    
    // Calculer les statistiques
    const pastCount = sampleConcerts.filter(c => c.status === 'Passé').length;
    const currentCount = sampleConcerts.filter(c => c.status === 'En cours').length;
    const upcomingCount = sampleConcerts.filter(c => c.status === 'À venir').length;
    
    // Calculer le revenu total (en supposant que les montants sont au format "X XXX €")
    const totalRevenue = sampleConcerts.reduce((sum, concert) => {
      const amount = parseFloat(concert.amount.replace(/\s/g, '').replace('€', '').replace(',', '.'));
      return sum + amount;
    }, 0);
    
    setStats({
      total: sampleConcerts.length,
      past: pastCount,
      current: currentCount,
      upcoming: upcomingCount,
      revenue: totalRevenue.toLocaleString('fr-FR')
    });
    
    // Appliquer le filtre initial
    applyFilter('all', sampleConcerts);
  }, []);
  
  // Fonction pour appliquer les filtres
  const applyFilter = (filter, concertList = concerts) => {
    setActiveFilter(filter);
    
    let filtered = [...concertList];
    
    // Appliquer le filtre de statut
    if (filter === 'past') {
      filtered = filtered.filter(concert => concert.status === 'Passé');
    } else if (filter === 'current') {
      filtered = filtered.filter(concert => concert.status === 'En cours');
    }
    
    // Appliquer la recherche si elle existe
    if (searchTerm) {
      filtered = filtered.filter(concert => 
        concert.artist.toLowerCase().includes(searchTerm.toLowerCase()) ||
        concert.venue.toLowerCase().includes(searchTerm.toLowerCase()) ||
        concert.programmer.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    setFilteredConcerts(filtered);
    setCurrentPage(1); // Réinitialiser à la première page après un changement de filtre
  };
  
  // Gérer le changement de filtre
  const handleFilterChange = (filter) => {
    applyFilter(filter);
  };
  
  // Gérer la recherche
  const handleSearch = (e) => {
    const term = e.target.value;
    setSearchTerm(term);
    applyFilter(activeFilter, concerts);
  };
  
  // Gérer le changement du nombre d'éléments par page
  const handleItemsPerPageChange = (e) => {
    setItemsPerPage(parseInt(e.target.value));
    setCurrentPage(1); // Réinitialiser à la première page
  };
  
  // Calculer les indices pour la pagination
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredConcerts.slice(indexOfFirstItem, indexOfLastItem);
  
  // Calculer le nombre total de pages
  const totalPages = Math.ceil(filteredConcerts.length / itemsPerPage);
  
  // Générer les numéros de page
  const pageNumbers = [];
  for (let i = 1; i <= totalPages; i++) {
    pageNumbers.push(i);
  }
  
  return (
    <div className="concerts-dashboard">
      <h1 className="dashboard-title">Gestion des concerts</h1>
      
      {/* Bouton d'ajout de concert */}
      <div className="add-concert-container">
        <button className="add-concert-button">
          <span className="add-icon">+</span> Ajouter un concert
        </button>
      </div>
      
      {/* Cartes statistiques */}
      <div className="stat-cards-container">
        <StatCard 
          title="Total des concerts" 
          value={stats.total} 
          icon={<MdMusicNote />} 
          color="#1a237e" 
        />
        <StatCard 
          title="Concerts passés" 
          value={stats.past} 
          icon={<MdHistory />} 
          color="#4a148c" 
        />
        <StatCard 
          title="En cours" 
          value={stats.current} 
          icon={<MdPlayCircleFilled />} 
          color="#bf360c" 
        />
        <StatCard 
          title="À venir" 
          value={stats.upcoming} 
          icon={<MdEvent />} 
          color="#1b5e20" 
        />
        <StatCard 
          title="Revenu total" 
          value={`${stats.revenue} €`} 
          icon={<MdEuroSymbol />} 
          color="#b71c1c" 
        />
      </div>
      
      {/* Filtres et recherche */}
      <div className="filters-container">
        <FilterButtons 
          activeFilter={activeFilter} 
          onFilterChange={handleFilterChange} 
        />
        <div className="search-container">
          <input 
            type="text" 
            placeholder="Rechercher..." 
            value={searchTerm}
            onChange={handleSearch}
            className="search-input"
          />
        </div>
      </div>
      
      {/* Tableau des concerts */}
      <div className="concerts-table-container">
        <table className="concerts-table">
          <thead>
            <tr>
              <th>DATE</th>
              <th>LIEU</th>
              <th>ARTISTE</th>
              <th>PROGRAMMATEUR</th>
              <th>STATUT</th>
              <th>MONTANT</th>
              <th>ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            {currentItems.map(concert => (
              <tr key={concert.id}>
                <td>{concert.date}</td>
                <td>{concert.venue}</td>
                <td>{concert.artist}</td>
                <td>{concert.programmer}</td>
                <td><StatusBadge status={concert.status} /></td>
                <td>{concert.amount}</td>
                <td className="actions-cell">
                  <button className="action-button view-button" title="Voir la fiche">
                    <MdVisibility />
                  </button>
                  <button className="action-button edit-button" title="Modifier">
                    <MdEdit />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      
      {/* Pagination */}
      <div className="pagination-container">
        <div className="items-per-page">
          <span>Afficher</span>
          <select 
            value={itemsPerPage} 
            onChange={handleItemsPerPageChange}
            className="items-per-page-select"
          >
            <option value="5">5</option>
            <option value="10">10</option>
            <option value="25">25</option>
            <option value="50">50</option>
          </select>
          <span>par page</span>
        </div>
        
        <div className="pagination-controls">
          <button 
            className="pagination-button"
            onClick={() => setCurrentPage(1)}
            disabled={currentPage === 1}
          >
            «
          </button>
          <button 
            className="pagination-button"
            onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
          >
            ‹
          </button>
          
          <span className="pagination-info">
            Page {currentPage} sur {totalPages}
          </span>
          
          <button 
            className="pagination-button"
            onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
            disabled={currentPage === totalPages}
          >
            ›
          </button>
          <button 
            className="pagination-button"
            onClick={() => setCurrentPage(totalPages)}
            disabled={currentPage === totalPages}
          >
            »
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConcertsDashboard;
