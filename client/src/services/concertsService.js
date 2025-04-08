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
  where
} from 'firebase/firestore';
import { db } from '../firebase';

const concertsCollection = collection(db, 'concerts');

export const getConcerts = async () => {
  try {
    const q = query(concertsCollection, orderBy('date'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des concerts:", error);
    // Retourner des données simulées en cas d'erreur ou si la collection n'existe pas encore
    return [
      {
        id: '1',
        date: '2025-05-15',
        time: '20:30',
        artist: { 
          id: '1',
          name: 'Les Harmonies Urbaines' 
        },
        venue: 'Salle des Fêtes',
        city: 'Lyon',
        status: 'confirmé',
        programmer: { 
          id: '1',
          name: 'Marie Dupont',
          structure: 'Association Vibrations'
        },
        ticketPrice: 15,
        capacity: 300
      },
      {
        id: '2',
        date: '2025-05-17',
        time: '21:00',
        artist: { 
          id: '2',
          name: 'Échos Poétiques' 
        },
        venue: 'Le Loft',
        city: 'Paris',
        status: 'contrat_envoyé',
        programmer: { 
          id: '2',
          name: 'Jean Martin',
          structure: 'Le Loft'
        },
        ticketPrice: 20,
        capacity: 500
      },
      {
        id: '3',
        date: '2025-05-22',
        time: '19:30',
        artist: { 
          id: '3',
          name: 'Rythmes Solaires' 
        },
        venue: 'Centre Culturel',
        city: 'Toulouse',
        status: 'acompte_reçu',
        programmer: { 
          id: '3',
          name: 'Sophie Legrand',
          structure: 'Centre Culturel Municipal'
        },
        ticketPrice: 18,
        capacity: 800
      }
    ];
  }
};

export const getUpcomingConcerts = async (limit = 10) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const q = query(
      concertsCollection, 
      where('date', '>=', today),
      orderBy('date'),
      limit(limit)
    );
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des concerts à venir:", error);
    // Utiliser les données simulées de getConcerts() en cas d'erreur
    const allConcerts = await getConcerts();
    return allConcerts.slice(0, limit);
  }
};

export const getConcertById = async (id) => {
  try {
    const docRef = doc(db, 'concerts', id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      return {
        id: snapshot.id,
        ...snapshot.data()
      };
    }
    
    return null;
  } catch (error) {
    console.error("Erreur lors de la récupération du concert:", error);
    return null;
  }
};

export const addConcert = async (concertData) => {
  try {
    const docRef = await addDoc(concertsCollection, {
      ...concertData,
      createdAt: new Date()
    });
    return {
      id: docRef.id,
      ...concertData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du concert:", error);
    throw error;
  }
};

export const updateConcert = async (id, concertData) => {
  try {
    const docRef = doc(db, 'concerts', id);
    await updateDoc(docRef, concertData);
    return {
      id,
      ...concertData
    };
  } catch (error) {
    console.error("Erreur lors de la mise à jour du concert:", error);
    throw error;
  }
};

export const deleteConcert = async (id) => {
  try {
    const docRef = doc(db, 'concerts', id);
    await deleteDoc(docRef);
    return id;
  } catch (error) {
    console.error("Erreur lors de la suppression du concert:", error);
    throw error;
  }
};
