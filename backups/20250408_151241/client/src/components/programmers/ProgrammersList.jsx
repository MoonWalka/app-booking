import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getProgrammers } from '../../services/programmersService';

const ProgrammersList = () => {
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchProgrammers = async () => {
      try {
        setLoading(true);
        console.log("Tentative de récupération des programmateurs...");
        const data = await getProgrammers();
        console.log("Programmateurs récupérés:", data);
        setProgrammers(data);
        setLoading(false);
      } catch (err) {
        console.error("Erreur dans le composant lors de la récupération des programmateurs:", err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchProgrammers();
  }, []);

  if (loading) return <div className="loading">Chargement des programmateurs...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  return (
    <div className="programmers-list-container">
      <h2>Liste des Programmateurs</h2>
      {programmers.length === 0 ? (
        <p className="no-results">Aucun programmateur trouvé.</p>
      ) : (
        <div className="programmers-table-container">
          <table className="programmers-table">
            <thead>
              <tr>
                <th>Nom</th>
                <th>Structure</th>
                <th>Ville</th>
                <th>Email</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {programmers.map((programmer) => (
                <tr key={programmer.id}>
                  <td>{programmer.name || 'Non spécifié'}</td>
                  <td>{programmer.structure || 'Non spécifié'}</td>
                  <td>{programmer.city || 'Non spécifié'}</td>
                  <td>{programmer.email || 'Non spécifié'}</td>
                  <td>
                    <Link to={`/programmateurs/${programmer.id}`} className="view-details-btn">
                      Voir
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <div className="add-programmer-container">
        <Link to="/programmateurs/nouveau" className="add-programmer-btn">
          Ajouter un programmateur
        </Link>
      </div>
    </div>
  );
};

export default ProgrammersList;
