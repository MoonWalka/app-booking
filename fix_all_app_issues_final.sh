#!/bin/bash

# Script de correction pour l'application App Booking
# Ce script corrige les problèmes identifiés lors des tests manuels

echo "Début des corrections de l'application App Booking..."

# Vérification que nous sommes à la racine du projet
if [ ! -d "./client" ] || [ ! -d "./server" ]; then
  echo "Erreur: Ce script doit être exécuté à la racine du projet App Booking"
  exit 1
fi

# Création d'un répertoire de sauvegarde
BACKUP_DIR="./backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Répertoire de sauvegarde créé: $BACKUP_DIR"

# Fonction pour sauvegarder un fichier avant modification
backup_file() {
  local file=$1
  if [ -f "$file" ]; then
    local backup_path="$BACKUP_DIR/$(dirname "$file" | sed 's/^\.\///')"
    mkdir -p "$backup_path"
    cp "$file" "$backup_path/$(basename "$file")"
    echo "Sauvegarde de $file effectuée"
  else
    echo "Avertissement: Le fichier $file n'existe pas, impossible de le sauvegarder"
  fi
}

# 1. Correction du problème d'affichage des artistes dans la liste des concerts
echo "Correction du problème d'affichage des artistes dans la liste des concerts..."
backup_file "./client/src/components/concerts/ConcertsList.js"

# Modification du fichier ConcertsList.js pour corriger l'affichage des artistes
cat > ./client/src/components/concerts/ConcertsList.js << 'EOL'
import React, { useState, useEffect, Suspense } from 'react';
import { Link } from 'react-router-dom';
import { getConcerts } from '../../services/concertsService';
import { getArtists } from '../../services/artistsService';
import './ConcertsList.css';

// Importation dynamique du tableau de bord
const ConcertsDashboard = React.lazy(() => import('./ConcertsDashboard'));

const ConcertsList = () => {
  const [concerts, setConcerts] = useState([]);
  const [artists, setArtists] = useState({});
  const [loading, setLoading] = useState(true);
  const [showDashboard, setShowDashboard] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Récupérer les artistes et créer un mapping par ID
        const artistsData = await getArtists();
        const artistsMap = {};
        artistsData.forEach(artist => {
          artistsMap[artist.id] = artist;
        });
        setArtists(artistsMap);
        
        // Récupérer les concerts
        const concertsData = await getConcerts();
        
        // Enrichir les concerts avec les noms d'artistes
        const enrichedConcerts = concertsData.map(concert => {
          const artistId = concert.artistId;
          const artist = artistId && artistsMap[artistId] ? artistsMap[artistId].name : 'Artiste inconnu';
          
          // Formater la date correctement
          let formattedDate = 'Date non spécifiée';
          if (concert.date) {
            const date = new Date(concert.date);
            if (!isNaN(date.getTime())) {
              formattedDate = date.toLocaleDateString('fr-FR', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
              });
            }
          }
          
          return {
            ...concert,
            artist,
            formattedDate
          };
        });
        
        setConcerts(enrichedConcerts || []);
        setLoading(false);
      } catch (error) {
        console.error("Erreur lors du chargement des données:", error);
        setLoading(false);
      }
    };
    
    fetchData();
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
                    <td>{concert.formattedDate || concert.date || 'Non spécifiée'}</td>
                    <td>{concert.venue || 'Non spécifié'}</td>
                    <td>{concert.city || 'Non spécifiée'}</td>
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

echo "Fichier ConcertsList.js corrigé"

# 2. Correction du problème de validation lors de l'ajout d'un concert
echo "Correction du problème de validation lors de l'ajout d'un concert..."
backup_file "./client/src/components/concerts/ConcertDetail.js"

# Modification du fichier ConcertDetail.js pour corriger la validation
sed -i 's/concert.artist?.name || '\''Non spécifié'\''/concert.artist || '\''Non spécifié'\''/g' ./client/src/components/concerts/ConcertDetail.js

# 3. Création d'un fichier utilitaire pour enrichir les concerts avec les informations d'artiste
echo "Création d'un fichier utilitaire pour les concerts..."
mkdir -p ./client/src/utils
backup_file "./client/src/utils/concertUtils.js"

cat > ./client/src/utils/concertUtils.js << 'EOL'
/**
 * Utilitaires pour les concerts
 */

/**
 * Enrichit les données de concert avec les informations d'artiste
 * @param {Object} concertData - Données du concert
 * @param {Object} artistData - Données de l'artiste
 * @returns {Object} Concert enrichi
 */
export const enrichConcertWithArtist = (concertData, artistData) => {
  if (!concertData) return null;
  
  return {
    ...concertData,
    artist: artistData ? artistData.name : "Artiste inconnu",
    artistData: artistData || null
  };
};

/**
 * Formate la date d'un concert
 * @param {Object} concert - Données du concert
 * @returns {Object} Concert avec date formatée
 */
export const formatConcertDate = (concert) => {
  if (!concert) return null;
  
  let formattedDate = 'Date non spécifiée';
  if (concert.date) {
    const date = new Date(concert.date);
    if (!isNaN(date.getTime())) {
      formattedDate = date.toLocaleDateString('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    }
  }
  
  return {
    ...concert,
    formattedDate
  };
};
EOL

echo "Fichier utilitaire pour les concerts créé"

# 4. Correction du problème de format d'affichage de la date et de l'heure des concerts
echo "Correction du format d'affichage des dates..."
backup_file "./client/src/utils/dateUtils.js"

cat > ./client/src/utils/dateUtils.js << 'EOL'
/**
 * Utilitaires pour le formatage des dates
 */

/**
 * Formate une date en format français
 * @param {Date|string|number} date - Date à formater
 * @param {boolean} includeTime - Inclure l'heure dans le format
 * @returns {string} Date formatée
 */
export const formatDate = (date, includeTime = false) => {
  if (!date) return 'Non spécifiée';
  
  try {
    const dateObj = date instanceof Date ? date : new Date(date);
    
    if (isNaN(dateObj.getTime())) {
      return 'Date invalide';
    }
    
    const options = {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    };
    
    if (includeTime) {
      options.hour = '2-digit';
      options.minute = '2-digit';
    }
    
    return dateObj.toLocaleDateString('fr-FR', options);
  } catch (error) {
    console.error('Erreur lors du formatage de la date:', error);
    return 'Erreur de format';
  }
};

/**
 * Convertit un timestamp Firestore en objet Date
 * @param {Object} timestamp - Timestamp Firestore
 * @returns {Date|null} Objet Date ou null si invalide
 */
export const timestampToDate = (timestamp) => {
  if (!timestamp) return null;
  
  try {
    if (timestamp.seconds) {
      return new Date(timestamp.seconds * 1000);
    } else if (timestamp.toDate && typeof timestamp.toDate === 'function') {
      return timestamp.toDate();
    } else {
      return new Date(timestamp);
    }
  } catch (error) {
    console.error('Erreur lors de la conversion du timestamp:', error);
    return null;
  }
};
EOL

echo "Fichier d'utilitaires de dates créé"

# 5. Correction du problème dans la page Concert
echo "Correction des problèmes dans la page Concert..."

# Modification du fichier App.js pour corriger les problèmes de routage
backup_file "./client/src/App.js"

# Vérifier si le fichier App.js utilise HashRouter ou BrowserRouter
if grep -q "HashRouter" "./client/src/App.js"; then
  echo "Le fichier App.js utilise déjà HashRouter, pas besoin de modification"
else
  echo "Modification du fichier App.js pour utiliser HashRouter"
  
  # Remplacer BrowserRouter par HashRouter
  sed -i 's/BrowserRouter/HashRouter/g' ./client/src/App.js
  sed -i 's/import { BrowserRouter as Router/import { HashRouter as Router/g' ./client/src/App.js
  
  # Si l'import n'existe pas, l'ajouter
  if ! grep -q "HashRouter" "./client/src/App.js"; then
    sed -i 's/import { \(.*\) } from '\''react-router-dom'\'';/import { \1, HashRouter as Router } from '\''react-router-dom'\'';/g' ./client/src/App.js
  fi
fi

# 6. Correction de la validation des formulaires
echo "Correction de la validation des formulaires..."
backup_file "./client/src/components/formValidation/FormValidationList.jsx"

# Modification du fichier FormValidationList.jsx pour supprimer les exemples par défaut
sed -i '/const mockSubmissions/,/];/c\
  // Les exemples par défaut ont été supprimés\
  const mockSubmissions = [];' ./client/src/components/formValidation/FormValidationList.jsx

# 7. Ajout de la fonction getProgrammerByEmail manquante
echo "Ajout de la fonction getProgrammerByEmail manquante..."
backup_file "./client/src/services/programmersService.js"

# Vérifier si la fonction existe déjà
if ! grep -q "getProgrammerByEmail" "./client/src/services/programmersService.js"; then
  # Ajouter la fonction après getProgrammerById
  sed -i '/export const getProgrammerById/,/};/!b;/};/a\\
// Ajout de la fonction manquante getProgrammerByEmail\
export const getProgrammerByEmail = async (email) => {\
  try {\
    // S'\''assurer que la collection existe\
    await ensureCollection(PROGRAMMERS_COLLECTION);\
    \
    console.log(`[getProgrammerByEmail] Recherche du programmateur avec email ${email}`);\
    \
    // Créer une requête pour trouver le programmateur par email\
    const programmersRef = collection(db, PROGRAMMERS_COLLECTION);\
    const q = query(programmersRef, where("email", "==", email));\
    const querySnapshot = await getDocs(q);\
    \
    if (!querySnapshot.empty) {\
      const programmerDoc = querySnapshot.docs[0];\
      const programmerData = {\
        id: programmerDoc.id,\
        ...programmerDoc.data()\
      };\
      console.log(`[getProgrammerByEmail] Programmateur trouvé:`, programmerData);\
      return programmerData;\
    }\
    \
    console.log(`[getProgrammerByEmail] Aucun programmateur trouvé avec l'\''email ${email}`);\
    return null;\
  } catch (error) {\
    console.error(`[getProgrammerByEmail] Erreur lors de la recherche du programmateur avec email ${email}:`, error);\
    return null;\
  }\
};' "./client/src/services/programmersService.js"
  
  echo "Fonction getProgrammerByEmail ajoutée"
else
  echo "La fonction getProgrammerByEmail existe déjà"
fi

# 8. Correction des fichiers CSS manquants
echo "Création des fichiers CSS manquants..."

# ContractsList.css
if [ ! -f "./client/src/components/contracts/ContractsList.css" ]; then
  cat > ./client/src/components/contracts/ContractsList.css << 'EOL'
.contracts-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.contracts-container h1 {
  margin-bottom: 20px;
  color: #333;
}

.contracts-container p {
  color: #666;
  font-size: 16px;
}
EOL
  echo "Fichier ContractsList.css créé"
fi

# InvoicesList.css
if [ ! -f "./client/src/components/invoices/InvoicesList.css" ]; then
  cat > ./client/src/components/invoices/InvoicesList.css << 'EOL'
.invoices-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.invoices-container h1 {
  margin-bottom: 20px;
  color: #333;
}

.invoices-container p {
  color: #666;
  font-size: 16px;
}
EOL
  echo "Fichier InvoicesList.css créé"
fi

# EmailsList.css
if [ ! -f "./client/src/components/emails/EmailsList.css" ]; then
  cat > ./client/src/components/emails/EmailsList.css << 'EOL'
.emails-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.emails-container h1 {
  margin-bottom: 20px;
  color: #333;
}

.emails-container p {
  color: #666;
  font-size: 16px;
}
EOL
  echo "Fichier EmailsList.css créé"
fi

# Settings.css
if [ ! -f "./client/src/components/settings/Settings.css" ]; then
  cat > ./client/src/components/settings/Settings.css << 'EOL'
.settings-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.settings-container h1 {
  margin-bottom: 20px;
  color: #333;
}

.settings-container p {
  color: #666;
  font-size: 16px;
}
EOL
  echo "Fichier Settings.css créé"
fi

# DocumentsList.css
if [ ! -f "./client/src/components/documents/DocumentsList.css" ]; then
  cat > ./client/src/components/documents/DocumentsList.css << 'EOL'
.documents-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.documents-container h1 {
  margin-bottom: 20px;
  color: #333;
}

.documents-container p {
  color: #666;
  font-size: 16px;
}
EOL
  echo "Fichier DocumentsList.css créé"
fi

# 9. Correction des erreurs d'importation
echo "Correction des erreurs d'importation..."

# Correction de ContractsTable.js
backup_file "./client/src/components/contracts/ContractsTable.js"
if grep -q "fetchContracts" "./client/src/components/contracts/ContractsTable.js"; then
  sed -i 's/fetchContracts/getAllContracts/g' "./client/src/components/contracts/ContractsTable.js"
  echo "Importation corrigée dans ContractsTable.js"
fi

# 10. Installation des dépendances nécessaires
echo "Installation des dépendances nécessaires..."
cd ./client && npm install --save react-router-dom firebase

# Retour à la racine du projet
cd ..

echo "Toutes les corrections ont été appliquées avec succès!"
echo "Pour tester les corrections, exécutez: npm run build"
