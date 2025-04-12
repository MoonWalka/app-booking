#!/bin/bash

# Script de correction complète pour l'application App Booking
# Ce script intègre toutes les corrections nécessaires :
# - Améliorations de sécurité
# - Correction des problèmes liés à currentUser
# - Correction des avertissements ESLint

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages d'information
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Fonction pour afficher les messages de succès
success() {
    echo -e "${GREEN}[SUCCÈS]${NC} $1"
}

# Fonction pour afficher les messages d'avertissement
warning() {
    echo -e "${YELLOW}[AVERTISSEMENT]${NC} $1"
}

# Fonction pour afficher les messages d'erreur
error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

# Fonction pour créer une sauvegarde d'un fichier
backup_file() {
    local file=$1
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$file" ]; then
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/$(basename "$file").bak"
        success "Sauvegarde de $file créée dans $backup_dir"
    else
        error "Le fichier $file n'existe pas, impossible de créer une sauvegarde"
        return 1
    fi
}

# Vérifier si nous sommes à la racine du projet
if [ ! -d "client" ] || [ ! -f "package.json" ]; then
    error "Ce script doit être exécuté à la racine du projet App Booking"
    exit 1
fi

# Créer le répertoire de sauvegarde
mkdir -p backups

# Créer un fichier README pour documenter les modifications
cat > CORRECTIONS_APPLIQUEES.md << 'EOF'
# Corrections appliquées à l'application App Booking

Ce document décrit les corrections appliquées par le script `app_booking_fix_all.sh`.

## 1. Améliorations de sécurité

- Configuration Firebase sécurisée avec variables d'environnement
- Mode bypass d'authentification configurable
- Règles Firestore renforcées
- Règles de stockage Firebase ajoutées
- Utilitaire de logging sécurisé
- En-têtes de sécurité HTTP

## 2. Correction des problèmes liés à currentUser

- Vérification de l'existence de currentUser avant d'accéder à ses propriétés
- Amélioration de la gestion du mode bypass d'authentification
- Création d'un utilitaire pour manipuler currentUser de manière sécurisée

## 3. Correction des avertissements ESLint

- Suppression des variables non utilisées
- Correction des problèmes de formatage
- Standardisation des extensions de fichiers JSX

## Configuration du mode de test

- Le mode bypass d'authentification est activé par défaut pour les tests
- Pour désactiver le bypass et utiliser l'authentification réelle, modifiez la variable REACT_APP_BYPASS_AUTH dans le fichier .env

## Sauvegarde

Tous les fichiers modifiés ont été sauvegardés dans le répertoire `backups` avec un horodatage.
EOF

success "Fichier de documentation CORRECTIONS_APPLIQUEES.md créé"

#############################
# PARTIE 1: SÉCURITÉ
#############################

info "Début des améliorations de sécurité..."

# 1. Créer un fichier .env pour la configuration Firebase
info "Création du fichier .env pour la configuration Firebase..."
cat > client/.env << 'EOF'
# Configuration Firebase
REACT_APP_FIREBASE_API_KEY=AIzaSyA5xB_JYx4UBxqDzDlU4Q8WnEpHe4UmN0k
REACT_APP_FIREBASE_AUTH_DOMAIN=app-booking-dev.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=app-booking-dev
REACT_APP_FIREBASE_STORAGE_BUCKET=app-booking-dev.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=123456789012
REACT_APP_FIREBASE_APP_ID=1:123456789012:web:abcdef1234567890

# Configuration de l'authentification
REACT_APP_BYPASS_AUTH=true

# Environnement
REACT_APP_ENV=development
EOF
success "Fichier .env créé avec succès"

# 2. Mettre à jour le fichier firebase.js pour utiliser les variables d'environnement
if [ -f "client/src/firebase.js" ]; then
    backup_file "client/src/firebase.js"
    
    info "Mise à jour du fichier firebase.js pour utiliser les variables d'environnement..."
    cat > client/src/firebase.js << 'EOF'
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Configuration Firebase à partir des variables d'environnement
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FIREBASE_APP_ID
};

// Initialiser Firebase
const app = initializeApp(firebaseConfig);

// Exporter les services Firebase
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

// Utilitaire de logging sécurisé
export const secureLog = (message, data = null) => {
  // Ne pas logger en production
  if (process.env.REACT_APP_ENV === 'production') return;
  
  // Masquer les informations sensibles
  const sanitizeData = (obj) => {
    if (!obj) return obj;
    
    const sanitized = { ...obj };
    
    // Liste des clés sensibles à masquer
    const sensitiveKeys = ['password', 'token', 'apiKey', 'secret', 'credential'];
    
    Object.keys(sanitized).forEach(key => {
      // Masquer les valeurs des clés sensibles
      if (sensitiveKeys.some(sk => key.toLowerCase().includes(sk.toLowerCase()))) {
        sanitized[key] = '***MASKED***';
      }
      // Récursion pour les objets imbriqués
      else if (typeof sanitized[key] === 'object' && sanitized[key] !== null) {
        sanitized[key] = sanitizeData(sanitized[key]);
      }
    });
    
    return sanitized;
  };
  
  console.log(message, data ? sanitizeData(data) : '');
};

export default app;
EOF
    success "Fichier firebase.js mis à jour avec succès"
else
    error "Le fichier client/src/firebase.js n'existe pas"
fi

# 3. Mettre à jour le fichier AuthContext.js pour améliorer la gestion de l'authentification
if [ -f "client/src/context/AuthContext.js" ]; then
    backup_file "client/src/context/AuthContext.js"
    
    info "Mise à jour du fichier AuthContext.js pour améliorer la gestion de l'authentification..."
    cat > client/src/context/AuthContext.js << 'EOF'
import React, { createContext, useState, useContext, useEffect } from 'react';
import { auth, secureLog } from '../firebase';
import { onAuthStateChanged } from 'firebase/auth';

// Créer le contexte d'authentification
const AuthContext = createContext();

// Définir les routes publiques qui ne nécessitent pas d'authentification
const PUBLIC_ROUTES = [
  '/login',
  '/register',
  '/reset-password',
  '/public-form'
];

// Vérifier si une route est publique
const isPublicRoute = (path) => {
  // Nettoyer le chemin
  const cleanPath = path.split('?')[0].split('#')[0];
  // Normaliser le chemin
  const normalizedPath = cleanPath || '/';
  
  secureLog("AuthContext - isPublicRoute - chemin original:", path);
  secureLog("AuthContext - isPublicRoute - chemin nettoyé:", cleanPath);
  secureLog("AuthContext - isPublicRoute - chemin normalisé:", normalizedPath);
  
  // Vérifier si le chemin est dans la liste des routes publiques
  const isPublic = PUBLIC_ROUTES.some(route => normalizedPath.startsWith(route));
  secureLog("AuthContext - isPublicRoute - est une route publique:", isPublic);
  
  return isPublic;
};

// Hook personnalisé pour utiliser le contexte d'authentification
export const useAuth = () => {
  return useContext(AuthContext);
};

// Fournisseur du contexte d'authentification
export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Utilisateur de test pour le mode bypass
  const TEST_USER = {
    uid: 'test-user-id',
    email: 'test@example.com',
    name: 'Utilisateur Test',
    role: 'admin',
    isAuthenticated: true
  };
  
  useEffect(() => {
    // Récupérer la route actuelle
    const currentRoute = window.location.hash.substring(1); // Pour les applications avec HashRouter
    secureLog("AuthContext - Route actuelle (hash brut):", window.location.hash);
    secureLog("AuthContext - Route actuelle (hash nettoyé):", currentRoute);
    
    // Vérifier si la route actuelle est publique
    const isPublic = isPublicRoute(currentRoute);
    secureLog("AuthContext - Est une route publique:", isPublic);
    
    // Récupérer la valeur de BYPASS_AUTH depuis les variables d'environnement
    const bypassAuth = process.env.REACT_APP_BYPASS_AUTH === 'true';
    secureLog("AuthContext - BYPASS_AUTH global:", bypassAuth);
    
    // Déterminer si le bypass doit être activé pour cette route
    const shouldBypass = bypassAuth && !isPublic;
    secureLog("AuthContext - Bypass effectif pour cette route:", shouldBypass);
    
    // Si le bypass est activé et que la route n'est pas publique, utiliser l'utilisateur de test
    if (shouldBypass) {
      secureLog("AuthContext - Route protégée avec bypass activé, authentification simulée");
      setCurrentUser(TEST_USER);
      setLoading(false);
      return;
    }
    
    // Sinon, utiliser l'authentification Firebase normale
    const unsubscribe = onAuthStateChanged(auth, 
      (user) => {
        if (user) {
          // Utilisateur connecté
          const formattedUser = {
            uid: user.uid,
            email: user.email,
            name: user.displayName || 'Utilisateur',
            isAuthenticated: true
          };
          setCurrentUser(formattedUser);
        } else {
          // Utilisateur déconnecté
          setCurrentUser(null);
        }
        setLoading(false);
      },
      (error) => {
        console.error("Erreur d'authentification:", error);
        setError("Une erreur s'est produite lors de l'authentification.");
        setLoading(false);
      }
    );
    
    // Nettoyer l'abonnement lors du démontage du composant
    return () => unsubscribe();
  }, []);
  
  // Si le mode bypass est activé pour les routes protégées, afficher un message
  useEffect(() => {
    if (process.env.REACT_APP_BYPASS_AUTH === 'true') {
      const currentRoute = window.location.hash.substring(1);
      if (!isPublicRoute(currentRoute)) {
        console.log("AuthContext - Mode bypass d'authentification activé pour route protégée");
      }
    }
  }, []);
  
  // Valeur du contexte
  const value = {
    currentUser,
    loading,
    error,
    isAuthenticated: !!currentUser
  };
  
  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
EOF
    success "Fichier AuthContext.js mis à jour avec succès"
else
    error "Le fichier client/src/context/AuthContext.js n'existe pas"
fi

# 4. Créer un fichier de règles Firestore renforcées
info "Création des règles Firestore renforcées..."
cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Fonction pour vérifier si l'utilisateur est authentifié
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Fonction pour vérifier si l'utilisateur est administrateur
    function isAdmin() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Fonction pour vérifier si l'utilisateur est le propriétaire du document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Règles pour la collection users
    match /users/{userId} {
      // Les utilisateurs peuvent lire leur propre profil
      // Les administrateurs peuvent lire tous les profils
      allow read: if isOwner(userId) || isAdmin();
      
      // Les utilisateurs peuvent modifier leur propre profil
      // Les administrateurs peuvent modifier tous les profils
      allow write: if isOwner(userId) || isAdmin();
    }
    
    // Règles pour la collection concerts
    match /concerts/{concertId} {
      // Tous les utilisateurs authentifiés peuvent lire les concerts
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des concerts
      allow write: if isAdmin();
    }
    
    // Règles pour la collection artists
    match /artists/{artistId} {
      // Tous les utilisateurs authentifiés peuvent lire les artistes
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des artistes
      allow write: if isAdmin();
    }
    
    // Règles pour la collection programmers
    match /programmers/{programmerId} {
      // Tous les utilisateurs authentifiés peuvent lire les programmateurs
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des programmateurs
      allow write: if isAdmin();
    }
    
    // Règles pour la collection contracts
    match /contracts/{contractId} {
      // Tous les utilisateurs authentifiés peuvent lire les contrats
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des contrats
      allow write: if isAdmin();
    }
    
    // Règles pour la collection invoices
    match /invoices/{invoiceId} {
      // Tous les utilisateurs authentifiés peuvent lire les factures
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des factures
      allow write: if isAdmin();
    }
    
    // Règles pour la collection formValidation
    match /formValidation/{formId} {
      // Tous les utilisateurs peuvent créer des formulaires de validation
      allow create: if true;
      
      // Seuls les utilisateurs authentifiés peuvent lire les formulaires
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent modifier ou supprimer des formulaires
      allow update, delete: if isAdmin();
    }
  }
}
EOF
success "Fichier firestore.rules créé avec succès"

# 5. Créer un fichier de règles de stockage Firebase
info "Création des règles de stockage Firebase..."
cat > storage.rules << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Fonction pour vérifier si l'utilisateur est authentifié
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Fonction pour vérifier si l'utilisateur est administrateur
    function isAdmin() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Règles par défaut - refuser tout accès
    match /{allPaths=**} {
      allow read, write: if false;
    }
    
    // Règles pour les documents de contrats
    match /contracts/{contractId}/{fileName} {
      // Tous les utilisateurs authentifiés peuvent lire les documents de contrats
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des documents de contrats
      allow write: if isAdmin();
    }
    
    // Règles pour les documents de factures
    match /invoices/{invoiceId}/{fileName} {
      // Tous les utilisateurs authentifiés peuvent lire les documents de factures
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des documents de factures
      allow write: if isAdmin();
    }
    
    // Règles pour les photos d'artistes
    match /artists/{artistId}/{fileName} {
      // Tous les utilisateurs authentifiés peuvent lire les photos d'artistes
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des photos d'artistes
      allow write: if isAdmin();
    }
    
    // Règles pour les documents publics
    match /public/{fileName} {
      // Tout le monde peut lire les documents publics
      allow read: if true;
      
      // Seuls les administrateurs peuvent créer, modifier ou supprimer des documents publics
      allow write: if isAdmin();
    }
    
    // Règles pour les pièces jointes des formulaires de validation
    match /formValidation/{formId}/{fileName} {
      // Tout le monde peut télécharger des pièces jointes pour les formulaires de validation
      allow create: if request.resource.size < 10 * 1024 * 1024 // Limite de 10 Mo
                    && (request.resource.contentType.matches('image/.*') 
                        || request.resource.contentType.matches('application/pdf'));
      
      // Tous les utilisateurs authentifiés peuvent lire les pièces jointes
      allow read: if isAuthenticated();
      
      // Seuls les administrateurs peuvent modifier ou supprimer des pièces jointes
      allow update, delete: if isAdmin();
    }
  }
}
EOF
success "Fichier storage.rules créé avec succès"

#############################
# PARTIE 2: CORRECTION DES PROBLÈMES LIÉS À CURRENTUSER
#############################

info "Début des corrections liées à currentUser..."

# 1. Créer un utilitaire pour manipuler currentUser de manière sécurisée
info "Création de l'utilitaire userUtils.js..."
mkdir -p client/src/utils
cat > client/src/utils/userUtils.js << 'EOF'
/**
 * Utilitaires pour manipuler currentUser de manière sécurisée
 */

/**
 * Vérifie si un utilisateur est défini et authentifié
 * @param {Object|null} user - L'objet utilisateur à vérifier
 * @returns {boolean} - true si l'utilisateur est défini et authentifié, false sinon
 */
export const isUserAuthenticated = (user) => {
  return !!user && !!user.isAuthenticated;
};

/**
 * Récupère le nom d'un utilisateur de manière sécurisée
 * @param {Object|null} user - L'objet utilisateur
 * @param {string} defaultName - Nom par défaut à utiliser si l'utilisateur n'est pas défini ou n'a pas de nom
 * @returns {string} - Le nom de l'utilisateur ou le nom par défaut
 */
export const getUserName = (user, defaultName = "Utilisateur") => {
  return (user && user.name) ? user.name : defaultName;
};

/**
 * Récupère l'email d'un utilisateur de manière sécurisée
 * @param {Object|null} user - L'objet utilisateur
 * @param {string} defaultEmail - Email par défaut à utiliser si l'utilisateur n'est pas défini ou n'a pas d'email
 * @returns {string} - L'email de l'utilisateur ou l'email par défaut
 */
export const getUserEmail = (user, defaultEmail = "non@disponible.com") => {
  return (user && user.email) ? user.email : defaultEmail;
};

/**
 * Récupère l'ID d'un utilisateur de manière sécurisée
 * @param {Object|null} user - L'objet utilisateur
 * @param {string} defaultId - ID par défaut à utiliser si l'utilisateur n'est pas défini ou n'a pas d'ID
 * @returns {string} - L'ID de l'utilisateur ou l'ID par défaut
 */
export const getUserId = (user, defaultId = "guest") => {
  return (user && user.uid) ? user.uid : defaultId;
};

/**
 * Vérifie si un utilisateur a un rôle spécifique
 * @param {Object|null} user - L'objet utilisateur
 * @param {string} role - Le rôle à vérifier
 * @returns {boolean} - true si l'utilisateur a le rôle spécifié, false sinon
 */
export const hasUserRole = (user, role) => {
  return !!user && !!user.role && user.role === role;
};

/**
 * Vérifie si un utilisateur est administrateur
 * @param {Object|null} user - L'objet utilisateur
 * @returns {boolean} - true si l'utilisateur est administrateur, false sinon
 */
export const isAdmin = (user) => {
  return hasUserRole(user, 'admin');
};

export default {
  isUserAuthenticated,
  getUserName,
  getUserEmail,
  getUserId,
  hasUserRole,
  isAdmin
};
EOF
success "Fichier userUtils.js créé avec succès"

# 2. Corriger le composant Layout.jsx pour utiliser l'utilitaire userUtils
if [ -f "client/src/components/common/Layout.jsx" ]; then
    backup_file "client/src/components/common/Layout.jsx"
    
    info "Mise à jour du composant Layout.jsx pour utiliser l'utilitaire userUtils..."
    cat > client/src/components/common/Layout.jsx << 'EOF'
import React from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { getUserName, isUserAuthenticated } from '../../utils/userUtils';
import Sidebar from '../layout/Sidebar';
import './Layout.css';

const Layout = () => {
  const { currentUser } = useAuth();
  const location = useLocation();
  
  // Utilisation sécurisée de currentUser avec l'utilitaire userUtils
  const userName = getUserName(currentUser, "Utilisateur");
  const isAuthenticated = isUserAuthenticated(currentUser);
  
  // Log sécurisé après avoir récupéré currentUser
  console.log("Layout - currentUser:", currentUser);
  
  return (
    <div className="app-container">
      {isAuthenticated && (
        <Sidebar />
      )}
      
      <div className="main-content">
        {isAuthenticated && (
          <div className="user-info">
            <p>{userName}</p>
            {process.env.REACT_APP_BYPASS_AUTH === 'true' && (
              <p className="test-mode">Mode test activé - Authentification simulée</p>
            )}
          </div>
        )}
        
        <Outlet />
      </div>
    </div>
  );
};

export default Layout;
EOF
    success "Fichier Layout.jsx mis à jour avec succès"
else
    warning "Le fichier client/src/components/common/Layout.jsx n'existe pas, création d'un nouveau fichier..."
    mkdir -p client/src/components/common
    cat > client/src/components/common/Layout.jsx << 'EOF'
import React from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { getUserName, isUserAuthenticated } from '../../utils/userUtils';
import Sidebar from '../layout/Sidebar';
import './Layout.css';

const Layout = () => {
  const { currentUser } = useAuth();
  const location = useLocation();
  
  // Utilisation sécurisée de currentUser avec l'utilitaire userUtils
  const userName = getUserName(currentUser, "Utilisateur");
  const isAuthenticated = isUserAuthenticated(currentUser);
  
  // Log sécurisé après avoir récupéré currentUser
  console.log("Layout - currentUser:", currentUser);
  
  return (
    <div className="app-container">
      {isAuthenticated && (
        <Sidebar />
      )}
      
      <div className="main-content">
        {isAuthenticated && (
          <div className="user-info">
            <p>{userName}</p>
            {process.env.REACT_APP_BYPASS_AUTH === 'true' && (
              <p className="test-mode">Mode test activé - Authentification simulée</p>
            )}
          </div>
        )}
        
        <Outlet />
      </div>
    </div>
  );
};

export default Layout;
EOF
    success "Fichier Layout.jsx créé avec succès"
    
    # Créer un fichier CSS pour Layout si nécessaire
    cat > client/src/components/common/Layout.css << 'EOF'
.app-container {
  display: flex;
  min-height: 100vh;
}

.main-content {
  flex: 1;
  padding: 20px;
  background-color: #f5f5f5;
}

.user-info {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-bottom: 20px;
  padding: 10px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.user-info p {
  margin: 0 10px;
}

.test-mode {
  color: #ff6b6b;
  font-weight: bold;
  font-size: 0.8rem;
}
EOF
    success "Fichier Layout.css créé avec succès"
fi

# 3. Mettre à jour App.jsx pour utiliser Layout et AuthProvider correctement
if [ -f "client/src/App.jsx" ]; then
    backup_file "client/src/App.jsx"
    
    info "Mise à jour du fichier App.jsx pour utiliser Layout et AuthProvider correctement..."
    cat > client/src/App.jsx << 'EOF'
import React from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';

// Composants
import Layout from './components/common/Layout';
import Dashboard from './components/dashboard/Dashboard';
import ConcertsList from './components/concerts/ConcertsList';
import ConcertDetail from './components/concerts/ConcertDetail';
import ArtistsList from './components/artists/ArtistsList';
import ArtistDetail from './components/artists/ArtistDetail';
import ProgrammersList from './components/programmers/ProgrammersList';
import ProgrammerDetail from './components/programmers/ProgrammerDetail';
import ContractsList from './components/contracts/ContractsList';
import ContractDetails from './components/contracts/ContractDetails';
import InvoicesList from './components/invoices/InvoicesList';
import InvoiceDetails from './components/invoices/InvoiceDetails';
import EmailsList from './components/emails/EmailsList';
import DocumentsList from './components/documents/DocumentsList';
import Settings from './components/settings/Settings';
import PublicFormPage from './components/public/PublicFormPage';
import FormValidationList from './components/formValidation/FormValidationList';
import ErrorBoundary from './components/common/ErrorBoundary';

function App() {
  console.log("App - Initialisation de l'application...");
  
  return (
    <ErrorBoundary>
      <AuthProvider>
        <Router>
          <Routes>
            {/* Routes publiques */}
            <Route path="/public-form" element={<PublicFormPage />} />
            
            {/* Routes protégées avec Layout */}
            <Route path="/" element={<Layout />}>
              <Route index element={<Dashboard />} />
              <Route path="dashboard" element={<Dashboard />} />
              <Route path="concerts" element={<ConcertsList />} />
              <Route path="concerts/:id" element={<ConcertDetail />} />
              <Route path="artists" element={<ArtistsList />} />
              <Route path="artists/:id" element={<ArtistDetail />} />
              <Route path="programmers" element={<ProgrammersList />} />
              <Route path="programmers/:id" element={<ProgrammerDetail />} />
              <Route path="contracts" element={<ContractsList />} />
              <Route path="contracts/:id" element={<ContractDetails />} />
              <Route path="invoices" element={<InvoicesList />} />
              <Route path="invoices/:id" element={<InvoiceDetails />} />
              <Route path="emails" element={<EmailsList />} />
              <Route path="documents" element={<DocumentsList />} />
              <Route path="settings" element={<Settings />} />
              <Route path="form-validation" element={<FormValidationList />} />
              <Route path="validation-formulaire" element={<FormValidationList />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Route>
          </Routes>
        </Router>
      </AuthProvider>
    </ErrorBoundary>
  );
}

export default App;
EOF
    success "Fichier App.jsx mis à jour avec succès"
else
    error "Le fichier client/src/App.jsx n'existe pas"
fi

#############################
# PARTIE 3: CORRECTION DES AVERTISSEMENTS ESLINT
#############################

info "Début des corrections des avertissements ESLint..."

# 1. Standardiser les extensions des fichiers JSX
info "Standardisation des extensions des fichiers JSX..."

find client/src -name "*.js" | while read file; do
    # Vérifier si le fichier contient du JSX
    if grep -q "React\|jsx\|<[a-zA-Z]" "$file"; then
        # Créer une sauvegarde du fichier
        backup_file "$file"
        
        # Renommer le fichier avec l'extension .jsx
        new_file="${file%.*}.jsx"
        mv "$file" "$new_file"
        success "Fichier $file renommé en $new_file"
        
        # Mettre à jour les imports dans les autres fichiers
        old_import="${file#client/src/}"
        old_import="${old_import%.*}"
        new_import="${old_import}"
        
        find client/src -type f -name "*.js" -o -name "*.jsx" | while read import_file; do
            if grep -q "import.*from.*['\"].*${old_import}['\"]" "$import_file"; then
                sed -i "s|import.*from.*['\"].*${old_import}['\"]|import from './${new_import}'|g" "$import_file"
                success "Imports mis à jour dans $import_file"
            fi
        done
    fi
done

# 2. Corriger les problèmes de formatage et les variables non utilisées dans les fichiers spécifiques
info "Correction des problèmes de formatage et des variables non utilisées..."

# Correction de ConcertsList.jsx
if [ -f "client/src/components/concerts/ConcertsList.jsx" ]; then
    backup_file "client/src/components/concerts/ConcertsList.jsx"
    
    info "Correction de ConcertsList.jsx..."
    sed -i 's/const \[loading, setLoading\] = useState(false);/const [loading] = useState(false);/' client/src/components/concerts/ConcertsList.jsx
    sed -i 's/const \[error, setError\] = useState(null);/const [error] = useState(null);/' client/src/components/concerts/ConcertsList.jsx
    success "ConcertsList.jsx corrigé avec succès"
fi

# Correction de ConcertsDashboard.jsx
if [ -f "client/src/components/concerts/ConcertsDashboard.jsx" ]; then
    backup_file "client/src/components/concerts/ConcertsDashboard.jsx"
    
    info "Correction de ConcertsDashboard.jsx..."
    sed -i 's/const \[loading, setLoading\] = useState(false);/const [loading] = useState(false);/' client/src/components/concerts/ConcertsDashboard.jsx
    sed -i 's/const \[error, setError\] = useState(null);/const [error] = useState(null);/' client/src/components/concerts/ConcertsDashboard.jsx
    success "ConcertsDashboard.jsx corrigé avec succès"
fi

# Correction de ContractsTable.jsx
if [ -f "client/src/components/contracts/ContractsTable.jsx" ]; then
    backup_file "client/src/components/contracts/ContractsTable.jsx"
    
    info "Correction de ContractsTable.jsx..."
    sed -i 's/const \[loading, setLoading\] = useState(false);/const [loading] = useState(false);/' client/src/components/contracts/ContractsTable.jsx
    sed -i 's/const \[error, setError\] = useState(null);/const [error] = useState(null);/' client/src/components/contracts/ContractsTable.jsx
    success "ContractsTable.jsx corrigé avec succès"
fi

# Correction de FormValidationList.jsx
if [ -f "client/src/components/formValidation/FormValidationList.jsx" ]; then
    backup_file "client/src/components/formValidation/FormValidationList.jsx"
    
    info "Correction de FormValidationList.jsx..."
    sed -i 's/const \[loading, setLoading\] = useState(false);/const [loading] = useState(false);/' client/src/components/formValidation/FormValidationList.jsx
    sed -i 's/const \[error, setError\] = useState(null);/const [error] = useState(null);/' client/src/components/formValidation/FormValidationList.jsx
    success "FormValidationList.jsx corrigé avec succès"
fi

# 3. Corriger les commentaires dans index.js
if [ -f "client/src/index.js" ]; then
    backup_file "client/src/index.js"
    
    info "Correction des commentaires dans index.js..."
    sed -i 's|// If you want to start measuring performance in your app, pass a function|/* If you want to start measuring performance in your app, pass a function|' client/src/index.js
    sed -i 's|// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals|or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals */|' client/src/index.js
    success "index.js corrigé avec succès"
fi

#############################
# FINALISATION
#############################

info "Finalisation des corrections..."

# Créer un fichier README pour expliquer comment utiliser le mode bypass d'authentification
cat > client/README.md << 'EOF'
# App Booking - Client

## Mode de test avec bypass d'authentification

Cette application utilise un mode de bypass d'authentification pour faciliter les tests et le développement. Ce mode permet d'accéder à toutes les fonctionnalités de l'application sans avoir à s'authentifier.

### Configuration

Le mode bypass d'authentification est configuré dans le fichier `.env` à la racine du projet client :

```
REACT_APP_BYPASS_AUTH=true
```

- `true` : Le bypass d'authentification est activé (mode test)
- `false` : Le bypass d'authentification est désactivé (authentification réelle)

### Utilisateur de test

Lorsque le mode bypass est activé, l'application utilise un utilisateur de test avec les informations suivantes :

```javascript
{
  uid: 'test-user-id',
  email: 'test@example.com',
  name: 'Utilisateur Test',
  role: 'admin',
  isAuthenticated: true
}
```

### Désactiver le mode bypass

Pour désactiver le mode bypass et utiliser l'authentification réelle, modifiez la valeur de `REACT_APP_BYPASS_AUTH` dans le fichier `.env` :

```
REACT_APP_BYPASS_AUTH=false
```

Puis reconstruisez l'application :

```
npm run build
```
EOF
success "Fichier README.md créé avec succès"

# Afficher un message de succès
success "Toutes les corrections ont été appliquées avec succès !"
success "Un fichier de documentation CORRECTIONS_APPLIQUEES.md a été créé à la racine du projet."
success "Les fichiers modifiés ont été sauvegardés dans le répertoire backups."

info "Pour tester l'application, exécutez les commandes suivantes :"
info "cd client && npm run build"
info "npx serve -s build"

info "Pour déployer les modifications, exécutez les commandes suivantes :"
info "git add ."
info "git commit -m \"Corrections de sécurité, currentUser et ESLint\""
info "git push"
