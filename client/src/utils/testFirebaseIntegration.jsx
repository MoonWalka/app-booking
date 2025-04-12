import { db } from '../firebase';
import { collection, getDocs, addDoc } from 'firebase/firestore';

/**
 * Vérifie si une collection existe dans Firestore
 * @param {string} collectionName - Nom de la collection à vérifier
 * @returns {Promise<boolean>} - True si la collection existe, false sinon
 */
export const checkCollectionExists = async (collectionName) => {
  try {
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(collectionRef);
    return !snapshot.empty;
  } catch (error) {
    console.error(`Erreur lors de la vérification de la collection ${collectionName}:`, error);
    return false;
  }
};

/**
 * Crée une collection si elle n'existe pas déjà
 * @param {string} collectionName - Nom de la collection à créer
 * @param {Object} sampleData - Données d'exemple à ajouter (optionnel)
 * @returns {Promise<boolean>} - True si la création a réussi, false sinon
 */
export const createCollectionIfNotExists = async (collectionName, sampleData = null) => {
  try {
    const exists = await checkCollectionExists(collectionName);
    
    if (!exists && sampleData) {
      const collectionRef = collection(db, collectionName);
      await addDoc(collectionRef, {
        ...sampleData,
        createdAt: new Date(),
        _test: true // Marquer comme donnée de test
      });
      return true;
    }
    
    return exists;
  } catch (error) {
    console.error(`Erreur lors de la création de la collection ${collectionName}:`, error);
    return false;
  }
};

/**
 * Vérifie et crée toutes les collections nécessaires pour l'application
 * @returns {Promise<Object>} - Résultats de la vérification/création pour chaque collection
 */
export const setupAllCollections = async () => {
  const results = {
    artists: false,
    programmers: false,
    concerts: false
  };
  
  // Données d'exemple pour chaque collection
  const sampleArtist = {
    name: "Exemple d'artiste",
    genre: "Genre musical",
    location: "Ville",
    members: 4,
    contactEmail: "email@exemple.com",
    contactPhone: "06 12 34 56 78"
  };
  
  const sampleProgrammer = {
    name: "Exemple de programmateur",
    structure: "Salle/Festival",
    city: "Ville",
    email: "programmateur@exemple.com",
    phone: "07 12 34 56 78"
  };
  
  const sampleConcert = {
    title: "Exemple de concert",
    date: new Date().toISOString().split('T')[0],
    time: "20:00",
    venue: "Lieu du concert",
    city: "Ville",
    status: "planifié"
  };
  
  // Vérifier/créer chaque collection
  results.artists = await createCollectionIfNotExists('artists', sampleArtist);
  results.programmers = await createCollectionIfNotExists('programmers', sampleProgrammer);
  results.concerts = await createCollectionIfNotExists('concerts', sampleConcert);
  
  return results;
};

export default {
  checkCollectionExists,
  createCollectionIfNotExists,
  setupAllCollections
};
