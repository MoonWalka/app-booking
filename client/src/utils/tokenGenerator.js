/**
 * Utilitaire pour générer et gérer les tokens communs entre les entités
 * (programmateur, concert, contrat)
 */

/**
 * Génère un token unique basé sur l'ID du concert et un timestamp
 * @param {string} concertId - ID du concert
 * @returns {string} Token unique
 */
export const generateToken = (concertId) => {
  const timestamp = Date.now();
  const randomPart = Math.random().toString(36).substring(2, 8);
  return `${concertId}-${timestamp}-${randomPart}`;
};

/**
 * Extrait l'ID du concert à partir d'un token
 * @param {string} token - Token à analyser
 * @returns {string|null} ID du concert ou null si le format est invalide
 */
export const extractConcertIdFromToken = (token) => {
  if (!token || typeof token !== 'string') return null;
  
  const parts = token.split('-');
  if (parts.length < 3) return null;
  
  return parts[0];
};

/**
 * Vérifie si un token est valide
 * @param {string} token - Token à vérifier
 * @returns {boolean} True si le token est valide, false sinon
 */
export const isValidToken = (token) => {
  if (!token || typeof token !== 'string') return false;
  
  // Format attendu: concertId-timestamp-random
  const parts = token.split('-');
  if (parts.length < 3) return false;
  
  // Vérifier que le timestamp est un nombre
  const timestamp = parseInt(parts[1], 10);
  if (isNaN(timestamp)) return false;
  
  return true;
};

/**
 * Génère un token pour un nouveau formulaire
 * @param {string} concertId - ID du concert
 * @returns {Object} Objet contenant le token et des métadonnées
 */
export const generateFormToken = (concertId) => {
  const token = generateToken(concertId);
  return {
    token,
    concertId,
    createdAt: new Date(),
    type: 'form'
  };
};
