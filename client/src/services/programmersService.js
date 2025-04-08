import { 
  collection, 
  getDocs, 
  getDoc, 
  doc, 
  addDoc, 
  updateDoc, 
  deleteDoc,
  query,
  orderBy
} from 'firebase/firestore';
import { db } from '../firebase';

const programmersCollection = collection(db, 'programmers');

export const getProgrammers = async () => {
  try {
    const q = query(programmersCollection, orderBy('name'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des programmateurs:", error);
    // Retourner des données simulées en cas d'erreur ou si la collection n'existe pas encore
    return [
      {
        id: '1',
        name: 'Marie Dupont',
        structure: 'Association Vibrations',
        email: 'marie.dupont@vibrations.fr',
        phone: '06 12 34 56 78',
        city: 'Lyon',
        region: 'Auvergne-Rhône-Alpes'
      },
      {
        id: '2',
        name: 'Thomas Martin',
        structure: 'Festival Éclectique',
        email: 'thomas.martin@eclectique.fr',
        phone: '07 23 45 67 89',
        city: 'Nantes',
        region: 'Pays de la Loire'
      }
    ];
  }
};

export const getProgrammerById = async (id) => {
  try {
    const docRef = doc(programmersCollection, id);
    const snapshot = await getDoc(docRef);
    if (snapshot.exists()) {
      return {
        id: snapshot.id,
        ...snapshot.data()
      };
    } else {
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la récupération du programmateur:", error);
    return null;
  }
};

export const addProgrammer = async (programmerData) => {
  try {
    const docRef = await addDoc(programmersCollection, {
      ...programmerData,
      createdAt: new Date()
    });
    return {
      id: docRef.id,
      ...programmerData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du programmateur:", error);
    throw error;
  }
};

export const updateProgrammer = async (id, programmerData) => {
  try {
    const docRef = doc(programmersCollection, id);
    await updateDoc(docRef, {
      ...programmerData,
      updatedAt: new Date()
    });
    return {
      id,
      ...programmerData
    };
  } catch (error) {
    console.error("Erreur lors de la mise à jour du programmateur:", error);
    throw error;
  }
};

export const deleteProgrammer = async (id) => {
  try {
    const docRef = doc(programmersCollection, id);
    await deleteDoc(docRef);
    return true;
  } catch (error) {
    console.error("Erreur lors de la suppression du programmateur:", error);
    throw error;
  }
};
