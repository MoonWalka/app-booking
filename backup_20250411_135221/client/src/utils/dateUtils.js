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
