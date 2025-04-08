# Documentation d'intégration Firebase

Cette documentation explique comment l'application app-booking est intégrée avec Firebase Firestore pour la gestion des données.

## Structure des collections

L'application utilise trois collections principales dans Firebase Firestore :

### Collection `artists`

Stocke les informations sur les artistes.

```javascript
{
  name: "Nom de l'artiste",
  genre: "Genre musical",
  location: "Ville",
  members: 4, // Nombre de membres
  contactEmail: "email@exemple.com",
  contactPhone: "06 12 34 56 78",
  bio: "Biographie de l'artiste",
  imageUrl: "https://exemple.com/image.jpg",
  socialMedia: {
    spotify: "https://open.spotify.com/artist/...",
    instagram: "https://instagram.com/..."
  },
  createdAt: Timestamp, // Date de création
  updatedAt: Timestamp // Date de mise à jour
}
