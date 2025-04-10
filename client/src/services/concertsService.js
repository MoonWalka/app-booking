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
  setDoc,
  Timestamp
} from 'firebase/firestore';
import { db } from '../firebase';

// Collection de référence
const CONCERTS_COLLECTION = 'concerts';

// Assurez-vous que la collection concerts existe
const concertsCollection = collection(db, CONCERTS_COLLECTION);

/**
 * Récupère tous les concerts
 * @param {Object} filters - Filtres à appliquer (optionnel)
 * @returns {Promise<Array>} Liste des concerts
 */
export const getConcerts = async (filters = {}) => {
  try {
    console.log("[getConcerts] Tentative de récupération des concerts depuis Firebase...");
    console.log("[getConcerts] Filtres appliqués:", filters);
    
    // Création d'une requête de base
    let concertsQuery = concertsCollection;
    
    // Application des filtres si nécessaire
    if (filters) {
      // Filtrer par programmateur
      if (filters.programmerId) {
        concertsQuery = query(concertsQuery, where('programmerId', '==', filters.programmerId));
      }
      
      // Filtrer par artiste
      if (filters.artistId) {
        concertsQuery = query(concertsQuery, where('artistId', '==', filters.artistId));
      }
      
      // Filtrer par lieu
      if (filters.venue) {
        concertsQuery = query(concertsQuery, where('venue', '==', filters.venue));
      }
      
      // Filtrer par token commun
      if (filters.commonToken) {
        concertsQuery = query(concertsQuery, where('commonToken', '==', filters.commonToken));
      }
    }
    
    // Ajout d'un tri par date (du plus récent au plus ancien)
    concertsQuery = query(concertsQuery, orderBy('date', 'desc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(concertsQuery);
    
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      // Convertir les timestamps en objets Date pour faciliter l'utilisation
      date: doc.data().date ? new Date(doc.data().date.seconds * 1000) : null
    }));
    
    console.log(`[getConcerts] ${concerts.length} concerts récupérés depuis Firebase`);
    return concerts;
  } catch (error) {
    console.error("[getConcerts] Erreur lors de la récupération des concerts:", error);
    throw error;
  }
};

/**
 * Récupère un concert par son ID
 * @param {string} id - ID du concert
 * @returns {Promise<Object>} Données du concert
 */
export const getConcertById = async (id) => {
  try {
    console.log(`[getConcertById] Tentative de récupération du concert ${id} depuis Firebase...`);
    
    const docRef = doc(db, CONCERTS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const concertData = {
        id: snapshot.id,
        ...snapshot.data(),
        // Convertir les timestamps en objets Date pour faciliter l'utilisation
        date: snapshot.data().date ? new Date(snapshot.data().date.seconds * 1000) : null
      };
      console.log(`[getConcertById] Concert ${id} récupéré depuis Firebase`);
      return concertData;
    }
    
    console.log(`[getConcertById] Concert ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`[getConcertById] Erreur lors de la récupération du concert ${id}:`, error);
    throw error;
  }
};

/**
 * Ajoute un nouveau concert
 * @param {Object} concertData - Données du concert
 * @returns {Promise<Object>} Concert créé avec ID
 */
export const addConcert = async (concertData) => {
  try {
    console.log("[addConcert] Tentative d'ajout d'un concert à Firebase:", concertData);
    
    // Convertir la date en Timestamp si elle existe
    const dataToAdd = {
      ...concertData,
      date: concertData.date ? Timestamp.fromDate(new Date(concertData.date)) : null
    };
    
    const docRef = await addDoc(concertsCollection, dataToAdd);
    console.log(`[addConcert] Concert ajouté avec succès, ID: ${docRef.id}`);
    
    return {
      id: docRef.id,
      ...concertData
    };
  } catch (error) {
    console.error("[addConcert] Erreur lors de l'ajout du concert:", error);
    throw error;
  }
};

/**
 * Met à jour un concert existant
 * @param {string} id - ID du concert
 * @param {Object} concertData - Nouvelles données du concert
 * @returns {Promise<Object>} Concert mis à jour
 */
export const updateConcert = async (id, concertData) => {
  try {
    console.log(`[updateConcert] Tentative de mise à jour du concert ${id}:`, concertData);
    
    // Convertir la date en Timestamp si elle existe
    const dataToUpdate = {
      ...concertData
    };
    
    if (concertData.date) {
      dataToUpdate.date = concertData.date instanceof Date ? 
        Timestamp.fromDate(concertData.date) : 
        Timestamp.fromDate(new Date(concertData.date));
    }
    
    // Vérifier si le concert existe déjà
    const docRef = doc(db, CONCERTS_COLLECTION, id);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      // Mettre à jour le concert existant
      await updateDoc(docRef, dataToUpdate);
      console.log(`[updateConcert] Concert ${id} mis à jour avec succès`);
    } else {
      // Créer un nouveau concert avec l'ID spécifié
      await setDoc(docRef, dataToUpdate);
      console.log(`[updateConcert] Nouveau concert créé avec ID spécifié: ${id}`);
    }
    
    return {
      id,
      ...concertData
    };
  } catch (error) {
    console.error(`[updateConcert] Erreur lors de la mise à jour du concert ${id}:`, error);
    throw error;
  }
};

/**
 * Supprime un concert
 * @param {string} id - ID du concert
 * @returns {Promise<boolean>} Succès de la suppression
 */
export const deleteConcert = async (id) => {
  try {
    console.log(`[deleteConcert] Tentative de suppression du concert ${id}`);
    
    const docRef = doc(db, CONCERTS_COLLECTION, id);
    await deleteDoc(docRef);
    
    console.log(`[deleteConcert] Concert ${id} supprimé avec succès`);
    return true;
  } catch (error) {
    console.error(`[deleteConcert] Erreur lors de la suppression du concert ${id}:`, error);
    throw error;
  }
};

/**
 * Récupère les concerts par token commun
 * @param {string} commonToken - Token commun
 * @returns {Promise<Array>} Liste des concerts
 */
export const getConcertsByToken = async (commonToken) => {
  return getConcerts({ commonToken });
};
