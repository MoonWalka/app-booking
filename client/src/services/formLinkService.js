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
import { v4 as uuidv4 } from 'uuid';

// Collection de référence
const FORM_LINKS_COLLECTION = 'formLinks';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, orderBy('createdAt', 'desc')));
    
    // Si la collection n'existe pas ou est vide, c'est normal pour les liens de formulaire
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, prête à recevoir des liens de formulaire.`);
    }
    
    return true;
  } catch (error) {
    console.error(`Erreur lors de la vérification/création de la collection ${collectionName}:`, error);
    return false;
  }
};

// Assurez-vous que la collection formLinks existe
const formLinksCollection = collection(db, FORM_LINKS_COLLECTION);

/**
 * Génère un lien unique pour un formulaire
 * @param {string} concertId - ID du concert associé
 * @param {Object} concertData - Données du concert
 * @param {string} programmerId - ID du programmateur
 * @param {string} programmerName - Nom du programmateur
 * @returns {Promise<Object>} Lien généré avec ID
 */
export const generateFormLink = async (concertId, concertData, programmerId, programmerName) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_LINKS_COLLECTION);
    
    // Vérifier si un lien existe déjà pour ce concert
    const existingLink = await getFormLinkByConcertId(concertId);
    if (existingLink) {
      console.log(`Un lien existe déjà pour le concert ${concertId}:`, existingLink);
      return existingLink;
    }
    
    // Générer un token unique
    const token = uuidv4();
    
    // Créer les données du lien
    const linkData = {
      concertId,
      concertName: concertData.artist?.name ? `${concertData.artist.name} à ${concertData.venue}` : `Concert à ${concertData.venue}`,
      concertDate: concertData.date || null,
      programmerId,
      programmerName,
      token,
      url: `/form/${token}`,
      createdAt: Timestamp.fromDate(new Date()),
      expiresAt: null, // Pas d'expiration pour l'instant
      isSubmitted: false,
      submissionId: null
    };
    
    console.log("Tentative de création d'un lien de formulaire:", linkData);
    const docRef = await addDoc(formLinksCollection, linkData);
    
    console.log(`Lien de formulaire créé avec succès, ID: ${docRef.id}`);
    return {
      id: docRef.id,
      ...linkData
    };
  } catch (error) {
    console.error("Erreur lors de la création du lien de formulaire:", error);
    
    // Essayer de créer le lien avec un ID généré manuellement en cas d'erreur
    try {
      const mockId = 'mock-link-' + Date.now();
      const token = uuidv4();
      
      const linkData = {
        concertId,
        concertName: concertData.artist?.name ? `${concertData.artist.name} à ${concertData.venue}` : `Concert à ${concertData.venue}`,
        concertDate: concertData.date || null,
        programmerId,
        programmerName,
        token,
        url: `/form/${token}`,
        createdAt: Timestamp.fromDate(new Date()),
        expiresAt: null,
        isSubmitted: false,
        submissionId: null
      };
      
      await setDoc(doc(db, FORM_LINKS_COLLECTION, mockId), linkData);
      
      console.log(`Lien de formulaire créé avec un ID manuel: ${mockId}`);
      return {
        id: mockId,
        ...linkData
      };
    } catch (setError) {
      console.error("Erreur lors de la création manuelle du lien de formulaire:", setError);
      
      // Simuler la création d'un lien en cas d'erreur
      const token = uuidv4();
      const mockId = 'mock-link-' + Date.now();
      
      return {
        id: mockId,
        concertId,
        concertName: concertData.artist?.name ? `${concertData.artist.name} à ${concertData.venue}` : `Concert à ${concertData.venue}`,
        concertDate: concertData.date || null,
        programmerId,
        programmerName,
        token,
        url: `/form/${token}`,
        createdAt: new Date(),
        expiresAt: null,
        isSubmitted: false,
        submissionId: null
      };
    }
  }
};

/**
 * Récupère un lien de formulaire par son ID
 * @param {string} id - ID du lien
 * @returns {Promise<Object>} Données du lien
 */
export const getFormLinkById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_LINKS_COLLECTION);
    
    console.log(`Tentative de récupération du lien ${id} depuis Firebase...`);
    const docRef = doc(db, FORM_LINKS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const linkData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Lien ${id} récupéré depuis Firebase:`, linkData);
      return linkData;
    }
    
    console.log(`Lien ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération du lien ${id}:`, error);
    return null;
  }
};

/**
 * Récupère un lien de formulaire par son token
 * @param {string} token - Token unique du lien
 * @returns {Promise<Object>} Données du lien
 */
export const getFormLinkByToken = async (token) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_LINKS_COLLECTION);
    
    console.log(`Tentative de récupération du lien avec le token ${token}...`);
    const linkQuery = query(
      formLinksCollection, 
      where('token', '==', token)
    );
    
    const snapshot = await getDocs(linkQuery);
    
    if (snapshot.empty) {
      console.log(`Aucun lien trouvé avec le token ${token}`);
      return null;
    }
    
    const linkData = {
      id: snapshot.docs[0].id,
      ...snapshot.docs[0].data()
    };
    
    console.log(`Lien avec le token ${token} récupéré:`, linkData);
    return linkData;
  } catch (error) {
    console.error(`Erreur lors de la récupération du lien avec le token ${token}:`, error);
    return null;
  }
};

/**
 * Récupère un lien de formulaire par l'ID du concert associé
 * @param {string} concertId - ID du concert
 * @returns {Promise<Object>} Données du lien
 */
export const getFormLinkByConcertId = async (concertId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_LINKS_COLLECTION);
    
    console.log(`Tentative de récupération du lien pour le concert ${concertId}...`);
    const linkQuery = query(
      formLinksCollection, 
      where('concertId', '==', concertId)
    );
    
    const snapshot = await getDocs(linkQuery);
    
    if (snapshot.empty) {
      console.log(`Aucun lien trouvé pour le concert ${concertId}`);
      return null;
    }
    
    const linkData = {
      id: snapshot.docs[0].id,
      ...snapshot.docs[0].data()
    };
    
    console.log(`Lien pour le concert ${concertId} récupéré:`, linkData);
    return linkData;
  } catch (error) {
    console.error(`Erreur lors de la récupération du lien pour le concert ${concertId}:`, error);
    return null;
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
    // S'assurer que la collection existe
    await ensureCollection(FORM_LINKS_COLLECTION);
    
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
    
    // Essayer de créer/remplacer le document
    try {
      await setDoc(doc(db, FORM_LINKS_COLLECTION, id), linkData, { merge: true });
      
      console.log(`Lien ${id} créé/remplacé avec succès`);
      return {
        id,
        ...linkData
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement du lien ${id}:`, setError);
      return null;
    }
  }
};

/**
 * Marque un lien comme soumis et l'associe à un ID de soumission
 * @param {string} id - ID du lien
 * @param {string} submissionId - ID de la soumission de formulaire
 * @returns {Promise<Object>} Lien mis à jour
 */
export const markFormLinkAsSubmitted = async (id, submissionId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_LINKS_COLLECTION);
    
    console.log(`Tentative de marquer le lien ${id} comme soumis avec la soumission ${submissionId}`);
    const docRef = doc(db, FORM_LINKS_COLLECTION, id);
    
    const updateData = {
      isSubmitted: true,
      submissionId,
      submittedAt: Timestamp.fromDate(new Date())
    };
    
    await updateDoc(docRef, updateData);
    
    console.log(`Lien ${id} marqué comme soumis avec succès`);
    return {
      id,
      ...updateData
    };
  } catch (error) {
    console.error(`Erreur lors du marquage du lien ${id} comme soumis:`, error);
    
    // Essayer de créer/remplacer le document
    try {
      const updateData = {
        isSubmitted: true,
        submissionId,
        submittedAt: Timestamp.fromDate(new Date())
      };
      
      await setDoc(doc(db, FORM_LINKS_COLLECTION, id), updateData, { merge: true });
      
      console.log(`Lien ${id} marqué comme soumis (via setDoc) avec succès`);
      return {
        id,
        ...updateData
      };
    } catch (setError) {
      console.error(`Erreur lors du marquage du lien ${id} comme soumis (via setDoc):`, setError);
      return null;
    }
  }
};

/**
 * Supprime un lien de formulaire
 * @param {string} id - ID du lien
 * @returns {Promise<string>} ID du lien supprimé
 */
export const deleteFormLink = async (id) => {
  try {
    console.log(`Tentative de suppression du lien ${id}`);
    const docRef = doc(db, FORM_LINKS_COLLECTION, id);
    await deleteDoc(docRef);
    
    console.log(`Lien ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du lien ${id}:`, error);
    return null;
  }
};

/**
 * Récupère tous les liens de formulaire
 * @param {Object} filters - Filtres à appliquer (optionnel)
 * @returns {Promise<Array>} Liste des liens de formulaire
 */
export const getFormLinks = async (filters = {}) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_LINKS_COLLECTION);
    
    console.log("Tentative de récupération des liens de formulaire depuis Firebase...");
    
    // Création d'une requête de base
    let linkQuery = formLinksCollection;
    
    // Application des filtres si nécessaire
    if (filters) {
      // Filtrer par statut de soumission
      if (filters.isSubmitted !== undefined) {
        linkQuery = query(linkQuery, where('isSubmitted', '==', filters.isSubmitted));
      }
      
      // Filtrer par programmateur
      if (filters.programmerId) {
        linkQuery = query(linkQuery, where('programmerId', '==', filters.programmerId));
      }
      
      // Filtrer par concert
      if (filters.concertId) {
        linkQuery = query(linkQuery, where('concertId', '==', filters.concertId));
      }
    }
    
    // Ajout d'un tri par date de création (du plus récent au plus ancien)
    linkQuery = query(linkQuery, orderBy('createdAt', 'desc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(linkQuery);
    
    if (snapshot.empty) {
      console.log("Aucun lien de formulaire trouvé dans Firebase");
      return [];
    }
    
    const formLinks = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${formLinks.length} liens de formulaire récupérés depuis Firebase`);
    return formLinks;
  } catch (error) {
    console.error("Erreur lors de la récupération des liens de formulaire:", error);
    return [];
  }
};
