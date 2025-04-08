#!/bin/bash

# Script pour sécuriser Firebase et réactiver l'authentification dans l'application App Booking
# Ce script applique les modifications nécessaires pour :
# 1. Réactiver l'authentification Firebase
# 2. Mettre en place des règles de sécurité Firebase
# 3. Maintenir l'application fonctionnelle avec l'authentification activée

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
  echo -e "${BLUE}$1${NC}"
}

print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}"
}

print_warning() {
  echo -e "${YELLOW}$1${NC}"
}

# Vérifier si nous sommes dans le répertoire du projet
if [ ! -d "./client" ]; then
  print_error "Erreur: Ce script doit être exécuté depuis la racine du projet app-booking"
  exit 1
fi

# Créer un répertoire de sauvegarde avec horodatage
BACKUP_DIR="./backups/firebase_auth_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR/client/src/context"
mkdir -p "$BACKUP_DIR/client/src"
print_message "📁 Création du répertoire de sauvegarde: $BACKUP_DIR"

# Sauvegarder les fichiers originaux
if [ -f "./client/src/context/AuthContext.js" ]; then
  cp "./client/src/context/AuthContext.js" "$BACKUP_DIR/client/src/context/"
fi

if [ -f "./client/src/firebase.js" ]; then
  cp "./client/src/firebase.js" "$BACKUP_DIR/client/src/"
fi

if [ -f "./firestore.rules" ]; then
  cp "./firestore.rules" "$BACKUP_DIR/"
fi

print_success "💾 Sauvegarde des fichiers originaux effectuée"

# Appliquer les correctifs
print_message "🔄 Application des correctifs pour sécuriser Firebase et réactiver l'authentification..."

# 1. Mettre à jour le fichier AuthContext.js pour réactiver l'authentification
cat > "./client/src/context/AuthContext.js" << 'EOL'
import React, { createContext, useState, useContext, useEffect } from 'react';
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'firebase/auth';
import { app } from '../firebase';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

// Configuration pour le mode bypass d'authentification
const BYPASS_AUTH = false; // Mettre à false pour activer l'authentification réelle
const TEST_USER = {
  id: 'test-user-id',
  email: 'test@example.com',
  name: 'Utilisateur Test',
  role: 'admin'
};

export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(BYPASS_AUTH ? TEST_USER : null);
  const [isAuthenticated, setIsAuthenticated] = useState(BYPASS_AUTH);
  const [loading, setLoading] = useState(!BYPASS_AUTH);
  const [error, setError] = useState(null);
  const auth = getAuth(app);

  useEffect(() => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Authentification simulée');
      return;
    }

    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        // Utilisateur connecté
        setCurrentUser({
          id: user.uid,
          email: user.email,
          name: user.displayName || user.email.split('@')[0],
          role: 'admin' // Par défaut, tous les utilisateurs sont admin pour l'instant
        });
        setIsAuthenticated(true);
      } else {
        // Utilisateur déconnecté
        setCurrentUser(null);
        setIsAuthenticated(false);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, [auth]);

  const login = async (email, password) => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Login simulé');
      setCurrentUser(TEST_USER);
      setIsAuthenticated(true);
      setError(null);
      return true;
    }

    try {
      setLoading(true);
      await signInWithEmailAndPassword(auth, email, password);
      setError(null);
      return true;
    } catch (error) {
      console.error('Erreur de connexion:', error);
      setError(error.message);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const logout = async () => {
    if (BYPASS_AUTH) {
      console.log('Mode bypass d\'authentification activé - Logout ignoré');
      return;
    }

    try {
      await signOut(auth);
    } catch (error) {
      console.error('Erreur lors de la déconnexion:', error);
    }
  };

  return (
    <React.Fragment>
      <AuthContext.Provider value={{ 
        currentUser, 
        isAuthenticated, 
        loading, 
        error, 
        login, 
        logout,
        bypassEnabled: BYPASS_AUTH
      }}>
        {children}
      </AuthContext.Provider>
    </React.Fragment>
  );
};
EOL

# 2. Mettre à jour le fichier firebase.js pour exporter l'instance d'authentification
cat > "./client/src/firebase.js" << 'EOL'
// client/src/firebase.js
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCt994en0glR_WVbxxkDATXM25QV7HKovA",
  authDomain: "app-booking-26571.firebaseapp.com",
  projectId: "app-booking-26571",
  storageBucket: "app-booking-26571.firebasestorage.app",
  messagingSenderId: "985724562753",
  appId: "1:985724562753:web:83a093ebd7a7034a9a85c0",
  measurementId: "G-LC94BW3MWX"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);

export { app, db, auth };
EOL

# 3. Créer les règles de sécurité Firestore
cat > "./firestore.rules" << 'EOL'
// Règles de sécurité Firestore pour l'application App Booking
// Ces règles limitent l'accès aux utilisateurs authentifiés uniquement
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règle par défaut : refuser l'accès à tous
    match /{document=**} {
      allow read, write: if false;
    }
    
    // Règles pour la collection artists
    match /artists/{artistId} {
      // Permettre la lecture à tous les utilisateurs authentifiés
      allow read: if request.auth != null;
      
      // Permettre l'écriture (création, mise à jour, suppression) aux utilisateurs authentifiés
      allow write: if request.auth != null;
    }
    
    // Règles pour la collection concerts
    match /concerts/{concertId} {
      // Permettre la lecture à tous les utilisateurs authentifiés
      allow read: if request.auth != null;
      
      // Permettre l'écriture aux utilisateurs authentifiés
      allow write: if request.auth != null;
    }
    
    // Règles pour la collection programmers
    match /programmers/{programmerId} {
      // Permettre la lecture à tous les utilisateurs authentifiés
      allow read: if request.auth != null;
      
      // Permettre l'écriture aux utilisateurs authentifiés
      allow write: if request.auth != null;
    }
    
    // Règles pour les autres collections (à adapter selon les besoins)
    match /users/{userId} {
      // Permettre à un utilisateur de lire et modifier uniquement ses propres données
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
EOL

print_success "✅ Correctifs appliqués avec succès"

# Résumé des modifications
print_message "🚀 Terminé! Les correctifs ont été appliqués pour sécuriser Firebase et réactiver l'authentification."
print_message "📝 Les fichiers originaux ont été sauvegardés dans: $BACKUP_DIR"

cat << 'EOL'
Les modifications apportées:

1. Réactivation de l'authentification Firebase:
   - Désactivation du mode bypass d'authentification (BYPASS_AUTH = false)
   - Mise à jour du contexte d'authentification pour utiliser les API Firebase Auth
   - Implémentation des fonctions de connexion et déconnexion avec Firebase

2. Sécurisation de Firebase:
   - Création de règles de sécurité Firestore qui limitent l'accès aux utilisateurs authentifiés
   - Mise à jour du fichier firebase.js pour exporter l'instance d'authentification

Pour déployer ces modifications sur Firebase:
1. Installez Firebase CLI si ce n'est pas déjà fait:
   npm install -g firebase-tools

2. Connectez-vous à Firebase:
   firebase login

3. Déployez les règles de sécurité:
   firebase deploy --only firestore:rules

Pour tester l'authentification:
1. Créez un utilisateur dans la console Firebase (Authentication > Users > Add User)
2. Utilisez ces identifiants pour vous connecter à l'application

Utilisateurs de test recommandés:
- Email: admin@example.com
- Mot de passe: password123

Si vous rencontrez des problèmes, consultez les logs de la console du navigateur
pour obtenir des informations de débogage détaillées.
EOL

exit 0
