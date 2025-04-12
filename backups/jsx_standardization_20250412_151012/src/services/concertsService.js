import { db } from '../firebase';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  Timestamp,
  setDoc
} from 'firebase/firestore';

// Nom de la collection dans Firestore
const CONCERTS_COLLECTION = 'concerts';
const concertsCollection = collection(db, CONCERTS_COLLECTION);

/**
 * Récupère la liste des concerts avec filtrage optionnel
 * @param {Object} filters - Filtres à appliquer (artistId, programmerId, etc.)
 * @returns {Promise<Array>} Liste des concerts
 */
export const getConcerts = async (filters = {}) => {
  try {
    console.log("[getConcerts] Tentative de récupération des concerts depuis Firebase avec filtres:", filters);
    
    // Construire la requête avec les filtres
    let concertsQuery = concertsCollection;
    
    if (filters.artistId) {
      console.log(`[getConcerts] Filtrage par artiste: ${filters.artistId}`);
      concertsQuery = query(concertsQuery, where('artist.id', '==', filters.artistId));
    }
    
    if (filters.programmerId) {
      console.log(`[getConcerts] Filtrage par programmateur: ${filters.programmerId}`);
      concertsQuery = query(concertsQuery, where('programmer.id', '==', filters.programmerId));
    }
    
    if (filters.status) {
      console.log(`[getConcerts] Filtrage par statut: ${filters.status}`);
      concertsQuery = query(concertsQuery, where('status', '==', filters.status));
    }
    
    if (filters.commonToken) {
      console.log(`[getConcerts] Filtrage par token commun: ${filters.commonToken}`);
      concertsQuery = query(concertsQuery, where('commonToken', '==', filters.commonToken));
    }
    
    // Tri par date décroissante
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
      console.log(`[getConcertById] Concert ${id} récupéré depuis Firebase:`, concertData);
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
    
    // Validation des données
    validateConcertData(concertData);
    
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
    
    // Validation des données
    validateConcertData(concertData);
    
    // Convertir la date en Timestamp si elle existe
    const dataToUpdate = {
      ...concertData
    };
    
    if (concertData.date) {
      dataToUpdate.date = concertData.date instanceof Date ? 
        Timestamp.fromDate(concertData.date) : 
        Timestamp.fromDate(new Date(concertData.date));
    }
    
    // S'assurer que les objets artist et programmer sont correctement formatés
    if (dataToUpdate.artist && typeof dataToUpdate.artist === 'object') {
      if (!dataToUpdate.artist.id) dataToUpdate.artist.id = '';
      if (!dataToUpdate.artist.name) dataToUpdate.artist.name = '';
    } else {
      dataToUpdate.artist = { id: '', name: '' };
    }
    
    if (dataToUpdate.programmer && typeof dataToUpdate.programmer === 'object') {
      if (!dataToUpdate.programmer.id) dataToUpdate.programmer.id = '';
      if (!dataToUpdate.programmer.name) dataToUpdate.programmer.name = '';
      if (!dataToUpdate.programmer.structure) dataToUpdate.programmer.structure = '';
    } else {
      dataToUpdate.programmer = { id: '', name: '', structure: '' };
    }
    
    // Vérifier si le concert existe déjà
    const docRef = doc(db, CONCERTS_COLLECTION, id);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      // Mettre à jour le concert existant
      await updateDoc(docRef, dataToUpdate);
      console.log(`[updateConcert] Concert ${id} mis à jour avec succès:`, dataToUpdate);
    } else {
      // Créer un nouveau concert avec l'ID spécifié
      await setDoc(docRef, dataToUpdate);
      console.log(`[updateConcert] Nouveau concert créé avec ID spécifié: ${id}`, dataToUpdate);
    }
    
    // Récupérer le concert mis à jour pour confirmer les changements
    const updatedConcert = await getConcertById(id);
    console.log(`[updateConcert] Concert après mise à jour:`, updatedConcert);
    
    return updatedConcert || {
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

/**
 * Récupère les concerts par artiste
 * @param {string} artistId - ID de l'artiste
 * @returns {Promise<Array>} Liste des concerts
 */
export const getConcertsByArtist = async (artistId) => {
  return getConcerts({ artistId });
};

/**
 * Valide les données d'un concert
 * @param {Object} concertData - Données du concert à valider
 * @throws {Error} Si les données sont invalides
 */
const validateConcertData = (concertData) => {
  console.log("[validateConcertData] Validation des données du concert:", concertData);
  
  // Vérifier que les champs obligatoires sont présents
  if (!concertData) {
    throw new Error("Les données du concert sont requises");
  }
  
  // Vérifier que la date est valide si elle est fournie
  if (concertData.date && isNaN(new Date(concertData.date).getTime())) {
    throw new Error("La date du concert est invalide");
  }
  
  // Vérifier que l'artiste est correctement formaté
  if (concertData.artist && typeof concertData.artist !== 'object') {
    throw new Error("L'artiste doit être un objet avec id et name");
  }
  
  // Vérifier que le programmateur est correctement formaté
  if (concertData.programmer && typeof concertData.programmer !== 'object') {
    throw new Error("Le programmateur doit être un objet avec id, name et structure");
  }
  
  console.log("[validateConcertData] Données du concert valides");
};
