/**
 * Utilitaire pour générer un token unique pour lier les entités (programmateur, concert, contrat)
 */

/**
 * Génère un token unique basé sur l'ID du concert et un timestamp
 * @param {string} concertId - ID du concert
 * @returns {string} Token unique
 */
export const generateToken = (concertId) => {
  // Utiliser l'ID du concert comme base pour garantir la cohérence
  const base = concertId || 'default';
  
  // Ajouter un timestamp pour l'unicité
  const timestamp = Date.now().toString(36);
  
  // Ajouter un élément aléatoire pour éviter les collisions
  const random = Math.random().toString(36).substring(2, 8);
  
  // Combiner les éléments pour créer un token unique
  return `${base}-${timestamp}-${random}`;
};

/**
 * Extrait l'ID du concert à partir d'un token
 * @param {string} token - Token à analyser
 * @returns {string|null} ID du concert ou null si le format est invalide
 */
export const extractConcertIdFromToken = (token) => {
  if (!token || typeof token !== 'string') {
    return null;
  }
  
  // Le format attendu est concertId-timestamp-random
  const parts = token.split('-');
  if (parts.length >= 3) {
    return parts[0];
  }
  
  return null;
};
