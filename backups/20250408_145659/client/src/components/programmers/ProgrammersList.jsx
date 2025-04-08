import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const ProgrammersList = ()  => {
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchProgrammers = async () => {
      try {
        setLoading(true);
        const response = await fetch('/api/programmers');
        if (!response.ok) {
          throw new Error('Erreur lors de la récupération des programmateurs');
        }
        const data = await response.json();
        setProgrammers(data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchProgrammers();
  }, []);

  if (loading) return <div>Chargement des programmateurs...</div>;
  if (error) return <div>Erreur: {error}</div>;

  return (
    <div className="programmers-list-container">
      <h2>Liste des Programmateurs</h2>
      {programmers.length === 0 ? (
        <p>Aucun programmateur trouvé.</p>
      ) : (
        <div className="programmers-table-container">
          <table className="programmers-table">
            <thead>
              <tr>
                <th>Nom</th>
                <th>Salle/Festival</th>
                <th>Ville</th>
                <th>Email</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {programmers.map((programmer) => (
                <tr key={programmer._id}>
                  <td>{programmer.name}</td>
                  <td>{programmer.venue}</td>
                  <td>{programmer.city}</td>
                  <td>{programmer.email}</td>
                  <td>
                    <Link to={`/programmateurs/${programmer._id}`} className="view-btn">
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
