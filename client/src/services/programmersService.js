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

// Données simulées pour le fallback en cas d'erreur d'authentification
const mockProgrammers = [
  {
    id: 'mock-programmer-1',
    name: 'Marie Dupont',
    structure: 'Association Vibrations',
    email: 'marie.dupont@vibrations.fr',
    phone: '06 12 34 56 78',
    city: 'Lyon',
    region: 'Auvergne-Rhône-Alpes',
    website: 'https://www.vibrations-asso.fr',
    notes: 'Programmation de musiques actuelles',
    createdAt: new Date()
  },
  {
    id: 'mock-programmer-2',
    name: 'Jean Martin',
    structure: 'La Cigale',
    email: 'jean.martin@lacigale.fr',
    phone: '01 23 45 67 89',
    city: 'Paris',
    region: 'Île-de-France',
    website: 'https://www.lacigale.fr',
    notes: 'Salle de concert parisienne',
    createdAt: new Date()
  }
];

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
    console.log("Utilisation des données simulées pour les programmateurs");
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockProgrammers;
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
    console.error(`Erreur lors de la récupération du programmateur ${id}:`, error);
    // Retourner un programmateur simulé en cas d'erreur
    return mockProgrammers.find(programmer => programmer.id === id) || mockProgrammers[0];
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
    console.log("Simulation de l'ajout d'un programmateur");
    // Simuler l'ajout d'un programmateur en cas d'erreur
    const mockId = 'mock-programmer-' + Date.now();
    return {
      id: mockId,
      ...programmerData,
      createdAt: new Date()
    };
  }
};

export const updateProgrammer = async (id, programmerData) => {
  try {
    const docRef = doc(db, 'programmers', id);
    await updateDoc(docRef, {
      ...programmerData,
      updatedAt: new Date()
    });
    return {
      id,
      ...programmerData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour du programmateur ${id}:`, error);
    console.log("Simulation de la mise à jour d'un programmateur");
    // Simuler la mise à jour d'un programmateur en cas d'erreur
    return {
      id,
      ...programmerData,
      updatedAt: new Date()
    };
  }
};

export const deleteProgrammer = async (id) => {
  try {
    const docRef = doc(db, 'programmers', id);
    await deleteDoc(docRef);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du programmateur ${id}:`, error);
    console.log("Simulation de la suppression d'un programmateur");
    // Simuler la suppression d'un programmateur en cas d'erreur
    return id;
  }
};
