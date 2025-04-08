// client/src/firebase.js
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCt994en0glR_WVbxxkDATXM25QV7HKovA",
  authDomain: "app-booking-26571.firebaseapp.com",
  projectId: "app-booking-26571",
  storageBucket: "app-booking-26571.firebasestorage.app",
  messagingSenderId: "985724562753",
  appId: "1:985724562753:web:83a093ebd7a7034a9a85c0",
  measurementId: "G-LC94BW3MWX"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig) ;
const analytics = getAnalytics(app);
const db = getFirestore(app);

export { db };
