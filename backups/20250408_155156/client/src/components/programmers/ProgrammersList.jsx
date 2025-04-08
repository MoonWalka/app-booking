import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getProgrammers, addProgrammer } from '../../services/programmersService';
import './ProgrammersList.css';

const ProgrammersList = () => {
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  
  // État pour le formulaire d'ajout de programmateur
  const [newProgrammer, setNewProgrammer] = useState({
    name: '',
    structure: '',
    email: '',
    phone: '',
    city: '',
    region: '',
    website: '',
    notes: ''
  });
  
  // Régions françaises pour le formulaire
  const regions = [
    'Auvergne-Rhône-Alpes',
    'Bourgogne-Franche-Comté',
    'Bretagne',
    'Centre-Val de Loire',
    'Corse',
    'Grand Est',
    'Hauts-de-France',
    'Île-de-France',
    'Normandie',
    'Nouvelle-Aquitaine',
    'Occitanie',
    'Pays de la Loire',
    'Provence-Alpes-Côte d\'Azur',
    'Guadeloupe',
    'Martinique',
    'Guyane',
    'La Réunion',
    'Mayotte',
    'Autre'
  ];

  useEffect(() => {
    const fetchProgrammers = async () => {
      try {
        setLoading(true);
        console.log("Tentative de récupération des programmateurs via Firebase...");
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

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewProgrammer({
      ...newProgrammer,
      [name]: value
    });
    
    // Log pour le débogage
    console.log(`Champ ${name} mis à jour avec la valeur: ${value}`);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      console.log("Données du programmateur à ajouter:", newProgrammer);
      
      await addProgrammer(newProgrammer);
      
      // Réinitialiser le formulaire
      setNewProgrammer({
        name: '',
        structure: '',
        email: '',
        phone: '',
        city: '',
        region: '',
        website: '',
        notes: ''
      });
      
      // Masquer le formulaire
      setShowForm(false);
      
      // Rafraîchir la liste des programmateurs
      const updatedProgrammers = await getProgrammers();
      setProgrammers(updatedProgrammers);
      
      setLoading(false);
    } catch (err) {
      console.error("Erreur lors de l'ajout du programmateur:", err);
      setError(err.message);
      setLoading(false);
    }
  };

  if (loading && programmers.length === 0) return <div className="loading">Chargement des programmateurs...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;

  return (
    <div className="programmers-list-container">
      <div className="programmers-header">
        <h2>Liste des Programmateurs</h2>
        <button 
          className="add-programmer-btn"
          onClick={() => setShowForm(!showForm)}
        >
          {showForm ? 'Annuler' : 'Ajouter un programmateur'}
        </button>
      </div>
      
      {showForm && (
        <div className="add-programmer-form-container">
          <h3>Ajouter un nouveau programmateur</h3>
          <form onSubmit={handleSubmit} className="add-programmer-form">
            <div className="form-group">
              <label htmlFor="name">Nom du programmateur *</label>
              <input
                type="text"
                id="name"
                name="name"
                value={newProgrammer.name}
                onChange={handleInputChange}
                required
                placeholder="Nom du programmateur"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="structure">Structure *</label>
              <input
                type="text"
                id="structure"
                name="structure"
                value={newProgrammer.structure}
                onChange={handleInputChange}
                required
                placeholder="Nom de la salle, festival, association..."
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="email">Email *</label>
              <input
                type="email"
                id="email"
                name="email"
                value={newProgrammer.email}
                onChange={handleInputChange}
                required
                placeholder="email@exemple.com"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="phone">Téléphone</label>
              <input
                type="tel"
                id="phone"
                name="phone"
                value={newProgrammer.phone}
                onChange={handleInputChange}
                placeholder="06 12 34 56 78"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="city">Ville *</label>
              <input
                type="text"
                id="city"
                name="city"
                value={newProgrammer.city}
                onChange={handleInputChange}
                required
                placeholder="Ville"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="region">Région</label>
              <select
                id="region"
                name="region"
                value={newProgrammer.region}
                onChange={handleInputChange}
              >
                <option value="">Sélectionner une région</option>
                {regions.map(region => (
                  <option key={region} value={region}>{region}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group">
              <label htmlFor="website">Site web</label>
              <input
                type="url"
                id="website"
                name="website"
                value={newProgrammer.website}
                onChange={handleInputChange}
                placeholder="https://www.exemple.com"
              />
            </div>
            
            <div className="form-group full-width">
              <label htmlFor="notes">Notes</label>
              <textarea
                id="notes"
                name="notes"
                value={newProgrammer.notes}
                onChange={handleInputChange}
                rows="4"
                placeholder="Informations complémentaires"
              ></textarea>
            </div>
            
            <div className="form-actions">
              <button type="button" className="cancel-btn" onClick={() => setShowForm(false)}>
                Annuler
              </button>
              <button type="submit" className="submit-btn" disabled={loading}>
                {loading ? 'Ajout en cours...' : 'Ajouter le programmateur'}
              </button>
            </div>
          </form>
        </div>
      )}
      
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
    </div>
  );
};

export default ProgrammersList;
