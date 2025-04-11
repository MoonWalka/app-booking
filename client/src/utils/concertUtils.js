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
