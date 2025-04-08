import React, { useState, useEffect } from 'react';
import { db } from '../../firebase';
import { collection, getDocs } from 'firebase/firestore';
import './TestFirebaseIntegration.css';

const TestFirebaseIntegration = () => {
  const [testResults, setTestResults] = useState({
    artistsCollection: { exists: false, count: 0 },
    programmersCollection: { exists: false, count: 0 },
    concertsCollection: { exists: false, count: 0 },
    error: null,
    loading: true
  });

  useEffect(() => {
    const testFirebaseCollections = async () => {
      try {
        // Test de la collection artists
        let snapshot = await getDocs(collection(db, 'artists'));
        const artistsExists = !snapshot.empty;
        const artistsCount = snapshot.size;

        // Test de la collection programmers
        snapshot = await getDocs(collection(db, 'programmers'));
        const programmersExists = !snapshot.empty;
        const programmersCount = snapshot.size;

        // Test de la collection concerts
        snapshot = await getDocs(collection(db, 'concerts'));
        const concertsExists = !snapshot.empty;
        const concertsCount = snapshot.size;

        setTestResults({
          artistsCollection: { exists: artistsExists, count: artistsCount },
          programmersCollection: { exists: programmersExists, count: programmersCount },
          concertsCollection: { exists: concertsExists, count: concertsCount },
          error: null,
          loading: false
        });
      } catch (error) {
        console.error("Erreur lors du test des collections Firebase:", error);
        setTestResults({
          artistsCollection: { exists: false, count: 0 },
          programmersCollection: { exists: false, count: 0 },
          concertsCollection: { exists: false, count: 0 },
          error: error.message,
          loading: false
        });
      }
    };

    testFirebaseCollections();
  }, []);

  const renderStatus = (collection) => {
    if (testResults.loading) return <span className="status loading">Vérification...</span>;
    if (testResults.error) return <span className="status error">Erreur</span>;
    if (collection.exists) return <span className="status success">Existe ({collection.count} éléments)</span>;
    return <span className="status warning">N'existe pas</span>;
  };

  return (
    <div className="test-firebase-container">
      <h1>Test d'intégration Firebase</h1>
      
      {testResults.error && (
        <div className="error-message">
          <h3>Erreur de connexion à Firebase</h3>
          <p>{testResults.error}</p>
          <p>Mode de contournement d'authentification activé. Les données simulées seront utilisées.</p>
        </div>
      )}

      <div className="test-results">
        <h2>État des collections Firebase</h2>
        
        <div className="collection-status">
          <h3>Collection "artists"</h3>
          {renderStatus(testResults.artistsCollection)}
          <p>Cette collection stocke les informations sur les artistes.</p>
        </div>
        
        <div className="collection-status">
          <h3>Collection "programmers"</h3>
          {renderStatus(testResults.programmersCollection)}
          <p>Cette collection stocke les informations sur les programmateurs.</p>
        </div>
        
        <div className="collection-status">
          <h3>Collection "concerts"</h3>
          {renderStatus(testResults.concertsCollection)}
          <p>Cette collection stocke les informations sur les concerts.</p>
        </div>
      </div>

      <div className="test-info">
        <h2>Informations sur le mode de test</h2>
        <p>
          L'application est configurée pour fonctionner même en cas d'erreur d'authentification Firebase.
          Si les collections n'existent pas ou si l'authentification échoue, des données simulées seront utilisées.
        </p>
        <p>
          Pour créer les collections automatiquement, utilisez les formulaires d'ajout dans les pages correspondantes :
        </p>
        <ul>
          <li>Ajoutez un artiste depuis la page Artistes</li>
          <li>Ajoutez un programmateur depuis la page Programmateurs</li>
          <li>Ajoutez un concert depuis la page Concerts</li>
        </ul>
      </div>
    </div>
  );
};

export default TestFirebaseIntegration;
