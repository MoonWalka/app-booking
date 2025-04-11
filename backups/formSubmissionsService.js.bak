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
  Timestamp,
  limit
} from 'firebase/firestore';
import { db } from '../firebase';

// Collection de référence
const FORM_SUBMISSIONS_COLLECTION = 'formSubmissions';

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

// Assurez-vous que la collection formSubmissions existe
const formSubmissionsCollection = collection(db, FORM_SUBMISSIONS_COLLECTION);

/**
 * Récupère tous les formulaires soumis
 * @param {Object} filters - Filtres à appliquer (optionnel)
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissions = async (filters = {}) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log("[getFormSubmissions] Tentative de récupération des formulaires depuis Firebase...");
    console.log("[getFormSubmissions] Filtres appliqués:", filters);
    
    // Création d'une requête de base
    let formQuery = formSubmissionsCollection;
    
    // Application des filtres si nécessaire
    if (filters) {
      // Filtrer par statut
      if (filters.status) {
        console.log(`[getFormSubmissions] Filtrage par statut: ${filters.status}`);
        formQuery = query(formQuery, where('status', '==', filters.status));
      }
      
      // Filtrer par programmateur
      if (filters.programmerId) {
        console.log(`[getFormSubmissions] Filtrage par programmateur: ${filters.programmerId}`);
        formQuery = query(formQuery, where('programmerId', '==', filters.programmerId));
      }
      
      // Filtrer par concert
      if (filters.concertId) {
        console.log(`[getFormSubmissions] Filtrage par concert: ${filters.concertId}`);
        formQuery = query(formQuery, where('concertId', '==', filters.concertId));
      }
      
      // Filtrer par lien de formulaire
      if (filters.formLinkId) {
        console.log(`[getFormSubmissions] Filtrage par lien de formulaire: ${filters.formLinkId}`);
        formQuery = query(formQuery, where('formLinkId', '==', filters.formLinkId));
      }
      
      // Filtrer par token commun
      if (filters.commonToken) {
        console.log(`[getFormSubmissions] Filtrage par token commun: ${filters.commonToken}`);
        formQuery = query(formQuery, where('commonToken', '==', filters.commonToken));
      }
    }
    
    // Ajout d'un tri par date de soumission (du plus récent au plus ancien)
    formQuery = query(formQuery, orderBy('submittedAt', 'desc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log("[getFormSubmissions] Aucun formulaire trouvé dans Firebase");
      
      // Récupérer tous les formulaires pour vérifier s'il y a des données
      const allFormsSnapshot = await getDocs(formSubmissionsCollection);
      if (!allFormsSnapshot.empty) {
        console.log(`[getFormSubmissions] ATTENTION: ${allFormsSnapshot.size} formulaires existent dans la collection, mais aucun ne correspond aux filtres`);
        console.log("[getFormSubmissions] Vérification des statuts disponibles...");
        
        const statusMap = {};
        allFormsSnapshot.docs.forEach(doc => {
          const status = doc.data().status || 'non défini';
          statusMap[status] = (statusMap[status] || 0) + 1;
        });
        
        console.log("[getFormSubmissions] Distribution des statuts:", statusMap);
      }
      
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`[getFormSubmissions] ${formSubmissions.length} formulaires récupérés depuis Firebase`);
    formSubmissions.forEach(form => {
      console.log(`[getFormSubmissions] Formulaire ID: ${form.id}, Token: ${form.commonToken}, Status: ${form.status}`);
    });
    
    return formSubmissions;
  } catch (error) {
    console.error("[getFormSubmissions] Erreur lors de la récupération des formulaires:", error);
    return [];
  }
};

/**
 * Récupère un formulaire soumis par son ID
 * @param {string} id - ID du formulaire
 * @returns {Promise<Object>} Données du formulaire
 */
export const getFormSubmissionById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`[getFormSubmissionById] Tentative de récupération du formulaire ${id} depuis Firebase...`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const formData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`[getFormSubmissionById] Formulaire ${id} récupéré depuis Firebase:`, formData);
      return formData;
    }
    
    console.log(`[getFormSubmissionById] Formulaire ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`[getFormSubmissionById] Erreur lors de la récupération du formulaire ${id}:`, error);
    return null;
  }
};

/**
 * Crée un nouveau formulaire soumis
 * @param {Object} formData - Données du formulaire
 * @returns {Promise<Object>} Formulaire créé avec ID
 */
export const createFormSubmission = async (formData) => {
  console.log("[createFormSubmission] Début de la création d'un nouveau formulaire");
  console.log("[createFormSubmission] Données reçues:", formData);
  
  try {
    // S'assurer que la collection existe
    console.log("[createFormSubmission] Vérification de l'existence de la collection...");
    const collectionExists = await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    console.log(`[createFormSubmission] Résultat de la vérification: ${collectionExists ? 'collection existe' : 'échec de la vérification'}`);
    
    // Vérifier les champs obligatoires
    const requiredFields = ['concertId'];
    const missingFields = requiredFields.filter(field => !formData[field]);
    
    if (missingFields.length > 0) {
      console.error(`[createFormSubmission] Champs obligatoires manquants: ${missingFields.join(', ')}`);
      throw new Error(`Champs obligatoires manquants: ${missingFields.join(', ')}`);
    }
    
    // Générer un token commun si non fourni
    let commonToken = formData.commonToken;
    if (!commonToken) {
      // Importer dynamiquement pour éviter les dépendances circulaires
      const { generateToken } = await import('../utils/tokenGenerator');
      commonToken = generateToken(formData.concertId);
      console.log(`[createFormSubmission] Génération d'un nouveau token commun: ${commonToken}`);
    }
    
    // S'assurer que les champs obligatoires sont présents et que le statut est explicitement défini
    const completeFormData = {
      ...formData,
      commonToken, // Ajouter le token commun
      status: 'pending', // Forcer le statut à 'pending' pour garantir la cohérence
      submittedAt: Timestamp.fromDate(new Date()),
      // Convertir la date du concert en Timestamp si elle existe
      concertDate: formData.concertDate ? 
        (formData.concertDate instanceof Date ? 
          Timestamp.fromDate(formData.concertDate) : 
          formData.concertDate) : 
        null
    };
    
    console.log("[createFormSubmission] Tentative d'ajout d'un formulaire à Firebase avec addDoc:", completeFormData);
    console.log("[createFormSubmission] Vérification de la présence de concertId:", completeFormData.concertId ? 'Présent' : 'Manquant');
    console.log("[createFormSubmission] Vérification de la présence du token commun:", completeFormData.commonToken ? 'Présent' : 'Manquant');
    console.log("[createFormSubmission] Vérification du statut:", completeFormData.status);
    
    try {
      const docRef = await addDoc(formSubmissionsCollection, completeFormData);
      console.log(`[createFormSubmission] Formulaire ajouté avec succès via addDoc, ID: ${docRef.id}`);
      
      // Vérifier immédiatement que le document a été créé avec le bon statut
      const createdDoc = await getDoc(docRef);
      if (createdDoc.exists()) {
        const createdData = createdDoc.data();
        console.log(`[createFormSubmission] Vérification du document créé - Statut: ${createdData.status}`);
      }
      
      return {
        id: docRef.id,
        ...completeFormData
      };
    } catch (addDocError) {
      console.error("[createFormSubmission] Erreur lors de l'ajout du formulaire avec addDoc:", addDocError);
      
      // Essayer d'ajouter le formulaire avec un ID généré manuellement
      console.log("[createFormSubmission] Tentative alternative avec setDoc...");
      const mockId = 'form-' + Date.now();
      
      try {
        await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, mockId), completeFormData);
        console.log(`[createFormSubmission] Formulaire ajouté avec succès via setDoc, ID: ${mockId}`);
        
        // Vérifier immédiatement que le document a été créé avec le bon statut
        const createdDoc = await getDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, mockId));
        if (createdDoc.exists()) {
          const createdData = createdDoc.data();
          console.log(`[createFormSubmission] Vérification du document créé - Statut: ${createdData.status}`);
        }
        
        return {
          id: mockId,
          ...completeFormData
        };
      } catch (setDocError) {
        console.error("[createFormSubmission] Erreur lors de l'ajout du formulaire avec setDoc:", setDocError);
        throw setDocError; // Propager l'erreur pour la gestion dans le composant
      }
    }
  } catch (error) {
    console.error("[createFormSubmission] Erreur générale lors de l'ajout du formulaire:", error);
    
    // Vérifier si l'erreur est liée à un champ manquant
    if (error.message && error.message.includes('Champs obligatoires manquants')) {
      throw error; // Propager l'erreur spécifique
    }
    
    throw error;
  }
};

/**
 * Met à jour un formulaire soumis existant
 * @param {string} id - ID du formulaire
 * @param {Object} formData - Nouvelles données du formulaire
 * @returns {Promise<Object>} Formulaire mis à jour
 */
export const updateFormSubmission = async (id, formData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`[updateFormSubmission] Tentative de mise à jour du formulaire ${id}:`, formData);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    
    // Si le statut change à 'processed' ou 'rejected', ajouter la date de traitement
    const updatedData = {
      ...formData
    };
    
    if (formData.status === 'processed' || formData.status === 'rejected') {
      updatedData.processedAt = Timestamp.fromDate(new Date());
    }
    
    // Convertir la date du concert en Timestamp si elle existe
    if (formData.concertDate) {
      updatedData.concertDate = formData.concertDate instanceof Date ? 
        Timestamp.fromDate(formData.concertDate) : 
        formData.concertDate;
    }
    
    await updateDoc(docRef, updatedData);
    console.log(`[updateFormSubmission] Formulaire ${id} mis à jour avec succès`);
    
    return {
      id,
      ...updatedData
    };
  } catch (error) {
    console.error(`[updateFormSubmission] Erreur lors de la mise à jour du formulaire ${id}:`, error);
    throw error;
  }
};

/**
 * Supprime un formulaire soumis
 * @param {string} id - ID du formulaire
 * @returns {Promise<boolean>} Succès de la suppression
 */
export const deleteFormSubmission = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`[deleteFormSubmission] Tentative de suppression du formulaire ${id}`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    await deleteDoc(docRef);
    console.log(`[deleteFormSubmission] Formulaire ${id} supprimé avec succès`);
    
    return true;
  } catch (error) {
    console.error(`[deleteFormSubmission] Erreur lors de la suppression du formulaire ${id}:`, error);
    throw error;
  }
};

/**
 * Récupère les formulaires soumis par un programmateur
 * @param {string} programmerId - ID du programmateur
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByProgrammer = async (programmerId) => {
  return getFormSubmissions({ programmerId });
};

/**
 * Récupère les formulaires soumis par statut
 * @param {string} status - Statut des formulaires
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByStatus = async (status) => {
  return getFormSubmissions({ status });
};

/**
 * Récupère les formulaires soumis pour un concert
 * @param {string} concertId - ID du concert
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByConcert = async (concertId) => {
  return getFormSubmissions({ concertId });
};

/**
 * Récupère les formulaires soumis par token commun
 * @param {string} commonToken - Token commun
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByToken = async (commonToken) => {
  return getFormSubmissions({ commonToken });
};

/**
 * Récupère un formulaire soumis par son ID de lien
 * @param {string} formLinkId - ID du lien de formulaire
 * @returns {Promise<Object>} Formulaire soumis
 */
export const getFormSubmissionByFormLinkId = async (formLinkId) => {
  try {
    const submissions = await getFormSubmissions({ formLinkId });
    return submissions.length > 0 ? submissions[0] : null;
  } catch (error) {
    console.error(`[getFormSubmissionByFormLinkId] Erreur lors de la récupération du formulaire avec formLinkId ${formLinkId}:`, error);
    throw error;
  }
};
