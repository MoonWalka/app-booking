// client/src/services/artistsService.js
import { 
  collection, 
  getDocs, 
  getDoc, 
  doc, 
  addDoc, 
  updateDoc, 
  deleteDoc 
} from 'firebase/firestore';
import { db } from '../firebase';

const artistsCollection = collection(db, 'artists');

export const getArtists = async () => {
  const snapshot = await getDocs(artistsCollection);
  return snapshot.docs.map(doc => ({
    _id: doc.id,
    ...doc.data()
  }));
};

export const getArtistById = async (id) => {
  const docRef = doc(db, 'artists', id);
  const snapshot = await getDoc(docRef);
  
  if (snapshot.exists()) {
    return {
      _id: snapshot.id,
      ...snapshot.data()
    };
  }
  
  return null;
};

export const addArtist = async (artistData) => {
  const docRef = await addDoc(artistsCollection, artistData);
  return {
    _id: docRef.id,
    ...artistData
  };
};

export const updateArtist = async (id, artistData) => {
  const docRef = doc(db, 'artists', id);
  await updateDoc(docRef, artistData);
  return {
    _id: id,
    ...artistData
  };
};

export const deleteArtist = async (id) => {
  const docRef = doc(db, 'artists', id);
  await deleteDoc(docRef);
  return id;
};
