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
