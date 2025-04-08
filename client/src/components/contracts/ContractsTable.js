import React, { useState, useEffect, useMemo } from 'react';
import { Link } from 'react-router-dom';
import './ContractsTable.css';

// Services à créer plus tard
import { fetchContracts } from '../../services/contractsService';

const ContractsTable = () => {
  const [contracts, setContracts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    artist: '',
    location: '',
    status: 'all',
    dateRange: { start: null, end: null }
  });
  const [sortConfig, setSortConfig] = useState({
    key: 'date',
    direction: 'ascending'
  });

  // Récupération des données
  useEffect(() => {
    const loadContracts = async () => {
      try {
        setLoading(true);
        // Temporairement, nous utilisons des données fictives
        // Plus tard, nous implémenterons fetchContracts avec Firebase
        const mockContracts = [
          {
            id: '1',
            date: '2025-05-15',
            artist: { id: 'a1', name: 'Les Harmonies Urbaines' },
            venue: 'L\'Olympia',
            city: 'Paris',
            programmer: { id: 'p1', name: 'Jean Dupont' },
            preContract: { status: 'signed', date: '2025-03-10' },
            contract: { status: 'pending', date: null },
            invoice: { status: 'pending', amount: 2500, date: null },
            status: 'en_cours'
          },
          {
            id: '2',
            date: '2025-06-20',
            artist: { id: 'a2', name: 'Échos Poétiques' },
            venue: 'Zénith',
            city: 'Lille',
            programmer: { id: 'p2', name: 'Marie Martin' },
            preContract: { status: 'signed', date: '2025-04-05' },
            contract: { status: 'signed', date: '2025-04-20' },
            invoice: { status: 'pending', amount: 3000, date: null },
            status: 'confirmé'
          },
          {
            id: '3',
            date: '2025-07-10',
            artist: { id: 'a3', name: 'Rythmes Solaires' },
            venue: 'La Cigale',
            city: 'Paris',
            programmer: { id: 'p3', name: 'Sophie Lefebvre' },
            preContract: { status: 'pending', date: null },
            contract: { status: 'pending', date: null },
            invoice: { status: 'pending', amount: 1800, date: null },
            status: 'en_négociation'
          },
          {
            id: '4',
            date: '2025-05-30',
            artist: { id: 'a4', name: 'Jazz Fusion Quartet' },
            venue: 'New Morning',
            city: 'Paris',
            programmer: { id: 'p4', name: 'Pierre Dubois' },
            preContract: { status: 'signed', date: '2025-03-15' },
            contract: { status: 'signed', date: '2025-04-10' },
            invoice: { status: 'paid', amount: 2200, date: '2025-04-25' },
            status: 'confirmé'
          },
          {
            id: '5',
            date: '2025-08-05',
            artist: { id: 'a5', name: 'Électro Symphonie' },
            venue: 'Bataclan',
            city: 'Paris',
            programmer: { id: 'p5', name: 'Lucie Moreau' },
            preContract: { status: 'signed', date: '2025-04-20' },
            contract: { status: 'pending', date: null },
            invoice: { status: 'pending', amount: 2800, date: null },
            status: 'en_cours'
          }
        ];
        
        setContracts(mockContracts);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors du chargement des contrats:', error);
        setLoading(false);
      }
    };

    loadContracts();
  }, [filters]);

  // Fonction pour changer le tri
  const requestSort = (key) => {
    let direction = 'ascending';
    if (sortConfig.key === key && sortConfig.direction === 'ascending') {
      direction = 'descending';
    }
    setSortConfig({ key, direction });
  };

  // Fonction de tri
  const sortedContracts = useMemo(() => {
    const sortableContracts = [...contracts];
    if (sortConfig.key) {
      sortableContracts.sort((a, b) => {
        let aValue, bValue;
        
        // Extraction des valeurs selon la clé de tri
        switch(sortConfig.key) {
          case 'date':
            aValue = new Date(a.date);
            bValue = new Date(b.date);
            break;
          case 'artist':
            aValue = a.artist.name.toLowerCase();
            bValue = b.artist.name.toLowerCase();
            break;
          case 'venue':
            aValue = a.venue.toLowerCase();
            bValue = b.venue.toLowerCase();
            break;
          case 'city':
            aValue = a.city.toLowerCase();
            bValue = b.city.toLowerCase();
            break;
          case 'programmer':
            aValue = a.programmer.name.toLowerCase();
            bValue = b.programmer.name.toLowerCase();
            break;
          case 'status':
            aValue = a.status.toLowerCase();
            bValue = b.status.toLowerCase();
            break;
          default:
            aValue = a[sortConfig.key];
            bValue = b[sortConfig.key];
        }
        
        // Comparaison
        if (aValue < bValue) {
          return sortConfig.direction === 'ascending' ? -1 : 1;
        }
        if (aValue > bValue) {
          return sortConfig.direction === 'ascending' ? 1 : -1;
        }
        return 0;
      });
    }
    return sortableContracts;
  }, [contracts, sortConfig]);

  // Gestion de la progression des contrats
  const getContractStatus = (contract) => {
    const { preContract, contract: contractSigned, invoice } = contract;
    
    // Calcul du pourcentage de progression
    let progress = 0;
    let statusText = '';
    let statusColor = '';
    
    if (preContract.status === 'signed') {
      progress += 33;
    }
    
    if (contractSigned.status === 'signed') {
      progress += 33;
    }
    
    if (invoice.status === 'paid') {
      progress += 34;
    }
    
    // Détermination du statut textuel et de la couleur
    if (progress === 0) {
      statusText = 'Non démarré';
      statusColor = 'gray';
    } else if (progress < 33) {
      statusText = 'Pré-contrat';
      statusColor = 'orange';
    } else if (progress < 66) {
      statusText = 'Contrat en cours';
      statusColor = 'blue';
    } else if (progress < 100) {
      statusText = 'Facturation';
      statusColor = 'purple';
    } else {
      statusText = 'Complété';
      statusColor = 'green';
    }
    
    return {
      progress,
      statusText,
      statusColor
    };
  };

  // Fonction pour filtrer les contrats
  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({
      ...prev,
      [name]: value
    }));
  };

  // Fonction pour réinitialiser les filtres
  const resetFilters = () => {
    setFilters({
      artist: '',
      location: '',
      status: 'all',
      dateRange: { start: null, end: null }
    });
  };

  // Fonction pour afficher les détails d'un contrat
  const showContractDetails = (contractId) => {
    // Cette fonction sera implémentée plus tard pour naviguer vers la page de détails
    console.log(`Afficher les détails du contrat ${contractId}`);
    // navigate(`/contrats/${contractId}`);
  };

  // Formatage de la date
  const formatDate = (dateString) => {
    if (!dateString) return 'Non défini';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR');
  };

  if (loading) {
    return <div className="loading-container">Chargement des contrats...</div>;
  }

  return (
    <div className="contracts-table-container">
      {/* En-tête avec titre et statistiques */}
      <div className="contracts-header">
        <h1>Gestion des Contrats</h1>
        <div className="contracts-stats">
          <div className="stat-card">
            <div className="stat-icon">
              <i className="fas fa-file-contract"></i>
            </div>
            <div className="stat-content">
              <h3>Total</h3>
              <p className="stat-number">{contracts.length}</p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <i className="fas fa-clock"></i>
            </div>
            <div className="stat-content">
              <h3>En cours</h3>
              <p className="stat-number">
                {contracts.filter(c => c.status === 'en_cours').length}
              </p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <i className="fas fa-check-circle"></i>
            </div>
            <div className="stat-content">
              <h3>Confirmés</h3>
              <p className="stat-number">
                {contracts.filter(c => c.status === 'confirmé').length}
              </p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <i className="fas fa-comments"></i>
            </div>
            <div className="stat-content">
              <h3>En négociation</h3>
              <p className="stat-number">
                {contracts.filter(c => c.status === 'en_négociation').length}
              </p>
            </div>
          </div>
        </div>
      </div>
      
      {/* Composants de filtres et recherche */}
      <div className="table-filters">
        <div className="filter-group">
          <input
            type="text"
            name="artist"
            placeholder="Rechercher par artiste"
            value={filters.artist}
            onChange={handleFilterChange}
            className="filter-input"
          />
        </div>
        <div className="filter-group">
          <input
            type="text"
            name="location"
            placeholder="Rechercher par lieu"
            value={filters.location}
            onChange={handleFilterChange}
            className="filter-input"
          />
        </div>
        <div className="filter-group">
          <select
            name="status"
            value={filters.status}
            onChange={handleFilterChange}
            className="filter-select"
          >
            <option value="all">Tous les statuts</option>
            <option value="en_cours">En cours</option>
            <option value="confirmé">Confirmé</option>
            <option value="en_négociation">En négociation</option>
          </select>
        </div>
        <button className="filter-reset-btn" onClick={resetFilters}>
          <i className="fas fa-undo"></i> Réinitialiser
        </button>
        <button className="add-contract-btn">
          <i className="fas fa-plus"></i> Nouveau contrat
        </button>
      </div>
      
      {/* Tableau principal */}
      <div className="table-responsive">
        <table className="contracts-table">
          <thead>
            <tr>
              <th onClick={() => requestSort('date')} className={sortConfig.key === 'date' ? `sorted-${sortConfig.direction}` : ''}>
                Date <i className="fas fa-sort"></i>
              </th>
              <th onClick={() => requestSort('artist')} className={sortConfig.key === 'artist' ? `sorted-${sortConfig.direction}` : ''}>
                Artiste <i className="fas fa-sort"></i>
              </th>
              <th onClick={() => requestSort('venue')} className={sortConfig.key === 'venue' ? `sorted-${sortConfig.direction}` : ''}>
                Lieu <i className="fas fa-sort"></i>
              </th>
              <th onClick={() => requestSort('city')} className={sortConfig.key === 'city' ? `sorted-${sortConfig.direction}` : ''}>
                Ville <i className="fas fa-sort"></i>
              </th>
              <th onClick={() => requestSort('programmer')} className={sortConfig.key === 'programmer' ? `sorted-${sortConfig.direction}` : ''}>
                Programmateur <i className="fas fa-sort"></i>
              </th>
              <th>Progression</th>
              <th onClick={() => requestSort('status')} className={sortConfig.key === 'status' ? `sorted-${sortConfig.direction}` : ''}>
                Statut <i className="fas fa-sort"></i>
              </th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {sortedContracts.length === 0 ? (
              <tr>
                <td colSpan="8" className="no-data">Aucun contrat trouvé</td>
              </tr>
            ) : (
              sortedContracts.map(contract => {
                const contractStatus = getContractStatus(contract);
                return (
                  <tr key={contract.id} onClick={() => showContractDetails(contract.id)}>
                    <td>{formatDate(contract.date)}</td>
                    <td>{contract.artist.name}</td>
                    <td>{contract.venue}</td>
                    <td>{contract.city}</td>
                    <td>{contract.programmer.name}</td>
                    <td>
                      <div className="progress-container">
                        <div 
                          className="progress-bar" 
                          style={{ 
                            width: `${contractStatus.progress}%`,
                            backgroundColor: contractStatus.statusColor 
                          }}
                        ></div>
                        <span className="progress-text">{contractStatus.progress}%</span>
                      </div>
                      <div className="progress-status" style={{ color: contractStatus.statusColor }}>
                        {contractStatus.statusText}
                      </div>
                    </td>
                    <td>
                      <span className={`status-badge status-${contract.status}`}>
                        {contract.status.charAt(0).toUpperCase() + contract.status.slice(1).replace('_', ' ')}
                      </span>
                    </td>
                    <td className="actions-cell">
                      <button className="action-btn edit-btn" onClick={(e) => { e.stopPropagation(); }}>
                        <i className="fas fa-edit"></i>
                      </button>
                      <button className="action-btn view-btn" onClick={(e) => { e.stopPropagation(); }}>
                        <i className="fas fa-eye"></i>
                      </button>
                      <button className="action-btn delete-btn" onClick={(e) => { e.stopPropagation(); }}>
                        <i className="fas fa-trash"></i>
                      </button>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
      
      {/* Pagination et informations sur le nombre total */}
      <div className="table-footer">
        <div className="pagination">
          <button className="pagination-btn" disabled>
            <i className="fas fa-chevron-left"></i> Précédent
          </button>
          <span className="pagination-info">Page 1 sur 1</span>
          <button className="pagination-btn" disabled>
            Suivant <i className="fas fa-chevron-right"></i>
          </button>
        </div>
        <div className="total-info">
          Affichage de {sortedContracts.length} contrat(s) sur {contracts.length} au total
        </div>
      </div>
    </div>
  );
};

export default ContractsTable;
