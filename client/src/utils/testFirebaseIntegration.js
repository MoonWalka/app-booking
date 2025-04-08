import React from 'react';
import { collection, getDocs, addDoc, query, where } from 'firebase/firestore';
import { db } from '../firebase';

// Fonction pour tester l'intégration Firebase avec les formulaires
const testFirebaseIntegration = async () => {
  console.log("Début du test d'intégration Firebase...");
  
  try {
    // 1. Test de création d'un artiste
    console.log("Test de création d'un artiste...");
    const artistData = {
      name: "Artiste Test",
      genre: "Test Genre",
      location: "Test City",
      contactEmail: "test@example.com",
      createdAt: new Date()
    };
    
    const artistsRef = collection(db, 'artists');
    const artistDoc = await addDoc(artistsRef, artistData);
    console.log("Artiste créé avec succès, ID:", artistDoc.id);
    
    // 2. Test de création d'un programmateur
    console.log("Test de création d'un programmateur...");
    const programmerData = {
      name: "Programmateur Test",
      structure: "Structure Test",
      email: "prog@example.com",
      city: "Test City",
      region: "Test Region",
      styles: ["Test", "Demo"],
      createdAt: new Date()
    };
    
    const programmersRef = collection(db, 'programmers');
    const programmerDoc = await addDoc(programmersRef, programmerData);
    console.log("Programmateur créé avec succès, ID:", programmerDoc.id);
    
    // 3. Test de création d'un concert avec références
    console.log("Test de création d'un concert...");
    const concertData = {
      date: "2025-12-31",
      time: "23:00",
      artist: {
        id: artistDoc.id,
        name: artistData.name
      },
      venue: "Salle Test",
      city: "Test City",
      status: "planifié",
      programmer: {
        id: programmerDoc.id,
        name: programmerData.name,
        structure: programmerData.structure
      },
      ticketPrice: 10,
      capacity: 100,
      createdAt: new Date()
    };
    
    const concertsRef = collection(db, 'concerts');
    const concertDoc = await addDoc(concertsRef, concertData);
    console.log("Concert créé avec succès, ID:", concertDoc.id);
    
    // 4. Test de récupération des données
    console.log("Test de récupération des données...");
    
    // Récupérer l'artiste créé
    const artistQuery = query(artistsRef, where("name", "==", "Artiste Test"));
    const artistSnapshot = await getDocs(artistQuery);
    if (!artistSnapshot.empty) {
      console.log("Artiste récupéré avec succès:", artistSnapshot.docs[0].data());
    } else {
      console.log("Erreur: Artiste non trouvé");
    }
    
    // Récupérer le programmateur créé
    const programmerQuery = query(programmersRef, where("name", "==", "Programmateur Test"));
    const programmerSnapshot = await getDocs(programmerQuery);
    if (!programmerSnapshot.empty) {
      console.log("Programmateur récupéré avec succès:", programmerSnapshot.docs[0].data());
    } else {
      console.log("Erreur: Programmateur non trouvé");
    }
    
    // Récupérer le concert créé
    const concertQuery = query(concertsRef, where("venue", "==", "Salle Test"));
    const concertSnapshot = await getDocs(concertQuery);
    if (!concertSnapshot.empty) {
      console.log("Concert récupéré avec succès:", concertSnapshot.docs[0].data());
    } else {
      console.log("Erreur: Concert non trouvé");
    }
    
    console.log("Tests d'intégration Firebase terminés avec succès!");
    return {
      success: true,
      message: "Tous les tests d'intégration Firebase ont réussi",
      createdIds: {
        artist: artistDoc.id,
        programmer: programmerDoc.id,
        concert: concertDoc.id
      }
    };
    
  } catch (error) {
    console.error("Erreur lors des tests d'intégration Firebase:", error);
    return {
      success: false,
      message: "Erreur lors des tests d'intégration Firebase",
      error: error.message
    };
  }
};

export default testFirebaseIntegration;
