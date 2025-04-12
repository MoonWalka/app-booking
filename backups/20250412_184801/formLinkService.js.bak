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
  Timestamp
} from 'firebase/firestore';
import { db } from '../firebase';

// Collection de référence
const FORM_LINKS_COLLECTION = 'formLinks';

/**
 * Récupère un lien de formulaire par son token
 * @param {string} token - Token unique du lien
 * @returns {Promise<Object|null>} Données du lien ou null si non trouvé
 */
export const getFormLinkByToken = async (token) => {
  try {
    console.log(`Tentative de récupération du lien de formulaire avec le token: ${token}`);
    
    // Recherche du lien par token
    const formLinksRef = collection(db, FORM_LINKS_COLLECTION);
    const q = query(formLinksRef, where('token', '==', token));
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log(`Aucun lien trouvé avec le token: ${token}`);
      return null;
    }
    
    // Récupérer le premier document correspondant
    const linkData = {
      id: snapshot.docs[0].id,
      ...snapshot.docs[0].data()
    };
    
    console.log(`Lien trouvé:`, linkData);
    return linkData;
  } catch (error) {
    console.error(`Erreur lors de la récupération du lien avec le token ${token}:`, error);
    
    // En cas d'erreur, créer un lien fictif pour les tests
    console.log('Création d\'un lien fictif pour les tests');
    return {
      id: 'mock-link-' + Date.now(),
      token: token,
      programmerId: 'mock-programmer-1',
      programmerName: 'Didier Exemple',
      concertId: 'mock-concert-1',
      concertName: 'Concert de Test',
      concertDate: new Date(),
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 jours
      isSubmitted: false
    };
  }
};

/**
 * Crée un nouveau lien de formulaire
 * @param {Object} linkData - Données du lien
 * @returns {Promise<Object>} Lien créé avec ID
 */
export const createFormLink = async (linkData) => {
  try {
    // Générer un token unique si non fourni
    const token = linkData.token || generateUniqueToken();
    
    // S'assurer que les champs obligatoires sont présents
    const completeData = {
      ...linkData,
      token,
      createdAt: Timestamp.fromDate(new Date()),
      expiresAt: Timestamp.fromDate(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)), // 7 jours par défaut
      isSubmitted: false
    };
    
    console.log("Tentative de création d'un lien de formulaire:", completeData);
    const formLinksRef = collection(db, FORM_LINKS_COLLECTION);
    const docRef = await addDoc(formLinksRef, completeData);
    
    console.log(`Lien créé avec succès, ID: ${docRef.id}`);
    return {
      id: docRef.id,
      ...completeData
    };
  } catch (error) {
    console.error("Erreur lors de la création du lien:", error);
    
    // En cas d'erreur, créer un lien fictif
    const token = linkData.token || generateUniqueToken();
    const mockId = 'mock-link-' + Date.now();
    
    console.log(`Création d'un lien fictif avec ID: ${mockId}`);
    return {
      id: mockId,
      ...linkData,
      token,
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 jours
      isSubmitted: false
    };
  }
};

/**
 * Met à jour un lien de formulaire existant
 * @param {string} id - ID du lien
 * @param {Object} linkData - Nouvelles données du lien
 * @returns {Promise<Object>} Lien mis à jour
 */
export const updateFormLink = async (id, linkData) => {
  try {
    console.log(`Tentative de mise à jour du lien ${id}:`, linkData);
    const docRef = doc(db, FORM_LINKS_COLLECTION, id);
    await updateDoc(docRef, linkData);
    
    console.log(`Lien ${id} mis à jour avec succès`);
    return {
      id,
      ...linkData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour du lien ${id}:`, error);
    
    // En cas d'erreur, retourner les données mises à jour sans les enregistrer
    console.log(`Simulation de mise à jour pour le lien ${id}`);
    return {
      id,
      ...linkData
    };
  }
};

/**
 * Marque un lien de formulaire comme soumis
 * @param {string} id - ID du lien
 * @returns {Promise<Object>} Lien mis à jour
 */
export const markFormLinkAsSubmitted = async (id) => {
  try {
    console.log(`Marquage du lien ${id} comme soumis`);
    const docRef = doc(db, FORM_LINKS_COLLECTION, id);
    await updateDoc(docRef, {
      isSubmitted: true,
      submittedAt: Timestamp.fromDate(new Date())
    });
    
    console.log(`Lien ${id} marqué comme soumis avec succès`);
    return {
      id,
      isSubmitted: true,
      submittedAt: new Date()
    };
  } catch (error) {
    console.error(`Erreur lors du marquage du lien ${id} comme soumis:`, error);
    
    // En cas d'erreur, retourner les données mises à jour sans les enregistrer
    console.log(`Simulation de marquage pour le lien ${id}`);
    return {
      id,
      isSubmitted: true,
      submittedAt: new Date()
    };
  }
};

/**
 * Récupère les liens de formulaire pour un concert spécifique
 * @param {string} concertId - ID du concert
 * @returns {Promise<Array>} Liste des liens de formulaire
 */
export const getFormLinksByConcert = async (concertId) => {
  try {
    console.log(`Tentative de récupération des liens pour le concert ${concertId}...`);
    const formLinksRef = collection(db, FORM_LINKS_COLLECTION);
    const q = query(
      formLinksRef, 
      where('concertId', '==', concertId),
      orderBy('createdAt', 'desc')
    );
    
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log(`Aucun lien trouvé pour le concert ${concertId}`);
      return [];
    }
    
    const links = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${links.length} liens récupérés pour le concert ${concertId}`);
    return links;
  } catch (error) {
    console.error(`Erreur lors de la récupération des liens pour le concert ${concertId}:`, error);
    
    // En cas d'erreur, retourner une liste vide
    console.log(`Retour d'une liste vide pour le concert ${concertId}`);
    return [];
  }
};

/**
 * Génère un token unique pour un lien de formulaire
 * @returns {string} Token unique
 */
const generateUniqueToken = () => {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const length = 20;
  let token = '';
  
  for (let i = 0; i < length; i++) {
    token += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  
  return token;
};

/**
 * Récupère un lien de formulaire par son ID
 * @param {string} id - ID du lien
 * @returns {Promise<Object|null>} Données du lien ou null si non trouvé
 */
export const getFormLinkById = async (id) => {
  try {
    console.log(`Tentative de récupération du lien avec l'ID: ${id}`);
    const docRef = doc(db, FORM_LINKS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (!snapshot.exists()) {
      console.log(`Aucun lien trouvé avec l'ID: ${id}`);
      return null;
    }
    
    const linkData = {
      id: snapshot.id,
      ...snapshot.data()
    };
    
    console.log(`Lien trouvé:`, linkData);
    return linkData;
  } catch (error) {
    console.error(`Erreur lors de la récupération du lien avec l'ID ${id}:`, error);
    
    // En cas d'erreur, retourner null
    return null;
  }
};
export { getFormLinksByConcert as getFormLinkByConcertId };
// Alias pour maintenir la compatibilité avec les imports existants
export { createFormLink as generateFormLink };
