import { db } from '../firebase';
import { collection, getDocs, doc, getDoc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';

// Récupérer tous les contrats
export const getAllContracts = async () => {
  try {
    const contractsCollection = collection(db, 'contracts');
    const contractsSnapshot = await getDocs(contractsCollection);
    return contractsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des contrats:", error);
    return [];
  }
};

// Récupérer un contrat par ID
export const getContractById = async (id) => {
  try {
    const contractDoc = doc(db, 'contracts', id);
    const contractSnapshot = await getDoc(contractDoc);
    
    if (contractSnapshot.exists()) {
      return {
        id: contractSnapshot.id,
        ...contractSnapshot.data()
      };
    } else {
      console.log("Aucun contrat trouvé avec cet ID");
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la récupération du contrat:", error);
    return null;
  }
};

// Créer un nouveau contrat
export const createContract = async (contractData) => {
  try {
    const contractsCollection = collection(db, 'contracts');
    const docRef = await addDoc(contractsCollection, {
      ...contractData,
      createdAt: new Date()
    });
    
    return {
      id: docRef.id,
      ...contractData
    };
  } catch (error) {
    console.error("Erreur lors de la création du contrat:", error);
    throw error;
  }
};

// Mettre à jour un contrat
export const updateContract = async (id, contractData) => {
  try {
    const contractDoc = doc(db, 'contracts', id);
    await updateDoc(contractDoc, {
      ...contractData,
      updatedAt: new Date()
    });
    
    return {
      id,
      ...contractData
    };
  } catch (error) {
    console.error("Erreur lors de la mise à jour du contrat:", error);
    throw error;
  }
};

// Supprimer un contrat
export const deleteContract = async (id) => {
  try {
    const contractDoc = doc(db, 'contracts', id);
    await deleteDoc(contractDoc);
    return true;
  } catch (error) {
    console.error("Erreur lors de la suppression du contrat:", error);
    return false;
  }
};
