#!/bin/bash

# Script de correction complète pour l'application de booking musical
# Ce script résout tous les problèmes identifiés :
# 1. Composant Sidebar manquant
# 2. Erreurs dans la page Concerts (tableau de bord)
# 3. Problèmes avec la page Validation Formulaire
# 4. Autres erreurs d'importation

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Début des corrections complètes pour l'application de booking musical...${NC}"

# Vérification que nous sommes dans le bon répertoire
if [ ! -d "client" ]; then
  echo -e "${RED}❌ Erreur: Ce script doit être exécuté à la racine du projet.${NC}"
  echo "Assurez-vous que vous êtes dans le répertoire principal contenant le dossier client."
  exit 1
fi

# Création du répertoire de sauvegarde
BACKUP_DIR="backups/complete-fixes-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${YELLOW}Création du répertoire de sauvegarde: $BACKUP_DIR${NC}"

# Fonction pour sauvegarder un fichier avant modification
backup_file() {
  local file=$1
  local dir=$(dirname "$file")
  
  # Créer le répertoire de destination dans les backups s'il n'existe pas
  mkdir -p "$BACKUP_DIR/$dir"
  
  # Copier le fichier s'il existe
  if [ -f "$file" ]; then
    cp "$file" "$BACKUP_DIR/$file"
    echo -e "${YELLOW}Sauvegarde de $file${NC}"
  fi
}

# 1. Création du composant Sidebar manquant
echo -e "${GREEN}1. Création du composant Sidebar manquant...${NC}"

mkdir -p client/src/components/layout
backup_file "client/src/components/layout/Sidebar.jsx"
backup_file "client/src/components/layout/Sidebar.css"

cat > client/src/components/layout/Sidebar.jsx << 'EOL'
import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { FaChartLine, FaFileContract, FaFileInvoiceDollar, FaMusic, FaUserTie, FaUsers, FaClipboardCheck, FaEnvelope, FaFile, FaCog } from 'react-icons/fa';
import './Sidebar.css';

const Sidebar = () => {
  const location = useLocation();
  const path = location.pathname;

  const isActive = (route) => {
    return path === route || (path.startsWith(route) && route !== '/');
  };

  return (
    <div className="sidebar">
      <div className="logo-container">
        <Link to="/" className="logo">
          <div className="logo-badge">+</div>
          <div>Label Musical</div>
        </Link>
        <div className="logo-subtitle">Gestion des concerts et artistes</div>
      </div>
      
      <nav className="sidebar-nav">
        <Link to="/" className={isActive('/') ? 'active' : ''}>
          <FaChartLine className="nav-icon" />
          <span>Tableau de bord</span>
        </Link>
        
        <Link to="/contrats" className={isActive('/contrats') ? 'active' : ''}>
          <FaFileContract className="nav-icon" />
          <span>Contrats</span>
        </Link>
        
        <Link to="/factures" className={isActive('/factures') ? 'active' : ''}>
          <FaFileInvoiceDollar className="nav-icon" />
          <span>Factures</span>
        </Link>
        
        <Link to="/concerts" className={isActive('/concerts') ? 'active' : ''}>
          <FaMusic className="nav-icon" />
          <span>Concerts</span>
        </Link>
        
        <Link to="/artistes" className={isActive('/artistes') ? 'active' : ''}>
          <FaUserTie className="nav-icon" />
          <span>Artistes</span>
        </Link>
        
        <Link to="/programmateurs" className={isActive('/programmateurs') ? 'active' : ''}>
          <FaUsers className="nav-icon" />
          <span>Programmateurs</span>
        </Link>
        
        <Link to="/validation-formulaire" className={isActive('/validation-formulaire') ? 'active' : ''}>
          <FaClipboardCheck className="nav-icon" />
          <span>Validation Formulaire</span>
        </Link>
        
        <Link to="/emails" className={isActive('/emails') ? 'active' : ''}>
          <FaEnvelope className="nav-icon" />
          <span>Emails</span>
        </Link>
        
        <Link to="/documents" className={isActive('/documents') ? 'active' : ''}>
          <FaFile className="nav-icon" />
          <span>Documents</span>
        </Link>
        
        <Link to="/parametres" className={isActive('/parametres') ? 'active' : ''}>
          <FaCog className="nav-icon" />
          <span>Paramètres</span>
        </Link>
      </nav>
    </div>
  );
};

export default Sidebar;
EOL

cat > client/src/components/layout/Sidebar.css << 'EOL'
.sidebar {
  width: 220px;
  background-color: #2c3e50;
  color: #ecf0f1;
  height: 100vh;
  padding: 0;
  display: flex;
  flex-direction: column;
  position: fixed;
  left: 0;
  top: 0;
}

.logo-container {
  padding: 20px 15px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.logo {
  display: flex;
  align-items: center;
  text-decoration: none;
  color: #3498db;
  font-size: 1.5rem;
  font-weight: bold;
  margin-bottom: 5px;
}

.logo-badge {
  background-color: #3498db;
  color: white;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  margin-right: 10px;
}

.logo-subtitle {
  font-size: 0.75rem;
  color: #95a5a6;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  padding: 15px 0;
  overflow-y: auto;
}

.sidebar-nav a {
  display: flex;
  align-items: center;
  padding: 12px 15px;
  color: #ecf0f1;
  text-decoration: none;
  transition: all 0.3s ease;
  border-left: 3px solid transparent;
}

.sidebar-nav a:hover {
  background-color: rgba(255, 255, 255, 0.05);
  border-left: 3px solid #3498db;
}

.sidebar-nav a.active {
  background-color: rgba(52, 152, 219, 0.2);
  border-left: 3px solid #3498db;
  color: #3498db;
}

.nav-icon {
  margin-right: 10px;
  font-size: 1.1rem;
}
EOL

echo -e "${GREEN}✅ Composant Sidebar créé avec succès${NC}"

# 2. Correction du composant ConcertsDashboard
echo -e "${GREEN}2. Correction du composant ConcertsDashboard...${NC}"

mkdir -p client/src/components/concerts
backup_file "client/src/components/concerts/ConcertsDashboard.jsx"
backup_file "client/src/components/concerts/ConcertsDashboard.css"

cat > client/src/components/concerts/ConcertsDashboard.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { FaCalendarAlt, FaUsers, FaMoneyBillWave, FaChartLine } from 'react-icons/fa';
import './ConcertsDashboard.css';

const ConcertsDashboard = ({ concerts }) => {
  const [stats, setStats] = useState({
    totalConcerts: 0,
    upcomingConcerts: 0,
    totalRevenue: 0,
    averageAttendance: 0
  });

  useEffect(() => {
    if (concerts && concerts.length > 0) {
      // Calculer les statistiques
      const now = new Date();
      const upcoming = concerts.filter(concert => {
        const concertDate = new Date(concert.date);
        return concertDate > now;
      });
      
      const revenue = concerts.reduce((total, concert) => {
        return total + (parseFloat(concert.amount) || 0);
      }, 0);
      
      const attendance = concerts.reduce((total, concert) => {
        return total + (parseInt(concert.attendance) || 0);
      }, 0);
      
      setStats({
        totalConcerts: concerts.length,
        upcomingConcerts: upcoming.length,
        totalRevenue: revenue,
        averageAttendance: concerts.length > 0 ? Math.round(attendance / concerts.length) : 0
      });
    }
  }, [concerts]);

  // Fonction pour formater les montants en euros
  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(amount);
  };

  return (
    <div className="concerts-dashboard">
      <h2 className="dashboard-title">Tableau de bord des concerts</h2>
      
      <div className="stats-container">
        <div className="stat-card">
          <div className="stat-icon">
            <FaCalendarAlt />
          </div>
          <div className="stat-content">
            <h3>Concerts totaux</h3>
            <p className="stat-value">{stats.totalConcerts}</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaCalendarAlt />
          </div>
          <div className="stat-content">
            <h3>Concerts à venir</h3>
            <p className="stat-value">{stats.upcomingConcerts}</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaMoneyBillWave />
          </div>
          <div className="stat-content">
            <h3>Revenus totaux</h3>
            <p className="stat-value">{formatCurrency(stats.totalRevenue)}</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon">
            <FaUsers />
          </div>
          <div className="stat-content">
            <h3>Audience moyenne</h3>
            <p className="stat-value">{stats.averageAttendance}</p>
          </div>
        </div>
      </div>
      
      <div className="recent-concerts">
        <h3>Concerts récents</h3>
        <div className="concerts-table-container">
          <table className="concerts-table">
            <thead>
              <tr>
                <th>Artiste</th>
                <th>Lieu</th>
                <th>Date</th>
                <th>Montant</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              {concerts && concerts.length > 0 ? (
                concerts.slice(0, 5).map((concert, index) => (
                  <tr key={index}>
                    <td>{concert.artist || 'Artiste inconnu'}</td>
                    <td>{concert.venue || 'Lieu non spécifié'}</td>
                    <td>{concert.date || 'Date non spécifiée'}</td>
                    <td>{formatCurrency(parseFloat(concert.amount) || 0)}</td>
                    <td>
                      <span className={`status-badge ${concert.status || 'pending'}`}>
                        {concert.status || 'En attente'}
                      </span>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="5" className="no-data">Aucun concert trouvé</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default ConcertsDashboard;
EOL

cat > client/src/components/concerts/ConcertsDashboard.css << 'EOL'
.concerts-dashboard {
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.dashboard-title {
  margin-bottom: 20px;
  color: #2c3e50;
  font-size: 1.8rem;
}

.stats-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  background-color: #3498db;
  color: white;
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  margin-right: 15px;
}

.stat-content {
  flex: 1;
}

.stat-content h3 {
  margin: 0;
  font-size: 0.9rem;
  color: #7f8c8d;
  font-weight: 500;
}

.stat-value {
  margin: 5px 0 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: #2c3e50;
}

.recent-concerts {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.recent-concerts h3 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #2c3e50;
  font-size: 1.2rem;
}

.concerts-table-container {
  overflow-x: auto;
}

.concerts-table {
  width: 100%;
  border-collapse: collapse;
}

.concerts-table th,
.concerts-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #ecf0f1;
}

.concerts-table th {
  background-color: #f8f9fa;
  color: #7f8c8d;
  font-weight: 500;
  font-size: 0.9rem;
}

.concerts-table tbody tr:hover {
  background-color: #f8f9fa;
}

.status-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.status-badge.confirmed {
  background-color: #2ecc71;
  color: white;
}

.status-badge.pending {
  background-color: #f39c12;
  color: white;
}

.status-badge.cancelled {
  background-color: #e74c3c;
  color: white;
}

.no-data {
  text-align: center;
  color: #95a5a6;
  padding: 20px 0;
}

@media (max-width: 768px) {
  .stats-container {
    grid-template-columns: 1fr;
  }
}
EOL

# 3. Correction du composant ConcertsList
echo -e "${GREEN}3. Correction du composant ConcertsList...${NC}"

backup_file "client/src/components/concerts/ConcertsList.js"

cat > client/src/components/concerts/ConcertsList.js << 'EOL'
import React, { useState, useEffect, Suspense } from 'react';
import { Link } from 'react-router-dom';
import { getAllConcerts } from '../../services/concertsService';
import './ConcertsList.css';

// Importation dynamique du tableau de bord
const ConcertsDashboard = React.lazy(() => import('./ConcertsDashboard'));

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showDashboard, setShowDashboard] = useState(false);

  useEffect(() => {
    const fetchConcerts = async () => {
      try {
        const concertsData = await getAllConcerts();
        setConcerts(concertsData || []);
        setLoading(false);
      } catch (error) {
        console.error("Erreur lors du chargement des concerts:", error);
        setLoading(false);
      }
    };

    fetchConcerts();
  }, []);

  const toggleView = () => {
    setShowDashboard(!showDashboard);
  };

  if (loading) {
    return <div className="loading">Chargement des concerts...</div>;
  }

  return (
    <div className="concerts-container">
      <h1>Gestion des concerts</h1>
      
      <div className="concerts-actions">
        <button 
          className={`view-toggle-btn ${showDashboard ? 'active' : ''}`} 
          onClick={toggleView}
        >
          {showDashboard ? 'Vue liste' : 'Vue tableau de bord'}
        </button>
        
        <Link to="/concerts/add" className="add-concert-btn">
          Ajouter un concert
        </Link>
      </div>
      
      {showDashboard ? (
        <Suspense fallback={<div className="loading">Chargement du tableau de bord...</div>}>
          <ConcertsDashboard concerts={concerts} />
        </Suspense>
      ) : (
        <div className="concerts-list">
          <h2>Liste des concerts ({concerts.length})</h2>
          
          <table className="concerts-table">
            <thead>
              <tr>
                <th>Artiste</th>
                <th>Date</th>
                <th>Lieu</th>
                <th>Ville</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {concerts.length > 0 ? (
                concerts.map((concert) => (
                  <tr key={concert.id}>
                    <td>{concert.artist || 'Artiste inconnu'}</td>
                    <td>{concert.date || ''}</td>
                    <td>{concert.venue || 'th'}</td>
                    <td>{concert.city || 'th'}</td>
                    <td>{concert.status || 'En attente'}</td>
                    <td>
                      <Link to={`/concerts/${concert.id}`} className="view-btn">
                        Voir
                      </Link>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" className="no-data">Aucun concert trouvé</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default ConcertsList;
EOL

# 4. Ajout du CSS pour ConcertsList
echo -e "${GREEN}4. Ajout du CSS pour ConcertsList...${NC}"

backup_file "client/src/components/concerts/ConcertsList.css"

cat > client/src/components/concerts/ConcertsList.css << 'EOL'
.concerts-container {
  padding: 20px;
}

.concerts-container h1 {
  margin-bottom: 20px;
  color: #2c3e50;
}

.concerts-actions {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}

.view-toggle-btn, .add-concert-btn {
  padding: 10px 15px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.view-toggle-btn {
  background-color: #3498db;
  color: white;
  border: none;
}

.view-toggle-btn:hover {
  background-color: #2980b9;
}

.view-toggle-btn.active {
  background-color: #2980b9;
}

.add-concert-btn {
  background-color: #2ecc71;
  color: white;
  text-decoration: none;
  display: inline-block;
}

.add-concert-btn:hover {
  background-color: #27ae60;
}

.concerts-list {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.concerts-list h2 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #2c3e50;
  font-size: 1.2rem;
}

.concerts-table {
  width: 100%;
  border-collapse: collapse;
}

.concerts-table th,
.concerts-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #ecf0f1;
}

.concerts-table th {
  background-color: #f8f9fa;
  color: #7f8c8d;
  font-weight: 500;
  font-size: 0.9rem;
}

.concerts-table tbody tr:hover {
  background-color: #f8f9fa;
}

.view-btn {
  display: inline-block;
  padding: 5px 10px;
  background-color: #3498db;
  color: white;
  border-radius: 4px;
  text-decoration: none;
  font-size: 0.9rem;
  transition: background-color 0.3s ease;
}

.view-btn:hover {
  background-color: #2980b9;
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
  font-size: 1.2rem;
  color: #7f8c8d;
}

.no-data {
  text-align: center;
  color: #95a5a6;
  padding: 20px 0;
}

@media (max-width: 768px) {
  .concerts-actions {
    flex-direction: column;
    gap: 10px;
  }
  
  .view-toggle-btn, .add-concert-btn {
    width: 100%;
    text-align: center;
  }
}
EOL

# 5. Correction du service formSubmissionsService.js
echo -e "${GREEN}5. Correction du service formSubmissionsService.js...${NC}"

backup_file "client/src/services/formSubmissionsService.js"

cat > client/src/services/formSubmissionsService.js << 'EOL'
import { db } from '../firebase';
import { collection, getDocs, doc, getDoc, addDoc, updateDoc, query, where } from 'firebase/firestore';

// Récupérer toutes les soumissions de formulaire
export const getAllFormSubmissions = async () => {
  try {
    const submissionsCollection = collection(db, 'formSubmissions');
    const submissionsSnapshot = await getDocs(submissionsCollection);
    const submissionsList = submissionsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    // Mettre à jour les soumissions sans statut
    for (const submission of submissionsList) {
      if (!submission.status) {
        await updateFormSubmissionStatus(submission.id, 'pending');
        submission.status = 'pending';
      }
    }
    
    return submissionsList;
  } catch (error) {
    console.error("Erreur lors de la récupération des soumissions:", error);
    return [];
  }
};

// Récupérer les soumissions en attente
export const getPendingFormSubmissions = async () => {
  try {
    const submissionsCollection = collection(db, 'formSubmissions');
    const q = query(submissionsCollection, where("status", "==", "pending"));
    const submissionsSnapshot = await getDocs(q);
    return submissionsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des soumissions en attente:", error);
    return [];
  }
};

// Récupérer une soumission par ID
export const getFormSubmissionById = async (id) => {
  try {
    const submissionDoc = doc(db, 'formSubmissions', id);
    const submissionSnapshot = await getDoc(submissionDoc);
    
    if (submissionSnapshot.exists()) {
      return {
        id: submissionSnapshot.id,
        ...submissionSnapshot.data()
      };
    } else {
      console.log("Aucune soumission trouvée avec cet ID");
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la récupération de la soumission:", error);
    return null;
  }
};

// Créer une nouvelle soumission de formulaire
export const createFormSubmission = async (formData) => {
  try {
    // S'assurer que le statut est défini
    const dataWithStatus = {
      ...formData,
      status: formData.status || 'pending',
      createdAt: new Date()
    };
    
    const submissionsCollection = collection(db, 'formSubmissions');
    const docRef = await addDoc(submissionsCollection, dataWithStatus);
    
    return {
      id: docRef.id,
      ...dataWithStatus
    };
  } catch (error) {
    console.error("Erreur lors de la création de la soumission:", error);
    throw error;
  }
};

// Mettre à jour le statut d'une soumission
export const updateFormSubmissionStatus = async (id, status) => {
  try {
    const submissionDoc = doc(db, 'formSubmissions', id);
    await updateDoc(submissionDoc, { status });
    return true;
  } catch (error) {
    console.error("Erreur lors de la mise à jour du statut:", error);
    return false;
  }
};

// Mettre à jour une soumission avec les données validées
export const updateFormSubmissionWithValidatedData = async (id, validatedData) => {
  try {
    const submissionDoc = doc(db, 'formSubmissions', id);
    await updateDoc(submissionDoc, { 
      ...validatedData,
      status: 'validated',
      validatedAt: new Date()
    });
    return true;
  } catch (error) {
    console.error("Erreur lors de la mise à jour des données validées:", error);
    return false;
  }
};

// Mettre à jour les entités liées via le token commun
export const updateLinkedEntities = async (commonToken, validatedData) => {
  try {
    // Rechercher toutes les soumissions avec ce token commun
    const submissionsCollection = collection(db, 'formSubmissions');
    const q = query(submissionsCollection, where("commonToken", "==", commonToken));
    const submissionsSnapshot = await getDocs(q);
    
    // Mettre à jour chaque soumission
    const updatePromises = submissionsSnapshot.docs.map(async (submission) => {
      const submissionDoc = doc(db, 'formSubmissions', submission.id);
      await updateDoc(submissionDoc, { 
        ...validatedData,
        status: 'validated',
        validatedAt: new Date()
      });
    });
    
    await Promise.all(updatePromises);
    return true;
  } catch (error) {
    console.error("Erreur lors de la mise à jour des entités liées:", error);
    return false;
  }
};
EOL

# 6. Correction du composant FormValidationList
echo -e "${GREEN}6. Correction du composant FormValidationList...${NC}"

mkdir -p client/src/components/formValidation
backup_file "client/src/components/formValidation/FormValidationList.jsx"

cat > client/src/components/formValidation/FormValidationList.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { getAllFormSubmissions, getPendingFormSubmissions, updateFormSubmissionStatus } from '../../services/formSubmissionsService';
import ComparisonTable from './ComparisonTable';
import './FormValidationList.css';

const FormValidationList = () => {
  const [submissions, setSubmissions] = useState([]);
  const [pendingSubmissions, setPendingSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedSubmission, setSelectedSubmission] = useState(null);
  const [showComparisonModal, setShowComparisonModal] = useState(false);
  const [debugInfo, setDebugInfo] = useState('');

  useEffect(() => {
    const fetchSubmissions = async () => {
      try {
        setLoading(true);
        
        // Récupérer toutes les soumissions
        const allSubmissions = await getAllFormSubmissions();
        setSubmissions(allSubmissions || []);
        
        // Récupérer les soumissions en attente
        const pendingSubmissionsData = await getPendingFormSubmissions();
        setPendingSubmissions(pendingSubmissionsData || []);
        
        // Générer des informations de débogage
        const pendingCount = pendingSubmissionsData ? pendingSubmissionsData.length : 0;
        const statusCounts = {};
        const withCommonToken = allSubmissions.filter(s => s.commonToken).length;
        const withoutCommonToken = allSubmissions.filter(s => !s.commonToken).length;
        
        allSubmissions.forEach(submission => {
          const status = submission.status || 'unknown';
          statusCounts[status] = (statusCounts[status] || 0) + 1;
        });
        
        const statusDistribution = Object.entries(statusCounts)
          .map(([status, count]) => `${status}: ${count}`)
          .join('\n');
        
        const debugText = `
Total des soumissions: ${allSubmissions.length}
Soumissions en attente: ${pendingCount}
Distribution des statuts:
${statusDistribution}
Avec token commun: ${withCommonToken}
Sans token commun: ${withoutCommonToken}
${pendingCount === 0 ? 'Aucune soumission en attente de validation.' : ''}
        `;
        
        setDebugInfo(debugText);
        setLoading(false);
      } catch (error) {
        console.error("Erreur lors du chargement des soumissions:", error);
        setLoading(false);
      }
    };

    fetchSubmissions();
  }, []);

  const handleValidateClick = (submission) => {
    setSelectedSubmission(submission);
    setShowComparisonModal(true);
  };

  const handleRejectSubmission = async (submissionId) => {
    try {
      const success = await updateFormSubmissionStatus(submissionId, 'rejected');
      if (success) {
        // Mettre à jour la liste des soumissions
        setPendingSubmissions(prevSubmissions => 
          prevSubmissions.filter(sub => sub.id !== submissionId)
        );
        
        // Mettre à jour la liste complète
        setSubmissions(prevSubmissions => 
          prevSubmissions.map(sub => 
            sub.id === submissionId ? { ...sub, status: 'rejected' } : sub
          )
        );
      }
    } catch (error) {
      console.error("Erreur lors du rejet de la soumission:", error);
    }
  };

  const closeComparisonModal = () => {
    setShowComparisonModal(false);
    setSelectedSubmission(null);
  };

  const handleValidationComplete = () => {
    // Rafraîchir les données après validation
    closeComparisonModal();
    
    // Mettre à jour la liste des soumissions en attente
    setPendingSubmissions(prevSubmissions => 
      prevSubmissions.filter(sub => sub.id !== selectedSubmission.id)
    );
    
    // Mettre à jour la liste complète
    setSubmissions(prevSubmissions => 
      prevSubmissions.map(sub => 
        sub.id === selectedSubmission.id ? { ...sub, status: 'validated' } : sub
      )
    );
  };

  if (loading) {
    return <div className="loading">Chargement des soumissions...</div>;
  }

  return (
    <div className="form-validation-container">
      <h1>Validation des formulaires</h1>
      
      <div className="debug-info">
        <h3>Informations de débogage</h3>
        <pre>{debugInfo}</pre>
      </div>
      
      <div className="pending-submissions">
        <h2>Soumissions en attente de validation</h2>
        
        {pendingSubmissions.length > 0 ? (
          <table className="submissions-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Nom</th>
                <th>Prénom</th>
                <th>Structure</th>
                <th>Email</th>
                <th>Téléphone</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {pendingSubmissions.map((submission) => (
                <tr key={submission.id}>
                  <td>{submission.createdAt ? new Date(submission.createdAt.seconds * 1000).toLocaleDateString() : 'N/A'}</td>
                  <td>{submission.lastName || 'N/A'}</td>
                  <td>{submission.firstName || 'N/A'}</td>
                  <td>{submission.organization || 'N/A'}</td>
                  <td>{submission.email || 'N/A'}</td>
                  <td>{submission.phone || 'N/A'}</td>
                  <td className="action-buttons">
                    <button 
                      className="validate-btn"
                      onClick={() => handleValidateClick(submission)}
                    >
                      Valider
                    </button>
                    <button 
                      className="reject-btn"
                      onClick={() => handleRejectSubmission(submission.id)}
                    >
                      Rejeter
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <p className="no-submissions">Aucune soumission en attente de validation.</p>
        )}
      </div>
      
      {showComparisonModal && selectedSubmission && (
        <div className="modal-overlay">
          <div className="comparison-modal">
            <button className="close-modal" onClick={closeComparisonModal}>×</button>
            <h2>Validation des données</h2>
            <ComparisonTable 
              submission={selectedSubmission} 
              onValidationComplete={handleValidationComplete}
            />
          </div>
        </div>
      )}
    </div>
  );
};

export default FormValidationList;
EOL

# 7. Ajout du CSS pour FormValidationList
echo -e "${GREEN}7. Ajout du CSS pour FormValidationList...${NC}"

backup_file "client/src/components/formValidation/FormValidationList.css"

cat > client/src/components/formValidation/FormValidationList.css << 'EOL'
.form-validation-container {
  padding: 20px;
}

.form-validation-container h1 {
  margin-bottom: 20px;
  color: #2c3e50;
}

.debug-info {
  background-color: #f8f9fa;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 20px;
  border: 1px solid #e9ecef;
}

.debug-info h3 {
  margin-top: 0;
  margin-bottom: 10px;
  font-size: 1rem;
  color: #6c757d;
}

.debug-info pre {
  margin: 0;
  white-space: pre-wrap;
  font-family: monospace;
  font-size: 0.9rem;
  color: #495057;
}

.pending-submissions {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.pending-submissions h2 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #2c3e50;
  font-size: 1.2rem;
}

.submissions-table {
  width: 100%;
  border-collapse: collapse;
}

.submissions-table th,
.submissions-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #ecf0f1;
}

.submissions-table th {
  background-color: #f8f9fa;
  color: #7f8c8d;
  font-weight: 500;
  font-size: 0.9rem;
}

.submissions-table tbody tr:hover {
  background-color: #f8f9fa;
}

.action-buttons {
  display: flex;
  gap: 10px;
}

.validate-btn,
.reject-btn {
  padding: 6px 12px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
}

.validate-btn {
  background-color: #2ecc71;
  color: white;
}

.validate-btn:hover {
  background-color: #27ae60;
}

.reject-btn {
  background-color: #e74c3c;
  color: white;
}

.reject-btn:hover {
  background-color: #c0392b;
}

.no-submissions {
  text-align: center;
  color: #95a5a6;
  padding: 20px 0;
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
  font-size: 1.2rem;
  color: #7f8c8d;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.comparison-modal {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  width: 90%;
  max-width: 1000px;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
}

.close-modal {
  position: absolute;
  top: 10px;
  right: 10px;
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #7f8c8d;
}

.close-modal:hover {
  color: #2c3e50;
}

@media (max-width: 768px) {
  .action-buttons {
    flex-direction: column;
  }
  
  .submissions-table {
    font-size: 0.9rem;
  }
  
  .submissions-table th,
  .submissions-table td {
    padding: 8px 10px;
  }
}
EOL

# 8. Création du composant ComparisonTable
echo -e "${GREEN}8. Création du composant ComparisonTable...${NC}"

backup_file "client/src/components/formValidation/ComparisonTable.jsx"
backup_file "client/src/components/formValidation/ComparisonTable.css"

cat > client/src/components/formValidation/ComparisonTable.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { updateFormSubmissionWithValidatedData, updateLinkedEntities } from '../../services/formSubmissionsService';
import { getProgrammerByEmail, updateProgrammer } from '../../services/programmersService';
import './ComparisonTable.css';

const ComparisonTable = ({ submission, onValidationComplete }) => {
  const [programmerData, setProgrammerData] = useState(null);
  const [finalData, setFinalData] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProgrammerData = async () => {
      try {
        setLoading(true);
        
        // Rechercher le programmateur par email
        if (submission.email) {
          const programmer = await getProgrammerByEmail(submission.email);
          if (programmer) {
            setProgrammerData(programmer);
            
            // Initialiser les données finales avec les valeurs existantes du programmateur
            const initialFinalData = {};
            Object.keys(submission).forEach(key => {
              if (key !== 'id' && key !== 'status' && key !== 'createdAt' && key !== 'commonToken') {
                initialFinalData[key] = programmer[key] || '';
              }
            });
            setFinalData(initialFinalData);
          } else {
            // Si aucun programmateur n'est trouvé, utiliser les données de la soumission
            const initialFinalData = {};
            Object.keys(submission).forEach(key => {
              if (key !== 'id' && key !== 'status' && key !== 'createdAt' && key !== 'commonToken') {
                initialFinalData[key] = submission[key] || '';
              }
            });
            setFinalData(initialFinalData);
          }
        } else {
          // Si pas d'email, utiliser les données de la soumission
          const initialFinalData = {};
          Object.keys(submission).forEach(key => {
            if (key !== 'id' && key !== 'status' && key !== 'createdAt' && key !== 'commonToken') {
              initialFinalData[key] = submission[key] || '';
            }
          });
          setFinalData(initialFinalData);
        }
        
        setLoading(false);
      } catch (error) {
        console.error("Erreur lors de la récupération des données du programmateur:", error);
        setLoading(false);
      }
    };

    fetchProgrammerData();
  }, [submission]);

  const handleCopyFromSubmission = (field) => {
    setFinalData(prevData => ({
      ...prevData,
      [field]: submission[field] || ''
    }));
  };

  const handleCopyFromProgrammer = (field) => {
    if (programmerData && programmerData[field]) {
      setFinalData(prevData => ({
        ...prevData,
        [field]: programmerData[field]
      }));
    }
  };

  const handleInputChange = (field, value) => {
    setFinalData(prevData => ({
      ...prevData,
      [field]: value
    }));
  };

  const handleValidateData = async () => {
    try {
      // Mettre à jour la soumission avec les données validées
      await updateFormSubmissionWithValidatedData(submission.id, finalData);
      
      // Si un token commun existe, mettre à jour toutes les entités liées
      if (submission.commonToken) {
        await updateLinkedEntities(submission.commonToken, finalData);
      }
      
      // Si un programmateur existe, le mettre à jour
      if (programmerData) {
        await updateProgrammer(programmerData.id, finalData);
      }
      
      // Notifier le composant parent que la validation est terminée
      if (onValidationComplete) {
        onValidationComplete();
      }
    } catch (error) {
      console.error("Erreur lors de la validation des données:", error);
    }
  };

  if (loading) {
    return <div className="loading">Chargement des données...</div>;
  }

  // Définir les champs à afficher et leur libellé
  const fields = [
    { key: 'firstName', label: 'Prénom' },
    { key: 'lastName', label: 'Nom' },
    { key: 'organization', label: 'Structure' },
    { key: 'position', label: 'Fonction' },
    { key: 'email', label: 'Email' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'address', label: 'Adresse' },
    { key: 'postalCode', label: 'Code postal' },
    { key: 'city', label: 'Ville' },
    { key: 'country', label: 'Pays' },
    { key: 'website', label: 'Site web' },
    { key: 'vatNumber', label: 'Numéro TVA' },
    { key: 'siret', label: 'SIRET' },
    { key: 'notes', label: 'Notes' }
  ];

  return (
    <div className="comparison-table-container">
      <table className="comparison-table">
        <thead>
          <tr>
            <th>Champ</th>
            <th>Valeur du formulaire</th>
            <th></th>
            <th>Valeur existante</th>
            <th></th>
            <th>Valeur finale</th>
          </tr>
        </thead>
        <tbody>
          {fields.map((field) => (
            <tr key={field.key}>
              <td className="field-label">{field.label}</td>
              <td className="submission-value">{submission[field.key] || ''}</td>
              <td className="action-cell">
                {submission[field.key] && (
                  <button 
                    className="copy-btn"
                    onClick={() => handleCopyFromSubmission(field.key)}
                    title="Utiliser cette valeur"
                  >
                    →
                  </button>
                )}
              </td>
              <td className="programmer-value">
                {programmerData ? (programmerData[field.key] || '') : ''}
              </td>
              <td className="action-cell">
                {programmerData && programmerData[field.key] && (
                  <button 
                    className="copy-btn"
                    onClick={() => handleCopyFromProgrammer(field.key)}
                    title="Utiliser cette valeur"
                  >
                    →
                  </button>
                )}
              </td>
              <td className="final-value">
                <input 
                  type="text" 
                  value={finalData[field.key] || ''} 
                  onChange={(e) => handleInputChange(field.key, e.target.value)}
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      
      <div className="validation-actions">
        <button 
          className="validate-final-btn"
          onClick={handleValidateData}
        >
          Valider les données
        </button>
      </div>
    </div>
  );
};

export default ComparisonTable;
EOL

cat > client/src/components/formValidation/ComparisonTable.css << 'EOL'
.comparison-table-container {
  margin-top: 20px;
}

.comparison-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}

.comparison-table th,
.comparison-table td {
  padding: 10px;
  text-align: left;
  border-bottom: 1px solid #ecf0f1;
}

.comparison-table th {
  background-color: #f8f9fa;
  color: #7f8c8d;
  font-weight: 500;
  font-size: 0.9rem;
}

.field-label {
  font-weight: 500;
  color: #2c3e50;
}

.submission-value {
  background-color: #e8f4fd;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
}

.programmer-value {
  background-color: #f0fff4;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
}

.action-cell {
  width: 50px;
  text-align: center;
}

.copy-btn {
  background-color: #3498db;
  color: white;
  border: none;
  border-radius: 4px;
  width: 30px;
  height: 30px;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.3s ease;
}

.copy-btn:hover {
  background-color: #2980b9;
}

.final-value input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.9rem;
}

.final-value input:focus {
  border-color: #3498db;
  outline: none;
  box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
}

.validation-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.validate-final-btn {
  background-color: #2ecc71;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 20px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.validate-final-btn:hover {
  background-color: #27ae60;
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 200px;
  font-size: 1.2rem;
  color: #7f8c8d;
}

@media (max-width: 768px) {
  .comparison-table {
    font-size: 0.9rem;
  }
  
  .comparison-table th,
  .comparison-table td {
    padding: 8px;
  }
  
  .copy-btn {
    width: 25px;
    height: 25px;
    font-size: 0.8rem;
  }
}
EOL

# 9. Correction du composant PublicFormPage
echo -e "${GREEN}9. Correction du composant PublicFormPage...${NC}"

mkdir -p client/src/components/public
backup_file "client/src/components/public/PublicFormPage.jsx"
backup_file "client/src/components/public/PublicFormPage.css"

cat > client/src/components/public/PublicFormPage.jsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { createFormSubmission } from '../../services/formSubmissionsService';
import './PublicFormPage.css';

const PublicFormPage = () => {
  const location = useLocation();
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    organization: '',
    position: '',
    email: '',
    phone: '',
    address: '',
    postalCode: '',
    city: '',
    country: 'France',
    website: '',
    vatNumber: '',
    siret: '',
    notes: ''
  });
  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');
  const [commonToken, setCommonToken] = useState('');

  useEffect(() => {
    // Extraire le token commun de l'URL
    const params = new URLSearchParams(location.search);
    const token = params.get('token');
    if (token) {
      setCommonToken(token);
    }
  }, [location]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prevData => ({
      ...prevData,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      setError('');
      
      // Ajouter le token commun aux données du formulaire
      const submissionData = {
        ...formData,
        commonToken: commonToken || null,
        status: 'pending',
        createdAt: new Date()
      };
      
      // Envoyer les données à Firebase
      await createFormSubmission(submissionData);
      
      // Réinitialiser le formulaire et afficher un message de succès
      setFormData({
        firstName: '',
        lastName: '',
        organization: '',
        position: '',
        email: '',
        phone: '',
        address: '',
        postalCode: '',
        city: '',
        country: 'France',
        website: '',
        vatNumber: '',
        siret: '',
        notes: ''
      });
      
      setSubmitted(true);
      setLoading(false);
    } catch (error) {
      console.error("Erreur lors de la soumission du formulaire:", error);
      setError("Une erreur s'est produite lors de la soumission du formulaire. Veuillez réessayer.");
      setLoading(false);
    }
  };

  return (
    <div className="public-form-container">
      <div className="form-header">
        <h1>Formulaire de renseignements</h1>
        <p>Merci de compléter ce formulaire pour nous permettre de préparer votre contrat.</p>
      </div>
      
      {submitted ? (
        <div className="success-message">
          <h2>Formulaire envoyé avec succès !</h2>
          <p>Nous avons bien reçu vos informations et nous les traiterons dans les plus brefs délais.</p>
          <button 
            className="new-form-btn"
            onClick={() => setSubmitted(false)}
          >
            Remplir un nouveau formulaire
          </button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="public-form">
          {error && <div className="error-message">{error}</div>}
          
          <div className="form-section">
            <h2>Informations personnelles</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="firstName">Prénom *</label>
                <input
                  type="text"
                  id="firstName"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="lastName">Nom *</label>
                <input
                  type="text"
                  id="lastName"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="organization">Structure / Organisation *</label>
                <input
                  type="text"
                  id="organization"
                  name="organization"
                  value={formData.organization}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="position">Fonction</label>
                <input
                  type="text"
                  id="position"
                  name="position"
                  value={formData.position}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>
          
          <div className="form-section">
            <h2>Coordonnées</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="email">Email *</label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="phone">Téléphone *</label>
                <input
                  type="tel"
                  id="phone"
                  name="phone"
                  value={formData.phone}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            
            <div className="form-group full-width">
              <label htmlFor="address">Adresse</label>
              <input
                type="text"
                id="address"
                name="address"
                value={formData.address}
                onChange={handleChange}
              />
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="postalCode">Code postal</label>
                <input
                  type="text"
                  id="postalCode"
                  name="postalCode"
                  value={formData.postalCode}
                  onChange={handleChange}
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="city">Ville</label>
                <input
                  type="text"
                  id="city"
                  name="city"
                  value={formData.city}
                  onChange={handleChange}
                />
              </div>
            </div>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="country">Pays</label>
                <input
                  type="text"
                  id="country"
                  name="country"
                  value={formData.country}
                  onChange={handleChange}
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="website">Site web</label>
                <input
                  type="url"
                  id="website"
                  name="website"
                  value={formData.website}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>
          
          <div className="form-section">
            <h2>Informations administratives</h2>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="vatNumber">Numéro de TVA intracommunautaire</label>
                <input
                  type="text"
                  id="vatNumber"
                  name="vatNumber"
                  value={formData.vatNumber}
                  onChange={handleChange}
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="siret">Numéro SIRET</label>
                <input
                  type="text"
                  id="siret"
                  name="siret"
                  value={formData.siret}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>
          
          <div className="form-section">
            <h2>Informations complémentaires</h2>
            
            <div className="form-group full-width">
              <label htmlFor="notes">Notes ou commentaires</label>
              <textarea
                id="notes"
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows="4"
              ></textarea>
            </div>
          </div>
          
          <div className="form-actions">
            <button 
              type="submit" 
              className="submit-btn"
              disabled={loading}
            >
              {loading ? 'Envoi en cours...' : 'Envoyer le formulaire'}
            </button>
          </div>
        </form>
      )}
    </div>
  );
};

export default PublicFormPage;
EOL

cat > client/src/components/public/PublicFormPage.css << 'EOL'
.public-form-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 30px 20px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.form-header {
  text-align: center;
  margin-bottom: 30px;
}

.form-header h1 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.form-header p {
  color: #7f8c8d;
}

.public-form {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.form-section {
  border-bottom: 1px solid #ecf0f1;
  padding-bottom: 20px;
}

.form-section h2 {
  color: #3498db;
  font-size: 1.2rem;
  margin-bottom: 15px;
}

.form-row {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
}

.form-group {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.form-group.full-width {
  width: 100%;
}

.form-group label {
  margin-bottom: 5px;
  font-weight: 500;
  color: #2c3e50;
  font-size: 0.9rem;
}

.form-group input,
.form-group textarea {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-group input:focus,
.form-group textarea:focus {
  border-color: #3498db;
  outline: none;
  box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
}

.form-actions {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.submit-btn {
  background-color: #3498db;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 12px 30px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.submit-btn:hover {
  background-color: #2980b9;
}

.submit-btn:disabled {
  background-color: #95a5a6;
  cursor: not-allowed;
}

.error-message {
  background-color: #fdeded;
  color: #e74c3c;
  padding: 10px 15px;
  border-radius: 4px;
  margin-bottom: 20px;
  border-left: 4px solid #e74c3c;
}

.success-message {
  background-color: #edfff2;
  padding: 30px;
  border-radius: 8px;
  text-align: center;
  border: 1px solid #d4f5e2;
}

.success-message h2 {
  color: #27ae60;
  margin-bottom: 15px;
}

.success-message p {
  color: #2c3e50;
  margin-bottom: 20px;
}

.new-form-btn {
  background-color: #3498db;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 10px 20px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.new-form-btn:hover {
  background-color: #2980b9;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 15px;
  }
  
  .public-form-container {
    padding: 20px 15px;
  }
}
EOL

# 10. Création des composants manquants pour éviter les erreurs de build
echo -e "${GREEN}10. Création des composants manquants pour éviter les erreurs de build...${NC}"

# Création des répertoires nécessaires
mkdir -p client/src/components/settings
mkdir -p client/src/components/documents
mkdir -p client/src/components/emails
mkdir -p client/src/components/contracts
mkdir -p client/src/components/invoices

# Création du composant Settings
backup_file "client/src/components/settings/Settings.jsx"
cat > client/src/components/settings/Settings.jsx << 'EOL'
import React from 'react';
import './Settings.css';

const Settings = () => {
  return (
    <div className="settings-container">
      <h1>Paramètres</h1>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default Settings;
EOL

backup_file "client/src/components/settings/Settings.css"
cat > client/src/components/settings/Settings.css << 'EOL'
.settings-container {
  padding: 20px;
}

.settings-container h1 {
  margin-bottom: 20px;
  color: #2c3e50;
}
EOL

# Création du composant DocumentsList
backup_file "client/src/components/documents/DocumentsList.jsx"
cat > client/src/components/documents/DocumentsList.jsx << 'EOL'
import React from 'react';
import './DocumentsList.css';

const DocumentsList = () => {
  return (
    <div className="documents-container">
      <h1>Documents</h1>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default DocumentsList;
EOL

backup_file "client/src/components/documents/DocumentsList.css"
cat > client/src/components/documents/DocumentsList.css << 'EOL'
.documents-container {
  padding: 20px;
}

.documents-container h1 {
  margin-bottom: 20px;
  color: #2c3e50;
}
EOL

# Création du composant EmailsList
backup_file "client/src/components/emails/EmailsList.jsx"
cat > client/src/components/emails/EmailsList.jsx << 'EOL'
import React from 'react';
import './EmailsList.css';

const EmailsList = () => {
  return (
    <div className="emails-container">
      <h1>Emails</h1>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default EmailsList;
EOL

backup_file "client/src/components/emails/EmailsList.css"
cat > client/src/components/emails/EmailsList.css << 'EOL'
.emails-container {
  padding: 20px;
}

.emails-container h1 {
  margin-bottom: 20px;
  color: #2c3e50;
}
EOL

# Création du composant ContractsList
backup_file "client/src/components/contracts/ContractsList.jsx"
cat > client/src/components/contracts/ContractsList.jsx << 'EOL'
import React from 'react';
import './ContractsList.css';

const ContractsList = () => {
  return (
    <div className="contracts-container">
      <h1>Contrats</h1>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default ContractsList;
EOL

backup_file "client/src/components/contracts/ContractsList.css"
cat > client/src/components/contracts/ContractsList.css << 'EOL'
.contracts-container {
  padding: 20px;
}

.contracts-container h1 {
  margin-bottom: 20px;
  color: #2c3e50;
}
EOL

# Création du composant ContractDetails
backup_file "client/src/components/contracts/ContractDetails.jsx"
cat > client/src/components/contracts/ContractDetails.jsx << 'EOL'
import React from 'react';
import { useParams } from 'react-router-dom';

const ContractDetails = () => {
  const { id } = useParams();
  
  return (
    <div className="contract-details-container">
      <h1>Détails du contrat</h1>
      <p>ID du contrat: {id}</p>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default ContractDetails;
EOL

# Création du composant InvoicesList
backup_file "client/src/components/invoices/InvoicesList.jsx"
cat > client/src/components/invoices/InvoicesList.jsx << 'EOL'
import React from 'react';
import './InvoicesList.css';

const InvoicesList = () => {
  return (
    <div className="invoices-container">
      <h1>Factures</h1>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default InvoicesList;
EOL

backup_file "client/src/components/invoices/InvoicesList.css"
cat > client/src/components/invoices/InvoicesList.css << 'EOL'
.invoices-container {
  padding: 20px;
}

.invoices-container h1 {
  margin-bottom: 20px;
  color: #2c3e50;
}
EOL

# Création du composant InvoiceDetails
backup_file "client/src/components/invoices/InvoiceDetails.jsx"
cat > client/src/components/invoices/InvoiceDetails.jsx << 'EOL'
import React from 'react';
import { useParams } from 'react-router-dom';

const InvoiceDetails = () => {
  const { id } = useParams();
  
  return (
    <div className="invoice-details-container">
      <h1>Détails de la facture</h1>
      <p>ID de la facture: {id}</p>
      <p>Cette page est en cours de développement.</p>
    </div>
  );
};

export default InvoiceDetails;
EOL

# 11. Création des services manquants
echo -e "${GREEN}11. Création des services manquants...${NC}"

# Création du service contractsService.js
backup_file "client/src/services/contractsService.js"
cat > client/src/services/contractsService.js << 'EOL'
import { db } from '../firebase';
import { collection, getDocs, doc, getDoc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';

// Récupérer tous les contrats
export const getAllContracts = async () => {
  try {
    const contractsCollection = collection(db, 'contracts');
    const contractsSnapshot = await getDocs(contractsCollection);
    return contractsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des contrats:", error);
    return [];
  }
};

// Récupérer un contrat par ID
export const getContractById = async (id) => {
  try {
    const contractDoc = doc(db, 'contracts', id);
    const contractSnapshot = await getDoc(contractDoc);
    
    if (contractSnapshot.exists()) {
      return {
        id: contractSnapshot.id,
        ...contractSnapshot.data()
      };
    } else {
      console.log("Aucun contrat trouvé avec cet ID");
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la récupération du contrat:", error);
    return null;
  }
};

// Créer un nouveau contrat
export const createContract = async (contractData) => {
  try {
    const contractsCollection = collection(db, 'contracts');
    const docRef = await addDoc(contractsCollection, {
      ...contractData,
      createdAt: new Date()
    });
    
    return {
      id: docRef.id,
      ...contractData
    };
  } catch (error) {
    console.error("Erreur lors de la création du contrat:", error);
    throw error;
  }
};

// Mettre à jour un contrat
export const updateContract = async (id, contractData) => {
  try {
    const contractDoc = doc(db, 'contracts', id);
    await updateDoc(contractDoc, {
      ...contractData,
      updatedAt: new Date()
    });
    
    return {
      id,
      ...contractData
    };
  } catch (error) {
    console.error("Erreur lors de la mise à jour du contrat:", error);
    throw error;
  }
};

// Supprimer un contrat
export const deleteContract = async (id) => {
  try {
    const contractDoc = doc(db, 'contracts', id);
    await deleteDoc(contractDoc);
    return true;
  } catch (error) {
    console.error("Erreur lors de la suppression du contrat:", error);
    return false;
  }
};
EOL

# Création du service invoicesService.js
backup_file "client/src/services/invoicesService.js"
cat > client/src/services/invoicesService.js << 'EOL'
import { db } from '../firebase';
import { collection, getDocs, doc, getDoc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';

// Récupérer toutes les factures
export const getAllInvoices = async () => {
  try {
    const invoicesCollection = collection(db, 'invoices');
    const invoicesSnapshot = await getDocs(invoicesCollection);
    return invoicesSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des factures:", error);
    return [];
  }
};

// Récupérer une facture par ID
export const getInvoiceById = async (id) => {
  try {
    const invoiceDoc = doc(db, 'invoices', id);
    const invoiceSnapshot = await getDoc(invoiceDoc);
    
    if (invoiceSnapshot.exists()) {
      return {
        id: invoiceSnapshot.id,
        ...invoiceSnapshot.data()
      };
    } else {
      console.log("Aucune facture trouvée avec cet ID");
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la récupération de la facture:", error);
    return null;
  }
};

// Créer une nouvelle facture
export const createInvoice = async (invoiceData) => {
  try {
    const invoicesCollection = collection(db, 'invoices');
    const docRef = await addDoc(invoicesCollection, {
      ...invoiceData,
      createdAt: new Date()
    });
    
    return {
      id: docRef.id,
      ...invoiceData
    };
  } catch (error) {
    console.error("Erreur lors de la création de la facture:", error);
    throw error;
  }
};

// Mettre à jour une facture
export const updateInvoice = async (id, invoiceData) => {
  try {
    const invoiceDoc = doc(db, 'invoices', id);
    await updateDoc(invoiceDoc, {
      ...invoiceData,
      updatedAt: new Date()
    });
    
    return {
      id,
      ...invoiceData
    };
  } catch (error) {
    console.error("Erreur lors de la mise à jour de la facture:", error);
    throw error;
  }
};

// Supprimer une facture
export const deleteInvoice = async (id) => {
  try {
    const invoiceDoc = doc(db, 'invoices', id);
    await deleteDoc(invoiceDoc);
    return true;
  } catch (error) {
    console.error("Erreur lors de la suppression de la facture:", error);
    return false;
  }
};
EOL

# 12. Création du service programmersService.js s'il n'existe pas
echo -e "${GREEN}12. Création du service programmersService.js s'il n'existe pas...${NC}"

if [ ! -f "client/src/services/programmersService.js" ]; then
  cat > client/src/services/programmersService.js << 'EOL'
import { db } from '../firebase';
import { collection, getDocs, doc, getDoc, addDoc, updateDoc, deleteDoc, query, where } from 'firebase/firestore';

// Récupérer tous les programmateurs
export const getAllProgrammers = async () => {
  try {
    const programmersCollection = collection(db, 'programmers');
    const programmersSnapshot = await getDocs(programmersCollection);
    return programmersSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Erreur lors de la récupération des programmateurs:", error);
    return [];
  }
};

// Récupérer un programmateur par ID
export const getProgrammerById = async (id) => {
  try {
    const programmerDoc = doc(db, 'programmers', id);
    const programmerSnapshot = await getDoc(programmerDoc);
    
    if (programmerSnapshot.exists()) {
      return {
        id: programmerSnapshot.id,
        ...programmerSnapshot.data()
      };
    } else {
      console.log("Aucun programmateur trouvé avec cet ID");
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la récupération du programmateur:", error);
    return null;
  }
};

// Récupérer un programmateur par email
export const getProgrammerByEmail = async (email) => {
  try {
    const programmersCollection = collection(db, 'programmers');
    const q = query(programmersCollection, where("email", "==", email));
    const querySnapshot = await getDocs(q);
    
    if (!querySnapshot.empty) {
      const programmerDoc = querySnapshot.docs[0];
      return {
        id: programmerDoc.id,
        ...programmerDoc.data()
      };
    } else {
      console.log("Aucun programmateur trouvé avec cet email");
      return null;
    }
  } catch (error) {
    console.error("Erreur lors de la recherche du programmateur par email:", error);
    return null;
  }
};

// Créer un nouveau programmateur
export const createProgrammer = async (programmerData) => {
  try {
    const programmersCollection = collection(db, 'programmers');
    const docRef = await addDoc(programmersCollection, {
      ...programmerData,
      createdAt: new Date()
    });
    
    return {
      id: docRef.id,
      ...programmerData
    };
  } catch (error) {
    console.error("Erreur lors de la création du programmateur:", error);
    throw error;
  }
};

// Mettre à jour un programmateur
export const updateProgrammer = async (id, programmerData) => {
  try {
    const programmerDoc = doc(db, 'programmers', id);
    await updateDoc(programmerDoc, {
      ...programmerData,
      updatedAt: new Date()
    });
    
    return {
      id,
      ...programmerData
    };
  } catch (error) {
    console.error("Erreur lors de la mise à jour du programmateur:", error);
    throw error;
  }
};

// Supprimer un programmateur
export const deleteProgrammer = async (id) => {
  try {
    const programmerDoc = doc(db, 'programmers', id);
    await deleteDoc(programmerDoc);
    return true;
  } catch (error) {
    console.error("Erreur lors de la suppression du programmateur:", error);
    return false;
  }
};
EOL
  echo -e "${GREEN}✅ Service programmersService.js créé${NC}"
else
  echo -e "${YELLOW}Le service programmersService.js existe déjà${NC}"
fi

# 13. Installation des dépendances nécessaires
echo -e "${GREEN}13. Installation des dépendances nécessaires...${NC}"

# Vérifier si react-icons est installé
if ! grep -q "react-icons" client/package.json; then
  echo -e "${YELLOW}Installation de react-icons...${NC}"
  cd client && npm install --save react-icons && cd ..
else
  echo -e "${YELLOW}react-icons est déjà installé${NC}"
fi

echo -e "${GREEN}✅ Toutes les corrections ont été appliquées avec succès !${NC}"
echo -e "${YELLOW}Vous pouvez maintenant lancer le build avec la commande :${NC}"
echo -e "cd client && npm run build"

echo -e "${YELLOW}Pour ajouter, commiter et pousser les modifications :${NC}"
echo -e "git add client/src/components/layout/Sidebar.jsx client/src/components/layout/Sidebar.css client/src/components/concerts/ConcertsDashboard.jsx client/src/components/concerts/ConcertsDashboard.css client/src/components/concerts/ConcertsList.js client/src/components/concerts/ConcertsList.css client/src/services/formSubmissionsService.js client/src/components/formValidation/FormValidationList.jsx client/src/components/formValidation/FormValidationList.css client/src/components/formValidation/ComparisonTable.jsx client/src/components/formValidation/ComparisonTable.css client/src/components/public/PublicFormPage.jsx client/src/components/public/PublicFormPage.css client/src/components/settings/Settings.jsx client/src/components/documents/DocumentsList.jsx client/src/components/emails/EmailsList.jsx client/src/components/contracts/ContractsList.jsx client/src/components/contracts/ContractDetails.jsx client/src/components/invoices/InvoicesList.jsx client/src/components/invoices/InvoiceDetails.jsx client/src/services/contractsService.js client/src/services/invoicesService.js && git commit -m \"Fix: Correction complète de l'application - résolution des problèmes d'importation, de validation de formulaire et d'affichage\" && git push origin main"
