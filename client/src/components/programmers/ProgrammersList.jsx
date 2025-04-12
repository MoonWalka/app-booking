import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import from './services/programmersService';


const ProgrammersList = () => {
  const [programmers, setProgrammers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  
  // État pour le formulaire d'ajout de programmateur
  const [newProgrammer, setNewProgrammer] = useState({
    businessName: '',
    contact: '',
    role: '',
    address: '',
    venue: '',
    vatNumber: '',
    siret: '',
    email: '',
    phone: '',
    website: '',
    notes: ''
  });
  
  // Options pour le champ "qualité"
  const roleOptions = [
    'Programmateur',
    'Président',
    'Gérant',
    'Directeur',
    'Administrateur',
    'Chargé de production',
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
        businessName: '',
        contact: '',
        role: '',
        address: '',
        venue: '',
        vatNumber: '',
        siret: '',
        email: '',
        phone: '',
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
              <label htmlFor="businessName">Raison sociale</label>
              <input
                type="text"
                id="businessName"
                name="businessName"
                value={newProgrammer.businessName}
                onChange={handleInputChange}
                placeholder="Nom de l'entreprise ou de l'organisation"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="contact">Contact</label>
              <input
                type="text"
                id="contact"
                name="contact"
                value={newProgrammer.contact}
                onChange={handleInputChange}
                placeholder="Nom et prénom du contact"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="role">Qualité</label>
              <select
                id="role"
                name="role"
                value={newProgrammer.role}
                onChange={handleInputChange}
              >
                <option value="">Sélectionner une qualité</option>
                {roleOptions.map(role => (
                  <option key={role} value={role}>{role}</option>
                ))}
              </select>
            </div>
            
            <div className="form-group">
              <label htmlFor="address">Adresse de la raison sociale</label>
              <textarea
                id="address"
                name="address"
                value={newProgrammer.address}
                onChange={handleInputChange}
                rows="3"
                placeholder="Adresse complète"
              ></textarea>
            </div>
            
            <div className="form-group">
              <label htmlFor="venue">Lieu ou festival</label>
              <input
                type="text"
                id="venue"
                name="venue"
                value={newProgrammer.venue}
                onChange={handleInputChange}
                placeholder="Nom du lieu ou du festival"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="vatNumber">Numéro intracommunautaire</label>
              <input
                type="text"
                id="vatNumber"
                name="vatNumber"
                value={newProgrammer.vatNumber}
                onChange={handleInputChange}
                placeholder="FR12345678901"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="siret">SIRET</label>
              <input
                type="text"
                id="siret"
                name="siret"
                value={newProgrammer.siret}
                onChange={handleInputChange}
                placeholder="123 456 789 00012"
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="email">Email</label>
              <input
                type="email"
                id="email"
                name="email"
                value={newProgrammer.email}
                onChange={handleInputChange}
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
                <th>Raison sociale</th>
                <th>Contact</th>
                <th>Lieu/Festival</th>
                <th>Email</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {programmers.map((programmer) => (
                <tr key={programmer.id}>
                  <td>{programmer.businessName || 'Non spécifié'}</td>
                  <td>{programmer.contact || 'Non spécifié'}</td>
                  <td>{programmer.venue || 'Non spécifié'}</td>
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
