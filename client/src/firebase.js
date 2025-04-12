import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Configuration Firebase à partir des variables d'environnement
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FIREBASE_APP_ID
};

// Initialiser Firebase
const app = initializeApp(firebaseConfig);

// Exporter les services Firebase
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

// Utilitaire de logging sécurisé
export const secureLog = (message, data = null) => {
  // Ne pas logger en production
  if (process.env.REACT_APP_ENV === 'production') return;
  
  // Masquer les informations sensibles
  const sanitizeData = (obj) => {
    if (!obj) return obj;
    
    const sanitized = { ...obj };
    
    // Liste des clés sensibles à masquer
    const sensitiveKeys = ['password', 'token', 'apiKey', 'secret', 'credential'];
    
    Object.keys(sanitized).forEach(key => {
      // Masquer les valeurs des clés sensibles
      if (sensitiveKeys.some(sk => key.toLowerCase().includes(sk.toLowerCase()))) {
        sanitized[key] = '***MASKED***';
      }
      // Récursion pour les objets imbriqués
      else if (typeof sanitized[key] === 'object' && sanitized[key] !== null) {
        sanitized[key] = sanitizeData(sanitized[key]);
      }
    });
    
    return sanitized;
  };
  
  console.log(message, data ? sanitizeData(data) : '');
};

export default app;
