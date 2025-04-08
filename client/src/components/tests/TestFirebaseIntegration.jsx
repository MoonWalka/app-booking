import React, { useState, useEffect } from 'react';
import testFirebaseIntegration from '../../utils/testFirebaseIntegration';

const TestFirebaseIntegration = () => {
  const [testResults, setTestResults] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const runTests = async () => {
    try {
      setLoading(true);
      setError(null);
      const results = await testFirebaseIntegration();
      setTestResults(results);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  return (
    <div className="test-container">
      <h1>Test d'intégration Firebase</h1>
      <p>
        Cette page permet de tester la création automatique des collections Firebase
        et de vérifier que l'intégration fonctionne correctement.
      </p>
      
      <button 
        onClick={runTests} 
        disabled={loading}
        className="test-btn"
      >
        {loading ? 'Test en cours...' : 'Lancer le test'}
      </button>
      
      {error && (
        <div className="error-message">
          <h3>Erreur :</h3>
          <p>{error}</p>
        </div>
      )}
      
      {testResults && (
        <div className="results-container">
          <h2>Résultats des tests</h2>
          <div className={`status-badge ${testResults.success ? 'success' : 'failure'}`}>
            {testResults.success ? 'Succès' : 'Échec'}
          </div>
          
          <p>{testResults.message}</p>
          
          {testResults.success && testResults.createdIds && (
            <div className="created-ids">
              <h3>IDs créés :</h3>
              <ul>
                <li><strong>Artiste :</strong> {testResults.createdIds.artist}</li>
                <li><strong>Programmateur :</strong> {testResults.createdIds.programmer}</li>
                <li><strong>Concert :</strong> {testResults.createdIds.concert}</li>
              </ul>
            </div>
          )}
          
          {!testResults.success && testResults.error && (
            <div className="error-details">
              <h3>Détails de l'erreur :</h3>
              <p>{testResults.error}</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default TestFirebaseIntegration;
