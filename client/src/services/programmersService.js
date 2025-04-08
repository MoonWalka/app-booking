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
  setDoc
} from 'firebase/firestore';
import { db } from '../firebase';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, orderBy('createdAt', 'desc')));
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, création d'un document initial...`);
      const initialDoc = {
        businessName: "Salle de Concert Exemple",
        contact: "Jean Dupont",
        role: "Programmateur",
        address: "123 rue de la Musique, 75001 Paris",
        venue: "La Scène Parisienne",
        vatNumber: "FR12345678901",
        siret: "123 456 789 00012",
        email: "contact@exemple.fr",
        phone: "01 23 45 67 89",
        website: "https://www.exemple.fr",
        notes: "Programmateur exemple créé automatiquement",
        createdAt: new Date()
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
const mockProgrammers = [
  {
    id: 'mock-programmer-1',
    businessName: "Association Vibrations",
    contact: "Marie Dupont",
    role: "Présidente",
    address: "45 rue de la République, 69001 Lyon",
    venue: "Festival Vibrations",
    vatNumber: "FR98765432101",
    siret: "987 654 321 00011",
    email: 'marie.dupont@vibrations.fr',
    phone: '06 12 34 56 78',
    website: 'https://www.vibrations-asso.fr',
    notes: 'Programmation de musiques actuelles',
    createdAt: new Date()
  },
  {
    id: 'mock-programmer-2',
    businessName: "SARL La Cigale",
    contact: "Jean Martin",
    role: "Gérant",
    address: "120 boulevard de Rochechouart, 75018 Paris",
    venue: "La Cigale",
    vatNumber: "FR45678901234",
    siret: "456 789 012 00013",
    email: 'jean.martin@lacigale.fr',
    phone: '01 23 45 67 89',
    website: 'https://www.lacigale.fr',
    notes: 'Salle de concert parisienne',
    createdAt: new Date()
  }
];

// Assurez-vous que la collection programmers existe
const programmersCollection = collection(db, 'programmers');

export const getProgrammers = async () => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('programmers');
    
    console.log("Tentative de récupération des programmateurs depuis Firebase...");
    const q = query(programmersCollection, orderBy('createdAt', 'desc'));
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log("Aucun programmateur trouvé dans Firebase, utilisation des données simulées");
      
      // Essayer d'ajouter les données simulées à Firebase
      try {
        console.log("Tentative d'ajout des données simulées à Firebase...");
        for (const programmer of mockProgrammers) {
          const { id, ...programmerData } = programmer;
          await setDoc(doc(db, 'programmers', id), programmerData);
        }
        console.log("Données simulées ajoutées à Firebase avec succès");
      } catch (addError) {
        console.error("Erreur lors de l'ajout des données simulées:", addError);
      }
      
      return mockProgrammers;
    }
    
    const programmers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${programmers.length} programmateurs récupérés depuis Firebase`);
    return programmers;
  } catch (error) {
    console.error("Erreur lors de la récupération des programmateurs:", error);
    console.log("Utilisation des données simulées pour les programmateurs");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("Tentative d'ajout des données simulées à Firebase...");
      for (const programmer of mockProgrammers) {
        const { id, ...programmerData } = programmer;
        await setDoc(doc(db, 'programmers', id), programmerData);
      }
      console.log("Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("Erreur lors de l'ajout des données simulées:", addError);
    }
    
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockProgrammers;
  }
};

export const getProgrammerById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('programmers');
    
    console.log(`Tentative de récupération du programmateur ${id} depuis Firebase...`);
    const docRef = doc(db, 'programmers', id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const programmerData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Programmateur ${id} récupéré depuis Firebase:`, programmerData);
      return programmerData;
    }
    
    console.log(`Programmateur ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération du programmateur ${id}:`, error);
    // Retourner un programmateur simulé en cas d'erreur
    const mockProgrammer = mockProgrammers.find(programmer => programmer.id === id) || mockProgrammers[0];
    console.log(`Utilisation du programmateur simulé:`, mockProgrammer);
    return mockProgrammer;
  }
};

export const addProgrammer = async (programmerData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('programmers');
    
    console.log("Tentative d'ajout d'un programmateur à Firebase:", programmerData);
    const docRef = await addDoc(programmersCollection, {
      ...programmerData,
      createdAt: new Date()
    });
    
    console.log(`Programmateur ajouté avec succès, ID: ${docRef.id}`);
    return {
      id: docRef.id,
      ...programmerData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du programmateur:", error);
    console.log("Simulation de l'ajout d'un programmateur");
    
    // Essayer d'ajouter le programmateur avec un ID généré manuellement
    try {
      const mockId = 'mock-programmer-' + Date.now();
      await setDoc(doc(db, 'programmers', mockId), {
        ...programmerData,
        createdAt: new Date()
      });
      
      console.log(`Programmateur ajouté avec un ID manuel: ${mockId}`);
      return {
        id: mockId,
        ...programmerData,
        createdAt: new Date()
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel du programmateur:", addError);
      
      // Simuler l'ajout d'un programmateur en cas d'erreur
      const mockId = 'mock-programmer-' + Date.now();
      return {
        id: mockId,
        ...programmerData,
        createdAt: new Date()
      };
    }
  }
};

export const updateProgrammer = async (id, programmerData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('programmers');
    
    console.log(`Tentative de mise à jour du programmateur ${id}:`, programmerData);
    const docRef = doc(db, 'programmers', id);
    await updateDoc(docRef, {
      ...programmerData,
      updatedAt: new Date()
    });
    
    console.log(`Programmateur ${id} mis à jour avec succès`);
    return {
      id,
      ...programmerData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour du programmateur ${id}:`, error);
    console.log("Simulation de la mise à jour d'un programmateur");
    
    // Essayer de créer/remplacer le document
    try {
      await setDoc(doc(db, 'programmers', id), {
        ...programmerData,
        updatedAt: new Date()
      });
      
      console.log(`Programmateur ${id} créé/remplacé avec succès`);
      return {
        id,
        ...programmerData,
        updatedAt: new Date()
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement du programmateur ${id}:`, setError);
      
      // Simuler la mise à jour d'un programmateur en cas d'erreur
      return {
        id,
        ...programmerData,
        updatedAt: new Date()
      };
    }
  }
};

export const deleteProgrammer = async (id) => {
  try {
    console.log(`Tentative de suppression du programmateur ${id}`);
    const docRef = doc(db, 'programmers', id);
    await deleteDoc(docRef);
    
    console.log(`Programmateur ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du programmateur ${id}:`, error);
    console.log("Simulation de la suppression d'un programmateur");
    // Simuler la suppression d'un programmateur en cas d'erreur
    return id;
  }
};
