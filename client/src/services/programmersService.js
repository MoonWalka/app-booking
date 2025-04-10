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

// Collection de référence
const PROGRAMMERS_COLLECTION = 'programmers';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    console.log(`[ensureCollection] Vérification de la collection ${collectionName}...`);
    
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, limit(1)));
    
    console.log(`[ensureCollection] Résultat de la vérification: ${snapshot.empty ? 'collection vide' : snapshot.size + ' documents trouvés'}`);
    
    return true;
  } catch (error) {
    console.error(`[ensureCollection] Erreur lors de la vérification de la collection ${collectionName}:`, error);
    return false;
  }
};

// Assurez-vous que la collection programmers existe
const programmersCollection = collection(db, PROGRAMMERS_COLLECTION);

/**
 * Récupère tous les programmateurs
 * @returns {Promise<Array>} Liste des programmateurs
 */
export const getProgrammers = async () => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log("[getProgrammers] Tentative de récupération des programmateurs depuis Firebase...");
    
    // Création d'une requête avec tri par nom
    const programmersQuery = query(programmersCollection, orderBy('businessName', 'asc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(programmersQuery);
    
    const programmers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getProgrammers] ${programmers.length} programmateurs récupérés depuis Firebase`);
    return programmers;
  } catch (error) {
    console.error("[getProgrammers] Erreur lors de la récupération des programmateurs:", error);
    throw error;
  }
};

/**
 * Récupère un programmateur par son ID
 * @param {string} id - ID du programmateur ou token commun
 * @returns {Promise<Object>} Données du programmateur
 */
export const getProgrammerById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log(`[getProgrammerById] Tentative de récupération du programmateur ${id} depuis Firebase...`);
    
    // D'abord, essayer de récupérer par ID direct
    const docRef = doc(db, PROGRAMMERS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const programmerData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`[getProgrammerById] Programmateur ${id} récupéré depuis Firebase par ID direct`);
      return programmerData;
    }
    
    // Si non trouvé par ID direct, essayer de rechercher par token commun
    console.log(`[getProgrammerById] Programmateur ${id} non trouvé par ID direct, recherche par token commun...`);
    const tokenQuery = query(programmersCollection, where('commonToken', '==', id));
    const tokenSnapshot = await getDocs(tokenQuery);
    
    if (!tokenSnapshot.empty) {
      const programmerData = {
        id: tokenSnapshot.docs[0].id,
        ...tokenSnapshot.docs[0].data()
      };
      console.log(`[getProgrammerById] Programmateur trouvé par token commun: ${programmerData.id}`);
      return programmerData;
    }
    
    console.log(`[getProgrammerById] Aucun programmateur trouvé pour ${id}`);
    return null;
  } catch (error) {
    console.error(`[getProgrammerById] Erreur lors de la récupération du programmateur ${id}:`, error);
    throw error;
  }
};

/**
 * Ajoute un nouveau programmateur
 * @param {Object} programmerData - Données du programmateur
 * @returns {Promise<Object>} Programmateur créé avec ID
 */
export const addProgrammer = async (programmerData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log("[addProgrammer] Tentative d'ajout d'un programmateur à Firebase:", programmerData);
    
    const docRef = await addDoc(programmersCollection, programmerData);
    console.log(`[addProgrammer] Programmateur ajouté avec succès, ID: ${docRef.id}`);
    
    return {
      id: docRef.id,
      ...programmerData
    };
  } catch (error) {
    console.error("[addProgrammer] Erreur lors de l'ajout du programmateur:", error);
    throw error;
  }
};

/**
 * Met à jour un programmateur existant
 * @param {string} id - ID du programmateur
 * @param {Object} programmerData - Nouvelles données du programmateur
 * @returns {Promise<Object>} Programmateur mis à jour
 */
export const updateProgrammer = async (id, programmerData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log(`[updateProgrammer] Tentative de mise à jour du programmateur ${id}:`, programmerData);
    
    // Vérifier si le programmateur existe déjà
    const docRef = doc(db, PROGRAMMERS_COLLECTION, id);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      // Mettre à jour le programmateur existant
      await updateDoc(docRef, programmerData);
      console.log(`[updateProgrammer] Programmateur ${id} mis à jour avec succès`);
    } else {
      // Créer un nouveau programmateur avec l'ID spécifié
      await setDoc(docRef, programmerData);
      console.log(`[updateProgrammer] Nouveau programmateur créé avec ID spécifié: ${id}`);
    }
    
    return {
      id,
      ...programmerData
    };
  } catch (error) {
    console.error(`[updateProgrammer] Erreur lors de la mise à jour du programmateur ${id}:`, error);
    throw error;
  }
};

/**
 * Supprime un programmateur
 * @param {string} id - ID du programmateur
 * @returns {Promise<boolean>} Succès de la suppression
 */
export const deleteProgrammer = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log(`[deleteProgrammer] Tentative de suppression du programmateur ${id}`);
    
    const docRef = doc(db, PROGRAMMERS_COLLECTION, id);
    await deleteDoc(docRef);
    
    console.log(`[deleteProgrammer] Programmateur ${id} supprimé avec succès`);
    return true;
  } catch (error) {
    console.error(`[deleteProgrammer] Erreur lors de la suppression du programmateur ${id}:`, error);
    throw error;
  }
};

/**
 * Récupère les programmateurs par token commun
 * @param {string} commonToken - Token commun
 * @returns {Promise<Array>} Liste des programmateurs
 */
export const getProgrammersByToken = async (commonToken) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(PROGRAMMERS_COLLECTION);
    
    console.log(`[getProgrammersByToken] Recherche des programmateurs avec token ${commonToken}`);
    
    const tokenQuery = query(programmersCollection, where('commonToken', '==', commonToken));
    const snapshot = await getDocs(tokenQuery);
    
    const programmers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getProgrammersByToken] ${programmers.length} programmateurs trouvés avec token ${commonToken}`);
    return programmers;
  } catch (error) {
    console.error(`[getProgrammersByToken] Erreur lors de la recherche des programmateurs avec token ${commonToken}:`, error);
    throw error;
  }
};
