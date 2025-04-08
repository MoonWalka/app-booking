#!/bin/bash

# Script de modification pour intégrer le nouveau module de contrats dans le Dashboard
# Créé le 8 avril 2025

echo "Début des modifications pour intégrer le nouveau module de contrats..."

# Création du dossier contracts s'il n'existe pas
mkdir -p ./client/src/components/contracts

# Création du fichier ContractsTable.js
cat > ./client/src/components/contracts/ContractsTable.js << 'EOL'
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
EOL

echo "Fichier ContractsTable.js créé."

# Création du fichier CSS pour le tableau des contrats
cat > ./client/src/components/contracts/ContractsTable.css << 'EOL'
/* ContractsTable.css */
.contracts-table-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  padding: 20px;
  margin-bottom: 20px;
}

.contracts-header {
  display: flex;
  flex-direction: column;
  margin-bottom: 20px;
}

.contracts-header h1 {
  font-size: 24px;
  margin-bottom: 20px;
  color: #333;
}

.contracts-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-bottom: 20px;
}

.stat-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 15px;
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 200px;
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-3px);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background-color: #f0f7ff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  font-size: 20px;
  color: #3498db;
}

.stat-content h3 {
  font-size: 14px;
  color: #666;
  margin: 0 0 5px 0;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.table-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 20px;
  align-items: center;
}

.filter-group {
  flex: 1;
  min-width: 200px;
}

.filter-input, .filter-select {
  width: 100%;
  padding: 10px 15px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.filter-reset-btn {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 10px 15px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
}

.filter-reset-btn:hover {
  background-color: #e9ecef;
}

.add-contract-btn {
  background-color: #3498db;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 15px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
  margin-left: auto;
}

.add-contract-btn:hover {
  background-color: #2980b9;
}

.table-responsive {
  overflow-x: auto;
  margin-bottom: 20px;
}

.contracts-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}

.contracts-table th {
  background-color: #f8f9fa;
  padding: 12px 15px;
  text-align: left;
  font-weight: 600;
  color: #495057;
  border-bottom: 2px solid #dee2e6;
  cursor: pointer;
  user-select: none;
}

.contracts-table th:hover {
  background-color: #e9ecef;
}

.contracts-table th.sorted-ascending::after {
  content: " ↑";
  color: #3498db;
}

.contracts-table th.sorted-descending::after {
  content: " ↓";
  color: #3498db;
}

.contracts-table td {
  padding: 12px 15px;
  border-bottom: 1px solid #dee2e6;
  color: #333;
}

.contracts-table tbody tr {
  transition: background-color 0.2s;
  cursor: pointer;
}

.contracts-table tbody tr:hover {
  background-color: #f8f9fa;
}

.progress-container {
  width: 100%;
  height: 8px;
  background-color: #e9ecef;
  border-radius: 4px;
  position: relative;
  margin-bottom: 5px;
}

.progress-bar {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 12px;
  color: #666;
}

.progress-status {
  font-size: 12px;
  font-weight: 600;
}

.status-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
}

.status-en_cours {
  background-color: #e3f2fd;
  color: #1976d2;
}

.status-confirmé {
  background-color: #e8f5e9;
  color: #388e3c;
}

.status-en_négociation {
  background-color: #fff8e1;
  color: #f57c00;
}

.actions-cell {
  white-space: nowrap;
}

.action-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 5px;
  margin: 0 2px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.action-btn:hover {
  background-color: #e9ecef;
}

.edit-btn {
  color: #3498db;
}

.view-btn {
  color: #2ecc71;
}

.delete-btn {
  color: #e74c3c;
}

.table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #dee2e6;
}

.pagination {
  display: flex;
  align-items: center;
  gap: 10px;
}

.pagination-btn {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 8px 12px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
}

.pagination-btn:hover:not(:disabled) {
  background-color: #e9ecef;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-info {
  font-size: 14px;
  color: #666;
}

.total-info {
  font-size: 14px;
  color: #666;
}

.no-data {
  text-align: center;
  padding: 30px;
  color: #666;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
  font-size: 16px;
  color: #666;
}

/* Responsive design */
@media (max-width: 992px) {
  .stat-card {
    min-width: 150px;
  }
  
  .filter-group {
    min-width: 150px;
  }
}

@media (max-width: 768px) {
  .contracts-stats {
    flex-direction: column;
  }
  
  .stat-card {
    width: 100%;
  }
  
  .table-filters {
    flex-direction: column;
  }
  
  .filter-group {
    width: 100%;
  }
  
  .add-contract-btn {
    margin-left: 0;
    margin-top: 10px;
    width: 100%;
    justify-content: center;
  }
  
  .table-footer {
    flex-direction: column;
    gap: 10px;
  }
  
  .pagination {
    width: 100%;
    justify-content: space-between;
  }
}
EOL

echo "Fichier ContractsTable.css créé."

# Création du service pour les contrats
mkdir -p ./client/src/services

cat > ./client/src/services/contractsService.js << 'EOL'
// client/src/services/contractsService.js
import { db } from '../firebase';
import { collection, getDocs, getDoc, doc, addDoc, updateDoc, deleteDoc, query, where } from 'firebase/firestore';

// Collection de référence
const CONTRACTS_COLLECTION = 'contracts';

/**
 * Récupère tous les contrats
 * @param {Object} filters - Filtres à appliquer (optionnel)
 * @returns {Promise<Array>} Liste des contrats
 */
export const fetchContracts = async (filters = {}) => {
  try {
    // Création d'une requête de base
    let contractsQuery = collection(db, CONTRACTS_COLLECTION);
    
    // Application des filtres si nécessaire
    if (filters) {
      // Exemple: filtrer par artiste
      if (filters.artist) {
        contractsQuery = query(contractsQuery, where('artist.name', '>=', filters.artist), 
                                             where('artist.name', '<=', filters.artist + '\uf8ff'));
      }
      
      // Exemple: filtrer par lieu
      if (filters.location) {
        contractsQuery = query(contractsQuery, where('venue', '>=', filters.location), 
                                             where('venue', '<=', filters.location + '\uf8ff'));
      }
      
      // Exemple: filtrer par statut
      if (filters.status && filters.status !== 'all') {
        contractsQuery = query(contractsQuery, where('status', '==', filters.status));
      }
      
      // Exemple: filtrer par plage de dates
      // Note: Ce type de filtre est plus complexe et pourrait nécessiter plusieurs requêtes
      // ou un traitement côté client selon les besoins spécifiques
    }
    
    // Exécution de la requête
    const querySnapshot = await getDocs(contractsQuery);
    
    // Transformation des documents en objets JavaScript
    const contracts = [];
    querySnapshot.forEach((doc) => {
      contracts.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return contracts;
  } catch (error) {
    console.error('Erreur lors de la récupération des contrats:', error);
    throw error;
  }
};

/**
 * Récupère un contrat par son ID
 * @param {string} id - ID du contrat
 * @returns {Promise<Object>} Données du contrat
 */
export const getContractById = async (id) => {
  try {
    const contractDoc = await getDoc(doc(db, CONTRACTS_COLLECTION, id));
    
    if (contractDoc.exists()) {
      return {
        id: contractDoc.id,
        ...contractDoc.data()
      };
    } else {
      throw new Error('Contrat non trouvé');
    }
  } catch (error) {
    console.error('Erreur lors de la récupération du contrat:', error);
    throw error;
  }
};

/**
 * Crée un nouveau contrat
 * @param {Object} contractData - Données du contrat
 * @returns {Promise<Object>} Contrat créé avec ID
 */
export const createContract = async (contractData) => {
  try {
    const docRef = await addDoc(collection(db, CONTRACTS_COLLECTION), contractData);
    return {
      id: docRef.id,
      ...contractData
    };
  } catch (error) {
    console.error('Erreur lors de la création du contrat:', error);
    throw error;
  }
};

/**
 * Met à jour un contrat existant
 * @param {string} id - ID du contrat
 * @param {Object} contractData - Nouvelles données du contrat
 * @returns {Promise<void>}
 */
export const updateContract = async (id, contractData) => {
  try {
    await updateDoc(doc(db, CONTRACTS_COLLECTION, id), contractData);
  } catch (error) {
    console.error('Erreur lors de la mise à jour du contrat:', error);
    throw error;
  }
};

/**
 * Supprime un contrat
 * @param {string} id - ID du contrat
 * @returns {Promise<void>}
 */
export const deleteContract = async (id) => {
  try {
    await deleteDoc(doc(db, CONTRACTS_COLLECTION, id));
  } catch (error) {
    console.error('Erreur lors de la suppression du contrat:', error);
    throw error;
  }
};

/**
 * Récupère les contrats liés à un artiste
 * @param {string} artistId - ID de l'artiste
 * @returns {Promise<Array>} Liste des contrats
 */
export const getContractsByArtist = async (artistId) => {
  try {
    const contractsQuery = query(collection(db, CONTRACTS_COLLECTION), where('artist.id', '==', artistId));
    const querySnapshot = await getDocs(contractsQuery);
    
    const contracts = [];
    querySnapshot.forEach((doc) => {
      contracts.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return contracts;
  } catch (error) {
    console.error('Erreur lors de la récupération des contrats par artiste:', error);
    throw error;
  }
};

/**
 * Récupère les contrats liés à un programmateur
 * @param {string} programmerId - ID du programmateur
 * @returns {Promise<Array>} Liste des contrats
 */
export const getContractsByProgrammer = async (programmerId) => {
  try {
    const contractsQuery = query(collection(db, CONTRACTS_COLLECTION), where('programmer.id', '==', programmerId));
    const querySnapshot = await getDocs(contractsQuery);
    
    const contracts = [];
    querySnapshot.forEach((doc) => {
      contracts.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return contracts;
  } catch (error) {
    console.error('Erreur lors de la récupération des contrats par programmateur:', error);
    throw error;
  }
};

/**
 * Récupère les contrats liés à un concert
 * @param {string} concertId - ID du concert
 * @returns {Promise<Array>} Liste des contrats
 */
export const getContractsByConcert = async (concertId) => {
  try {
    const contractsQuery = query(collection(db, CONTRACTS_COLLECTION), where('concertId', '==', concertId));
    const querySnapshot = await getDocs(contractsQuery);
    
    const contracts = [];
    querySnapshot.forEach((doc) => {
      contracts.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return contracts;
  } catch (error) {
    console.error('Erreur lors de la récupération des contrats par concert:', error);
    throw error;
  }
};
EOL

echo "Fichier contractsService.js créé."

# Modification du Dashboard.js pour intégrer le nouveau module
cat > ./client/src/components/dashboard/Dashboard.js << 'EOL'
import React from 'react';
import ContractsTable from '../contracts/ContractsTable';
import './Dashboard.css';

const Dashboard = () => {
  return (
    <div className="dashboard-container">
      <ContractsTable />
    </div>
  );
};

export default Dashboard;
EOL

echo "Fichier Dashboard.js modifié."

# Modification du Layout.js pour ajouter les onglets contrat et facture
cat > ./client/src/components/common/Layout.js << 'EOL'
// client/src/components/common/Layout.js
import React from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import './Layout.css';

const Layout = () => {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isActive = (path) => {
    return location.pathname === path;
  };

  return (
    <div className="app-container">
      <aside className="sidebar">
        <div className="sidebar-header">
          <Link to="/" className="logo">
            <span className="logo-text">Label Musical</span>
          </Link>
          <div className="sidebar-subtitle">Gestion des concerts et artistes</div>
        </div>
        
        <nav className="sidebar-nav">
          <Link to="/" className={`nav-item ${isActive('/') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-chart-line"></i>
            </span>
            Tableau de bord
          </Link>
          <Link to="/contrats" className={`nav-item ${isActive('/contrats') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-contract"></i>
            </span>
            Contrats
          </Link>
          <Link to="/factures" className={`nav-item ${isActive('/factures') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-invoice-dollar"></i>
            </span>
            Factures
          </Link>
          <Link to="/concerts" className={`nav-item ${isActive('/concerts') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-calendar-alt"></i>
            </span>
            Concerts
          </Link>
          <Link to="/artistes" className={`nav-item ${isActive('/artistes') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-music"></i>
            </span>
            Artistes
          </Link>
          <Link to="/programmateurs" className={`nav-item ${isActive('/programmateurs') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-user-tie"></i>
            </span>
            Programmateurs
          </Link>
          <Link to="/emails" className={`nav-item ${isActive('/emails') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-envelope"></i>
            </span>
            Emails
          </Link>
          <Link to="/documents" className={`nav-item ${isActive('/documents') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-alt"></i>
            </span>
            Documents
          </Link>
          <Link to="/parametres" className={`nav-item ${isActive('/parametres') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-cog"></i>
            </span>
            Paramètres
          </Link>
        </nav>
      </aside>
      
      <div className="main-content">
        <header className="main-header">
          <div className="page-title">
            {location.pathname === '/' && 'Tableau de bord'}
            {location.pathname === '/contrats' && 'Gestion des contrats'}
            {location.pathname === '/factures' && 'Gestion des factures'}
            {location.pathname === '/concerts' && 'Gestion des concerts'}
            {location.pathname === '/artistes' && 'Gestion des artistes'}
            {location.pathname === '/programmateurs' && 'Gestion des programmateurs'}
            {location.pathname === '/emails' && 'Système d\'emails'}
            {location.pathname === '/documents' && 'Gestion des documents'}
            {location.pathname === '/parametres' && 'Paramètres'}
          </div>
          
          <div className="user-menu">
            {currentUser && (
              <>
                <span className="user-name">{currentUser.name || 'Utilisateur'}</span>
                <button onClick={handleLogout} className="logout-btn">
                  Déconnexion
                </button>
              </>
            )}
          </div>
        </header>
        
        <main className="main-container">
          <Outlet />
        </main>
        
        <footer className="app-footer">
          <p>&copy; {new Date().getFullYear()} App Booking - Tous droits réservés</p>
        </footer>
      </div>
    </div>
  );
};

export default Layout;
EOL

echo "Fichier Layout.js modifié."

# Modification du App.js pour ajouter les routes pour contrats et factures
cat > ./client/src/App.js << 'EOL'
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import './App.css';

// Composants
import Layout from './components/common/Layout';
import Login from './components/auth/Login';
import NotFound from './components/common/NotFound';
import Dashboard from './components/dashboard/Dashboard';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import EmailSystem from './components/emails/EmailSystem';
import DocumentsManager from './components/documents/DocumentsManager';
import TestFirebaseIntegration from './components/tests/TestFirebaseIntegration';
import ArtistEdit from './components/artists/ArtistEdit';
import ContractsTable from './components/contracts/ContractsTable';

// Route protégée
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading, bypassEnabled } = useAuth();
  
  if (loading) {
    return <div>Chargement...</div>;
  }
  
  // Si le mode bypass est activé, on autorise l'accès même sans authentification
  if (bypassEnabled) {
    console.log('Mode bypass d\'authentification activé - Accès autorisé');
    return children;
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }
  
  return children;
};

function App() {
  const { bypassEnabled } = useAuth();

  return (
    <div className="App">
      <Routes>
        {/* Si le mode bypass est activé, la page de login redirige vers le dashboard */}
        <Route path="/login" element={
          bypassEnabled ? <Navigate to="/" /> : <Login />
        } />
        
        <Route path="/" element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }>
          <Route index element={<Dashboard />} />
          <Route path="contrats" element={<ContractsTable />} />
          <Route path="factures" element={<div>Module Factures à venir</div>} />
          <Route path="programmateurs" element={<ProgrammersList />} />
          <Route path="programmateurs/:id" element={<ProgrammerDetail />} />
          <Route path="concerts" element={<ConcertsList />} />
          <Route path="concerts/:id" element={<ConcertDetail />} />
          <Route path="artistes" element={<ArtistsList />} />
          <Route path="artistes/:id" element={<ArtistDetail />} />
          <Route path="emails" element={<EmailSystem />} />
          <Route path="documents" element={<DocumentsManager />} />
          <Route path="tests" element={<TestFirebaseIntegration />} />
        </Route>
        
        <Route path="*" element={<NotFound />} />
      </Routes>
      
      {/* Bannière d'information sur le mode bypass */}
      {bypassEnabled && (
        <div style={{
          position: 'fixed',
          bottom: 0,
          left: 0,
          right: 0,
          backgroundColor: '#fff3cd',
          color: '#856404',
          padding: '10px',
          textAlign: 'center',
          borderTop: '1px solid #ffeeba',
          zIndex: 1000
        }}>
          Mode test activé - Authentification désactivée
        </div>
      )}
    </div>
  );
}

export default App;
EOL

echo "Fichier App.js modifié."

echo "Toutes les modifications ont été effectuées avec succès."
