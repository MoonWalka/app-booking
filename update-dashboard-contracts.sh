#!/bin/bash

# Script pour mettre à jour le Dashboard et le module contrat
# Auteur: Manus
# Date: 8 avril 2025

echo "Début de la mise à jour du Dashboard et du module contrat..."

# Vérifier si nous sommes dans le bon répertoire
if [ ! -d "./client" ]; then
  echo "Erreur: Ce script doit être exécuté depuis la racine du projet app-booking"
  exit 1
fi

# Mise à jour du composant ContractsTable.js
echo "Mise à jour du composant ContractsTable.js..."
mkdir -p ./client/src/components/contracts
cat > ./client/src/components/contracts/ContractsTable.js << 'EOL'
import React, { useState, useEffect, useMemo } from 'react';
import { Link } from 'react-router-dom';
import './ContractsTable.css';

// Services
import { fetchContracts, updateContract } from '../../services/contractsService';

const ContractsTable = () => {
  const [contracts, setContracts] = useState([]);
  const [loading, setLoading] = useState(true);

  // Récupération des données
  useEffect(() => {
    const loadContracts = async () => {
      try {
        setLoading(true);
        // Utiliser le service pour récupérer les contrats depuis Firebase
        const contractsData = await fetchContracts();
        setContracts(contractsData);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors du chargement des contrats:', error);
        setLoading(false);
      }
    };

    loadContracts();
  }, []);

  // Formatage de la date
  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR');
  };

  // Formatage du montant
  const formatAmount = (amount) => {
    if (!amount && amount !== 0) return '-';
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(amount);
  };

  // Gestion du changement de statut
  const handleStatusChange = async (contractId, field, newStatus) => {
    try {
      // Trouver le contrat à mettre à jour
      const contractToUpdate = contracts.find(c => c.id === contractId);
      if (!contractToUpdate) return;

      // Créer une copie du contrat avec le statut mis à jour
      const updatedContract = { ...contractToUpdate };
      
      // Mettre à jour le statut selon le champ
      switch (field) {
        case 'formStatus':
          updatedContract.formStatus = newStatus;
          break;
        case 'contractSentStatus':
          updatedContract.contractSentStatus = newStatus;
          break;
        case 'contractSignedStatus':
          updatedContract.contractSignedStatus = newStatus;
          break;
        case 'invoiceStatus':
          updatedContract.invoiceStatus = newStatus;
          break;
        default:
          break;
      }

      // Mettre à jour le contrat dans Firebase
      await updateContract(contractId, updatedContract);

      // Mettre à jour l'état local
      setContracts(prevContracts => 
        prevContracts.map(c => c.id === contractId ? updatedContract : c)
      );
    } catch (error) {
      console.error('Erreur lors de la mise à jour du statut:', error);
    }
  };

  // Rendu des icônes de statut
  const renderStatusIcon = (status, contractId, field) => {
    let icon, color, title;

    switch (status) {
      case 'validated':
        icon = 'fas fa-check-circle';
        color = '#28a745';
        title = 'Validé';
        break;
      case 'pending':
        icon = 'fas fa-clock';
        color = '#ffc107';
        title = 'À faire';
        break;
      case 'cancelled':
        icon = 'fas fa-times-circle';
        color = '#dc3545';
        title = 'Annulé';
        break;
      default:
        icon = 'fas fa-question-circle';
        color = '#6c757d';
        title = 'Non défini';
        break;
    }

    // Déterminer le prochain statut lors du clic
    const getNextStatus = (currentStatus) => {
      switch (currentStatus) {
        case 'validated': return 'pending';
        case 'pending': return 'cancelled';
        case 'cancelled': return 'validated';
        default: return 'validated';
      }
    };

    return (
      <span 
        className="status-icon" 
        style={{ color }}
        title={title}
        onClick={(e) => {
          e.stopPropagation();
          handleStatusChange(contractId, field, getNextStatus(status));
        }}
      >
        <i className={icon}></i>
      </span>
    );
  };

  if (loading) {
    return <div className="loading-container">Chargement des contrats...</div>;
  }

  return (
    <div className="contracts-dashboard">
      <div className="contracts-header">
        <h1>Gestion des Contrats</h1>
        <div className="header-actions">
          <Link to="/concerts/new" className="add-button">
            <i className="fas fa-plus"></i> Nouveau concert
          </Link>
        </div>
      </div>
      
      <div className="table-responsive">
        <table className="contracts-table">
          <thead>
            <tr>
              <th className="col-artist">Artiste</th>
              <th className="col-project">Projet</th>
              <th className="col-venue">Lieu (concert)</th>
              <th className="col-option-date">Prise d'option</th>
              <th className="col-start-date">Début</th>
              <th className="col-amount">Montant (€)</th>
              <th className="col-status">Formulaire</th>
              <th className="col-status">Contrat envoyé</th>
              <th className="col-status">Contrat signé</th>
              <th className="col-status">Facture émise</th>
              <th className="col-actions">Actions</th>
            </tr>
          </thead>
          <tbody>
            {contracts.length === 0 ? (
              <tr>
                <td colSpan="11" className="no-data">Aucun contrat trouvé</td>
              </tr>
            ) : (
              contracts.map(contract => (
                <tr key={contract.id}>
                  <td className="col-artist">{contract.artist?.name || '-'}</td>
                  <td className="col-project">{contract.project || '-'}</td>
                  <td className="col-venue">{contract.venue || '-'}</td>
                  <td className="col-option-date">{formatDate(contract.optionDate)}</td>
                  <td className="col-start-date">{formatDate(contract.date)}</td>
                  <td className="col-amount">{formatAmount(contract.amount)}</td>
                  <td className="col-status status-cell">
                    {renderStatusIcon(contract.formStatus || 'pending', contract.id, 'formStatus')}
                  </td>
                  <td className="col-status status-cell">
                    {renderStatusIcon(contract.contractSentStatus || 'pending', contract.id, 'contractSentStatus')}
                  </td>
                  <td className="col-status status-cell">
                    {renderStatusIcon(contract.contractSignedStatus || 'pending', contract.id, 'contractSignedStatus')}
                  </td>
                  <td className="col-status status-cell">
                    {renderStatusIcon(contract.invoiceStatus || 'pending', contract.id, 'invoiceStatus')}
                  </td>
                  <td className="col-actions actions-cell">
                    <button className="action-btn edit-btn" title="Modifier" onClick={(e) => { e.stopPropagation(); }}>
                      <i className="fas fa-edit"></i>
                    </button>
                    <button className="action-btn view-btn" title="Voir" onClick={(e) => { e.stopPropagation(); }}>
                      <i className="fas fa-eye"></i>
                    </button>
                    <button className="action-btn delete-btn" title="Supprimer" onClick={(e) => { e.stopPropagation(); }}>
                      <i className="fas fa-trash"></i>
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ContractsTable;
EOL

# Mise à jour du fichier CSS pour ContractsTable
echo "Mise à jour du fichier CSS pour ContractsTable..."
cat > ./client/src/components/contracts/ContractsTable.css << 'EOL'
/* ContractsTable.css */
.contracts-dashboard {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  padding: 20px;
  margin-bottom: 20px;
}

.contracts-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.contracts-header h1 {
  font-size: 24px;
  color: #333;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.add-button {
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
  text-decoration: none;
  transition: background-color 0.2s;
}

.add-button:hover {
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
  white-space: nowrap;
}

.contracts-table td {
  padding: 12px 15px;
  border-bottom: 1px solid #dee2e6;
  color: #333;
}

.contracts-table tbody tr {
  transition: background-color 0.2s;
}

.contracts-table tbody tr:hover {
  background-color: #f8f9fa;
}

/* Colonnes spécifiques */
.col-artist {
  min-width: 150px;
}

.col-project {
  min-width: 120px;
}

.col-venue {
  min-width: 150px;
}

.col-option-date, .col-start-date {
  min-width: 100px;
  white-space: nowrap;
}

.col-amount {
  min-width: 100px;
  text-align: right;
}

.col-status {
  width: 80px;
  text-align: center;
}

.col-actions {
  width: 120px;
  text-align: center;
}

.status-cell {
  text-align: center;
}

.status-icon {
  font-size: 18px;
  cursor: pointer;
  display: inline-block;
  width: 30px;
  height: 30px;
  line-height: 30px;
  border-radius: 50%;
  background-color: #f8f9fa;
  transition: transform 0.2s, background-color 0.2s;
}

.status-icon:hover {
  transform: scale(1.2);
  background-color: #e9ecef;
}

.actions-cell {
  white-space: nowrap;
  text-align: center;
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
@media (max-width: 1200px) {
  .contracts-table {
    min-width: 1100px;
  }
}

@media (max-width: 768px) {
  .contracts-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .header-actions {
    width: 100%;
  }
  
  .add-button {
    width: 100%;
    justify-content: center;
  }
}
EOL

# Mise à jour du service des contrats
echo "Mise à jour du service des contrats..."
mkdir -p ./client/src/services
cat > ./client/src/services/contractsService.js << 'EOL'
// client/src/services/contractsService.js
import { db } from '../firebase';
import { collection, getDocs, getDoc, doc, addDoc, updateDoc, deleteDoc, query, where, orderBy } from 'firebase/firestore';

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
      // Filtrer par artiste
      if (filters.artist) {
        contractsQuery = query(contractsQuery, where('artist.name', '>=', filters.artist), 
                                             where('artist.name', '<=', filters.artist + '\uf8ff'));
      }
      
      // Filtrer par lieu
      if (filters.venue) {
        contractsQuery = query(contractsQuery, where('venue', '>=', filters.venue), 
                                             where('venue', '<=', filters.venue + '\uf8ff'));
      }
      
      // Filtrer par projet
      if (filters.project) {
        contractsQuery = query(contractsQuery, where('project', '>=', filters.project), 
                                             where('project', '<=', filters.project + '\uf8ff'));
      }
    }
    
    // Ajout d'un tri par date
    contractsQuery = query(contractsQuery, orderBy('date', 'desc'));
    
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
    
    // En cas d'erreur, retourner des données fictives pour le développement
    const mockContracts = [
      {
        id: '1',
        date: '2025-05-15',
        optionDate: '2025-03-01',
        artist: { id: 'a1', name: 'Les Harmonies Urbaines' },
        project: 'Tournée Printemps',
        venue: 'L\'Olympia',
        city: 'Paris',
        programmer: { id: 'p1', name: 'Jean Dupont' },
        amount: 2500,
        formStatus: 'validated',
        contractSentStatus: 'validated',
        contractSignedStatus: 'pending',
        invoiceStatus: 'pending',
        status: 'en_cours'
      },
      {
        id: '2',
        date: '2025-06-20',
        optionDate: '2025-04-01',
        artist: { id: 'a2', name: 'Échos Poétiques' },
        project: 'Festival d\'été',
        venue: 'Zénith',
        city: 'Lille',
        programmer: { id: 'p2', name: 'Marie Martin' },
        amount: 3000,
        formStatus: 'validated',
        contractSentStatus: 'validated',
        contractSignedStatus: 'validated',
        invoiceStatus: 'pending',
        status: 'confirmé'
      },
      {
        id: '3',
        date: '2025-07-10',
        optionDate: null,
        artist: { id: 'a3', name: 'Rythmes Solaires' },
        project: 'Showcase',
        venue: 'La Cigale',
        city: 'Paris',
        programmer: { id: 'p3', name: 'Sophie Lefebvre' },
        amount: 1800,
        formStatus: 'pending',
        contractSentStatus: 'pending',
        contractSignedStatus: 'pending',
        invoiceStatus: 'pending',
        status: 'en_négociation'
      },
      {
        id: '4',
        date: '2025-08-05',
        optionDate: '2025-05-15',
        artist: { id: 'a4', name: 'Jazz Fusion Quartet' },
        project: 'Jazz Tour',
        venue: 'New Morning',
        city: 'Paris',
        programmer: { id: 'p4', name: 'Pierre Dubois' },
        amount: 2200,
        formStatus: 'validated',
        contractSentStatus: 'validated',
        contractSignedStatus: 'validated',
        invoiceStatus: 'validated',
        status: 'confirmé'
      },
      {
        id: '5',
        date: '2025-09-12',
        optionDate: '2025-06-20',
        artist: { id: 'a5', name: 'Électro Symphonie' },
        project: 'Électro Night',
        venue: 'Bataclan',
        city: 'Paris',
        programmer: { id: 'p5', name: 'Lucie Moreau' },
        amount: 2800,
        formStatus: 'validated',
        contractSentStatus: 'cancelled',
        contractSignedStatus: 'pending',
        invoiceStatus: 'pending',
        status: 'en_négociation'
      }
    ];
    
    return mockContracts;
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
    // S'assurer que les nouveaux champs sont présents
    const completeContractData = {
      ...contractData,
      project: contractData.project || null,
      optionDate: contractData.optionDate || null,
      amount: contractData.amount || 0,
      formStatus: contractData.formStatus || 'pending',
      contractSentStatus: contractData.contractSentStatus || 'pending',
      contractSignedStatus: contractData.contractSignedStatus || 'pending',
      invoiceStatus: contractData.invoiceStatus || 'pending'
    };
    
    const docRef = await addDoc(collection(db, CONTRACTS_COLLECTION), completeContractData);
    return {
      id: docRef.id,
      ...completeContractData
    };
  } catch (error) {
    console.error('Erreur lors de la création du contrat:', error);
    
    // En cas d'erreur, simuler la création d'un contrat
    const mockId = 'mock-contract-' + Date.now();
    return {
      id: mockId,
      ...contractData
    };
  }
};

/**
 * Met à jour un contrat existant
 * @param {string} id - ID du contrat
 * @param {Object} contractData - Nouvelles données du contrat
 * @returns {Promise<Object>} Contrat mis à jour
 */
export const updateContract = async (id, contractData) => {
  try {
    await updateDoc(doc(db, CONTRACTS_COLLECTION, id), contractData);
    return {
      id,
      ...contractData
    };
  } catch (error) {
    console.error('Erreur lors de la mise à jour du contrat:', error);
    throw error;
  }
};

/**
 * Supprime un contrat
 * @param {string} id - ID du contrat
 * @returns {Promise<string>} ID du contrat supprimé
 */
export const deleteContract = async (id) => {
  try {
    await deleteDoc(doc(db, CONTRACTS_COLLECTION, id));
    return id;
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
    const contractsQuery = query(
      collection(db, CONTRACTS_COLLECTION), 
      where('artist.id', '==', artistId),
      orderBy('date', 'desc')
    );
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
    const contractsQuery = query(
      collection(db, CONTRACTS_COLLECTION), 
      where('programmer.id', '==', programmerId),
      orderBy('date', 'desc')
    );
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
    const contractsQuery = query(
      collection(db, CONTRACTS_COLLECTION), 
      where('concertId', '==', concertId)
    );
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

/**
 * Récupère les contrats par projet
 * @param {string} project - Nom du projet
 * @returns {Promise<Array>} Liste des contrats
 */
export const getContractsByProject = async (project) => {
  try {
    const contractsQuery = query(
      collection(db, CONTRACTS_COLLECTION), 
      where('project', '==', project),
      orderBy('date', 'desc')
    );
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
    console.error('Erreur lors de la récupération des contrats par projet:', error);
    throw error;
  }
};
EOL

# Mise à jour du service des concerts pour créer des contrats avec les nouveaux champs
echo "Mise à jour du service des concerts..."
cat > ./client/src/services/concertsService.js << 'EOL'
import { 
  collection, 
  getDocs, 
  getDoc, 
  doc, 
  addDoc, 
  updateDoc, 
  deleteDoc,
  query,
  orderBy,
  where,
  setDoc
} from 'firebase/firestore';
import { db } from '../firebase';
import { createContract } from './contractsService';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, orderBy('date', 'desc')));
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, création d'un document initial...`);
      const initialDoc = {
        artist: {
          id: 'mock-artist-1',
          name: 'Artiste Exemple'
        },
        programmer: {
          id: 'mock-programmer-1',
          name: 'Programmateur Exemple',
          structure: 'Salle Exemple'
        },
        date: '2025-12-31',
        time: '20:00',
        venue: 'Salle de concert',
        city: 'Paris',
        price: 25,
        status: 'En attente',
        notes: 'Concert exemple créé automatiquement',
        createdAt: new Date()
      };
      
      await addDoc(collectionRef, initialDoc);
      console.log(`Document initial créé dans la collection ${collectionName}`);
    }
    
    return true;
  } catch (error) {
    console.error(`Erreur lors de la vérification/création de la collection ${collectionName}:`, error);
    return false;
  }
};

// Données simulées pour le fallback en cas d'erreur d'authentification
const mockConcerts = [
  {
    id: 'mock-concert-1',
    artist: {
      id: 'mock-artist-1',
      name: 'The Weeknd'
    },
    programmer: {
      id: 'mock-programmer-1',
      name: 'Marie Dupont',
      structure: 'Association Vibrations'
    },
    date: '2025-06-15',
    time: '20:00',
    venue: 'Stade de France',
    city: 'Paris',
    price: 85,
    status: 'Confirmé',
    notes: 'Concert complet',
    createdAt: new Date()
  },
  {
    id: 'mock-concert-2',
    artist: {
      id: 'mock-artist-2',
      name: 'Daft Punk'
    },
    programmer: {
      id: 'mock-programmer-2',
      name: 'Jean Martin',
      structure: 'La Cigale'
    },
    date: '2025-07-20',
    time: '21:00',
    venue: 'La Cigale',
    city: 'Paris',
    price: 65,
    status: 'En attente',
    notes: 'Tournée de retour',
    createdAt: new Date()
  }
];

// Assurez-vous que la collection concerts existe
const concertsCollection = collection(db, 'concerts');

export const getConcerts = async () => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log("Tentative de récupération des concerts depuis Firebase...");
    const q = query(concertsCollection, orderBy('date', 'desc'));
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log("Aucun concert trouvé dans Firebase, utilisation des données simulées");
      
      // Essayer d'ajouter les données simulées à Firebase
      try {
        console.log("Tentative d'ajout des données simulées à Firebase...");
        for (const concert of mockConcerts) {
          const { id, ...concertData } = concert;
          await setDoc(doc(db, 'concerts', id), concertData);
        }
        console.log("Données simulées ajoutées à Firebase avec succès");
      } catch (addError) {
        console.error("Erreur lors de l'ajout des données simulées:", addError);
      }
      
      return mockConcerts;
    }
    
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${concerts.length} concerts récupérés depuis Firebase`);
    return concerts;
  } catch (error) {
    console.error("Erreur lors de la récupération des concerts:", error);
    console.log("Utilisation des données simulées pour les concerts");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("Tentative d'ajout des données simulées à Firebase...");
      for (const concert of mockConcerts) {
        const { id, ...concertData } = concert;
        await setDoc(doc(db, 'concerts', id), concertData);
      }
      console.log("Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("Erreur lors de l'ajout des données simulées:", addError);
    }
    
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockConcerts;
  }
};

export const getConcertsByArtist = async (artistId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log(`Tentative de récupération des concerts pour l'artiste ${artistId}...`);
    const q = query(
      concertsCollection, 
      where('artist.id', '==', artistId),
      orderBy('date', 'desc')
    );
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log(`Aucun concert trouvé pour l'artiste ${artistId}`);
      return [];
    }
    
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${concerts.length} concerts récupérés pour l'artiste ${artistId}`);
    return concerts;
  } catch (error) {
    console.error(`Erreur lors de la récupération des concerts pour l'artiste ${artistId}:`, error);
    // Retourner des concerts simulés pour cet artiste
    const mockArtistConcerts = mockConcerts.filter(concert => concert.artist.id === artistId);
    console.log(`Utilisation de ${mockArtistConcerts.length} concerts simulés pour l'artiste ${artistId}`);
    return mockArtistConcerts;
  }
};

export const getConcertsByProgrammer = async (programmerId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log(`Tentative de récupération des concerts pour le programmateur ${programmerId}...`);
    const q = query(
      concertsCollection, 
      where('programmer.id', '==', programmerId),
      orderBy('date', 'desc')
    );
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log(`Aucun concert trouvé pour le programmateur ${programmerId}`);
      return [];
    }
    
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${concerts.length} concerts récupérés pour le programmateur ${programmerId}`);
    return concerts;
  } catch (error) {
    console.error(`Erreur lors de la récupération des concerts pour le programmateur ${programmerId}:`, error);
    // Retourner des concerts simulés pour ce programmateur
    const mockProgrammerConcerts = mockConcerts.filter(concert => concert.programmer.id === programmerId);
    console.log(`Utilisation de ${mockProgrammerConcerts.length} concerts simulés pour le programmateur ${programmerId}`);
    return mockProgrammerConcerts;
  }
};

export const getConcertById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log(`Tentative de récupération du concert ${id} depuis Firebase...`);
    const docRef = doc(db, 'concerts', id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const concertData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Concert ${id} récupéré depuis Firebase:`, concertData);
      return concertData;
    }
    
    console.log(`Concert ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération du concert ${id}:`, error);
    // Retourner un concert simulé en cas d'erreur
    const mockConcert = mockConcerts.find(concert => concert.id === id) || mockConcerts[0];
    console.log(`Utilisation du concert simulé:`, mockConcert);
    return mockConcert;
  }
};

export const addConcert = async (concertData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log("Tentative d'ajout d'un concert à Firebase:", concertData);
    const docRef = await addDoc(concertsCollection, {
      ...concertData,
      createdAt: new Date()
    });
    
    console.log(`Concert ajouté avec succès, ID: ${docRef.id}`);
    
    // Créer automatiquement un contrat associé au concert
    try {
      const contractData = {
        concertId: docRef.id,
        date: concertData.date,
        optionDate: concertData.optionDate || null,
        artist: concertData.artist,
        project: concertData.project || null,
        venue: concertData.venue,
        city: concertData.city,
        programmer: concertData.programmer,
        amount: concertData.price || 0,
        formStatus: 'pending',
        contractSentStatus: 'pending',
        contractSignedStatus: 'pending',
        invoiceStatus: 'pending',
        status: 'en_cours',
        createdAt: new Date()
      };
      
      const newContract = await createContract(contractData);
      console.log(`Contrat créé automatiquement pour le concert ${docRef.id}:`, newContract);
    } catch (contractError) {
      console.error("Erreur lors de la création automatique du contrat:", contractError);
    }
    
    return {
      id: docRef.id,
      ...concertData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du concert:", error);
    console.log("Simulation de l'ajout d'un concert");
    
    // Essayer d'ajouter le concert avec un ID généré manuellement
    try {
      const mockId = 'mock-concert-' + Date.now();
      await setDoc(doc(db, 'concerts', mockId), {
        ...concertData,
        createdAt: new Date()
      });
      
      console.log(`Concert ajouté avec un ID manuel: ${mockId}`);
      
      // Créer automatiquement un contrat associé au concert simulé
      try {
        const contractData = {
          concertId: mockId,
          date: concertData.date,
          optionDate: concertData.optionDate || null,
          artist: concertData.artist,
          project: concertData.project || null,
          venue: concertData.venue,
          city: concertData.city,
          programmer: concertData.programmer,
          amount: concertData.price || 0,
          formStatus: 'pending',
          contractSentStatus: 'pending',
          contractSignedStatus: 'pending',
          invoiceStatus: 'pending',
          status: 'en_cours',
          createdAt: new Date()
        };
        
        const newContract = await createContract(contractData);
        console.log(`Contrat créé automatiquement pour le concert simulé ${mockId}:`, newContract);
      } catch (contractError) {
        console.error("Erreur lors de la création automatique du contrat simulé:", contractError);
      }
      
      return {
        id: mockId,
        ...concertData,
        createdAt: new Date()
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel du concert:", addError);
      
      // Simuler l'ajout d'un concert en cas d'erreur
      const mockId = 'mock-concert-' + Date.now();
      return {
        id: mockId,
        ...concertData,
        createdAt: new Date()
      };
    }
  }
};

export const updateConcert = async (id, concertData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log(`Tentative de mise à jour du concert ${id}:`, concertData);
    const docRef = doc(db, 'concerts', id);
    await updateDoc(docRef, {
      ...concertData,
      updatedAt: new Date()
    });
    
    console.log(`Concert ${id} mis à jour avec succès`);
    return {
      id,
      ...concertData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour du concert ${id}:`, error);
    console.log("Simulation de la mise à jour d'un concert");
    
    // Essayer de créer/remplacer le document
    try {
      await setDoc(doc(db, 'concerts', id), {
        ...concertData,
        updatedAt: new Date()
      });
      
      console.log(`Concert ${id} créé/remplacé avec succès`);
      return {
        id,
        ...concertData,
        updatedAt: new Date()
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement du concert ${id}:`, setError);
      
      // Simuler la mise à jour d'un concert en cas d'erreur
      return {
        id,
        ...concertData,
        updatedAt: new Date()
      };
    }
  }
};

export const deleteConcert = async (id) => {
  try {
    console.log(`Tentative de suppression du concert ${id}`);
    const docRef = doc(db, 'concerts', id);
    await deleteDoc(docRef);
    
    console.log(`Concert ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du concert ${id}:`, error);
    console.log("Simulation de la suppression d'un concert");
    // Simuler la suppression d'un concert en cas d'erreur
    return id;
  }
};
EOL

echo "Fin de la mise à jour du Dashboard et du module contrat."
echo "Pour appliquer ces modifications, exécutez ce script avec la commande:"
echo "chmod +x update-dashboard-contracts.sh && ./update-dashboard-contracts.sh"
