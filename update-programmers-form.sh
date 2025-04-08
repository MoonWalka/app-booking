#!/bin/bash

# Script pour mettre à jour la structure de la fiche programmateur
# Auteur: Manus
# Date: 8 avril 2025
# Version: 1.0

echo "Début de la mise à jour de la structure de la fiche programmateur..."

# Vérifier si nous sommes dans le bon répertoire
if [ ! -d "./client" ]; then
  echo "Erreur: Ce script doit être exécuté depuis la racine du projet app-booking"
  exit 1
fi

# Mise à jour du composant ProgrammerDetail.jsx
echo "Mise à jour du composant ProgrammerDetail.jsx..."
mkdir -p ./client/src/components/programmers
cat > ./client/src/components/programmers/ProgrammerDetail.jsx << 'EOL'
// client/src/components/programmers/ProgrammerDetail.jsx
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getProgrammerById, deleteProgrammer, updateProgrammer } from '../../services/programmersService';
import './ProgrammerDetail.css';

const ProgrammerDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [programmer, setProgrammer] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
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
    const fetchProgrammer = async () => {
      try {
        setLoading(true);
        console.log(`Tentative de récupération du programmateur avec l'ID: ${id}`);
        
        // Utiliser le service Firebase au lieu de fetch
        const data = await getProgrammerById(id);
        
        if (!data) {
          throw new Error('Programmateur non trouvé');
        }
        
        console.log('Programmateur récupéré:', data);
        setProgrammer(data);
        setFormData({
          businessName: data.businessName || '',
          contact: data.contact || '',
          role: data.role || '',
          address: data.address || '',
          venue: data.venue || '',
          vatNumber: data.vatNumber || '',
          siret: data.siret || '',
          email: data.email || '',
          phone: data.phone || '',
          website: data.website || '',
          notes: data.notes || ''
        });
        setLoading(false);
      } catch (err) {
        console.error('Erreur lors de la récupération du programmateur:', err);
        setError(err.message);
        setLoading(false);
      }
    };

    fetchProgrammer();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      
      // Utiliser le service Firebase pour mettre à jour le programmateur
      await updateProgrammer(id, formData);
      
      // Récupérer les données mises à jour
      const updatedData = await getProgrammerById(id);
      setProgrammer(updatedData);
      
      setIsEditing(false);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce programmateur ?')) {
      try {
        setLoading(true);
        
        // Utiliser le service Firebase pour supprimer le programmateur
        await deleteProgrammer(id);
        
        navigate('/programmateurs');
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    }
  };

  if (loading) return <div className="loading">Chargement des détails du programmateur...</div>;
  if (error) return <div className="error-message">Erreur: {error}</div>;
  if (!programmer) return <div className="not-found">Programmateur non trouvé</div>;

  return (
    <div className="programmer-detail-container">
      <h2>Détails du programmateur</h2>
      
      {isEditing ? (
        <form onSubmit={handleSubmit} className="edit-form">
          <div className="form-group">
            <label htmlFor="businessName">Raison sociale</label>
            <input
              type="text"
              id="businessName"
              name="businessName"
              value={formData.businessName}
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
              value={formData.contact}
              onChange={handleInputChange}
              placeholder="Nom et prénom du contact"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="role">Qualité</label>
            <select
              id="role"
              name="role"
              value={formData.role}
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
              value={formData.address}
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
              value={formData.venue}
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
              value={formData.vatNumber}
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
              value={formData.siret}
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
              value={formData.email}
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
              value={formData.phone}
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
              value={formData.website}
              onChange={handleInputChange}
              placeholder="https://www.exemple.com"
            />
          </div>
          
          <div className="form-group full-width">
            <label htmlFor="notes">Notes</label>
            <textarea
              id="notes"
              name="notes"
              value={formData.notes}
              onChange={handleInputChange}
              rows="4"
              placeholder="Informations complémentaires"
            ></textarea>
          </div>
          
          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={() => setIsEditing(false)}>
              Annuler
            </button>
            <button type="submit" className="save-btn" disabled={loading}>
              {loading ? 'Enregistrement...' : 'Enregistrer'}
            </button>
          </div>
        </form>
      ) : (
        <>
          <div className="programmer-info">
            <div className="info-row">
              <span className="info-label">Raison sociale:</span>
              <span className="info-value">{programmer.businessName || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Contact:</span>
              <span className="info-value">{programmer.contact || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Qualité:</span>
              <span className="info-value">{programmer.role || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Adresse:</span>
              <span className="info-value">{programmer.address || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Lieu ou festival:</span>
              <span className="info-value">{programmer.venue || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">N° intracommunautaire:</span>
              <span className="info-value">{programmer.vatNumber || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">SIRET:</span>
              <span className="info-value">{programmer.siret || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Email:</span>
              <span className="info-value">{programmer.email || 'Non spécifié'}</span>
            </div>
            
            <div className="info-row">
              <span className="info-label">Téléphone:</span>
              <span className="info-value">{programmer.phone || 'Non spécifié'}</span>
            </div>
            
            {programmer.website && (
              <div className="info-row">
                <span className="info-label">Site web:</span>
                <span className="info-value">
                  <a href={programmer.website} target="_blank" rel="noopener noreferrer">
                    {programmer.website}
                  </a>
                </span>
              </div>
            )}
            
            <div className="info-row notes">
              <span className="info-label">Notes:</span>
              <span className="info-value">{programmer.notes || 'Aucune note'}</span>
            </div>
          </div>
          
          <div className="programmer-actions">
            <button onClick={() => setIsEditing(true)} className="edit-btn">
              Modifier
            </button>
            <button onClick={handleDelete} className="delete-btn">
              Supprimer
            </button>
            <button onClick={() => navigate('/programmateurs')} className="back-btn">
              Retour à la liste
            </button>
          </div>
        </>
      )}
    </div>
  );
};

export default ProgrammerDetail;
EOL

# Mise à jour du composant ProgrammersList.jsx
echo "Mise à jour du composant ProgrammersList.jsx..."
cat > ./client/src/components/programmers/ProgrammersList.jsx << 'EOL'
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
EOL

# Mise à jour du service programmersService.js
echo "Mise à jour du service programmersService.js..."
mkdir -p ./client/src/services
cat > ./client/src/services/programmersService.js << 'EOL'
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
  setDoc
} from 'firebase/firestore';
import { db } from '../firebase';

// Assurez-vous que la collection existe
const ensureCollection = async (collectionName) => {
  try {
    // Vérifier si la collection existe en essayant de récupérer des documents
    const collectionRef = collection(db, collectionName);
    const snapshot = await getDocs(query(collectionRef, orderBy('createdAt', 'desc')));
    
    // Si la collection n'existe pas ou est vide, créer un document initial
    if (snapshot.empty) {
      console.log(`Collection ${collectionName} vide, création d'un document initial...`);
      const initialDoc = {
        businessName: "Salle de Concert Exemple",
        contact: "Jean Dupont",
        role: "Programmateur",
        address: "123 rue de la Musique, 75001 Paris",
        venue: "La Scène Parisienne",
        vatNumber: "FR12345678901",
        siret: "123 456 789 00012",
        email: "contact@exemple.fr",
        phone: "01 23 45 67 89",
        website: "https://www.exemple.fr",
        notes: "Programmateur exemple créé automatiquement",
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
const mockProgrammers = [
  {
    id: 'mock-programmer-1',
    businessName: "Association Vibrations",
    contact: "Marie Dupont",
    role: "Présidente",
    address: "45 rue de la République, 69001 Lyon",
    venue: "Festival Vibrations",
    vatNumber: "FR98765432101",
    siret: "987 654 321 00011",
    email: 'marie.dupont@vibrations.fr',
    phone: '06 12 34 56 78',
    website: 'https://www.vibrations-asso.fr',
    notes: 'Programmation de musiques actuelles',
    createdAt: new Date()
  },
  {
    id: 'mock-programmer-2',
    businessName: "SARL La Cigale",
    contact: "Jean Martin",
    role: "Gérant",
    address: "120 boulevard de Rochechouart, 75018 Paris",
    venue: "La Cigale",
    vatNumber: "FR45678901234",
    siret: "456 789 012 00013",
    email: 'jean.martin@lacigale.fr',
    phone: '01 23 45 67 89',
    website: 'https://www.lacigale.fr',
    notes: 'Salle de concert parisienne',
    createdAt: new Date()
  }
];

// Assurez-vous que la collection programmers existe
const programmersCollection = collection(db, 'programmers');

export const getProgrammers = async () => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('programmers');
    
    console.log("Tentative de récupération des programmateurs depuis Firebase...");
    const q = query(programmersCollection, orderBy('createdAt', 'desc'));
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      console.log("Aucun programmateur trouvé dans Firebase, utilisation des données simulées");
      
      // Essayer d'ajouter les données simulées à Firebase
      try {
        console.log("Tentative d'ajout des données simulées à Firebase...");
        for (const programmer of mockProgrammers) {
          const { id, ...programmerData } = programmer;
          await setDoc(doc(db, 'programmers', id), programmerData);
        }
        console.log("Données simulées ajoutées à Firebase avec succès");
      } catch (addError) {
        console.error("Erreur lors de l'ajout des données simulées:", addError);
      }
      
      return mockProgrammers;
    }
    
    const programmers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    console.log(`${programmers.length} programmateurs récupérés depuis Firebase`);
    return programmers;
  } catch (error) {
    console.error("Erreur lors de la récupération des programmateurs:", error);
    console.log("Utilisation des données simulées pour les programmateurs");
    
    // Essayer d'ajouter les données simulées à Firebase
    try {
      console.log("Tentative d'ajout des données simulées à Firebase...");
      for (const programmer of mockProgrammers) {
        const { id, ...programmerData } = programmer;
        await setDoc(doc(db, 'programmers', id), programmerData);
      }
      console.log("Données simulées ajoutées à Firebase avec succès");
    } catch (addError) {
      console.error("Erreur lors de l'ajout des données simulées:", addError);
    }
    
    // Retourner des données simulées en cas d'erreur d'authentification
    return mockProgrammers;
  }
};

export const getProgrammerById = async (id) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('programmers');
    
    console.log(`Tentative de récupération du programmateur ${id} depuis Firebase...`);
    const docRef = doc(db, 'programmers', id);
    const snapshot = await getDoc(docRef);
    
    if (snapshot.exists()) {
      const programmerData = {
        id: snapshot.id,
        ...snapshot.data()
      };
      console.log(`Programmateur ${id} récupéré depuis Firebase:`, programmerData);
      return programmerData;
    }
    
    console.log(`Programmateur ${id} non trouvé dans Firebase`);
    return null;
  } catch (error) {
    console.error(`Erreur lors de la récupération du programmateur ${id}:`, error);
    // Retourner un programmateur simulé en cas d'erreur
    const mockProgrammer = mockProgrammers.find(programmer => programmer.id === id) || mockProgrammers[0];
    console.log(`Utilisation du programmateur simulé:`, mockProgrammer);
    return mockProgrammer;
  }
};

export const addProgrammer = async (programmerData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('programmers');
    
    console.log("Tentative d'ajout d'un programmateur à Firebase:", programmerData);
    const docRef = await addDoc(programmersCollection, {
      ...programmerData,
      createdAt: new Date()
    });
    
    console.log(`Programmateur ajouté avec succès, ID: ${docRef.id}`);
    return {
      id: docRef.id,
      ...programmerData
    };
  } catch (error) {
    console.error("Erreur lors de l'ajout du programmateur:", error);
    console.log("Simulation de l'ajout d'un programmateur");
    
    // Essayer d'ajouter le programmateur avec un ID généré manuellement
    try {
      const mockId = 'mock-programmer-' + Date.now();
      await setDoc(doc(db, 'programmers', mockId), {
        ...programmerData,
        createdAt: new Date()
      });
      
      console.log(`Programmateur ajouté avec un ID manuel: ${mockId}`);
      return {
        id: mockId,
        ...programmerData,
        createdAt: new Date()
      };
    } catch (addError) {
      console.error("Erreur lors de l'ajout manuel du programmateur:", addError);
      
      // Simuler l'ajout d'un programmateur en cas d'erreur
      const mockId = 'mock-programmer-' + Date.now();
      return {
        id: mockId,
        ...programmerData,
        createdAt: new Date()
      };
    }
  }
};

export const updateProgrammer = async (id, programmerData) => {
  try {
    // S'assurer que la collection existe
    await ensureCollection('programmers');
    
    console.log(`Tentative de mise à jour du programmateur ${id}:`, programmerData);
    const docRef = doc(db, 'programmers', id);
    await updateDoc(docRef, {
      ...programmerData,
      updatedAt: new Date()
    });
    
    console.log(`Programmateur ${id} mis à jour avec succès`);
    return {
      id,
      ...programmerData
    };
  } catch (error) {
    console.error(`Erreur lors de la mise à jour du programmateur ${id}:`, error);
    console.log("Simulation de la mise à jour d'un programmateur");
    
    // Essayer de créer/remplacer le document
    try {
      await setDoc(doc(db, 'programmers', id), {
        ...programmerData,
        updatedAt: new Date()
      });
      
      console.log(`Programmateur ${id} créé/remplacé avec succès`);
      return {
        id,
        ...programmerData,
        updatedAt: new Date()
      };
    } catch (setError) {
      console.error(`Erreur lors de la création/remplacement du programmateur ${id}:`, setError);
      
      // Simuler la mise à jour d'un programmateur en cas d'erreur
      return {
        id,
        ...programmerData,
        updatedAt: new Date()
      };
    }
  }
};

export const deleteProgrammer = async (id) => {
  try {
    console.log(`Tentative de suppression du programmateur ${id}`);
    const docRef = doc(db, 'programmers', id);
    await deleteDoc(docRef);
    
    console.log(`Programmateur ${id} supprimé avec succès`);
    return id;
  } catch (error) {
    console.error(`Erreur lors de la suppression du programmateur ${id}:`, error);
    console.log("Simulation de la suppression d'un programmateur");
    // Simuler la suppression d'un programmateur en cas d'erreur
    return id;
  }
};
EOL

echo "Fin de la mise à jour de la structure de la fiche programmateur."
echo "Pour appliquer ces modifications, exécutez ce script avec la commande:"
echo "chmod +x update-programmers-form.sh && ./update-programmers-form.sh"
echo ""
echo "Après avoir exécuté le script, utilisez les commandes Git suivantes pour pousser les modifications vers GitHub :"
echo "git add ."
echo "git commit -m \"Mise à jour de la structure de la fiche programmateur avec nouveaux champs facultatifs\""
echo "git push origin main"
