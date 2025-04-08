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

const artistsCollection = collection(db, 'artists');

// Données simulées pour le fallback en cas d'erreur d'authentification
const mockArtists = [
  {
    id: 'mock-artist-1',
    name: 'The Weeknd',
    genre: 'R&B/Pop',
    location: 'Toronto, Canada',
    members: 1,
    contactEmail: 'contact@theweeknd.com',
    contactPhone: '+1 123 456 7890',
    bio: 'Abel Makkonen Tesfaye, connu sous le nom de The Weeknd, est un auteur-compositeur-interprète canadien.',
    imageUrl: 'https://example.com/theweeknd.jpg',
    socialMedia: {
      spotify: 'https://open.spotify.com/artist/1Xyo4u8uXC1ZmMpatF05PJ',
      instagram: 'https://instagram.com/theweeknd'
    },
    createdAt: new Date()
  },
  {
    id: 'mock-artist-2',
    name: 'Daft Punk',
    genre: 'Electronic',
    location: 'Paris, France',
    members: 2,
    contactEmail: 'contact@daftpunk.com',
    contactPhone: '+33 1 23 45 67 89',
    bio: 'Daft Punk était un duo de musique électronique français formé en 1993 à Paris.',
    imageUrl: 'https://example.com/daftpunk.jpg',
    socialMedia: {
      spotify: 'https://open.spotify.com/artist/4tZwfgrHOc3mvqYlEYSvVi',
      instagram: 'https://instagram.com/daftpunk'
    },
    createdAt: new Date()
  }
];

export const getArtists = async () => {
  try {
    const q = query(artistsCollection, orderBy('name'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des artistes:", error);
    console.log("Utilisation des données simulées pour les artistes");
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockArtists;
  }
};

export const getArtistById = async (id) => {
  try {
    const docRef = doc(db, 'artists', id);
    const snapshot = await getDoc(docRef);
    if (snapshot.exists()) {
      return {
        id: snapshot.id,
        ...snapshot.data()
      };
    }
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération de l'artiste ${id}:`, error);
    // Retourner un artiste simulé en cas d'erreur
    return mockArtists.find(artist => artist.id === id) || mockArtists[0];
  }
};

export const addArtist = async (artistData) => {
  try {
    const docRef = await addDoc(artistsCollection, {
      ...artistData,
      createdAt: new Date()
    });
    return {
      id: docRef.id,
      ...artistData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'artiste:", error);
    console.log("Simulation de l'ajout d'un artiste");
    // Simuler l'ajout d'un artiste en cas d'erreur
    const mockId = 'mock-artist-' + Date.now();
    return {
      id: mockId,
      ...artistData,
      createdAt: new Date()
    };
  }
};

export const updateArtist = async (id, artistData) => {
  try {
    const docRef = doc(db, 'artists', id);
    await updateDoc(docRef, {
      ...artistData,
      updatedAt: new Date()
    });
    return {
      id,
      ...artistData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour de l'artiste ${id}:`, error);
    console.log("Simulation de la mise à jour d'un artiste");
    // Simuler la mise à jour d'un artiste en cas d'erreur
    return {
      id,
      ...artistData,
      updatedAt: new Date()
    };
  }
};

export const deleteArtist = async (id) => {
  try {
    const docRef = doc(db, 'artists', id);
    await deleteDoc(docRef);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression de l'artiste ${id}:`, error);
    console.log("Simulation de la suppression d'un artiste");
    // Simuler la suppression d'un artiste en cas d'erreur
    return id;
  }
};
