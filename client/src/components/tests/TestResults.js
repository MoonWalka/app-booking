import React, { useState, useEffect } from 'react';
import { getArtists } from '../../services/artistsService';
import { getProgrammers } from '../../services/programmersService';
import { getConcerts } from '../../services/concertsService';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../../firebase';
import './TestResults.css';

const TestResults = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [results, setResults] = useState({
    artists: { count: 0, exists: false },
    programmers: { count: 0, exists: false },
    concerts: { count: 0, exists: false }
  });

  useEffect(() => {
    const runTests = async () => {
      try {
        setLoading(true);
        
        // Vérifier si les collections existent dans Firebase
        const artistsSnapshot = await getDocs(collection(db, 'artists'));
        const programmersSnapshot = await getDocs(collection(db, 'programmers'));
        const concertsSnapshot = await getDocs(collection(db, 'concerts'));
        
        // Récupérer les données via les services
        const artistsData = await getArtists();
        const programmersData = await getProgrammers();
        const concertsData = await getConcerts();
        
        setResults({
          artists: { 
            count: artistsData.length, 
            exists: !artistsSnapshot.empty 
          },
          programmers: { 
            count: programmersData.length, 
            exists: !programmersSnapshot.empty 
          },
          concerts: { 
            count: concertsData.length, 
            exists: !concertsSnapshot.empty 
          }
        });
        
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    runTests();
  }, []);

  if (loading) return <div className="loading">Exécution des tests...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  return (
    <div className="test-results-container">
      <h2>Résultats des Tests d'Intégration Firebase</h2>
      
      <div className="results-grid">
        <div className="result-card">
          <h3>Collection Artistes</h3>
          <div className="result-status">
            <span className={`status-badge ${results.artists.exists ? 'status-success' : 'status-error'}`}>
              {results.artists.exists ? 'Collection créée' : 'Collection non créée'}
            </span>
          </div>
          <div className="result-count">
            <span className="count-label">Nombre d'artistes:</span>
            <span className="count-value">{results.artists.count}</span>
          </div>
          <div className="result-action">
            <button onClick={() => window.location.href = '/artistes'} className="action-btn">
              Aller à la page Artistes
            </button>
          </div>
        </div>
        
        <div className="result-card">
          <h3>Collection Programmateurs</h3>
          <div className="result-status">
            <span className={`status-badge ${results.programmers.exists ? 'status-success' : 'status-error'}`}>
              {results.programmers.exists ? 'Collection créée' : 'Collection non créée'}
            </span>
          </div>
          <div className="result-count">
            <span className="count-label">Nombre de programmateurs:</span>
            <span className="count-value">{results.programmers.count}</span>
          </div>
          <div className="result-action">
            <button onClick={() => window.location.href = '/programmateurs'} className="action-btn">
              Aller à la page Programmateurs
            </button>
          </div>
        </div>
        
        <div className="result-card">
          <h3>Collection Concerts</h3>
          <div className="result-status">
            <span className={`status-badge ${results.concerts.exists ? 'status-success' : 'status-error'}`}>
              {results.concerts.exists ? 'Collection créée' : 'Collection non créée'}
            </span>
          </div>
          <div className="result-count">
            <span className="count-label">Nombre de concerts:</span>
            <span className="count-value">{results.concerts.count}</span>
          </div>
          <div className="result-action">
            <button onClick={() => window.location.href = '/concerts'} className="action-btn">
              Aller à la page Concerts
            </button>
          </div>
        </div>
      </div>
      
      <div className="test-summary">
        <h3>Résumé des tests</h3>
        <p>
          {results.artists.exists && results.programmers.exists && results.concerts.exists
            ? 'Toutes les collections Firebase ont été créées avec succès.'
            : 'Certaines collections Firebase n\'ont pas encore été créées.'}
        </p>
        <p>
          Pour créer automatiquement les collections manquantes, utilisez les formulaires d'ajout dans les pages correspondantes.
        </p>
      </div>
      
      <div className="test-instructions">
        <h3>Instructions pour tester l'application</h3>
        <ol>
          <li>Accédez à la page Artistes et ajoutez un nouvel artiste via le formulaire</li>
          <li>Accédez à la page Programmateurs et ajoutez un nouveau programmateur via le formulaire</li>
          <li>Accédez à la page Concerts et ajoutez un nouveau concert en sélectionnant l'artiste et le programmateur créés</li>
          <li>Revenez à cette page pour vérifier que toutes les collections ont été créées</li>
        </ol>
      </div>
    </div>
  );
};

export default TestResults;
