// client/src/components/programmers/ProgrammerDetail.jsx
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';

const ProgrammerDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [programmer, setProgrammer] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchProgrammer = async () => {
      try {
        setLoading(true);
        const response = await fetch(`/api/programmers/${id}`);
        if (!response.ok) {
          throw new Error('Erreur lors de la récupération des détails du programmateur');
        }
        const data = await response.json();
        setProgrammer(data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchProgrammer();
  }, [id]);

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce programmateur ?')) {
      try {
        const response = await fetch(`/api/programmers/${id}`, {
          method: 'DELETE',
        });
        if (!response.ok) {
          throw new Error('Erreur lors de la suppression du programmateur');
        }
        navigate('/programmateurs');
      } catch (err) {
        setError(err.message);
      }
    }
  };

  if (loading) return <div>Chargement des détails du programmateur...</div>;
  if (error) return <div>Erreur: {error}</div>;
  if (!programmer) return <div>Programmateur non trouvé</div>;

  return (
    <div className="programmer-detail-container">
      <h2>{programmer.name}</h2>
      <div className="programmer-info">
        <p><strong>Salle/Festival:</strong> {programmer.venue}</p>
        <p><strong>Ville:</strong> {programmer.city}</p>
        <p><strong>Email:</strong> {programmer.email}</p>
        <p><strong>Téléphone:</strong> {programmer.phone}</p>
        {programmer.website && (
          <p>
            <strong>Site web:</strong>{' '}
            <a href={programmer.website} target="_blank" rel="noopener noreferrer">
              {programmer.website}
            </a>
          </p>
        )}
        <p><strong>Notes:</strong> {programmer.notes || 'Aucune note'}</p>
      </div>

      <div className="programmer-actions">
        <button
          onClick={() => navigate(`/programmateurs/modifier/${id}`)}
          className="edit-btn"
        >
          Modifier
        </button>
        <button onClick={handleDelete} className="delete-btn">
          Supprimer
        </button>
        <button onClick={() => navigate('/programmateurs')} className="back-btn">
          Retour à la liste
        </button>
      </div>
    </div>
  );
};

export default ProgrammerDetail;
