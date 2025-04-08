#!/bin/bash

# Script pour corriger les problèmes de la page des contrats
# et implémenter la fonctionnalité de création automatique de contrats

echo "Début de la correction de la page des contrats..."

# Vérifier si nous sommes dans le bon répertoire
if [ ! -d "./client" ]; then
  echo "Erreur: Ce script doit être exécuté depuis la racine du projet app-booking"
  exit 1
fi

# Correction du package.json du client (suppression du doublon Firebase)
echo "Correction du package.json du client..."
cat > ./client/package.json << 'EOL'
{
  "name": "app-booking-client",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.3.4",
    "firebase": "^11.6.0",
    "jwt-decode": "^3.1.2",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-firebase-hooks": "^5.1.1",
    "react-router-dom": "^6.8.2",
    "react-scripts": "5.0.1",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "proxy": "http://localhost:5000"
}
EOL

# Mise à jour du service des contrats
echo "Mise à jour du service des contrats..."
mkdir -p ./client/src/services
cat > ./client/src/services/contractsService.js << 'EOL'
// client/src/services/contractsService.js
import { db } from '../firebase';
import { collection, getDocs, getDoc, doc, addDoc, updateDoc, deleteDoc, query, where, orderBy } from 'firebase/firestore';

// Collection de référence
const CONTRACTS_COLLECTION = 'contracts';

/**
 * Récupère tous les contrats
 * @param {Object} filters - Filtres à appliquer (optionnel)
 * @returns {Promise<Array>} Liste des contrats
 */
export const fetchContracts = async (filters = {}) => {
  try {
    // Création d'une requête de base
    let contractsQuery = collection(db, CONTRACTS_COLLECTION);
    
    // Application des filtres si nécessaire
    if (filters) {
      // Exemple: filtrer par artiste
      if (filters.artist) {
        contractsQuery = query(contractsQuery, where('artist.name', '>=', filters.artist), 
                                             where('artist.name', '<=', filters.artist + '\uf8ff'));
      }
      
      // Exemple: filtrer par lieu
      if (filters.location) {
        contractsQuery = query(contractsQuery, where('venue', '>=', filters.location), 
                                             where('venue', '<=', filters.location + '\uf8ff'));
      }
      
      // Exemple: filtrer par statut
      if (filters.status && filters.status !== 'all') {
        contractsQuery = query(contractsQuery, where('status', '==', filters.status));
      }
      
      // Exemple: filtrer par plage de dates
      // Note: Ce type de filtre est plus complexe et pourrait nécessiter plusieurs requêtes
      // ou un traitement côté client selon les besoins spécifiques
    }
    
    // Ajout d'un tri par date
    contractsQuery = query(contractsQuery, orderBy('date', 'desc'));
    
    // Exécution de la requête
    const querySnapshot = await getDocs(contractsQuery);
    
    // Transformation des documents en objets JavaScript
    const contracts = [];
    querySnapshot.forEach((doc) => {
      contracts.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return contracts;
  } catch (error) {
    console.error('Erreur lors de la récupération des contrats:', error);
    
    // En cas d'erreur, retourner des données fictives pour le développement
    const mockContracts = [
      {
        id: '1',
        date: '2025-05-15',
        artist: { id: 'a1', name: 'Les Harmonies Urbaines' },
        venue: 'L\'Olympia',
        city: 'Paris',
        programmer: { id: 'p1', name: 'Jean Dupont' },
        preContract: { status: 'signed', date: '2025-03-10' },
        contract: { status: 'pending', date: null },
        invoice: { status: 'pending', amount: 2500, date: null },
        status: 'en_cours'
      },
      {
        id: '2',
        date: '2025-06-20',
        artist: { id: 'a2', name: 'Échos Poétiques' },
        venue: 'Zénith',
        city: 'Lille',
        programmer: { id: 'p2', name: 'Marie Martin' },
        preContract: { status: 'signed', date: '2025-04-05' },
        contract: { status: 'signed', date: '2025-04-20' },
        invoice: { status: 'pending', amount: 3000, date: null },
        status: 'confirmé'
      },
      {
        id: '3',
        date: '2025-07-10',
        artist: { id: 'a3', name: 'Rythmes Solaires' },
        venue: 'La Cigale',
        city: 'Paris',
        programmer: { id: 'p3', name: 'Sophie Lefebvre' },
        preContract: { status: 'pending', date: null },
        contract: { status: 'pending', date: null },
        invoice: { status: 'pending', amount: 1800, date: null },
        status: 'en_négociation'
      }
    ];
    
    return mockContracts;
  }
};

/**
 * Récupère un contrat par son ID
 * @param {string} id - ID du contrat
 * @returns {Promise<Object>} Données du contrat
 */
export const getContractById = async (id) => {
  try {
    const contractDoc = await getDoc(doc(db, CONTRACTS_COLLECTION, id));
    
    if (contractDoc.exists()) {
      return {
        id: contractDoc.id,
        ...contractDoc.data()
      };
    } else {
      throw new Error('Contrat non trouvé');
    }
  } catch (error) {
    console.error('Erreur lors de la récupération du contrat:', error);
    throw error;
  }
};

/**
 * Crée un nouveau contrat
 * @param {Object} contractData - Données du contrat
 * @returns {Promise<Object>} Contrat créé avec ID
 */
export const createContract = async (contractData) => {
  try {
    const docRef = await addDoc(collection(db, CONTRACTS_COLLECTION), contractData);
    return {
      id: docRef.id,
      ...contractData
    };
  } catch (error) {
    console.error('Erreur lors de la création du contrat:', error);
    
    // En cas d'erreur, simuler la création d'un contrat
    const mockId = 'mock-contract-' + Date.now();
    return {
      id: mockId,
      ...contractData
    };
  }
};

/**
 * Met à jour un contrat existant
 * @param {string} id - ID du contrat
 * @param {Object} contractData - Nouvelles données du contrat
 * @returns {Promise<void>}
 */
export const updateContract = async (id, contractData) => {
  try {
    await updateDoc(doc(db, CONTRACTS_COLLECTION, id), contractData);
    return {
      id,
      ...contractData
    };
  } catch (error) {
    console.error('Erreur lors de la mise à jour du contrat:', error);
    throw error;
  }
};

/**
 * Supprime un contrat
 * @param {string} id - ID du contrat
 * @returns {Promise<void>}
 */
export const deleteContract = async (id) => {
  try {
    await deleteDoc(doc(db, CONTRACTS_COLLECTION, id));
    return id;
  } catch (error) {
    console.error('Erreur lors de la suppression du contrat:', error);
    throw error;
  }
};

/**
 * Récupère les contrats liés à un artiste
 * @param {string} artistId - ID de l'artiste
 * @returns {Promise<Array>} Liste des contrats
 */
export const getContractsByArtist = async (artistId) => {
  try {
    const contractsQuery = query(
      collection(db, CONTRACTS_COLLECTION), 
      where('artist.id', '==', artistId),
      orderBy('date', 'desc')
    );
    const querySnapshot = await getDocs(contractsQuery);
    
    const contracts = [];
    querySnapshot.forEach((doc) => {
      contracts.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return contracts;
  } catch (error) {
    console.error('Erreur lors de la récupération des contrats par artiste:', error);
    throw error;
  }
};

/**
 * Récupère les contrats liés à un programmateur
 * @param {string} programmerId - ID du programmateur
 * @returns {Promise<Array>} Liste des contrats
 */
export const getContractsByProgrammer = async (programmerId) => {
  try {
    const contractsQuery = query(
      collection(db, CONTRACTS_COLLECTION), 
      where('programmer.id', '==', programmerId),
      orderBy('date', 'desc')
    );
    const querySnapshot = await getDocs(contractsQuery);
    
    const contracts = [];
    querySnapshot.forEach((doc) => {
      contracts.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return contracts;
  } catch (error) {
    console.error('Erreur lors de la récupération des contrats par programmateur:', error);
    throw error;
  }
};

/**
 * Récupère les contrats liés à un concert
 * @param {string} concertId - ID du concert
 * @returns {Promise<Array>} Liste des contrats
 */
export const getContractsByConcert = async (concertId) => {
  try {
    const contractsQuery = query(
      collection(db, CONTRACTS_COLLECTION), 
      where('concertId', '==', concertId)
    );
    const querySnapshot = await getDocs(contractsQuery);
    
    const contracts = [];
    querySnapshot.forEach((doc) => {
      contracts.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return contracts;
  } catch (error) {
    console.error('Erreur lors de la récupération des contrats par concert:', error);
    throw error;
  }
};

/**
 * Met à jour le statut d'un contrat
 * @param {string} id - ID du contrat
 * @param {string} status - Nouveau statut
 * @returns {Promise<Object>} Contrat mis à jour
 */
export const updateContractStatus = async (id, status) => {
  try {
    const contractRef = doc(db, CONTRACTS_COLLECTION, id);
    await updateDoc(contractRef, { status });
    
    // Récupérer le contrat mis à jour
    const updatedContract = await getContractById(id);
    return updatedContract;
  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut du contrat:', error);
    throw error;
  }
};
EOL

# Mise à jour du service des concerts
echo "Mise à jour du service des concerts..."
cat > ./client/src/services/concertsService.js << 'EOL'
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
  setDoc
} from 'firebase/firestore';
import { db } from '../firebase';
import { createContract } from './contractsService';

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
        date: '2025-12-31',
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
    const docRef = await addDoc(concertsCollection, {
      ...concertData,
      createdAt: new Date()
    });
    
    console.log(`Concert ajouté avec succès, ID: ${docRef.id}`);
    
    // Créer automatiquement un contrat associé au concert
    try {
      const contractData = {
        concertId: docRef.id,
        date: concertData.date,
        artist: concertData.artist,
        venue: concertData.venue,
        city: concertData.city,
        programmer: concertData.programmer,
        preContract: { status: 'pending', date: null },
        contract: { status: 'pending', date: null },
        invoice: { status: 'pending', amount: concertData.price || 0, date: null },
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
      ...concertData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du concert:", error);
    console.log("Simulation de l'ajout d'un concert");
    
    // Essayer d'ajouter le concert avec un ID généré manuellement
    try {
      const mockId = 'mock-concert-' + Date.now();
      await setDoc(doc(db, 'concerts', mockId), {
        ...concertData,
        createdAt: new Date()
      });
      
      console.log(`Concert ajouté avec un ID manuel: ${mockId}`);
      
      // Créer automatiquement un contrat associé au concert simulé
      try {
        const contractData = {
          concertId: mockId,
          date: concertData.date,
          artist: concertData.artist,
          venue: concertData.venue,
          city: concertData.city,
          programmer: concertData.programmer,
          preContract: { status: 'pending', date: null },
          contract: { status: 'pending', date: null },
          invoice: { status: 'pending', amount: concertData.price || 0, date: null },
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
        ...concertData,
        createdAt: new Date()
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel du concert:", addError);
      
      // Simuler l'ajout d'un concert en cas d'erreur
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
      
      // Simuler la mise à jour d'un concert en cas d'erreur
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
    
    console.log(`Concert ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du concert ${id}:`, error);
    console.log("Simulation de la suppression d'un concert");
    // Simuler la suppression d'un concert en cas d'erreur
    return id;
  }
};
EOL

# Mise à jour du composant ContractsTable
echo "Mise à jour du composant ContractsTable..."
mkdir -p ./client/src/components/contracts
cat > ./client/src/components/contracts/ContractsTable.js << 'EOL'
import React, { useState, useEffect, useMemo } from 'react';
import { Link } from 'react-router-dom';
import './ContractsTable.css';

// Services
import { fetchContracts, updateContractStatus } from '../../services/contractsService';

const ContractsTable = () => {
  const [contracts, setContracts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    artist: '',
    location: '',
    status: 'all',
    dateRange: { start: null, end: null }
  });
  const [sortConfig, setSortConfig] = useState({
    key: 'date',
    direction: 'ascending'
  });

  // Récupération des données
  useEffect(() => {
    const loadContracts = async () => {
      try {
        setLoading(true);
        // Utiliser le service pour récupérer les contrats depuis Firebase
        const contractsData = await fetchContracts(filters);
        setContracts(contractsData);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors du chargement des contrats:', error);
        setLoading(false);
      }
    };

    loadContracts();
  }, [filters]);

  // Fonction pour changer le tri
  const requestSort = (key) => {
    let direction = 'ascending';
    if (sortConfig.key === key && sortConfig.direction === 'ascending') {
      direction = 'descending';
    }
    setSortConfig({ key, direction });
  };

  // Fonction de tri
  const sortedContracts = useMemo(() => {
    const sortableContracts = [...contracts];
    if (sortConfig.key) {
      sortableContracts.sort((a, b) => {
        let aValue, bValue;
        
        // Extraction des valeurs selon la clé de tri
        switch(sortConfig.key) {
          case 'date':
            aValue = new Date(a.date);
            bValue = new Date(b.date);
            break;
          case 'artist':
            aValue = a.artist?.name?.toLowerCase() || '';
            bValue = b.artist?.name?.toLowerCase() || '';
            break;
          case 'venue':
            aValue = a.venue?.toLowerCase() || '';
            bValue = b.venue?.toLowerCase() || '';
            break;
          case 'city':
            aValue = a.city?.toLowerCase() || '';
            bValue = b.city?.toLowerCase() || '';
            break;
          case 'programmer':
            aValue = a.programmer?.name?.toLowerCase() || '';
            bValue = b.programmer?.name?.toLowerCase() || '';
            break;
          case 'status':
            aValue = a.status?.toLowerCase() || '';
            bValue = b.status?.toLowerCase() || '';
            break;
          default:
            aValue = a[sortConfig.key];
            bValue = b[sortConfig.key];
        }
        
        // Comparaison
        if (aValue < bValue) {
          return sortConfig.direction === 'ascending' ? -1 : 1;
        }
        if (aValue > bValue) {
          return sortConfig.direction === 'ascending' ? 1 : -1;
        }
        return 0;
      });
    }
    return sortableContracts;
  }, [contracts, sortConfig]);

  // Gestion de la progression des contrats
  const getContractStatus = (contract) => {
    const { preContract, contract: contractSigned, invoice } = contract;
    
    // Calcul du pourcentage de progression
    let progress = 0;
    let statusText = '';
    let statusColor = '';
    let statusIcon = '';
    
    if (preContract.status === 'signed') {
      progress += 33;
    }
    
    if (contractSigned.status === 'signed') {
      progress += 33;
    }
    
    if (invoice.status === 'paid') {
      progress += 34;
    }
    
    // Détermination du statut textuel, de la couleur et de l'icône
    if (progress === 0) {
      statusText = 'Non démarré';
      statusColor = 'gray';
      statusIcon = 'fas fa-file';
    } else if (progress < 33) {
      statusText = 'Pré-contrat';
      statusColor = 'orange';
      statusIcon = 'fas fa-file-signature';
    } else if (progress < 66) {
      statusText = 'Contrat en cours';
      statusColor = 'blue';
      statusIcon = 'fas fa-paper-plane';
    } else if (progress < 100) {
      statusText = 'Facturation';
      statusColor = 'purple';
      statusIcon = 'fas fa-file-invoice-dollar';
    } else {
      statusText = 'Complété';
      statusColor = 'green';
      statusIcon = 'fas fa-check-circle';
    }
    
    return {
      progress,
      statusText,
      statusColor,
      statusIcon
    };
  };

  // Fonction pour filtrer les contrats
  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({
      ...prev,
      [name]: value
    }));
  };

  // Fonction pour réinitialiser les filtres
  const resetFilters = () => {
    setFilters({
      artist: '',
      location: '',
      status: 'all',
      dateRange: { start: null, end: null }
    });
  };

  // Fonction pour afficher les détails d'un contrat
  const showContractDetails = (contractId) => {
    // Cette fonction sera implémentée plus tard pour naviguer vers la page de détails
    console.log(`Afficher les détails du contrat ${contractId}`);
    // navigate(`/contrats/${contractId}`);
  };

  // Formatage de la date
  const formatDate = (dateString) => {
    if (!dateString) return 'Non défini';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR');
  };

  if (loading) {
    return <div className="loading-container">Chargement des contrats...</div>;
  }

  return (
    <div className="contracts-table-container">
      {/* En-tête avec titre et statistiques */}
      <div className="contracts-header">
        <h1>Gestion des Contrats</h1>
        <div className="contracts-stats">
          <div className="stat-card">
            <div className="stat-icon">
              <i className="fas fa-file-contract"></i>
            </div>
            <div className="stat-content">
              <h3>Total</h3>
              <p className="stat-number">{contracts.length}</p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <i className="fas fa-clock"></i>
            </div>
            <div className="stat-content">
              <h3>En cours</h3>
              <p className="stat-number">
                {contracts.filter(c => c.status === 'en_cours').length}
              </p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <i className="fas fa-check-circle"></i>
            </div>
            <div className="stat-content">
              <h3>Confirmés</h3>
              <p className="stat-number">
                {contracts.filter(c => c.status === 'confirmé').length}
              </p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <i className="fas fa-comments"></i>
            </div>
            <div className="stat-content">
              <h3>En négociation</h3>
              <p className="stat-number">
                {contracts.filter(c => c.status === 'en_négociation').length}
              </p>
            </div>
          </div>
        </div>
      </div>
      
      {/* Composants de filtres et recherche */}
      <div className="table-filters">
        <div className="filter-group">
          <input
            type="text"
            name="artist"
            placeholder="Rechercher par artiste"
            value={filters.artist}
            onChange={handleFilterChange}
            className="filter-input"
          />
        </div>
        <div className="filter-group">
          <input
            type="text"
            name="location"
            placeholder="Rechercher par lieu"
            value={filters.location}
            onChange={handleFilterChange}
            className="filter-input"
          />
        </div>
        <div className="filter-group">
          <select
            name="status"
            value={filters.status}
            onChange={handleFilterChange}
            className="filter-select"
          >
            <option value="all">Tous les statuts</option>
            <option value="en_cours">En cours</option>
            <option value="confirmé">Confirmé</option>
            <option value="en_négociation">En négociation</option>
          </select>
        </div>
        <button className="filter-reset-btn" onClick={resetFilters}>
          <i className="fas fa-undo"></i> Réinitialiser
        </button>
        <Link to="/concerts" className="add-contract-btn">
          <i className="fas fa-plus"></i> Nouveau concert
        </Link>
      </div>
      
      {/* Tableau principal */}
      <div className="table-responsive">
        <table className="contracts-table">
          <thead>
            <tr>
              <th onClick={() => requestSort('date')} className={sortConfig.key === 'date' ? `sorted-${sortConfig.direction}` : ''}>
                Date <i className="fas fa-sort"></i>
              </th>
              <th onClick={() => requestSort('artist')} className={sortConfig.key === 'artist' ? `sorted-${sortConfig.direction}` : ''}>
                Artiste <i className="fas fa-sort"></i>
              </th>
              <th onClick={() => requestSort('venue')} className={sortConfig.key === 'venue' ? `sorted-${sortConfig.direction}` : ''}>
                Lieu <i className="fas fa-sort"></i>
              </th>
              <th onClick={() => requestSort('city')} className={sortConfig.key === 'city' ? `sorted-${sortConfig.direction}` : ''}>
                Ville <i className="fas fa-sort"></i>
              </th>
              <th onClick={() => requestSort('programmer')} className={sortConfig.key === 'programmer' ? `sorted-${sortConfig.direction}` : ''}>
                Programmateur <i className="fas fa-sort"></i>
              </th>
              <th>Progression</th>
              <th onClick={() => requestSort('status')} className={sortConfig.key === 'status' ? `sorted-${sortConfig.direction}` : ''}>
                Statut <i className="fas fa-sort"></i>
              </th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {sortedContracts.length === 0 ? (
              <tr>
                <td colSpan="8" className="no-data">Aucun contrat trouvé</td>
              </tr>
            ) : (
              sortedContracts.map(contract => {
                const contractStatus = getContractStatus(contract);
                return (
                  <tr key={contract.id} onClick={() => showContractDetails(contract.id)}>
                    <td>{formatDate(contract.date)}</td>
                    <td>{contract.artist?.name || 'Non défini'}</td>
                    <td>{contract.venue || 'Non défini'}</td>
                    <td>{contract.city || 'Non défini'}</td>
                    <td>{contract.programmer?.name || 'Non défini'}</td>
                    <td>
                      <div className="progress-container">
                        <div 
                          className="progress-bar" 
                          style={{ 
                            width: `${contractStatus.progress}%`,
                            backgroundColor: contractStatus.statusColor 
                          }}
                        ></div>
                        <span className="progress-text">{contractStatus.progress}%</span>
                      </div>
                      <div className="progress-status" style={{ color: contractStatus.statusColor }}>
                        <i className={contractStatus.statusIcon}></i> {contractStatus.statusText}
                      </div>
                    </td>
                    <td>
                      <span className={`status-badge status-${contract.status}`}>
                        {contract.status?.charAt(0).toUpperCase() + contract.status?.slice(1).replace('_', ' ') || 'Non défini'}
                      </span>
                    </td>
                    <td className="actions-cell">
                      <button className="action-btn edit-btn" onClick={(e) => { e.stopPropagation(); }}>
                        <i className="fas fa-edit"></i>
                      </button>
                      <button className="action-btn view-btn" onClick={(e) => { e.stopPropagation(); }}>
                        <i className="fas fa-eye"></i>
                      </button>
                      <button className="action-btn delete-btn" onClick={(e) => { e.stopPropagation(); }}>
                        <i className="fas fa-trash"></i>
                      </button>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
      
      {/* Pagination et informations sur le nombre total */}
      <div className="table-footer">
        <div className="pagination">
          <button className="pagination-btn" disabled>
            <i className="fas fa-chevron-left"></i> Précédent
          </button>
          <span className="pagination-info">Page 1 sur 1</span>
          <button className="pagination-btn" disabled>
            Suivant <i className="fas fa-chevron-right"></i>
          </button>
        </div>
        <div className="total-info">
          Affichage de {sortedContracts.length} contrat(s) sur {contracts.length} au total
        </div>
      </div>
    </div>
  );
};

export default ContractsTable;
EOL

# Création du fichier CSS pour ContractsTable s'il n'existe pas
if [ ! -f "./client/src/components/contracts/ContractsTable.css" ]; then
  echo "Création du fichier CSS pour ContractsTable..."
  cat > ./client/src/components/contracts/ContractsTable.css << 'EOL'
/* ContractsTable.css */
.contracts-table-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  padding: 20px;
  margin-bottom: 20px;
}

.contracts-header {
  display: flex;
  flex-direction: column;
  margin-bottom: 20px;
}

.contracts-header h1 {
  font-size: 24px;
  margin-bottom: 20px;
  color: #333;
}

.contracts-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-bottom: 20px;
}

.stat-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 15px;
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 200px;
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-3px);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background-color: #f0f7ff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  font-size: 20px;
  color: #3498db;
}

.stat-content h3 {
  font-size: 14px;
  color: #666;
  margin: 0 0 5px 0;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.table-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 20px;
  align-items: center;
}

.filter-group {
  flex: 1;
  min-width: 200px;
}

.filter-input, .filter-select {
  width: 100%;
  padding: 10px 15px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.filter-reset-btn {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 10px 15px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
}

.filter-reset-btn:hover {
  background-color: #e9ecef;
}

.add-contract-btn {
  background-color: #3498db;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 15px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
  margin-left: auto;
  text-decoration: none;
}

.add-contract-btn:hover {
  background-color: #2980b9;
}

.table-responsive {
  overflow-x: auto;
  margin-bottom: 20px;
}

.contracts-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}

.contracts-table th {
  background-color: #f8f9fa;
  padding: 12px 15px;
  text-align: left;
  font-weight: 600;
  color: #495057;
  border-bottom: 2px solid #dee2e6;
  cursor: pointer;
  user-select: none;
}

.contracts-table th:hover {
  background-color: #e9ecef;
}

.contracts-table th.sorted-ascending::after {
  content: " ↑";
  color: #3498db;
}

.contracts-table th.sorted-descending::after {
  content: " ↓";
  color: #3498db;
}

.contracts-table td {
  padding: 12px 15px;
  border-bottom: 1px solid #dee2e6;
  color: #333;
}

.contracts-table tbody tr {
  transition: background-color 0.2s;
  cursor: pointer;
}

.contracts-table tbody tr:hover {
  background-color: #f8f9fa;
}

.progress-container {
  width: 100%;
  height: 8px;
  background-color: #e9ecef;
  border-radius: 4px;
  position: relative;
  margin-bottom: 5px;
}

.progress-bar {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 12px;
  color: #666;
}

.progress-status {
  font-size: 12px;
  font-weight: 600;
}

.status-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
}

.status-en_cours {
  background-color: #e3f2fd;
  color: #1976d2;
}

.status-confirmé {
  background-color: #e8f5e9;
  color: #388e3c;
}

.status-en_négociation {
  background-color: #fff8e1;
  color: #f57c00;
}

.actions-cell {
  white-space: nowrap;
}

.action-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 5px;
  margin: 0 2px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.action-btn:hover {
  background-color: #e9ecef;
}

.edit-btn {
  color: #3498db;
}

.view-btn {
  color: #2ecc71;
}

.delete-btn {
  color: #e74c3c;
}

.table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #dee2e6;
}

.pagination {
  display: flex;
  align-items: center;
  gap: 10px;
}

.pagination-btn {
  background-color: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 8px 12px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 5px;
}

.pagination-btn:hover:not(:disabled) {
  background-color: #e9ecef;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-info {
  font-size: 14px;
  color: #666;
}

.total-info {
  font-size: 14px;
  color: #666;
}

.no-data {
  text-align: center;
  padding: 30px;
  color: #666;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
  font-size: 16px;
  color: #666;
}

/* Responsive design */
@media (max-width: 992px) {
  .stat-card {
    min-width: 150px;
  }
  
  .filter-group {
    min-width: 150px;
  }
}

@media (max-width: 768px) {
  .contracts-stats {
    flex-direction: column;
  }
  
  .stat-card {
    width: 100%;
  }
  
  .table-filters {
    flex-direction: column;
  }
  
  .filter-group {
    width: 100%;
  }
  
  .add-contract-btn {
    margin-left: 0;
    margin-top: 10px;
    width: 100%;
    justify-content: center;
  }
  
  .table-footer {
    flex-direction: column;
    gap: 10px;
  }
  
  .pagination {
    width: 100%;
    justify-content: space-between;
  }
}
EOL
fi

# Création du fichier de configuration pour Render
echo "Création du fichier de configuration pour Render..."
cat > ./render.yaml << 'EOL'
services:
  - type: web
    name: app-booking
    env: node
    buildCommand: npm install && npm run install-client && npm run build
    startCommand: npm start
    envVars:
      - key: NODE_ENV
        value: production
    routes:
      - type: rewrite
        source: /*
        destination: /index.html
EOL

# Création du fichier static.json pour Render
echo "Création du fichier static.json pour le client..."
cat > ./client/static.json << 'EOL'
{
  "root": "build/",
  "routes": {
    "/**": "index.html"
  }
}
EOL

# Création du fichier _redirects pour Netlify (au cas où)
echo "Création du fichier _redirects pour Netlify..."
mkdir -p ./client/public
cat > ./client/public/_redirects << 'EOL'
/*    /index.html   200
EOL

echo "Fin de la correction de la page des contrats."
echo "Pour appliquer ces modifications, exécutez ce script avec la commande:"
echo "chmod +x fix-contrats-page.sh && ./fix-contrats-page.sh"
