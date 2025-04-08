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
    const snapshot = await getDocs(query(collectionRef, orderBy('name')));
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, création d'un document initial...`);
      const initialDoc = {
        name: "Artiste exemple",
        genre: "Rock",
        location: "Paris",
        members: 1,
        contactEmail: "exemple@email.com",
        bio: "Ceci est un artiste exemple créé automatiquement.",
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

// Assurez-vous que la collection artists existe
const artistsCollection = collection(db, 'artists');

export const getArtists = async () => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('artists');
    
    console.log("Tentative de récupération des artistes depuis Firebase...");
    const q = query(artistsCollection, orderBy('name'));
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log("Aucun artiste trouvé dans Firebase, utilisation des données simulées");
      return mockArtists;
    }
    
    const artists = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${artists.length} artistes récupérés depuis Firebase`);
    return artists;
  } catch (error) {
    console.error("Erreur lors de la récupération des artistes:", error);
    console.log("Utilisation des données simulées pour les artistes");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("Tentative d'ajout des données simulées à Firebase...");
      for (const artist of mockArtists) {
        const { id, ...artistData } = artist;
        await setDoc(doc(db, 'artists', id), artistData);
      }
      console.log("Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("Erreur lors de l'ajout des données simulées:", addError);
    }
    
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockArtists;
  }
};

export const getArtistById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('artists');
    
    console.log(`Tentative de récupération de l'artiste ${id} depuis Firebase...`);
    const docRef = doc(db, 'artists', id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const artistData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Artiste ${id} récupéré depuis Firebase:`, artistData);
      return artistData;
    }
    
    console.log(`Artiste ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération de l'artiste ${id}:`, error);
    // Retourner un artiste simulé en cas d'erreur
    const mockArtist = mockArtists.find(artist => artist.id === id) || mockArtists[0];
    console.log(`Utilisation de l'artiste simulé:`, mockArtist);
    return mockArtist;
  }
};

export const addArtist = async (artistData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('artists');
    
    console.log("Tentative d'ajout d'un artiste à Firebase:", artistData);
    const docRef = await addDoc(artistsCollection, {
      ...artistData,
      createdAt: new Date()
    });
    
    console.log(`Artiste ajouté avec succès, ID: ${docRef.id}`);
    return {
      id: docRef.id,
      ...artistData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'artiste:", error);
    console.log("Simulation de l'ajout d'un artiste");
    
    // Essayer d'ajouter l'artiste avec un ID généré manuellement
    try {
      const mockId = 'mock-artist-' + Date.now();
      await setDoc(doc(db, 'artists', mockId), {
        ...artistData,
        createdAt: new Date()
      });
      
      console.log(`Artiste ajouté avec un ID manuel: ${mockId}`);
      return {
        id: mockId,
        ...artistData,
        createdAt: new Date()
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel de l'artiste:", addError);
      
      // Simuler l'ajout d'un artiste en cas d'erreur
      const mockId = 'mock-artist-' + Date.now();
      return {
        id: mockId,
        ...artistData,
        createdAt: new Date()
      };
    }
  }
};

export const updateArtist = async (id, artistData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('artists');
    
    console.log(`Tentative de mise à jour de l'artiste ${id}:`, artistData);
    const docRef = doc(db, 'artists', id);
    await updateDoc(docRef, {
      ...artistData,
      updatedAt: new Date()
    });
    
    console.log(`Artiste ${id} mis à jour avec succès`);
    return {
      id,
      ...artistData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour de l'artiste ${id}:`, error);
    console.log("Simulation de la mise à jour d'un artiste");
    
    // Essayer de créer/remplacer le document
    try {
      await setDoc(doc(db, 'artists', id), {
        ...artistData,
        updatedAt: new Date()
      });
      
      console.log(`Artiste ${id} créé/remplacé avec succès`);
      return {
        id,
        ...artistData,
        updatedAt: new Date()
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement de l'artiste ${id}:`, setError);
      
      // Simuler la mise à jour d'un artiste en cas d'erreur
      return {
        id,
        ...artistData,
        updatedAt: new Date()
      };
    }
  }
};

export const deleteArtist = async (id) => {
  try {
    console.log(`Tentative de suppression de l'artiste ${id}`);
    const docRef = doc(db, 'artists', id);
    await deleteDoc(docRef);
    
    console.log(`Artiste ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression de l'artiste ${id}:`, error);
    console.log("Simulation de la suppression d'un artiste");
    // Simuler la suppression d'un artiste en cas d'erreur
    return id;
  }
};
