import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

// Traductions
const resources = {
  fr: {
    translation: {
      // Navigation principale
      "Dashboard": "Tableau de Bord",
      "Programmers": "Programmateurs",
      "Artists": "Artistes",
      "Concerts": "Concerts",
      "Emails": "Emails",
      "Documents": "Documents",
      "Settings": "Paramètres",
      "Logout": "Déconnexion",
      
      // Statuts des concerts
      "Prospecting": "Prospection",
      "Pending": "En attente",
      "Confirmed": "Confirmé",
      "Contract sent": "Contrat envoyé",
      "Deposit received": "Acompte reçu",
      "Balance paid": "Solde payé",
      
      // Champs des formulaires
      "Name": "Nom",
      "Structure": "Structure",
      "Email": "Email",
      "Phone": "Téléphone",
      "City": "Ville",
      "Region": "Région",
      "Music Style": "Style Musical",
      "Notes": "Notes",
      "Artist": "Artiste",
      "Programmer": "Programmateur",
      "Date": "Date",
      "Venue": "Lieu",
      "Address": "Adresse",
      "Time": "Heure",
      "Price": "Prix",
      "Status": "Statut",
      "Hospitality Needs": "Besoins d'Accueil",
      "Technical Requirements": "Exigences Techniques",
      
      // Boutons et actions
      "Add Programmer": "Ajouter un Programmateur",
      "Edit": "Modifier",
      "Delete": "Supprimer",
      "Search": "Rechercher",
      "Filter": "Filtrer",
      "Clear Filters": "Effacer les Filtres",
      "Save": "Enregistrer",
      "Cancel": "Annuler",
      "Send": "Envoyer",
      "Generate": "Générer",
      "Preview": "Aperçu",
      "Download": "Télécharger",
      
      // Messages
      "Login successful": "Connexion réussie",
      "Invalid credentials": "Identifiants invalides",
      "Please fill all required fields": "Veuillez remplir tous les champs obligatoires",
      "Changes saved successfully": "Modifications enregistrées avec succès",
      "Are you sure you want to delete this item?": "Êtes-vous sûr de vouloir supprimer cet élément ?",
      "Yes, delete": "Oui, supprimer",
      "No, cancel": "Non, annuler",
      "Email sent successfully": "Email envoyé avec succès",
      "Document generated successfully": "Document généré avec succès",
      
      // Et d'autres traductions...
    }
  }
};

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: 'fr',
    interpolation: {
      escapeValue: false
    }
  });

export default i18n;
