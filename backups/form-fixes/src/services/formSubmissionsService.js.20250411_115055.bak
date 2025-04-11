import { db } from '../firebase';
import { collection, getDocs, getDoc, doc, addDoc, updateDoc, deleteDoc, query, where, orderBy } from 'firebase/firestore';

const COLLECTION_NAME = 'formSubmissions';

// Récupérer toutes les soumissions de formulaire
export const getFormSubmissions = async () => {
  try {
    console.log('FormSubmissionsService - Récupération de toutes les soumissions...');
    const submissionsCollection = collection(db, COLLECTION_NAME);
    const submissionsSnapshot = await getDocs(submissionsCollection);
    
    const submissions = submissionsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`FormSubmissionsService - ${submissions.length} soumissions récupérées`);
    
    // Mettre à jour les soumissions sans statut
    const submissionsToUpdate = submissions.filter(submission => !submission.status);
    if (submissionsToUpdate.length > 0) {
      console.log(`FormSubmissionsService - Mise à jour de ${submissionsToUpdate.length} soumissions sans statut...`);
      for (const submission of submissionsToUpdate) {
        await updateFormSubmissionStatus(submission.id, 'pending');
      }
      
      // Récupérer à nouveau les soumissions après la mise à jour
      const updatedSubmissionsSnapshot = await getDocs(submissionsCollection);
      const updatedSubmissions = updatedSubmissionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      console.log(`FormSubmissionsService - ${updatedSubmissions.length} soumissions récupérées après mise à jour`);
      return updatedSubmissions;
    }
    
    return submissions;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors de la récupération des soumissions:', error);
    throw new Error('Erreur lors de la récupération des soumissions de formulaire');
  }
};

// Récupérer les soumissions en attente
export const getPendingFormSubmissions = async () => {
  try {
    console.log('FormSubmissionsService - Récupération des soumissions en attente...');
    const submissionsCollection = collection(db, COLLECTION_NAME);
    const pendingQuery = query(
      submissionsCollection,
      where('status', '==', 'pending'),
      orderBy('submissionDate', 'desc')
    );
    
    const pendingSnapshot = await getDocs(pendingQuery);
    const pendingSubmissions = pendingSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`FormSubmissionsService - ${pendingSubmissions.length} soumissions en attente récupérées`);
    return pendingSubmissions;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors de la récupération des soumissions en attente:', error);
    throw new Error('Erreur lors de la récupération des soumissions en attente');
  }
};

// Récupérer une soumission de formulaire par ID
export const getFormSubmission = async (id) => {
  try {
    console.log(`FormSubmissionsService - Récupération de la soumission ${id}...`);
    const submissionDoc = doc(db, COLLECTION_NAME, id);
    const submissionSnapshot = await getDoc(submissionDoc);
    
    if (!submissionSnapshot.exists()) {
      console.error(`FormSubmissionsService - Soumission ${id} non trouvée`);
      throw new Error('Soumission de formulaire non trouvée');
    }
    
    const submission = {
      id: submissionSnapshot.id,
      ...submissionSnapshot.data()
    };
    
    console.log(`FormSubmissionsService - Soumission ${id} récupérée:`, submission);
    return submission;
  } catch (error) {
    console.error(`FormSubmissionsService - Erreur lors de la récupération de la soumission ${id}:`, error);
    throw new Error('Erreur lors de la récupération de la soumission de formulaire');
  }
};

// Ajouter une nouvelle soumission de formulaire
export const addFormSubmission = async (formData) => {
  try {
    console.log('FormSubmissionsService - Ajout d\'une nouvelle soumission:', formData);
    
    // S'assurer que le statut est défini
    const submissionData = {
      ...formData,
      status: formData.status || 'pending',
      submissionDate: new Date()
    };
    
    const submissionsCollection = collection(db, COLLECTION_NAME);
    const docRef = await addDoc(submissionsCollection, submissionData);
    
    const newSubmission = {
      id: docRef.id,
      ...submissionData
    };
    
    console.log('FormSubmissionsService - Nouvelle soumission ajoutée:', newSubmission);
    return newSubmission;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors de l\'ajout de la soumission:', error);
    throw new Error('Erreur lors de l\'ajout de la soumission de formulaire');
  }
};

// Mettre à jour le statut d'une soumission de formulaire
export const updateFormSubmissionStatus = async (id, status) => {
  try {
    console.log(`FormSubmissionsService - Mise à jour du statut de la soumission ${id} à ${status}...`);
    const submissionDoc = doc(db, COLLECTION_NAME, id);
    
    await updateDoc(submissionDoc, { status });
    
    console.log(`FormSubmissionsService - Statut de la soumission ${id} mis à jour à ${status}`);
    return { id, status };
  } catch (error) {
    console.error(`FormSubmissionsService - Erreur lors de la mise à jour du statut de la soumission ${id}:`, error);
    throw new Error('Erreur lors de la mise à jour du statut de la soumission');
  }
};

// Supprimer une soumission de formulaire
export const deleteFormSubmission = async (id) => {
  try {
    console.log(`FormSubmissionsService - Suppression de la soumission ${id}...`);
    const submissionDoc = doc(db, COLLECTION_NAME, id);
    
    await deleteDoc(submissionDoc);
    
    console.log(`FormSubmissionsService - Soumission ${id} supprimée`);
    return { id };
  } catch (error) {
    console.error(`FormSubmissionsService - Erreur lors de la suppression de la soumission ${id}:`, error);
    throw new Error('Erreur lors de la suppression de la soumission de formulaire');
  }
};

// Récupérer les statistiques des soumissions
export const getFormSubmissionsStats = async () => {
  try {
    console.log('FormSubmissionsService - Calcul des statistiques des soumissions...');
    const submissions = await getFormSubmissions();
    
    // Compter les soumissions par statut
    const statusCounts = submissions.reduce((counts, submission) => {
      const status = submission.status || 'pending';
      counts[status] = (counts[status] || 0) + 1;
      return counts;
    }, {});
    
    // Compter les soumissions avec et sans token commun
    const withCommonToken = submissions.filter(submission => submission.commonToken).length;
    const withoutCommonToken = submissions.length - withCommonToken;
    
    // Compter les soumissions en attente
    const pendingCount = statusCounts.pending || 0;
    
    const stats = {
      total: submissions.length,
      pendingCount,
      statusCounts,
      withCommonToken,
      withoutCommonToken
    };
    
    console.log('FormSubmissionsService - Statistiques calculées:', stats);
    return stats;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors du calcul des statistiques:', error);
    throw new Error('Erreur lors du calcul des statistiques des soumissions');
  }


// Créer une nouvelle soumission de formulaire (alias pour addFormSubmission)
export const createFormSubmission = async (formData) => {
  try {
    console.log('FormSubmissionsService - Création d\'une nouvelle soumission:', formData);
    
    // S'assurer que le statut est défini
    const submissionData = {
      ...formData,
      status: formData.status || 'pending',
      submissionDate: new Date()
    };
    
    const submissionsCollection = collection(db, COLLECTION_NAME);
    const docRef = await addDoc(submissionsCollection, submissionData);
    
    const newSubmission = {
      id: docRef.id,
      ...submissionData
    };
    
    console.log('FormSubmissionsService - Nouvelle soumission créée:', newSubmission);
    return newSubmission;
  } catch (error) {
    console.error('FormSubmissionsService - Erreur lors de la création de la soumission:', error);
    throw new Error('Erreur lors de la création de la soumission de formulaire');
  }
};

