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
import { getArtistById } from './artistsService';
import { getProgrammerById } from './programmersService';

const concertsCollection = collection(db, 'concerts');

export const getConcerts = async () => {
  try {
    const q = query(concertsCollection, orderBy('date', 'desc'));
    const snapshot = await getDocs(q);
    
    // Récupérer les données des concerts
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    // Enrichir les données avec les informations des artistes et programmateurs
    const enrichedConcerts = await Promise.all(concerts.map(async (concert) => {
      let artist = null;
      let programmer = null;
      
      if (concert.artistId) {
        artist = await getArtistById(concert.artistId);
      }
      
      if (concert.programmerId) {
        programmer = await getProgrammerById(concert.programmerId);
      }
      
      return {
        ...concert,
        artist,
        programmer
      };
    }));
    
    return enrichedConcerts;
  } catch (error) {
    console.error("Erreur lors de la récupération des concerts:", error);
    // Retourner des données simulées en cas d'erreur ou si la collection n'existe pas encore
    return [
      {
        id: '1',
        title: 'Concert Jazz',
        date: '2025-05-15',
        time: '20:00',
        venue: 'Salle Pleyel',
        city: 'Paris',
        ticketPrice: 25,
        status: 'confirmé',
        artist: {
          id: '1',
          name: 'Quartet Moderne',
          genre: 'Jazz'
        },
        programmer: {
          id: '1',
          name: 'Marie Dupont',
          structure: 'Association Vibrations'
        }
      },
      {
        id: '2',
        title: 'Festival Rock',
        date: '2025-06-20',
        time: '19:30',
        venue: 'Zénith',
        city: 'Nantes',
        ticketPrice: 35,
        status: 'planifié',
        artist: {
          id: '2',
          name: 'Les Échos Électriques',
          genre: 'Rock'
        },
        programmer: {
          id: '2',
          name: 'Thomas Martin',
          structure: 'Festival Éclectique'
        }
      }
    ];
  }
};

export const getConcertsByArtist = async (artistId) => {
  try {
    const q = query(concertsCollection, where('artistId', '==', artistId), orderBy('date', 'desc'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des concerts par artiste:", error);
    return [];
  }
};

export const getConcertsByProgrammer = async (programmerId) => {
  try {
    const q = query(concertsCollection, where('programmerId', '==', programmerId), orderBy('date', 'desc'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des concerts par programmateur:", error);
    return [];
  }
};

export const getConcertById = async (id) => {
  try {
    const docRef = doc(concertsCollection, id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const concertData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      
      // Enrichir avec les données de l'artiste et du programmateur
      if (concertData.artistId) {
        concertData.artist = await getArtistById(concertData.artistId);
      }
      
      if (concertData.programmerId) {
        concertData.programmer = await getProgrammerById(concertData.programmerId);
      }
      
      return concertData;
    } else {
      return null;
    }
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
    const docRef = doc(concertsCollection, id);
    await updateDoc(docRef, {
      ...concertData,
      updatedAt: new Date()
    });
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
    const docRef = doc(concertsCollection, id);
    await deleteDoc(docRef);
    return true;
  } catch (error) {
    console.error("Erreur lors de la suppression du concert:", error);
    throw error;
  }
};
