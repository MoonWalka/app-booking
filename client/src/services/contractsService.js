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
    const docRef = await addDoc(collection(db, CONTRACTS_COLLECTION), contractData);
    return {
      id: docRef.id,
      ...contractData
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
 * @returns {Promise<void>}
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
 * @returns {Promise<void>}
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
 * Met à jour le statut d'un contrat
 * @param {string} id - ID du contrat
 * @param {string} status - Nouveau statut
 * @returns {Promise<Object>} Contrat mis à jour
 */
export const updateContractStatus = async (id, status) => {
  try {
    const contractRef = doc(db, CONTRACTS_COLLECTION, id);
    await updateDoc(contractRef, { status });
    
    // Récupérer le contrat mis à jour
    const updatedContract = await getContractById(id);
    return updatedContract;
  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut du contrat:', error);
    throw error;
  }
};
