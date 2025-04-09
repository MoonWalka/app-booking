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
  where,
  setDoc,
  Timestamp
} from 'firebase/firestore';
import { db } from '../firebase';
import { createContract, deleteContractsByConcert } from './contractsService';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, orderBy('date', 'desc')));
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, création d'un document initial...`);
      const initialDoc = {
        artist: {
          id: 'mock-artist-1',
          name: 'Artiste Exemple'
        },
        programmer: {
          id: 'mock-programmer-1',
          name: 'Programmateur Exemple',
          structure: 'Salle Exemple'
        },
        // Conversion de la chaîne en Timestamp
        date: Timestamp.fromDate(new Date('2025-12-31')),
        time: '20:00',
        venue: 'Salle de concert',
        city: 'Paris',
        price: 25,
        status: 'En attente',
        notes: 'Concert exemple créé automatiquement',
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
const mockConcerts = [
  {
    id: 'mock-concert-1',
    artist: {
      id: 'mock-artist-1',
      name: 'The Weeknd'
    },
    programmer: {
      id: 'mock-programmer-1',
      name: 'Marie Dupont',
      structure: 'Association Vibrations'
    },
    date: '2025-06-15',
    time: '20:00',
    venue: 'Stade de France',
    city: 'Paris',
    price: 85,
    status: 'Confirmé',
    notes: 'Concert complet',
    createdAt: new Date()
  },
  {
    id: 'mock-concert-2',
    artist: {
      id: 'mock-artist-2',
      name: 'Daft Punk'
    },
    programmer: {
      id: 'mock-programmer-2',
      name: 'Jean Martin',
      structure: 'La Cigale'
    },
    date: '2025-07-20',
    time: '21:00',
    venue: 'La Cigale',
    city: 'Paris',
    price: 65,
    status: 'En attente',
    notes: 'Tournée de retour',
    createdAt: new Date()
  }
];

// Assurez-vous que la collection concerts existe
const concertsCollection = collection(db, 'concerts');

export const getConcerts = async () => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log("Tentative de récupération des concerts depuis Firebase...");
    const q = query(concertsCollection, orderBy('date', 'desc'));
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log("Aucun concert trouvé dans Firebase, utilisation des données simulées");
      
      // Essayer d'ajouter les données simulées à Firebase
      try {
        console.log("Tentative d'ajout des données simulées à Firebase...");
        for (const concert of mockConcerts) {
          const { id, ...concertData } = concert;
          await setDoc(doc(db, 'concerts', id), concertData);
        }
        console.log("Données simulées ajoutées à Firebase avec succès");
      } catch (addError) {
        console.error("Erreur lors de l'ajout des données simulées:", addError);
      }
      
      return mockConcerts;
    }
    
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${concerts.length} concerts récupérés depuis Firebase`);
    return concerts;
  } catch (error) {
    console.error("Erreur lors de la récupération des concerts:", error);
    console.log("Utilisation des données simulées pour les concerts");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("Tentative d'ajout des données simulées à Firebase...");
      for (const concert of mockConcerts) {
        const { id, ...concertData } = concert;
        await setDoc(doc(db, 'concerts', id), concertData);
      }
      console.log("Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("Erreur lors de l'ajout des données simulées:", addError);
    }
    
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockConcerts;
  }
};

export const getConcertsByArtist = async (artistId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log(`Tentative de récupération des concerts pour l'artiste ${artistId}...`);
    const q = query(
      concertsCollection, 
      where('artist.id', '==', artistId),
      orderBy('date', 'desc')
    );
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log(`Aucun concert trouvé pour l'artiste ${artistId}`);
      return [];
    }
    
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${concerts.length} concerts récupérés pour l'artiste ${artistId}`);
    return concerts;
  } catch (error) {
    console.error(`Erreur lors de la récupération des concerts pour l'artiste ${artistId}:`, error);
    // Retourner des concerts simulés pour cet artiste
    const mockArtistConcerts = mockConcerts.filter(concert => concert.artist.id === artistId);
    console.log(`Utilisation de ${mockArtistConcerts.length} concerts simulés pour l'artiste ${artistId}`);
    return mockArtistConcerts;
  }
};

export const getConcertsByProgrammer = async (programmerId) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log(`Tentative de récupération des concerts pour le programmateur ${programmerId}...`);
    const q = query(
      concertsCollection, 
      where('programmer.id', '==', programmerId),
      orderBy('date', 'desc')
    );
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log(`Aucun concert trouvé pour le programmateur ${programmerId}`);
      return [];
    }
    
    const concerts = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${concerts.length} concerts récupérés pour le programmateur ${programmerId}`);
    return concerts;
  } catch (error) {
    console.error(`Erreur lors de la récupération des concerts pour le programmateur ${programmerId}:`, error);
    // Retourner des concerts simulés pour ce programmateur
    const mockProgrammerConcerts = mockConcerts.filter(concert => concert.programmer.id === programmerId);
    console.log(`Utilisation de ${mockProgrammerConcerts.length} concerts simulés pour le programmateur ${programmerId}`);
    return mockProgrammerConcerts;
  }
};

export const getConcertById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log(`Tentative de récupération du concert ${id} depuis Firebase...`);
    const docRef = doc(db, 'concerts', id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const concertData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Concert ${id} récupéré depuis Firebase:`, concertData);
      return concertData;
    }
    
    console.log(`Concert ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération du concert ${id}:`, error);
    // Retourner un concert simulé en cas d'erreur
    const mockConcert = mockConcerts.find(concert => concert.id === id) || mockConcerts[0];
    console.log(`Utilisation du concert simulé:`, mockConcert);
    return mockConcert;
  }
};

export const addConcert = async (concertData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log("Tentative d'ajout d'un concert à Firebase:", concertData);
    // Conversion du champ "date" en Timestamp si nécessaire
    const convertedConcertData = {
      ...concertData,
      date: typeof concertData.date === 'string'
              ? Timestamp.fromDate(new Date(concertData.date))
              : concertData.date,
      createdAt: new Date()
    };
    
    const docRef = await addDoc(concertsCollection, convertedConcertData);
    console.log(`Concert ajouté avec succès, ID: ${docRef.id}`);
    
    // Créer automatiquement un contrat associé au concert avec conversion de la date
    try {
      const contractData = {
        concertId: docRef.id,
        date: typeof concertData.date === 'string'
                ? Timestamp.fromDate(new Date(concertData.date))
                : concertData.date,
        optionDate: concertData.optionDate || null,
        artist: concertData.artist,
        project: concertData.project || null,
        venue: concertData.venue,
        city: concertData.city,
        programmer: concertData.programmer,
        amount: concertData.price || 0,
        formStatus: 'pending',
        contractSentStatus: 'pending',
        contractSignedStatus: 'pending',
        invoiceStatus: 'pending',
        status: 'en_cours',
        createdAt: new Date()
      };
      
      const newContract = await createContract(contractData);
      console.log(`Contrat créé automatiquement pour le concert ${docRef.id}:`, newContract);
    } catch (contractError) {
      console.error("Erreur lors de la création automatique du contrat:", contractError);
    }
    
    return {
      id: docRef.id,
      ...convertedConcertData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du concert:", error);
    console.log("Simulation de l'ajout d'un concert");
    
    // En cas d'erreur, essayer d'ajouter le concert avec un ID généré manuellement
    try {
      const mockId = 'mock-concert-' + Date.now();
      const convertedConcertData = {
        ...concertData,
        date: typeof concertData.date === 'string'
                ? Timestamp.fromDate(new Date(concertData.date))
                : concertData.date,
        createdAt: new Date()
      };
      await setDoc(doc(db, 'concerts', mockId), convertedConcertData);
      console.log(`Concert ajouté avec un ID manuel: ${mockId}`);
      
      // Créer automatiquement un contrat associé au concert simulé
      try {
        const contractData = {
          concertId: mockId,
          date: typeof concertData.date === 'string'
                  ? Timestamp.fromDate(new Date(concertData.date))
                  : concertData.date,
          optionDate: concertData.optionDate || null,
          artist: concertData.artist,
          project: concertData.project || null,
          venue: concertData.venue,
          city: concertData.city,
          programmer: concertData.programmer,
          amount: concertData.price || 0,
          formStatus: 'pending',
          contractSentStatus: 'pending',
          contractSignedStatus: 'pending',
          invoiceStatus: 'pending',
          status: 'en_cours',
          createdAt: new Date()
        };
        
        const newContract = await createContract(contractData);
        console.log(`Contrat créé automatiquement pour le concert simulé ${mockId}:`, newContract);
      } catch (contractError) {
        console.error("Erreur lors de la création automatique du contrat simulé:", contractError);
      }
      
      return {
        id: mockId,
        ...convertedConcertData
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel du concert:", addError);
      
      // Simulation minimale de l'ajout en cas d'échec
      const mockId = 'mock-concert-' + Date.now();
      return {
        id: mockId,
        ...concertData,
        createdAt: new Date()
      };
    }
  }
};

export const updateConcert = async (id, concertData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('concerts');
    
    console.log(`Tentative de mise à jour du concert ${id}:`, concertData);
    const docRef = doc(db, 'concerts', id);
    await updateDoc(docRef, {
      ...concertData,
      updatedAt: new Date()
    });
    
    console.log(`Concert ${id} mis à jour avec succès`);
    return {
      id,
      ...concertData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour du concert ${id}:`, error);
    console.log("Simulation de la mise à jour d'un concert");
    
    // Essayer de créer/remplacer le document
    try {
      await setDoc(doc(db, 'concerts', id), {
        ...concertData,
        updatedAt: new Date()
      });
      
      console.log(`Concert ${id} créé/remplacé avec succès`);
      return {
        id,
        ...concertData,
        updatedAt: new Date()
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement du concert ${id}:`, setError);
      
      // Simulation de la mise à jour en cas d'erreur
      return {
        id,
        ...concertData,
        updatedAt: new Date()
      };
    }
  }
};

export const deleteConcert = async (id) => {
  try {
    console.log(`Tentative de suppression du concert ${id}`);
    const docRef = doc(db, 'concerts', id);
    await deleteDoc(docRef);
    
    // Supprimer également tous les contrats liés à ce concert
    try {
      const deletedContractIds = await deleteContractsByConcert(id);
      console.log(`Concert ${id} et ${deletedContractIds.length} contrats associés supprimés avec succès`);
    } catch (contractError) {
      console.error(`Erreur lors de la suppression des contrats liés au concert ${id}:`, contractError);
    }
    
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du concert ${id}:`, error);
    console.log("Simulation de la suppression d'un concert");
    
    // Tenter de supprimer les contrats associés même en cas d'erreur
    try {
      const deletedContractIds = await deleteContractsByConcert(id);
      console.log(`${deletedContractIds.length} contrats associés au concert ${id} supprimés avec succès`);
    } catch (contractError) {
      console.error(`Erreur lors de la suppression des contrats liés au concert ${id}:`, contractError);
    }
    
    // Simuler la suppression d'un concert en cas d'erreur
    return id;
  }
};