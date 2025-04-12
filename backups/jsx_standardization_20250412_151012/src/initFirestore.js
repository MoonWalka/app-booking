// client/src/initFirestore.js
import { collection, addDoc } from 'firebase/firestore';
import { db } from './firebase';

const initializeFirestore = async () => {
  // Artistes
  const artistsCollection = collection(db, 'artists');
  await addDoc(artistsCollection, {
    name: 'The Weeknd',
    genre: 'R&B/Pop',
    origin: 'Canada',
    bio: 'Abel Makkonen Tesfaye, connu sous le nom de The Weeknd, est un auteur-compositeur-interprète canadien.',
    website: 'https://www.theweeknd.com'
  }) ;
  
  await addDoc(artistsCollection, {
    name: 'Daft Punk',
    genre: 'Electronic',
    origin: 'France',
    bio: 'Daft Punk était un duo de musique électronique français formé en 1993 à Paris.',
    website: 'https://www.daftpunk.com'
  }) ;

  // Programmateurs
  const programmersCollection = collection(db, 'programmers');
  await addDoc(programmersCollection, {
    name: 'Jean Dupont',
    venue: 'La Cigale',
    city: 'Paris',
    email: 'jean.dupont@lacigale.fr',
    phone: '+33123456789',
    website: 'https://www.lacigale.fr',
    notes: 'Programmateur principal'
  }) ;
  
  // Concerts
  const concertsCollection = collection(db, 'concerts');
  await addDoc(concertsCollection, {
    artist: {
      name: 'The Weeknd'
    },
    date: '2023-06-15',
    time: '20:00',
    venue: 'Stade de France',
    city: 'Paris',
    price: 85,
    status: 'Confirmé',
    notes: 'Concert complet'
  });
  
  console.log('Données initiales ajoutées à Firestore');
};

export default initializeFirestore;
