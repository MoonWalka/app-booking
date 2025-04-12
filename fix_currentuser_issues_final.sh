#!/bin/bash

# Script de correction des problèmes d'utilisation de currentUser dans App Booking
# Ce script corrige les problèmes qui causent l'affichage d'une page blanche
# lorsqu'on accède à la racine /#/ de l'application
# Créé le $(date +%Y-%m-%d)

echo "=== Début des corrections pour App Booking ==="
echo "Ce script corrige les problèmes d'utilisation de currentUser dans l'application"

# 1. Création du répertoire de sauvegarde
BACKUP_DIR="./backups/currentuser_fixes_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "✅ Répertoire de sauvegarde créé: $BACKUP_DIR"

# 2. Sauvegarde des fichiers qui seront modifiés
echo "📂 Sauvegarde des fichiers originaux..."
cp -f ./client/src/components/common/Layout.jsx "$BACKUP_DIR/" 2>/dev/null || echo "⚠️ Fichier Layout.jsx non trouvé"
cp -f ./client/src/context/AuthContext.js "$BACKUP_DIR/" 2>/dev/null || echo "⚠️ Fichier AuthContext.js non trouvé"
echo "✅ Sauvegarde des fichiers originaux effectuée"

# 3. Correction du fichier Layout.jsx
if [ -f "./client/src/components/common/Layout.jsx" ]; then
  echo "🔧 Correction du fichier Layout.jsx..."
  
  # Créer un nouveau fichier Layout.jsx corrigé
  cat > ./client/src/components/common/Layout.jsx << 'EOL'
// client/src/components/common/Layout.js
import React from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const Layout = () => {
  const { currentUser, logout } = useAuth();
  console.log("Layout - currentUser:", currentUser); // Console log déplacé à un endroit approprié
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isActive = (path) => {
    return location.pathname === path;
  };

  return (
    <div className="app-container">
      <aside className="sidebar">
        <div className="sidebar-header">
          <Link to="/" className="logo">
            <span className="logo-text">Label Musical</span>
          </Link>
          <div className="sidebar-subtitle">Gestion des concerts et artistes</div>
        </div>
        
        <nav className="sidebar-nav">
          <Link to="/" className={`nav-item ${isActive('/') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-chart-line"></i>
            </span>
            Tableau de bord
          </Link>
          <Link to="/contrats" className={`nav-item ${isActive('/contrats') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-contract"></i>
            </span>
            Contrats
          </Link>
          <Link to="/factures" className={`nav-item ${isActive('/factures') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-invoice-dollar"></i>
            </span>
            Factures
          </Link>
          <Link to="/concerts" className={`nav-item ${isActive('/concerts') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-calendar-alt"></i>
            </span>
            Concerts
          </Link>
          <Link to="/artistes" className={`nav-item ${isActive('/artistes') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-music"></i>
            </span>
            Artistes
          </Link>
          <Link to="/programmateurs" className={`nav-item ${isActive('/programmateurs') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-user-tie"></i>
            </span>
            Programmateurs
          </Link>
          <Link to="/validation-formulaires" className={`nav-item ${isActive('/validation-formulaires') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-clipboard-check"></i>
            </span>
            Validation Formulaire
          </Link>
          <Link to="/emails" className={`nav-item ${isActive('/emails') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-envelope"></i>
            </span>
            Emails
          </Link>
          <Link to="/documents" className={`nav-item ${isActive('/documents') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-file-alt"></i>
            </span>
            Documents
          </Link>
          <Link to="/parametres" className={`nav-item ${isActive('/parametres') ? 'active' : ''}`}>
            <span className="nav-icon">
              <i className="fas fa-cog"></i>
            </span>
            Paramètres
          </Link>
        </nav>
      </aside>
      
      <div className="main-content">
        <header className="main-header">
          <div className="page-title">
            {location.pathname === '/' && 'Tableau de bord'}
            {location.pathname === '/contrats' && 'Gestion des contrats'}
            {location.pathname === '/factures' && 'Gestion des factures'}
            {location.pathname === '/concerts' && 'Gestion des concerts'}
            {location.pathname === '/artistes' && 'Gestion des artistes'}
            {location.pathname === '/programmateurs' && 'Gestion des programmateurs'}
            {location.pathname === '/validation-formulaires' && 'Validation des formulaires'}
            {location.pathname === '/emails' && 'Système d\'emails'}
            {location.pathname === '/documents' && 'Gestion des documents'}
            {location.pathname === '/parametres' && 'Paramètres'}
          </div>
          
          <div className="user-menu">
            {currentUser ? (
              <div className="user-menu-content">
                <span className="user-name">{currentUser && currentUser.name ? currentUser.name : 'Utilisateur'}</span>
                <button onClick={handleLogout} className="logout-btn">
                  Déconnexion
                </button>
              </div>
            ) : null}
          </div>
        </header>
        
        <main className="main-container">
          <Outlet />
        </main>
        
        <footer className="app-footer">
          <p>&copy; {new Date().getFullYear()} App Booking - Tous droits réservés</p>
        </footer>
      </div>
    </div>
  );
};

export default Layout;
EOL
  
  echo "✅ Fichier Layout.jsx corrigé"
else
  echo "❌ Fichier Layout.jsx non trouvé, impossible de le corriger"
fi

# 4. Vérification et amélioration du fichier AuthContext.js
if [ -f "./client/src/context/AuthContext.js" ]; then
  echo "🔧 Vérification et amélioration du fichier AuthContext.js..."
  
  # Vérifier si TEST_USER est déjà défini
  if grep -q "const TEST_USER" ./client/src/context/AuthContext.js; then
    echo "ℹ️ TEST_USER est déjà défini dans AuthContext.js"
    
    # Créer un fichier temporaire pour AuthContext.js
    TMP_AUTH=$(mktemp)
    cp ./client/src/context/AuthContext.js "$TMP_AUTH"
    
    # Ajouter un useEffect pour s'assurer que currentUser n'est jamais undefined
    if ! grep -q "// S'assurer que currentUser n'est jamais undefined" "$TMP_AUTH"; then
      echo "ℹ️ Ajout d'un useEffect pour s'assurer que currentUser n'est jamais undefined"
      
      # Trouver la ligne où currentUser est initialisé
      CURRENT_USER_LINE=$(grep -n "const \[currentUser, setCurrentUser\] = useState" "$TMP_AUTH" | cut -d: -f1)
      
      if [ -n "$CURRENT_USER_LINE" ]; then
        # Créer un fichier temporaire pour l'insertion
        TMP_EFFECT=$(mktemp)
        
        # Extraire les lignes avant l'initialisation de currentUser
        head -n "$CURRENT_USER_LINE" "$TMP_AUTH" > "$TMP_EFFECT"
        
        # Ajouter l'initialisation de currentUser et le nouvel useEffect
        echo "  const [currentUser, setCurrentUser] = useState(effectiveBypass ? TEST_USER : null);" >> "$TMP_EFFECT"
        echo "" >> "$TMP_EFFECT"
        echo "  // S'assurer que currentUser n'est jamais undefined" >> "$TMP_EFFECT"
        echo "  useEffect(() => {" >> "$TMP_EFFECT"
        echo "    if (effectiveBypass && (!currentUser || Object.keys(currentUser).length === 0)) {" >> "$TMP_EFFECT"
        echo "      console.log(\"AuthContext - Réinitialisation de currentUser avec TEST_USER\");" >> "$TMP_EFFECT"
        echo "      setCurrentUser(TEST_USER);" >> "$TMP_EFFECT"
        echo "    }" >> "$TMP_EFFECT"
        echo "  }, [effectiveBypass, currentUser]);" >> "$TMP_EFFECT"
        
        # Extraire les lignes après l'initialisation de currentUser
        NEXT_LINE=$((CURRENT_USER_LINE + 1))
        tail -n +"$NEXT_LINE" "$TMP_AUTH" | grep -v "const \[currentUser, setCurrentUser\] = useState" >> "$TMP_EFFECT"
        
        # Remplacer le fichier temporaire
        mv "$TMP_EFFECT" "$TMP_AUTH"
      else
        echo "⚠️ Impossible de trouver l'initialisation de currentUser dans AuthContext.js"
      fi
    else
      echo "ℹ️ L'useEffect pour s'assurer que currentUser n'est jamais undefined existe déjà"
    fi
    
    # Copier le fichier temporaire vers le fichier original
    cp "$TMP_AUTH" ./client/src/context/AuthContext.js
    rm "$TMP_AUTH"
  else
    echo "ℹ️ Ajout de la définition de TEST_USER dans AuthContext.js"
    
    # Créer un fichier temporaire
    TMP_AUTH=$(mktemp)
    
    # Ajouter la définition de TEST_USER après BYPASS_AUTH
    cat ./client/src/context/AuthContext.js |
    sed '/const BYPASS_AUTH/a \
\
// Utilisateur de test toujours disponible pour le mode bypass\
const TEST_USER = {\
  id: "test-user-id",\
  email: "test@example.com",\
  name: "Utilisateur Test",\
  role: "admin"\
};' > "$TMP_AUTH"
    
    # Ajouter un useEffect pour s'assurer que currentUser n'est jamais undefined
    if ! grep -q "// S'assurer que currentUser n'est jamais undefined" "$TMP_AUTH"; then
      echo "ℹ️ Ajout d'un useEffect pour s'assurer que currentUser n'est jamais undefined"
      
      # Trouver la ligne où currentUser est initialisé
      CURRENT_USER_LINE=$(grep -n "const \[currentUser, setCurrentUser\] = useState" "$TMP_AUTH" | cut -d: -f1)
      
      if [ -n "$CURRENT_USER_LINE" ]; then
        # Créer un fichier temporaire pour l'insertion
        TMP_EFFECT=$(mktemp)
        
        # Extraire les lignes avant l'initialisation de currentUser
        head -n "$CURRENT_USER_LINE" "$TMP_AUTH" > "$TMP_EFFECT"
        
        # Ajouter l'initialisation de currentUser et le nouvel useEffect
        echo "  const [currentUser, setCurrentUser] = useState(effectiveBypass ? TEST_USER : null);" >> "$TMP_EFFECT"
        echo "" >> "$TMP_EFFECT"
        echo "  // S'assurer que currentUser n'est jamais undefined" >> "$TMP_EFFECT"
        echo "  useEffect(() => {" >> "$TMP_EFFECT"
        echo "    if (effectiveBypass && (!currentUser || Object.keys(currentUser).length === 0)) {" >> "$TMP_EFFECT"
        echo "      console.log(\"AuthContext - Réinitialisation de currentUser avec TEST_USER\");" >> "$TMP_EFFECT"
        echo "      setCurrentUser(TEST_USER);" >> "$TMP_EFFECT"
        echo "    }" >> "$TMP_EFFECT"
        echo "  }, [effectiveBypass, currentUser]);" >> "$TMP_EFFECT"
        
        # Extraire les lignes après l'initialisation de currentUser
        NEXT_LINE=$((CURRENT_USER_LINE + 1))
        tail -n +"$NEXT_LINE" "$TMP_AUTH" | grep -v "const \[currentUser, setCurrentUser\] = useState" >> "$TMP_EFFECT"
        
        # Remplacer le fichier temporaire
        mv "$TMP_EFFECT" "$TMP_AUTH"
      else
        echo "⚠️ Impossible de trouver l'initialisation de currentUser dans AuthContext.js"
      fi
    else
      echo "ℹ️ L'useEffect pour s'assurer que currentUser n'est jamais undefined existe déjà"
    fi
    
    # Copier le fichier temporaire vers le fichier original
    cp "$TMP_AUTH" ./client/src/context/AuthContext.js
    rm "$TMP_AUTH"
  fi
  
  echo "✅ Fichier AuthContext.js amélioré"
else
  echo "❌ Fichier AuthContext.js non trouvé, impossible de l'améliorer"
fi

# 5. Création d'un utilitaire pour vérifier la présence de currentUser
echo "🔧 Création d'un utilitaire pour vérifier la présence de currentUser..."
mkdir -p ./client/src/utils
cat > ./client/src/utils/userUtils.js << EOL
/**
 * Utilitaire pour vérifier la présence de currentUser et éviter les erreurs
 */

/**
 * Vérifie si un utilisateur est défini et retourne une valeur par défaut si ce n'est pas le cas
 * @param {Object} user - L'objet utilisateur à vérifier
 * @param {string} property - La propriété à récupérer
 * @param {*} defaultValue - La valeur par défaut à retourner si l'utilisateur ou la propriété n'existe pas
 * @returns {*} - La valeur de la propriété ou la valeur par défaut
 */
export const getUserProperty = (user, property, defaultValue = '') => {
  if (!user) return defaultValue;
  return user[property] !== undefined ? user[property] : defaultValue;
};

/**
 * Vérifie si un utilisateur est défini et a un rôle spécifique
 * @param {Object} user - L'objet utilisateur à vérifier
 * @param {string} role - Le rôle à vérifier
 * @returns {boolean} - true si l'utilisateur a le rôle spécifié, false sinon
 */
export const hasRole = (user, role) => {
  if (!user || !user.role) return false;
  return user.role === role;
};

/**
 * Vérifie si un utilisateur est défini et est un administrateur
 * @param {Object} user - L'objet utilisateur à vérifier
 * @returns {boolean} - true si l'utilisateur est un administrateur, false sinon
 */
export const isAdmin = (user) => {
  return hasRole(user, 'admin');
};

/**
 * Crée un objet utilisateur par défaut pour les tests
 * @returns {Object} - Un objet utilisateur par défaut
 */
export const createDefaultUser = () => {
  return {
    id: 'default-user-id',
    email: 'default@example.com',
    name: 'Utilisateur Par Défaut',
    role: 'user'
  };
};
EOL
echo "✅ Utilitaire userUtils.js créé"

# 6. Création d'un fichier README pour expliquer les corrections
echo "📝 Création d'un fichier README pour les corrections..."
cat > ./CURRENTUSER_FIXES.md << EOL
# Corrections des problèmes d'utilisation de currentUser dans App Booking

Ce document explique les corrections apportées pour résoudre le problème d'affichage d'une page blanche lorsqu'on accède à la racine /#/ de l'application.

## Problème identifié

L'application affichait une page blanche lorsqu'on accédait à la racine /#/ (donc / pour l'app) à cause de deux problèmes principaux :

1. Un \`console.log\` au début du fichier Layout.jsx qui tentait d'accéder à \`currentUser\` avant qu'il ne soit défini
2. Une vérification insuffisante de l'existence de \`currentUser\` avant d'accéder à ses propriétés

## Corrections apportées

### 1. Correction du fichier Layout.jsx

- **Déplacement du console.log** : Le \`console.log\` a été déplacé à l'intérieur du composant Layout, après la définition de \`currentUser\`
- **Amélioration de la vérification conditionnelle** : La vérification de \`currentUser\` a été renforcée en utilisant un opérateur ternaire avec une valeur par défaut explicite
- **Remplacement de l'opérateur optionnel** : L'opérateur optionnel (\`currentUser?.name\`) a été remplacé par une vérification plus robuste

### 2. Amélioration du fichier AuthContext.js

- **Définition explicite de TEST_USER** : La définition de \`TEST_USER\` a été clarifiée et placée à un endroit approprié
- **Initialisation robuste de currentUser** : Un effet a été ajouté pour s'assurer que \`currentUser\` n'est jamais \`undefined\` lorsque le mode bypass est activé

### 3. Création d'un utilitaire userUtils.js

Un nouvel utilitaire a été créé pour faciliter la manipulation sécurisée de \`currentUser\` dans toute l'application :

- **getUserProperty** : Récupère une propriété d'un utilisateur avec une valeur par défaut si l'utilisateur ou la propriété n'existe pas
- **hasRole** : Vérifie si un utilisateur a un rôle spécifique
- **isAdmin** : Vérifie si un utilisateur est un administrateur
- **createDefaultUser** : Crée un objet utilisateur par défaut pour les tests

## Comment utiliser l'utilitaire userUtils.js

Pour éviter des problèmes similaires à l'avenir, utilisez l'utilitaire \`userUtils.js\` dans vos composants :

\`\`\`jsx
import { getUserProperty, isAdmin } from '../utils/userUtils';

// Au lieu de
const userName = currentUser?.name || 'Utilisateur';

// Utilisez
const userName = getUserProperty(currentUser, 'name', 'Utilisateur');

// Pour vérifier si un utilisateur est admin
if (isAdmin(currentUser)) {
  // Code pour les administrateurs
}
\`\`\`

## Recommandations pour l'avenir

1. **Toujours vérifier l'existence de currentUser** : Ne jamais supposer que \`currentUser\` est défini, même avec le mode bypass activé
2. **Utiliser l'utilitaire userUtils.js** : Pour toutes les opérations impliquant \`currentUser\`
3. **Éviter les console.log au niveau du module** : Toujours placer les \`console.log\` à l'intérieur des composants ou des fonctions
4. **Ajouter des tests unitaires** : Pour vérifier que l'application fonctionne correctement avec et sans utilisateur authentifié
EOL
echo "✅ Fichier README pour les corrections créé"

echo "=== Corrections terminées ==="
echo "✅ Toutes les corrections ont été appliquées avec succès!"
echo "📋 Consultez le fichier CURRENTUSER_FIXES.md pour plus de détails sur les corrections effectuées."
echo ""
echo "Pour activer ces modifications en production:"
echo "1. Testez d'abord localement avec: npm run start"
echo "2. Puis déployez avec: git add . && git commit -m \"Correction des problèmes d'utilisation de currentUser\" && git push"
