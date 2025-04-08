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
