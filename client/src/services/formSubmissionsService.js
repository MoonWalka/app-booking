import { db } from '../firebase';
import { collection, getDocs, doc, getDoc, addDoc, updateDoc, query, where } from 'firebase/firestore';

// Récupérer toutes les soumissions de formulaire
export const getAllFormSubmissions = async () => {
  try {
    const submissionsCollection = collection(db, 'formSubmissions');
    const submissionsSnapshot = await getDocs(submissionsCollection);
    const submissionsList = submissionsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    // Mettre à jour les soumissions sans statut
    for (const submission of submissionsList) {
      if (!submission.status) {
        await updateFormSubmissionStatus(submission.id, 'pending');
        submission.status = 'pending';
      }
    }
    
    return submissionsList;
  } catch (error) {
    console.error("Erreur lors de la récupération des soumissions:", error);
    return [];
  }
};

// Récupérer les soumissions en attente
export const getPendingFormSubmissions = async () => {
  try {
    const submissionsCollection = collection(db, 'formSubmissions');
    const q = query(submissionsCollection, where("status", "==", "pending"));
    const submissionsSnapshot = await getDocs(q);
    return submissionsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des soumissions en attente:", error);
    return [];
  }
};

// Récupérer une soumission par ID
export const getFormSubmissionById = async (id) => {
  try {
    const submissionDoc = doc(db, 'formSubmissions', id);
    const submissionSnapshot = await getDoc(submissionDoc);
    
    if (submissionSnapshot.exists()) {
      return {
        id: submissionSnapshot.id,
        ...submissionSnapshot.data()
      };
    } else {
      console.log("Aucune soumission trouvée avec cet ID");
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la récupération de la soumission:", error);
    return null;
  }
};

// Créer une nouvelle soumission de formulaire
export const createFormSubmission = async (formData) => {
  try {
    // S'assurer que le statut est défini
    const dataWithStatus = {
      ...formData,
      status: formData.status || 'pending',
      createdAt: new Date()
    };
    
    const submissionsCollection = collection(db, 'formSubmissions');
    const docRef = await addDoc(submissionsCollection, dataWithStatus);
    
    return {
      id: docRef.id,
      ...dataWithStatus
    };
  } catch (error) {
    console.error("Erreur lors de la création de la soumission:", error);
    throw error;
  }
};

// Mettre à jour le statut d'une soumission
export const updateFormSubmissionStatus = async (id, status) => {
  try {
    const submissionDoc = doc(db, 'formSubmissions', id);
    await updateDoc(submissionDoc, { status });
    return true;
  } catch (error) {
    console.error("Erreur lors de la mise à jour du statut:", error);
    return false;
  }
};

// Mettre à jour une soumission avec les données validées
export const updateFormSubmissionWithValidatedData = async (id, validatedData) => {
  try {
    const submissionDoc = doc(db, 'formSubmissions', id);
    await updateDoc(submissionDoc, { 
      ...validatedData,
      status: 'validated',
      validatedAt: new Date()
    });
    return true;
  } catch (error) {
    console.error("Erreur lors de la mise à jour des données validées:", error);
    return false;
  }
};

// Mettre à jour les entités liées via le token commun
export const updateLinkedEntities = async (commonToken, validatedData) => {
  try {
    // Rechercher toutes les soumissions avec ce token commun
    const submissionsCollection = collection(db, 'formSubmissions');
    const q = query(submissionsCollection, where("commonToken", "==", commonToken));
    const submissionsSnapshot = await getDocs(q);
    
    // Mettre à jour chaque soumission
    const updatePromises = submissionsSnapshot.docs.map(async (submission) => {
      const submissionDoc = doc(db, 'formSubmissions', submission.id);
      await updateDoc(submissionDoc, { 
        ...validatedData,
        status: 'validated',
        validatedAt: new Date()
      });
    });
    
    await Promise.all(updatePromises);
    return true;
  } catch (error) {
    console.error("Erreur lors de la mise à jour des entités liées:", error);
    return false;
  }
};
