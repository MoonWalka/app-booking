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
