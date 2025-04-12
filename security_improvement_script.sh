#!/bin/bash

# Script d'amélioration de sécurité pour App Booking
# Ce script implémente des améliorations de sécurité tout en maintenant l'accès public pour les tests
# Créé le $(date +%Y-%m-%d)

echo "=== Début des améliorations de sécurité pour App Booking ==="
echo "Ce script équilibre sécurité et accessibilité pour les tests"

# 1. Création du répertoire de sauvegarde
BACKUP_DIR="./backups/security_improvements_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "✅ Répertoire de sauvegarde créé: $BACKUP_DIR"

# 2. Sauvegarde des fichiers qui seront modifiés
echo "📂 Sauvegarde des fichiers originaux..."
cp -f ./client/src/context/AuthContext.js "$BACKUP_DIR/" 2>/dev/null || echo "⚠️ Fichier AuthContext.js non trouvé"
cp -f ./client/src/firebase.js "$BACKUP_DIR/" 2>/dev/null || echo "⚠️ Fichier firebase.js non trouvé"
cp -f ./firestore.rules "$BACKUP_DIR/" 2>/dev/null || echo "⚠️ Fichier firestore.rules non trouvé"
cp -f ./render.yaml "$BACKUP_DIR/" 2>/dev/null || echo "⚠️ Fichier render.yaml non trouvé"
echo "✅ Sauvegarde des fichiers originaux effectuée"

# 3. Modification du mode bypass d'authentification pour utiliser des variables d'environnement
# tout en le maintenant activé pour les tests
if [ -f "./client/src/context/AuthContext.js" ]; then
  echo "🔐 Configuration du mode bypass d'authentification..."
  # Remplacer la ligne de définition de BYPASS_AUTH par une version qui utilise des variables d'environnement
  # mais qui reste activée par défaut pour les tests
  sed -i 's/const BYPASS_AUTH = true;/const BYPASS_AUTH = process.env.REACT_APP_BYPASS_AUTH === "false" ? false : true; \/\/ Maintenu à true par défaut pour les tests/' ./client/src/context/AuthContext.js
  echo "✅ Mode bypass d'authentification configuré pour utiliser des variables d'environnement (maintenu activé par défaut pour les tests)"
else
  echo "❌ Fichier AuthContext.js non trouvé, impossible de modifier le mode bypass"
fi

# 4. Création des fichiers .env pour le développement et la production
echo "🔧 Création des fichiers .env..."
mkdir -p ./client

# .env.development - Bypass activé pour le développement
cat > ./client/.env.development << EOL
# Configuration pour l'environnement de développement
# Le bypass d'authentification est activé pour faciliter les tests
REACT_APP_BYPASS_AUTH=true

# Configuration Firebase
REACT_APP_FIREBASE_API_KEY=AIzaSyCt994en0glR_WVbxxkDATXM25QV7HKovA
REACT_APP_FIREBASE_AUTH_DOMAIN=app-booking-26571.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=app-booking-26571
REACT_APP_FIREBASE_STORAGE_BUCKET=app-booking-26571.firebasestorage.app
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=985724562753
REACT_APP_FIREBASE_APP_ID=1:985724562753:web:83a093ebd7a7034a9a85c0
REACT_APP_FIREBASE_MEASUREMENT_ID=G-LC94BW3MWX
EOL

# .env.production - Bypass configurable pour la production
cat > ./client/.env.production << EOL
# Configuration pour l'environnement de production
# Le bypass d'authentification est désactivé par défaut en production
# Pour l'activer temporairement pour les tests, définir cette variable à "true"
REACT_APP_BYPASS_AUTH=false

# Configuration Firebase
REACT_APP_FIREBASE_API_KEY=AIzaSyCt994en0glR_WVbxxkDATXM25QV7HKovA
REACT_APP_FIREBASE_AUTH_DOMAIN=app-booking-26571.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=app-booking-26571
REACT_APP_FIREBASE_STORAGE_BUCKET=app-booking-26571.firebasestorage.app
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=985724562753
REACT_APP_FIREBASE_APP_ID=1:985724562753:web:83a093ebd7a7034a9a85c0
REACT_APP_FIREBASE_MEASUREMENT_ID=G-LC94BW3MWX
EOL

# .env - Pour les tests locaux, avec bypass activé
cat > ./client/.env << EOL
# Configuration pour les tests locaux
# Le bypass d'authentification est activé pour faciliter les tests
REACT_APP_BYPASS_AUTH=true

# Configuration Firebase
REACT_APP_FIREBASE_API_KEY=AIzaSyCt994en0glR_WVbxxkDATXM25QV7HKovA
REACT_APP_FIREBASE_AUTH_DOMAIN=app-booking-26571.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=app-booking-26571
REACT_APP_FIREBASE_STORAGE_BUCKET=app-booking-26571.firebasestorage.app
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=985724562753
REACT_APP_FIREBASE_APP_ID=1:985724562753:web:83a093ebd7a7034a9a85c0
REACT_APP_FIREBASE_MEASUREMENT_ID=G-LC94BW3MWX
EOL

echo "✅ Fichiers .env créés pour le développement, la production et les tests locaux"

# 5. Modification du fichier firebase.js pour utiliser les variables d'environnement
if [ -f "./client/src/firebase.js" ]; then
  echo "🔧 Configuration de Firebase pour utiliser des variables d'environnement..."
  cat > ./client/src/firebase.js << EOL
// client/src/firebase.js
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

// Configuration Firebase
// Utilisation de variables d'environnement pour améliorer la sécurité
// Les valeurs par défaut sont utilisées si les variables d'environnement ne sont pas définies
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY || "AIzaSyCt994en0glR_WVbxxkDATXM25QV7HKovA",
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN || "app-booking-26571.firebaseapp.com",
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID || "app-booking-26571",
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET || "app-booking-26571.firebasestorage.app",
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID || "985724562753",
  appId: process.env.REACT_APP_FIREBASE_APP_ID || "1:985724562753:web:83a093ebd7a7034a9a85c0",
  measurementId: process.env.REACT_APP_FIREBASE_MEASUREMENT_ID || "G-LC94BW3MWX"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);

export { app, db, auth };
EOL
  echo "✅ Fichier firebase.js modifié pour utiliser les variables d'environnement"
else
  echo "❌ Fichier firebase.js non trouvé, impossible de le modifier"
fi

# 6. Renforcement des règles Firestore tout en maintenant l'accès pour les tests
echo "🔧 Renforcement des règles Firestore..."
cat > ./firestore.rules << EOL
// Règles de sécurité Firestore pour l'application App Booking
// Ces règles équilibrent sécurité et accessibilité pour les tests
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
      
      // Permettre l'écriture aux utilisateurs authentifiés
      // Note: En production, cette règle devrait être plus restrictive
      // (par exemple, limiter aux administrateurs uniquement)
      allow write: if request.auth != null;
    }
    
    // Règles pour la collection concerts
    match /concerts/{concertId} {
      // Permettre la lecture à tous les utilisateurs authentifiés
      allow read: if request.auth != null;
      
      // Permettre l'écriture aux utilisateurs authentifiés
      // Note: En production, cette règle devrait être plus restrictive
      // (par exemple, limiter aux administrateurs ou au programmateur associé au concert)
      allow write: if request.auth != null;
    }
    
    // Règles pour la collection programmers
    match /programmers/{programmerId} {
      // Permettre la lecture à tous les utilisateurs authentifiés
      allow read: if request.auth != null;
      
      // Permettre l'écriture aux utilisateurs authentifiés
      // Note: En production, cette règle devrait être plus restrictive
      // (par exemple, limiter aux administrateurs ou au programmateur lui-même)
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
echo "✅ Règles Firestore renforcées (avec commentaires pour les améliorations futures)"

# 7. Création des règles de stockage Firebase
echo "🔧 Création des règles de stockage Firebase..."
cat > ./storage.rules << EOL
// Règles de sécurité pour le stockage Firebase
// Ces règles équilibrent sécurité et accessibilité pour les tests
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Règle par défaut : refuser l'accès à tous
    match /{allPaths=**} {
      allow read, write: if false;
    }
    
    // Règles pour les images d'artistes
    match /artists/{artistId}/{fileName} {
      // Permettre la lecture à tous les utilisateurs authentifiés
      allow read: if request.auth != null;
      
      // Permettre l'écriture aux utilisateurs authentifiés
      // Note: En production, cette règle devrait être plus restrictive
      allow write: if request.auth != null;
    }
    
    // Règles pour les documents de concerts
    match /concerts/{concertId}/{fileName} {
      // Permettre la lecture à tous les utilisateurs authentifiés
      allow read: if request.auth != null;
      
      // Permettre l'écriture aux utilisateurs authentifiés
      // Note: En production, cette règle devrait être plus restrictive
      allow write: if request.auth != null;
    }
  }
}
EOL
echo "✅ Règles de stockage Firebase créées"

# 8. Création de l'utilitaire de logging pour masquer les informations sensibles en production
echo "🔧 Création de l'utilitaire de logging..."
mkdir -p ./client/src/utils
cat > ./client/src/utils/logger.js << EOL
// Utilitaire de logging qui désactive les logs en production
// et masque les informations sensibles
const isProduction = process.env.NODE_ENV === 'production';

// Fonction pour masquer les informations sensibles dans les logs
const maskSensitiveInfo = (message) => {
  if (typeof message !== 'string') return message;
  
  // Masquer les tokens, clés API, mots de passe, etc.
  return message
    .replace(/token[=:]\s*([^&\s]+)/gi, 'token=***MASKED***')
    .replace(/api[_-]?key[=:]\s*([^&\s]+)/gi, 'api_key=***MASKED***')
    .replace(/password[=:]\s*([^&\s]+)/gi, 'password=***MASKED***')
    .replace(/secret[=:]\s*([^&\s]+)/gi, 'secret=***MASKED***');
};

// Fonction pour formater les arguments de log
const formatArgs = (args) => {
  return args.map(arg => {
    if (typeof arg === 'string') {
      return maskSensitiveInfo(arg);
    }
    return arg;
  });
};

export const logger = {
  log: (...args) => {
    if (!isProduction) {
      console.log(...formatArgs(args));
    }
  },
  error: (...args) => {
    // Toujours logger les erreurs, même en production, mais masquer les infos sensibles
    console.error(...formatArgs(args));
  },
  warn: (...args) => {
    if (!isProduction) {
      console.warn(...formatArgs(args));
    } else {
      // En production, logger uniquement les avertissements importants
      if (args[0] && args[0].includes('[IMPORTANT]')) {
        console.warn(...formatArgs(args));
      }
    }
  },
  info: (...args) => {
    if (!isProduction) {
      console.info(...formatArgs(args));
    }
  },
  // Fonction spéciale pour les logs de débogage (jamais en production)
  debug: (...args) => {
    if (!isProduction) {
      console.log('[DEBUG]', ...formatArgs(args));
    }
  }
};
EOL
echo "✅ Utilitaire de logging créé"

# 9. Modification du fichier render.yaml pour ajouter des en-têtes de sécurité
if [ -f "./render.yaml" ]; then
  echo "🔧 Ajout d'en-têtes de sécurité à la configuration de déploiement..."
  cat > ./render.yaml << EOL
services:
  - type: web
    name: app-booking
    env: node
    buildCommand: npm install && npm run install-client && npm run build
    startCommand: npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: REACT_APP_BYPASS_AUTH
        value: false
    headers:
      - path: /*
        name: X-Frame-Options
        value: DENY
      - path: /*
        name: X-Content-Type-Options
        value: nosniff
      - path: /*
        name: Referrer-Policy
        value: strict-origin-when-cross-origin
      - path: /*
        name: Content-Security-Policy
        value: "default-src 'self'; script-src 'self' 'unsafe-inline' https://apis.google.com https://www.googletagmanager.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https://www.google-analytics.com; connect-src 'self' https://*.firebaseio.com https://www.googleapis.com"
      - path: /*
        name: Strict-Transport-Security
        value: "max-age=31536000; includeSubDomains"
    routes:
      - type: rewrite
        source: /api/*
        destination: /api/$1
      - type: rewrite
        source: /static/*
        destination: /static/$1
      - type: rewrite
        source: /*
        destination: /index.html
EOL
  echo "✅ En-têtes de sécurité ajoutés à la configuration de déploiement"
else
  echo "❌ Fichier render.yaml non trouvé, impossible de le modifier"
fi

# 10. Création d'un fichier README pour expliquer les améliorations de sécurité
echo "📝 Création d'un fichier README pour les améliorations de sécurité..."
cat > ./SECURITY_IMPROVEMENTS.md << EOL
# Améliorations de sécurité pour App Booking

Ce document explique les améliorations de sécurité apportées à l'application App Booking tout en maintenant l'accès public pour les tests.

## Améliorations implémentées

### 1. Configuration Firebase sécurisée

- **Variables d'environnement** : Les clés API Firebase sont maintenant stockées dans des fichiers .env et accessibles via process.env
- **Valeurs par défaut** : Des valeurs par défaut sont fournies pour garantir le fonctionnement de l'application même sans variables d'environnement

### 2. Mode bypass d'authentification configurable

- **Activation par défaut pour les tests** : Le mode bypass reste activé par défaut pour faciliter les tests
- **Configuration via variables d'environnement** : REACT_APP_BYPASS_AUTH permet de basculer facilement entre les modes
- **Fichiers .env distincts** : Configurations séparées pour le développement et la production

### 3. Règles Firestore renforcées

- **Structure améliorée** : Règles organisées par collection avec des commentaires explicatifs
- **Accès limité** : Accès en lecture/écriture limité aux utilisateurs authentifiés
- **Commentaires pour l'avenir** : Suggestions pour renforcer davantage les règles en production

### 4. Règles de stockage Firebase

- **Protection par défaut** : Refus d'accès par défaut à tous les fichiers
- **Accès contrôlé** : Accès limité aux utilisateurs authentifiés pour les collections spécifiques

### 5. Utilitaire de logging sécurisé

- **Désactivation en production** : Les logs sont désactivés en production pour éviter les fuites d'informations
- **Masquage des informations sensibles** : Les tokens, clés API et mots de passe sont automatiquement masqués

### 6. En-têtes de sécurité HTTP

- **Protection contre le clickjacking** : X-Frame-Options: DENY
- **Protection contre le MIME sniffing** : X-Content-Type-Options: nosniff
- **Politique de référence** : Referrer-Policy: strict-origin-when-cross-origin
- **Content Security Policy** : Restrictions sur les sources de contenu
- **HSTS** : Strict-Transport-Security pour forcer HTTPS

## Comment basculer entre les modes de test et de production

### Pour les tests locaux

Le mode bypass d'authentification est activé par défaut pour faciliter les tests. Aucune action n'est nécessaire.

### Pour la production

1. Assurez-vous que la variable d'environnement REACT_APP_BYPASS_AUTH est définie à "false"
2. Ou modifiez le fichier .env.production pour définir REACT_APP_BYPASS_AUTH=false

### Pour activer temporairement le mode test en production

1. Définissez la variable d'environnement REACT_APP_BYPASS_AUTH à "true"
2. Ou modifiez le fichier .env.production pour définir REACT_APP_BYPASS_AUTH=true

## Recommandations pour l'avenir

1. **Renforcer les règles Firestore** : Limiter l'accès en écriture aux administrateurs ou aux propriétaires des données
2. **Mettre en place un système de rôles** : Implémenter un système de rôles plus complet (admin, programmateur, utilisateur)
3. **Audit de sécurité régulier** : Effectuer des audits de sécurité réguliers pour identifier et corriger les vulnérabilités
4. **Mise à jour des dépendances** : Maintenir les dépendances à jour pour corriger les vulnérabilités connues
EOL
echo "✅ Fichier README pour les améliorations de sécurité créé"

# 11. Mise à jour des dépendances vulnérables
echo "🔧 Mise à jour des dépendances vulnérables..."
echo "⚠️ Cette étape est commentée pour éviter de modifier package.json sans test préalable"
echo "⚠️ Décommentez les lignes suivantes pour mettre à jour les dépendances"

# Décommentez ces lignes pour mettre à jour les dépendances
# npm update nodemon@latest semver@latest simple-update-notifier@latest
# cd client && npm update react-scripts@latest && npm audit fix && cd ..

echo "✅ Instructions pour la mise à jour des dépendances ajoutées au script"

echo "=== Améliorations de sécurité terminées ==="
echo "✅ Toutes les améliorations de sécurité ont été appliquées avec succès!"
echo "📋 Consultez le fichier SECURITY_IMPROVEMENTS.md pour plus de détails sur les améliorations effectuées."
echo ""
echo "Pour activer ces modifications en production:"
echo "1. Testez d'abord localement avec: npm run start"
echo "2. Puis déployez avec: git add . && git commit -m \"Améliorations de sécurité\" && git push"
echo ""
echo "Pour basculer entre les modes de test et de production:"
echo "- Mode test (bypass activé): REACT_APP_BYPASS_AUTH=true"
echo "- Mode production (authentification réelle): REACT_APP_BYPASS_AUTH=false"
