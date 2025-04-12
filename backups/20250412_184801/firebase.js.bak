// client/src/firebase.js
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

// Configuration Firebase
// Utilisation de variables d'environnement pour améliorer la sécurité
// Les valeurs par défaut sont utilisées si les variables d'environnement ne sont pas définies
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY || "AIzaSyCt994en0glR_WVbxxkDATXM25QV7HKovA",
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN || "app-booking-26571.firebaseapp.com",
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID || "app-booking-26571",
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET || "app-booking-26571.firebasestorage.app",
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID || "985724562753",
  appId: process.env.REACT_APP_FIREBASE_APP_ID || "1:985724562753:web:83a093ebd7a7034a9a85c0",
  measurementId: process.env.REACT_APP_FIREBASE_MEASUREMENT_ID || "G-LC94BW3MWX"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);

export { app, db, auth };
