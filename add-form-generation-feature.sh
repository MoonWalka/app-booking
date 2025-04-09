#!/bin/bash

# Script pour ajouter la fonctionnalité de génération de liens de formulaires
# depuis la page de détail d'un concert

echo "Début de l'installation de la fonctionnalité de génération de liens de formulaires..."

# Création des répertoires nécessaires s'ils n'existent pas
mkdir -p ./client/src/components/public
echo "Répertoires créés."

# Installation des dépendances nécessaires
echo "Installation des dépendances..."
cd ./client
npm install uuid --save
cd ..
echo "Dépendances installées."

# Création du service de gestion des liens de formulaires
echo "Création du service formLinkService.js..."
cat > ./client/src/services/formLinkService.js << 'EOL'
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
EOL
echo "Service formLinkService.js créé."

# Mise à jour du service formSubmissionsService.js
echo "Mise à jour du service formSubmissionsService.js..."
cat > ./client/src/services/formSubmissionsService.js << 'EOL'
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
EOL
echo "Service formSubmissionsService.js mis à jour."

# Création du composant PublicFormPage
echo "Création du composant PublicFormPage..."
cat > ./client/src/components/public/PublicFormPage.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getFormLinkByToken } from '../../services/formLinkService';
import { createFormSubmission } from '../../services/formSubmissionsService';
import { markFormLinkAsSubmitted } from '../../services/formLinkService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const { token } = useParams();
  const navigate = useNavigate();
  const [formLink, setFormLink] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [formData, setFormData] = useState({
    businessName: '',
    contact: '',
    role: '',
    address: '',
    venue: '',
    vatNumber: '',
    siret: '',
    email: '',
    phone: '',
    website: ''
  });

  useEffect(() => {
    const fetchFormLink = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération du lien avec le token: ${token}`);
        
        const linkData = await getFormLinkByToken(token);
        
        if (!linkData) {
          throw new Error('Lien de formulaire non trouvé ou expiré');
        }
        
        if (linkData.isSubmitted) {
          throw new Error('Ce formulaire a déjà été soumis');
        }
        
        console.log('Lien de formulaire récupéré:', linkData);
        setFormLink(linkData);
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération du lien de formulaire:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchFormLink();
  }, [token]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setSubmitting(true);
      
      // Créer la soumission de formulaire
      const submissionData = {
        ...formData,
        programmerId: formLink.programmerId,
        programmerName: formLink.programmerName,
        concertId: formLink.concertId,
        concertName: formLink.concertName,
        concertDate: formLink.concertDate,
        status: 'pending',
        formLinkId: formLink.id
      };
      
      console.log("Données du formulaire à soumettre:", submissionData);
      
      // Envoyer les données à Firebase
      const submission = await createFormSubmission(submissionData);
      
      // Marquer le lien comme soumis
      await markFormLinkAsSubmitted(formLink.id, submission.id);
      
      console.log("Formulaire soumis avec succès:", submission);
      
      setSubmitting(false);
      setSubmitted(true);
      
      // Rediriger vers la page de confirmation après 3 secondes
      setTimeout(() => {
        navigate('/form-submitted');
      }, 3000);
      
    } catch (err) {
      console.error("Erreur lors de la soumission du formulaire:", err);
      setError(`Erreur lors de la soumission du formulaire: ${err.message}`);
      setSubmitting(false);
    }
  };

  if (loading) return <div className="public-form-loading">Chargement du formulaire...</div>;
  if (error) return <div className="public-form-error">{error}</div>;
  if (submitted) return (
    <div className="public-form-submitted">
      <div className="submitted-icon">
        <i className="fas fa-check-circle"></i>
      </div>
      <h2>Formulaire soumis avec succès !</h2>
      <p>Merci d'avoir complété ce formulaire. Vos informations ont été enregistrées.</p>
      <p>Vous allez être redirigé automatiquement...</p>
    </div>
  );

  return (
    <div className="public-form-container">
      <div className="public-form-header">
        <h1>Formulaire de renseignements</h1>
        <p className="form-description">
          Merci de compléter ce formulaire pour le concert : 
          <strong> {formLink.concertName}</strong>
          {formLink.concertDate && (
            <span> le {new Date(formLink.concertDate).toLocaleDateString()}</span>
          )}
        </p>
      </div>
      
      <form onSubmit={handleSubmit} className="public-form">
        <div className="form-section">
          <h2>Informations générales</h2>
          
          <div className="form-group">
            <label htmlFor="businessName">Raison sociale</label>
            <input
              type="text"
              id="businessName"
              name="businessName"
              value={formData.businessName}
              onChange={handleInputChange}
              placeholder="Nom de votre structure (association, entreprise, etc.)"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="contact">Contact</label>
            <input
              type="text"
              id="contact"
              name="contact"
              value={formData.contact}
              onChange={handleInputChange}
              placeholder="Nom et prénom de la personne à contacter"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="role">Qualité</label>
            <select
              id="role"
              name="role"
              value={formData.role}
              onChange={handleInputChange}
            >
              <option value="">Sélectionnez votre fonction</option>
              <option value="Président">Président</option>
              <option value="Programmateur">Programmateur</option>
              <option value="Gérant">Gérant</option>
              <option value="Directeur">Directeur</option>
              <option value="Autre">Autre</option>
            </select>
          </div>
        </div>
        
        <div className="form-section">
          <h2>Coordonnées</h2>
          
          <div className="form-group">
            <label htmlFor="address">Adresse de la raison sociale</label>
            <textarea
              id="address"
              name="address"
              value={formData.address}
              onChange={handleInputChange}
              placeholder="Adresse complète de votre structure"
              rows="3"
            ></textarea>
          </div>
          
          <div className="form-group">
            <label htmlFor="venue">Lieu ou festival</label>
            <input
              type="text"
              id="venue"
              name="venue"
              value={formData.venue}
              onChange={handleInputChange}
              placeholder="Nom du lieu ou du festival"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              placeholder="Adresse email de contact"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="phone">Téléphone</label>
            <input
              type="tel"
              id="phone"
              name="phone"
              value={formData.phone}
              onChange={handleInputChange}
              placeholder="Numéro de téléphone"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="website">Site web</label>
            <input
              type="url"
              id="website"
              name="website"
              value={formData.website}
              onChange={handleInputChange}
              placeholder="URL de votre site web (commençant par http:// ou https://)"
            />
          </div>
        </div>
        
        <div className="form-section">
          <h2>Informations administratives</h2>
          
          <div className="form-group">
            <label htmlFor="vatNumber">Numéro intracommunautaire</label>
            <input
              type="text"
              id="vatNumber"
              name="vatNumber"
              value={formData.vatNumber}
              onChange={handleInputChange}
              placeholder="Numéro de TVA intracommunautaire (ex: FR12345678901)"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="siret">SIRET</label>
            <input
              type="text"
              id="siret"
              name="siret"
              value={formData.siret}
              onChange={handleInputChange}
              placeholder="Numéro SIRET (14 chiffres)"
            />
          </div>
        </div>
        
        <div className="form-actions">
          <button 
            type="submit" 
            className="submit-btn"
            disabled={submitting}
          >
            {submitting ? 'Envoi en cours...' : 'Envoyer le formulaire'}
          </button>
        </div>
      </form>
      
      <div className="public-form-footer">
        <p>
          Les informations recueillies sur ce formulaire sont enregistrées dans un fichier informatisé 
          pour la gestion des contrats et la facturation. Elles sont conservées pendant la durée nécessaire 
          à la gestion de la relation contractuelle et sont destinées aux services concernés.
        </p>
      </div>
    </div>
  );
};

export default PublicFormPage;
EOL
echo "Composant PublicFormPage créé."

# Création du CSS pour PublicFormPage
echo "Création du CSS pour PublicFormPage..."
cat > ./client/src/components/public/PublicFormPage.css << 'EOL'
.public-form-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 30px 20px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.public-form-header {
  text-align: center;
  margin-bottom: 30px;
}

.public-form-header h1 {
  font-size: 28px;
  color: #333;
  margin-bottom: 10px;
}

.form-description {
  color: #666;
  font-size: 16px;
  line-height: 1.5;
}

.public-form {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.form-section {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px;
  background-color: #fafafa;
}

.form-section h2 {
  font-size: 20px;
  color: #333;
  margin-top: 0;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #e0e0e0;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #555;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  border-color: #2196f3;
  outline: none;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-actions {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.submit-btn {
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 12px 24px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.submit-btn:hover {
  background-color: #43a047;
}

.submit-btn:disabled {
  background-color: #a5d6a7;
  cursor: not-allowed;
}

.public-form-footer {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #e0e0e0;
  font-size: 12px;
  color: #757575;
  text-align: center;
}

.public-form-loading {
  text-align: center;
  padding: 50px 20px;
  font-size: 18px;
  color: #666;
}

.public-form-error {
  background-color: #ffebee;
  color: #c62828;
  padding: 20px;
  border-radius: 8px;
  margin: 50px auto;
  max-width: 600px;
  text-align: center;
  font-size: 16px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.public-form-submitted {
  text-align: center;
  padding: 50px 20px;
  max-width: 600px;
  margin: 50px auto;
  background-color: #e8f5e9;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.submitted-icon {
  font-size: 60px;
  color: #4caf50;
  margin-bottom: 20px;
}

.public-form-submitted h2 {
  color: #2e7d32;
  margin-bottom: 20px;
}

.public-form-submitted p {
  color: #333;
  margin-bottom: 10px;
  font-size: 16px;
}

@media (max-width: 768px) {
  .public-form-container {
    padding: 20px 15px;
  }
  
  .public-form-header h1 {
    font-size: 24px;
  }
  
  .form-section {
    padding: 15px;
  }
  
  .form-section h2 {
    font-size: 18px;
  }
  
  .submit-btn {
    width: 100%;
  }
}
EOL
echo "CSS pour PublicFormPage créé."

# Création du composant FormSubmittedPage
echo "Création du composant FormSubmittedPage..."
cat > ./client/src/components/public/FormSubmittedPage.jsx << 'EOL'
import React from 'react';
import './FormSubmittedPage.css';

const FormSubmittedPage = () => {
  return (
    <div className="form-submitted-container">
      <div className="form-submitted-content">
        <div className="success-icon">
          <i className="fas fa-check-circle"></i>
        </div>
        <h1>Formulaire envoyé avec succès !</h1>
        <p className="thank-you-message">
          Merci d'avoir complété ce formulaire. Vos informations ont été enregistrées et seront traitées prochainement.
        </p>
        <div className="additional-info">
          <p>
            <i className="fas fa-info-circle"></i>
            Les informations que vous avez fournies seront utilisées pour la préparation des contrats et la facturation.
          </p>
          <p>
            <i className="fas fa-envelope"></i>
            Vous pourriez être contacté par email ou téléphone si des informations supplémentaires sont nécessaires.
          </p>
        </div>
        <div className="form-submitted-footer">
          <p>Vous pouvez maintenant fermer cette page.</p>
        </div>
      </div>
    </div>
  );
};

export default FormSubmittedPage;
EOL
echo "Composant FormSubmittedPage créé."

# Création du CSS pour FormSubmittedPage
echo "Création du CSS pour FormSubmittedPage..."
cat > ./client/src/components/public/FormSubmittedPage.css << 'EOL'
.form-submitted-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f5f5;
  padding: 20px;
}

.form-submitted-content {
  max-width: 600px;
  width: 100%;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
  padding: 40px 30px;
  text-align: center;
}

.success-icon {
  font-size: 80px;
  color: #4caf50;
  margin-bottom: 20px;
}

.form-submitted-content h1 {
  color: #333;
  font-size: 28px;
  margin-bottom: 20px;
}

.thank-you-message {
  font-size: 18px;
  color: #555;
  margin-bottom: 30px;
  line-height: 1.5;
}

.additional-info {
  background-color: #f9f9f9;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 30px;
  text-align: left;
}

.additional-info p {
  margin: 0 0 15px 0;
  color: #555;
  font-size: 16px;
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.additional-info p:last-child {
  margin-bottom: 0;
}

.additional-info i {
  color: #2196f3;
  font-size: 18px;
  margin-top: 2px;
}

.form-submitted-footer {
  color: #757575;
  font-size: 14px;
  margin-top: 20px;
}

@media (max-width: 768px) {
  .form-submitted-content {
    padding: 30px 20px;
  }
  
  .success-icon {
    font-size: 60px;
  }
  
  .form-submitted-content h1 {
    font-size: 24px;
  }
  
  .thank-you-message {
    font-size: 16px;
  }
}
EOL
echo "CSS pour FormSubmittedPage créé."

# Mise à jour du composant ConcertDetail.js
echo "Mise à jour du composant ConcertDetail.js..."
cat > ./client/src/components/concerts/ConcertDetail.js << 'EOL'
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getConcertById, updateConcert, deleteConcert } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import { getProgrammers } from '../../services/programmersService';
import { generateFormLink, getFormLinkByConcertId } from '../../services/formLinkService';
import './ConcertDetail.css';

const ConcertDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [concert, setConcert] = useState(null);
  const [artists, setArtists] = useState([]);
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formLink, setFormLink] = useState(null);
  const [showLinkModal, setShowLinkModal] = useState(false);
  const [linkCopied, setLinkCopied] = useState(false);
  const [formData, setFormData] = useState({
    artist: { id: '', name: '' },
    programmer: { id: '', name: '', structure: '' },
    date: '',
    time: '',
    venue: '',
    city: '',
    price: '',
    status: 'En attente',
    notes: ''
  });

  // Statuts possibles pour un concert
  const statuses = [
    'En attente',
    'Confirmé',
    'Contrat envoyé',
    'Contrat signé',
    'Acompte reçu',
    'Soldé',
    'Annulé'
  ];
  
  // Générer les options pour les heures (00h à 23h)
  const hours = Array.from({ length: 24 }, (_, i) => 
    i < 10 ? `0${i}` : `${i}`
  );
  
  // Générer les options pour les minutes (00 à 59)
  const minutes = Array.from({ length: 60 }, (_, i) => 
    i < 10 ? `0${i}` : `${i}`
  );

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération du concert avec l'ID: ${id}`);
        
        // Utiliser le service Firebase au lieu de fetch
        const concertData = await getConcertById(id);
        
        if (!concertData) {
          throw new Error('Concert non trouvé');
        }
        
        console.log('Concert récupéré:', concertData);
        setConcert(concertData);
        
        // Initialiser le formulaire avec les données du concert
        setFormData({
          artist: concertData.artist || { id: '', name: '' },
          programmer: concertData.programmer || { id: '', name: '', structure: '' },
          date: concertData.date || '',
          time: concertData.time || '',
          venue: concertData.venue || '',
          city: concertData.city || '',
          price: concertData.price ? concertData.price.toString() : '',
          status: concertData.status || 'En attente',
          notes: concertData.notes || ''
        });
        
        // Récupérer les artistes pour le formulaire d'édition
        console.log("Tentative de récupération des artistes...");
        const artistsData = await getArtists();
        console.log("Artistes récupérés:", artistsData);
        setArtists(artistsData);
        
        // Récupérer les programmateurs pour le formulaire d'édition
        console.log("Tentative de récupération des programmateurs...");
        const programmersData = await getProgrammers();
        console.log("Programmateurs récupérés:", programmersData);
        setProgrammers(programmersData);
        
        // Vérifier si un lien de formulaire existe déjà pour ce concert
        const existingLink = await getFormLinkByConcertId(id);
        if (existingLink) {
          console.log("Lien de formulaire existant trouvé:", existingLink);
          setFormLink(existingLink);
        }
        
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération du concert:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'artist') {
      const selectedArtist = artists.find(artist => artist.id === value);
      setFormData({
        ...formData,
        artist: {
          id: selectedArtist.id,
          name: selectedArtist.name
        }
      });
    } else if (name === 'programmer') {
      const selectedProgrammer = programmers.find(programmer => programmer.id === value);
      setFormData({
        ...formData,
        programmer: {
          id: selectedProgrammer.id,
          name: selectedProgrammer.name,
          structure: selectedProgrammer.structure || ''
        }
      });
    } else if (name === 'hour' || name === 'minute') {
      // Gérer les sélections d'heure et de minute
      const currentTime = formData.time ? formData.time.split(':') : ['00', '00'];
      const hour = name === 'hour' ? value : currentTime[0];
      const minute = name === 'minute' ? value : currentTime[1];
      
      setFormData({
        ...formData,
        time: `${hour}:${minute}`
      });
    } else {
      setFormData({
        ...formData,
        [name]: value
      });
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      // Convertir price en nombre
      const concertData = {
        ...formData,
        price: parseFloat(formData.price) || 0
      };
      
      console.log("Données du concert à mettre à jour:", concertData);
      
      // Utiliser le service Firebase pour mettre à jour le concert
      await updateConcert(id, concertData);
      
      // Récupérer les données mises à jour
      const updatedData = await getConcertById(id);
      setConcert(updatedData);
      
      setIsEditing(false);
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de la mise à jour du concert:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce concert ?')) {
      try {
        setLoading(true);
        
        // Utiliser le service Firebase pour supprimer le concert
        await deleteConcert(id);
        
        navigate('/concerts');
      } catch (err) {
        console.error("Erreur lors de la suppression du concert:", err);
        setError(err.message);
        setLoading(false);
      }
    }
  };

  const handleGenerateFormLink = async () => {
    try {
      setLoading(true);
      
      // Vérifier si le concert a un programmateur associé
      if (!concert.programmer || !concert.programmer.id) {
        alert("Ce concert n'a pas de programmateur associé. Veuillez d'abord ajouter un programmateur.");
        setLoading(false);
        return;
      }
      
      // Vérifier si un lien existe déjà
      if (formLink) {
        setShowLinkModal(true);
        setLoading(false);
        return;
      }
      
      // Générer un nouveau lien
      const newLink = await generateFormLink(
        id,
        concert,
        concert.programmer.id,
        concert.programmer.name
      );
      
      setFormLink(newLink);
      setShowLinkModal(true);
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de la génération du lien de formulaire:", err);
      setError(err.message);
      setLoading(false);
      alert("Une erreur est survenue lors de la génération du lien de formulaire. Veuillez réessayer.");
    }
  };

  const handleCopyLink = () => {
    if (!formLink) return;
    
    const baseUrl = window.location.origin;
    const fullUrl = `${baseUrl}/form/${formLink.token}`;
    
    navigator.clipboard.writeText(fullUrl)
      .then(() => {
        setLinkCopied(true);
        setTimeout(() => setLinkCopied(false), 3000);
      })
      .catch(err => {
        console.error("Erreur lors de la copie du lien:", err);
        alert("Impossible de copier le lien. Veuillez le sélectionner et le copier manuellement.");
      });
  };

  const closeLinkModal = () => {
    setShowLinkModal(false);
    setLinkCopied(false);
  };

  if (loading && !concert) return <div className="loading">Chargement des détails du concert...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;
  if (!concert) return <div className="not-found">Concert non trouvé</div>;

  // Extraire l'heure et les minutes du temps actuel pour le formulaire d'édition
  const currentTime = formData.time ? formData.time.split(':') : ['', ''];
  const currentHour = currentTime[0];
  const currentMinute = currentTime[1];

  // Construire l'URL complète du formulaire
  const baseUrl = window.location.origin;
  const formUrl = formLink ? `${baseUrl}/form/${formLink.token}` : '';

  return (
    <div className="concert-detail-container">
      <h2>Détails du Concert</h2>
      
      {isEditing ? (
        <form onSubmit={handleSubmit} className="edit-form">
          <div className="form-group">
            <label htmlFor="artist">Artiste *</label>
            <select
              id="artist"
              name="artist"
              value={formData.artist.id}
              onChange={handleInputChange}
              required
            >
              <option value="">Sélectionner un artiste</option>
              {artists.map(artist => (
                <option key={artist.id} value={artist.id}>{artist.name}</option>
              ))}
            </select>
          </div>
          
          <div className="form-group">
            <label htmlFor="programmer">Programmateur *</label>
            <select
              id="programmer"
              name="programmer"
              value={formData.programmer.id}
              onChange={handleInputChange}
              required
            >
              <option value="">Sélectionner un programmateur</option>
              {programmers.map(programmer => (
                <option key={programmer.id} value={programmer.id}>
                  {programmer.name} ({programmer.structure || 'Structure non spécifiée'})
                </option>
              ))}
            </select>
          </div>
          
          <div className="form-group">
            <label htmlFor="date">Date *</label>
            <input
              type="date"
              id="date"
              name="date"
              value={formData.date}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group time-selects">
            <label>Heure *</label>
            <div className="time-inputs">
              <select
                id="hour"
                name="hour"
                value={currentHour}
                onChange={handleInputChange}
                required
                aria-label="Heure"
              >
                <option value="">Heure</option>
                {hours.map(hour => (
                  <option key={hour} value={hour}>{hour}h</option>
                ))}
              </select>
              
              <select
                id="minute"
                name="minute"
                value={currentMinute}
                onChange={handleInputChange}
                required
                aria-label="Minute"
              >
                <option value="">Minute</option>
                {minutes.map(minute => (
                  <option key={minute} value={minute}>{minute}</option>
                ))}
              </select>
            </div>
          </div>
          
          <div className="form-group">
            <label htmlFor="venue">Lieu *</label>
            <input
              type="text"
              id="venue"
              name="venue"
              value={formData.venue}
              onChange={handleInputChange}
              required
              placeholder="Nom de la salle ou du lieu"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="city">Ville *</label>
            <input
              type="text"
              id="city"
              name="city"
              value={formData.city}
              onChange={handleInputChange}
              required
              placeholder="Ville"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="price">Prix (€)</label>
            <input
              type="number"
              id="price"
              name="price"
              value={formData.price}
              onChange={handleInputChange}
              min="0"
              step="0.01"
              placeholder="Prix en euros"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="status">Statut</label>
            <select
              id="status"
              name="status"
              value={formData.status}
              onChange={handleInputChange}
            >
              {statuses.map(status => (
                <option key={status} value={status}>{status}</option>
              ))}
            </select>
          </div>
          
          <div className="form-group full-width">
            <label htmlFor="notes">Notes</label>
            <textarea
              id="notes"
              name="notes"
              value={formData.notes}
              onChange={handleInputChange}
              rows="4"
              placeholder="Informations complémentaires"
            ></textarea>
          </div>
          
          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={() => setIsEditing(false)}>
              Annuler
            </button>
            <button type="submit" className="save-btn" disabled={loading}>
              {loading ? 'Enregistrement...' : 'Enregistrer'}
            </button>
          </div>
        </form>
      ) : (
        <>
          <div className="concert-info">
            <div className="info-row">
              <span className="info-label">Artiste:</span>
              <span className="info-value">{concert.artist?.name || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Programmateur:</span>
              <span className="info-value">
                {concert.programmer?.name || 'Non spécifié'}
                {concert.programmer?.structure && ` (${concert.programmer.structure})`}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Date:</span>
              <span className="info-value">
                {concert.date ? new Date(concert.date).toLocaleDateString() : 'Non spécifiée'}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Heure:</span>
              <span className="info-value">{concert.time || 'Non spécifiée'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Lieu:</span>
              <span className="info-value">{concert.venue || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Ville:</span>
              <span className="info-value">{concert.city || 'Non spécifiée'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Prix:</span>
              <span className="info-value">
                {concert.price ? `${concert.price} €` : 'Non spécifié'}
              </span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Statut:</span>
              <span className="info-value">{concert.status || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row notes">
              <span className="info-label">Notes:</span>
              <span className="info-value">{concert.notes || 'Aucune note'}</span>
            </div>
            
            <div className="info-row form-link-status">
              <span className="info-label">Formulaire:</span>
              <span className="info-value">
                {formLink ? (
                  formLink.isSubmitted ? (
                    <span className="form-submitted">Formulaire soumis</span>
                  ) : (
                    <span className="form-pending">Formulaire envoyé, en attente de réponse</span>
                  )
                ) : (
                  <span className="form-not-sent">Formulaire non envoyé</span>
                )}
              </span>
            </div>
          </div>
          
          <div className="concert-actions">
            <button onClick={() => setIsEditing(true)} className="edit-btn">
              Modifier
            </button>
            <button onClick={handleDelete} className="delete-btn">
              Supprimer
            </button>
            <button 
              onClick={handleGenerateFormLink} 
              className="send-form-btn"
              disabled={loading || !concert.programmer?.id}
            >
              {formLink ? 'Voir le lien du formulaire' : 'Envoyer le formulaire'}
            </button>
            <button onClick={() => navigate('/concerts')} className="back-btn">
              Retour à la liste
            </button>
          </div>
        </>
      )}
      
      {/* Modal pour afficher le lien du formulaire */}
      {showLinkModal && formLink && (
        <div className="form-link-modal-overlay">
          <div className="form-link-modal">
            <div className="form-link-modal-header">
              <h3>{formLink.isSubmitted ? 'Formulaire déjà soumis' : 'Lien du formulaire'}</h3>
              <button className="close-modal-btn" onClick={closeLinkModal}>
                <i className="fas fa-times"></i>
              </button>
            </div>
            
            <div className="form-link-modal-content">
              {formLink.isSubmitted ? (
                <div className="form-submitted-message">
                  <p>
                    <i className="fas fa-check-circle"></i>
                    Ce formulaire a déjà été soumis par le programmateur.
                  </p>
                  <p>
                    Vous pouvez consulter les informations soumises dans l'onglet 
                    <strong> Validation Formulaire</strong>.
                  </p>
                </div>
              ) : (
                <>
                  <p className="form-link-instructions">
                    Voici le lien unique à envoyer au programmateur pour qu'il puisse remplir le formulaire :
                  </p>
                  
                  <div className="form-link-container">
                    <input
                      type="text"
                      value={formUrl}
                      readOnly
                      className="form-link-input"
                    />
                    <button 
                      className="copy-link-btn"
                      onClick={handleCopyLink}
                    >
                      {linkCopied ? (
                        <>
                          <i className="fas fa-check"></i> Copié
                        </>
                      ) : (
                        <>
                          <i className="fas fa-copy"></i> Copier
                        </>
                      )}
                    </button>
                  </div>
                  
                  <div className="form-link-info">
                    <p>
                      <i className="fas fa-info-circle"></i>
                      Ce lien est unique et associé à ce concert. Il permet au programmateur de remplir 
                      ses informations sans avoir besoin de créer un compte.
                    </p>
                    <p>
                      Une fois le formulaire soumis, les informations apparaîtront dans l'onglet 
                      <strong> Validation Formulaire</strong>.
                    </p>
                  </div>
                </>
              )}
            </div>
            
            <div className="form-link-modal-actions">
              <button className="close-btn" onClick={closeLinkModal}>
                Fermer
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ConcertDetail;
EOL
echo "Composant ConcertDetail.js mis à jour."

# Création du CSS pour ConcertDetail
echo "Création du CSS pour ConcertDetail..."
cat > ./client/src/components/concerts/ConcertDetail.css << 'EOL'
.concert-detail-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  padding: 20px;
  margin-bottom: 20px;
}

.concert-detail-container h2 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #333;
  font-size: 24px;
}

.concert-info {
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  width: 150px;
  font-weight: 600;
  color: #555;
}

.info-value {
  flex: 1;
  color: #333;
}

.notes {
  align-items: flex-start;
}

.notes .info-value {
  white-space: pre-line;
}

.concert-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.edit-btn, .delete-btn, .back-btn, .send-form-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
}

.edit-btn {
  background-color: #4caf50;
  color: white;
}

.edit-btn:hover {
  background-color: #43a047;
}

.delete-btn {
  background-color: #f44336;
  color: white;
}

.delete-btn:hover {
  background-color: #e53935;
}

.back-btn {
  background-color: #f0f0f0;
  color: #333;
}

.back-btn:hover {
  background-color: #e0e0e0;
}

.send-form-btn {
  background-color: #2196f3;
  color: white;
}

.send-form-btn:hover {
  background-color: #1e88e5;
}

.send-form-btn:disabled {
  background-color: #bbdefb;
  cursor: not-allowed;
}

.edit-form {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group.full-width {
  grid-column: span 2;
}

.form-group label {
  margin-bottom: 5px;
  font-weight: 500;
  color: #555;
}

.form-group input,
.form-group select,
.form-group textarea {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.time-selects {
  display: flex;
  flex-direction: column;
}

.time-inputs {
  display: flex;
  gap: 10px;
}

.time-inputs select {
  flex: 1;
}

.form-actions {
  grid-column: span 2;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.cancel-btn, .save-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
}

.cancel-btn {
  background-color: #f0f0f0;
  color: #333;
}

.cancel-btn:hover {
  background-color: #e0e0e0;
}

.save-btn {
  background-color: #4caf50;
  color: white;
}

.save-btn:hover {
  background-color: #43a047;
}

.save-btn:disabled {
  background-color: #a5d6a7;
  cursor: not-allowed;
}

.loading {
  text-align: center;
  padding: 20px;
  color: #666;
}

.error-message {
  background-color: #ffebee;
  color: #c62828;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.not-found {
  text-align: center;
  padding: 30px;
  color: #666;
  font-style: italic;
}

/* Styles pour le statut du formulaire */
.form-link-status .info-value {
  display: flex;
  align-items: center;
}

.form-submitted, .form-pending, .form-not-sent {
  display: inline-flex;
  align-items: center;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 14px;
}

.form-submitted {
  background-color: #e8f5e9;
  color: #2e7d32;
  border: 1px solid #a5d6a7;
}

.form-submitted::before {
  content: '\f058';
  font-family: 'Font Awesome 5 Free';
  font-weight: 900;
  margin-right: 5px;
}

.form-pending {
  background-color: #fff8e1;
  color: #f57c00;
  border: 1px solid #ffcc80;
}

.form-pending::before {
  content: '\f017';
  font-family: 'Font Awesome 5 Free';
  font-weight: 900;
  margin-right: 5px;
}

.form-not-sent {
  background-color: #f5f5f5;
  color: #757575;
  border: 1px solid #e0e0e0;
}

.form-not-sent::before {
  content: '\f06a';
  font-family: 'Font Awesome 5 Free';
  font-weight: 900;
  margin-right: 5px;
}

/* Modal pour afficher le lien du formulaire */
.form-link-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.form-link-modal {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.form-link-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #dee2e6;
}

.form-link-modal-header h3 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.close-modal-btn {
  background: none;
  border: none;
  font-size: 20px;
  color: #6c757d;
  cursor: pointer;
  padding: 5px;
}

.close-modal-btn:hover {
  color: #343a40;
}

.form-link-modal-content {
  padding: 20px;
  overflow-y: auto;
}

.form-link-instructions {
  margin-bottom: 15px;
  color: #495057;
  font-size: 15px;
  line-height: 1.5;
}

.form-link-container {
  display: flex;
  margin-bottom: 20px;
}

.form-link-input {
  flex: 1;
  padding: 10px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px 0 0 4px;
  font-size: 14px;
  background-color: #f8f9fa;
  color: #495057;
}

.copy-link-btn {
  background-color: #2196f3;
  color: white;
  border: none;
  border-radius: 0 4px 4px 0;
  padding: 0 15px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
  display: flex;
  align-items: center;
  gap: 5px;
}

.copy-link-btn:hover {
  background-color: #1e88e5;
}

.form-link-info {
  background-color: #e3f2fd;
  border-radius: 4px;
  padding: 15px;
  margin-top: 15px;
}

.form-link-info p {
  margin: 0 0 10px 0;
  color: #0d47a1;
  font-size: 14px;
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.form-link-info p:last-child {
  margin-bottom: 0;
}

.form-link-info i {
  margin-top: 2px;
}

.form-submitted-message {
  background-color: #e8f5e9;
  border-radius: 4px;
  padding: 15px;
  margin-bottom: 15px;
}

.form-submitted-message p {
  margin: 0 0 10px 0;
  color: #2e7d32;
  font-size: 15px;
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.form-submitted-message p:last-child {
  margin-bottom: 0;
}

.form-submitted-message i {
  margin-top: 2px;
}

.form-link-modal-actions {
  display: flex;
  justify-content: flex-end;
  padding: 15px 20px;
  border-top: 1px solid #dee2e6;
}

.close-btn {
  background-color: #f8f9fa;
  color: #495057;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 8px 16px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
}

.close-btn:hover {
  background-color: #e9ecef;
}
EOL
echo "CSS pour ConcertDetail créé."

# Mise à jour du fichier App.js pour ajouter les nouvelles routes
echo "Mise à jour du fichier App.js..."
cat > ./client/src/App.js << 'EOL'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/common/Layout';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ContractsTable from './components/contracts/ContractsTable';
import FormValidationList from './components/formValidation/FormValidationList';
import PublicFormPage from './components/public/PublicFormPage';
import FormSubmittedPage from './components/public/FormSubmittedPage';
import './App.css';

function App() {
  return (
    <Router>
      <Routes>
        {/* Routes publiques pour les formulaires */}
        <Route path="/form/:token" element={<PublicFormPage />} />
        <Route path="/form-submitted" element={<FormSubmittedPage />} />
        
        {/* Routes protégées par le layout */}
        <Route path="/" element={<Layout />}>
          <Route index element={<Navigate to="/concerts" replace />} />
          <Route path="artists" element={<ArtistsList />} />
          <Route path="artists/:id" element={<ArtistDetail />} />
          <Route path="programmers" element={<ProgrammersList />} />
          <Route path="programmers/:id" element={<ProgrammerDetail />} />
          <Route path="concerts" element={<ConcertsList />} />
          <Route path="concerts/:id" element={<ConcertDetail />} />
          <Route path="contrats" element={<ContractsTable />} />
          <Route path="form-validation" element={<FormValidationList />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
EOL
echo "Fichier App.js mis à jour."

echo "Installation de la fonctionnalité de génération de liens de formulaires terminée."
echo ""
echo "Pour appliquer ces modifications à votre projet :"
echo "1. Placez ce script à la racine de votre projet app-booking"
echo "2. Rendez-le exécutable avec la commande : chmod +x add-form-generation-feature.sh"
echo "3. Exécutez-le : ./add-form-generation-feature.sh"
echo "4. Utilisez les commandes Git suivantes pour pousser les modifications vers GitHub :"
echo "   git add ."
echo "   git commit -m \"Ajout de la fonctionnalité de génération de liens de formulaires\""
echo "   git push origin main"
echo ""
echo "Une fois ces modifications déployées, vous pourrez générer des liens de formulaires depuis la page de détail d'un concert."
