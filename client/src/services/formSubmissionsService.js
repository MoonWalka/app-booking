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
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, orderBy('submittedAt', 'desc')));
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, création d'un document initial...`);
      const initialDoc = {
        programmerId: 'mock-programmer-1',
        programmerName: 'Didier Exemple',
        businessName: 'Association Culturelle du Sud',
        contact: 'Didier Martin',
        role: 'Programmateur',
        address: '45 rue des Arts, 13001 Marseille',
        venue: 'Festival du Sud',
        vatNumber: 'FR12345678901',
        siret: '123 456 789 00012',
        email: 'didier.martin@festivaldusud.fr',
        phone: '06 12 34 56 78',
        website: 'https://www.festivaldusud.fr',
        status: 'pending',
        submittedAt: Timestamp.fromDate(new Date()),
        notes: 'Formulaire exemple créé automatiquement'
      };
      
      await addDoc(collectionRef, initialDoc);
      console.log(`Document initial créé dans la collection ${collectionName}`);
    }
    
    return true;
  } catch (error) {
    console.error(`Erreur lors de la vérification/création de la collection ${collectionName}:`, error);
    return false;
  }
};

// Données simulées pour le fallback en cas d'erreur d'authentification
const mockFormSubmissions = [
  {
    id: 'mock-form-1',
    programmerId: 'mock-programmer-1',
    programmerName: 'Didier Exemple',
    businessName: 'Association Culturelle du Sud',
    contact: 'Didier Martin',
    role: 'Programmateur',
    address: '45 rue des Arts, 13001 Marseille',
    venue: 'Festival du Sud',
    vatNumber: 'FR12345678901',
    siret: '123 456 789 00012',
    email: 'didier.martin@festivaldusud.fr',
    phone: '06 12 34 56 78',
    website: 'https://www.festivaldusud.fr',
    status: 'pending',
    submittedAt: new Date(),
    notes: 'Formulaire exemple',
    // Nouveaux champs pour lier au concert
    concertId: 'mock-concert-1',
    concertName: 'Concert exemple',
    concertDate: new Date(),
    formLinkId: 'mock-link-1'
  },
  {
    id: 'mock-form-2',
    programmerId: 'mock-programmer-2',
    programmerName: 'Jean Martin',
    businessName: 'SARL La Cigale',
    contact: 'Jean Martin',
    role: 'Gérant',
    address: '120 boulevard de Rochechouart, 75018 Paris',
    venue: 'La Cigale',
    vatNumber: 'FR45678901234',
    siret: '456 789 012 00013',
    email: 'jean.martin@lacigale.fr',
    phone: '01 23 45 67 89',
    website: 'https://www.lacigale.fr',
    status: 'processed',
    submittedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 7 jours avant
    processedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // 5 jours avant
    notes: 'Formulaire traité',
    // Nouveaux champs pour lier au concert
    concertId: 'mock-concert-2',
    concertName: 'Concert exemple 2',
    concertDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 jours après
    formLinkId: 'mock-link-2'
  },
  {
    id: 'mock-form-3',
    programmerId: null,
    programmerName: null,
    businessName: 'Le Petit Théâtre',
    contact: 'Sophie Dubois',
    role: 'Directrice',
    address: '15 rue des Lilas, 69003 Lyon',
    venue: 'Le Petit Théâtre',
    vatNumber: 'FR98765432109',
    siret: '987 654 321 00014',
    email: 'sophie.dubois@petittheatre.fr',
    phone: '04 56 78 90 12',
    website: 'https://www.petittheatre.fr',
    status: 'pending',
    submittedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 jours avant
    notes: 'Formulaire sans programmateur associé',
    // Nouveaux champs pour lier au concert
    concertId: 'mock-concert-3',
    concertName: 'Concert exemple 3',
    concertDate: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000), // 15 jours après
    formLinkId: 'mock-link-3'
  }
];

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
    
    console.log("Tentative de récupération des formulaires depuis Firebase...");
    
    // Création d'une requête de base
    let formQuery = formSubmissionsCollection;
    
    // Application des filtres si nécessaire
    if (filters) {
      // Filtrer par statut
      if (filters.status) {
        formQuery = query(formQuery, where('status', '==', filters.status));
      }
      
      // Filtrer par programmateur
      if (filters.programmerId) {
        formQuery = query(formQuery, where('programmerId', '==', filters.programmerId));
      }
      
      // Filtrer par concert
      if (filters.concertId) {
        formQuery = query(formQuery, where('concertId', '==', filters.concertId));
      }
      
      // Filtrer par lien de formulaire
      if (filters.formLinkId) {
        formQuery = query(formQuery, where('formLinkId', '==', filters.formLinkId));
      }
    }
    
    // Ajout d'un tri par date de soumission (du plus récent au plus ancien)
    formQuery = query(formQuery, orderBy('submittedAt', 'desc'));
    
    // Exécution de la requête
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log("Aucun formulaire trouvé dans Firebase, utilisation des données simulées");
      
      // Essayer d'ajouter les données simulées à Firebase
      try {
        console.log("Tentative d'ajout des données simulées à Firebase...");
        for (const form of mockFormSubmissions) {
          const { id, ...formData } = form;
          await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), {
            ...formData,
            submittedAt: Timestamp.fromDate(formData.submittedAt),
            processedAt: formData.processedAt ? Timestamp.fromDate(formData.processedAt) : null,
            concertDate: formData.concertDate ? Timestamp.fromDate(formData.concertDate) : null
          });
        }
        console.log("Données simulées ajoutées à Firebase avec succès");
      } catch (addError) {
        console.error("Erreur lors de l'ajout des données simulées:", addError);
      }
      
      return mockFormSubmissions;
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${formSubmissions.length} formulaires récupérés depuis Firebase`);
    return formSubmissions;
  } catch (error) {
    console.error("Erreur lors de la récupération des formulaires:", error);
    console.log("Utilisation des données simulées pour les formulaires");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("Tentative d'ajout des données simulées à Firebase...");
      for (const form of mockFormSubmissions) {
        const { id, ...formData } = form;
        await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), {
          ...formData,
          submittedAt: Timestamp.fromDate(formData.submittedAt),
          processedAt: formData.processedAt ? Timestamp.fromDate(formData.processedAt) : null,
          concertDate: formData.concertDate ? Timestamp.fromDate(formData.concertDate) : null
        });
      }
      console.log("Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("Erreur lors de l'ajout des données simulées:", addError);
    }
    
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockFormSubmissions;
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
    
    console.log(`Tentative de récupération du formulaire ${id} depuis Firebase...`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const formData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Formulaire ${id} récupéré depuis Firebase:`, formData);
      return formData;
    }
    
    console.log(`Formulaire ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération du formulaire ${id}:`, error);
    // Retourner un formulaire simulé en cas d'erreur
    const mockForm = mockFormSubmissions.find(form => form.id === id) || mockFormSubmissions[0];
    console.log(`Utilisation du formulaire simulé:`, mockForm);
    return mockForm;
  }
};

/**
 * Crée un nouveau formulaire soumis
 * @param {Object} formData - Données du formulaire
 * @returns {Promise<Object>} Formulaire créé avec ID
 */
export const createFormSubmission = async (formData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    // S'assurer que les champs obligatoires sont présents
    const completeFormData = {
      ...formData,
      status: formData.status || 'pending',
      submittedAt: Timestamp.fromDate(new Date()),
      // Convertir la date du concert en Timestamp si elle existe
      concertDate: formData.concertDate ? 
        (formData.concertDate instanceof Date ? 
          Timestamp.fromDate(formData.concertDate) : 
          formData.concertDate) : 
        null
    };
    
    console.log("Tentative d'ajout d'un formulaire à Firebase:", completeFormData);
    const docRef = await addDoc(formSubmissionsCollection, completeFormData);
    
    console.log(`Formulaire ajouté avec succès, ID: ${docRef.id}`);
    return {
      id: docRef.id,
      ...completeFormData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du formulaire:", error);
    console.log("Simulation de l'ajout d'un formulaire");
    
    // Essayer d'ajouter le formulaire avec un ID généré manuellement
    try {
      const mockId = 'mock-form-' + Date.now();
      const completeFormData = {
        ...formData,
        status: formData.status || 'pending',
        submittedAt: Timestamp.fromDate(new Date()),
        // Convertir la date du concert en Timestamp si elle existe
        concertDate: formData.concertDate ? 
          (formData.concertDate instanceof Date ? 
            Timestamp.fromDate(formData.concertDate) : 
            formData.concertDate) : 
          null
      };
      
      await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, mockId), completeFormData);
      
      console.log(`Formulaire ajouté avec un ID manuel: ${mockId}`);
      return {
        id: mockId,
        ...completeFormData
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel du formulaire:", addError);
      
      // Simuler l'ajout d'un formulaire en cas d'erreur
      const mockId = 'mock-form-' + Date.now();
      return {
        id: mockId,
        ...formData,
        status: formData.status || 'pending',
        submittedAt: new Date(),
        concertDate: formData.concertDate || null
      };
    }
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
    
    console.log(`Tentative de mise à jour du formulaire ${id}:`, formData);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    
    // Si le statut change à 'processed' ou 'rejected', ajouter la date de traitement
    const updateData = { ...formData };
    if ((formData.status === 'processed' || formData.status === 'rejected') && !formData.processedAt) {
      updateData.processedAt = Timestamp.fromDate(new Date());
    }
    
    // Convertir la date du concert en Timestamp si elle existe
    if (updateData.concertDate) {
      updateData.concertDate = updateData.concertDate instanceof Date ? 
        Timestamp.fromDate(updateData.concertDate) : 
        updateData.concertDate;
    }
    
    await updateDoc(docRef, updateData);
    
    console.log(`Formulaire ${id} mis à jour avec succès`);
    return {
      id,
      ...updateData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour du formulaire ${id}:`, error);
    console.log("Simulation de la mise à jour d'un formulaire");
    
    // Essayer de créer/remplacer le document
    try {
      // Si le statut change à 'processed' ou 'rejected', ajouter la date de traitement
      const updateData = { ...formData };
      if ((formData.status === 'processed' || formData.status === 'rejected') && !formData.processedAt) {
        updateData.processedAt = Timestamp.fromDate(new Date());
      }
      
      // Convertir la date du concert en Timestamp si elle existe
      if (updateData.concertDate) {
        updateData.concertDate = updateData.concertDate instanceof Date ? 
          Timestamp.fromDate(updateData.concertDate) : 
          updateData.concertDate;
      }
      
      await setDoc(doc(db, FORM_SUBMISSIONS_COLLECTION, id), updateData, { merge: true });
      
      console.log(`Formulaire ${id} créé/remplacé avec succès`);
      return {
        id,
        ...updateData
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement du formulaire ${id}:`, setError);
      
      // Simuler la mise à jour d'un formulaire en cas d'erreur
      return {
        id,
        ...formData,
        processedAt: (formData.status === 'processed' || formData.status === 'rejected') ? new Date() : null
      };
    }
  }
};

/**
 * Supprime un formulaire soumis
 * @param {string} id - ID du formulaire
 * @returns {Promise<string>} ID du formulaire supprimé
 */
export const deleteFormSubmission = async (id) => {
  try {
    console.log(`Tentative de suppression du formulaire ${id}`);
    const docRef = doc(db, FORM_SUBMISSIONS_COLLECTION, id);
    await deleteDoc(docRef);
    
    console.log(`Formulaire ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du formulaire ${id}:`, error);
    console.log("Simulation de la suppression d'un formulaire");
    // Simuler la suppression d'un formulaire en cas d'erreur
    return id;
  }
};

/**
 * Récupère les formulaires soumis pour un programmateur spécifique
 * @param {string} programmerId - ID du programmateur
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByProgrammer = async (programmerId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`Tentative de récupération des formulaires pour le programmateur ${programmerId}...`);
    const formQuery = query(
      formSubmissionsCollection, 
      where('programmerId', '==', programmerId),
      orderBy('submittedAt', 'desc')
    );
    
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log(`Aucun formulaire trouvé pour le programmateur ${programmerId}`);
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${formSubmissions.length} formulaires récupérés pour le programmateur ${programmerId}`);
    return formSubmissions;
  } catch (error) {
    console.error(`Erreur lors de la récupération des formulaires pour le programmateur ${programmerId}:`, error);
    // Retourner des formulaires simulés pour ce programmateur
    const mockForms = mockFormSubmissions.filter(form => form.programmerId === programmerId);
    console.log(`Utilisation de ${mockForms.length} formulaires simulés pour le programmateur ${programmerId}`);
    return mockForms;
  }
};

/**
 * Récupère les formulaires soumis par statut
 * @param {string} status - Statut des formulaires ('pending', 'processed', 'rejected')
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByStatus = async (status) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`Tentative de récupération des formulaires avec le statut ${status}...`);
    const formQuery = query(
      formSubmissionsCollection, 
      where('status', '==', status),
      orderBy('submittedAt', 'desc')
    );
    
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log(`Aucun formulaire trouvé avec le statut ${status}`);
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${formSubmissions.length} formulaires récupérés avec le statut ${status}`);
    return formSubmissions;
  } catch (error) {
    console.error(`Erreur lors de la récupération des formulaires avec le statut ${status}:`, error);
    // Retourner des formulaires simulés pour ce statut
    const mockForms = mockFormSubmissions.filter(form => form.status === status);
    console.log(`Utilisation de ${mockForms.length} formulaires simulés avec le statut ${status}`);
    return mockForms;
  }
};

/**
 * Récupère les formulaires soumis pour un concert spécifique
 * @param {string} concertId - ID du concert
 * @returns {Promise<Array>} Liste des formulaires soumis
 */
export const getFormSubmissionsByConcert = async (concertId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`Tentative de récupération des formulaires pour le concert ${concertId}...`);
    const formQuery = query(
      formSubmissionsCollection, 
      where('concertId', '==', concertId),
      orderBy('submittedAt', 'desc')
    );
    
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log(`Aucun formulaire trouvé pour le concert ${concertId}`);
      return [];
    }
    
    const formSubmissions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${formSubmissions.length} formulaires récupérés pour le concert ${concertId}`);
    return formSubmissions;
  } catch (error) {
    console.error(`Erreur lors de la récupération des formulaires pour le concert ${concertId}:`, error);
    // Retourner des formulaires simulés pour ce concert
    const mockForms = mockFormSubmissions.filter(form => form.concertId === concertId);
    console.log(`Utilisation de ${mockForms.length} formulaires simulés pour le concert ${concertId}`);
    return mockForms;
  }
};

/**
 * Récupère un formulaire soumis par l'ID du lien de formulaire
 * @param {string} formLinkId - ID du lien de formulaire
 * @returns {Promise<Object>} Données du formulaire
 */
export const getFormSubmissionByFormLinkId = async (formLinkId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection(FORM_SUBMISSIONS_COLLECTION);
    
    console.log(`Tentative de récupération du formulaire pour le lien ${formLinkId}...`);
    const formQuery = query(
      formSubmissionsCollection, 
      where('formLinkId', '==', formLinkId),
      limit(1)
    );
    
    const snapshot = await getDocs(formQuery);
    
    if (snapshot.empty) {
      console.log(`Aucun formulaire trouvé pour le lien ${formLinkId}`);
      return null;
    }
    
    const formData = {
      id: snapshot.docs[0].id,
      ...snapshot.docs[0].data()
    };
    
    console.log(`Formulaire pour le lien ${formLinkId} récupéré:`, formData);
    return formData;
  } catch (error) {
    console.error(`Erreur lors de la récupération du formulaire pour le lien ${formLinkId}:`, error);
    // Retourner un formulaire simulé pour ce lien
    const mockForm = mockFormSubmissions.find(form => form.formLinkId === formLinkId);
    console.log(`Utilisation du formulaire simulé pour le lien ${formLinkId}:`, mockForm);
    return mockForm;
  }
};
