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
