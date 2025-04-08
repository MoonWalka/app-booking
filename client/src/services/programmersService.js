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
        region: 'Auvergne-Rhône-Alpes',
        styles: ['Jazz', 'Folk'],
        capacity: 300,
        lastContact: '2025-03-15'
      },
      {
        id: '2',
        name: 'Jean Martin',
        structure: 'Le Loft',
        email: 'jean.martin@leloft.com',
        phone: '06 98 76 54 32',
        city: 'Paris',
        region: 'Île-de-France',
        styles: ['Électro', 'Hip-Hop'],
        capacity: 500,
        lastContact: '2025-03-20'
      },
      {
        id: '3',
        name: 'Sophie Legrand',
        structure: 'Centre Culturel Municipal',
        email: 'sophie.legrand@ccm.fr',
        phone: '06 45 67 89 01',
        city: 'Toulouse',
        region: 'Occitanie',
        styles: ['Classique', 'World'],
        capacity: 800,
        lastContact: '2025-03-10'
      }
    ];
  }
};

export const getProgrammerById = async (id) => {
  try {
    const docRef = doc(db, 'programmers', id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      return {
        id: snapshot.id,
        ...snapshot.data()
      };
    }
    
    return null;
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
    const docRef = doc(db, 'programmers', id);
    await updateDoc(docRef, programmerData);
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
    const docRef = doc(db, 'programmers', id);
    await deleteDoc(docRef);
    return id;
  } catch (error) {
    console.error("Erreur lors de la suppression du programmateur:", error);
    throw error;
  }
};
