# Documentation d'intégration Firebase Automatique

## Introduction

Cette documentation explique comment l'application app-booking crée automatiquement les collections Firebase nécessaires lors de l'utilisation des formulaires d'ajout. Contrairement à une approche où les collections doivent être créées manuellement à l'avance, notre implémentation permet de créer ces collections à la volée lorsque vous ajoutez des données via l'interface utilisateur.

## Principe de fonctionnement

Firebase Firestore crée automatiquement les collections et documents lorsque vous tentez d'y ajouter des données pour la première fois. Notre application exploite cette fonctionnalité pour vous permettre de commencer à utiliser l'application sans configuration préalable de la base de données.

## Fonctionnalités d'ajout implémentées

Nous avons implémenté des formulaires d'ajout complets pour les principales sections de l'application :

### 1. Ajout d'artistes
- Accessible depuis la page "Artistes" via le bouton "Ajouter un artiste"
- Crée automatiquement la collection `artists` dans Firebase
- Collecte toutes les informations nécessaires (nom, genre, localisation, contacts, etc.)

### 2. Ajout de programmateurs
- Accessible depuis la page "Programmateurs" via le bouton "Ajouter un programmateur"
- Crée automatiquement la collection `programmers` dans Firebase
- Collecte toutes les informations nécessaires (nom, structure, email, ville, région, styles musicaux, etc.)

### 3. Ajout de concerts
- Accessible depuis la page "Concerts" via le bouton "Ajouter un concert"
- Crée automatiquement la collection `concerts` dans Firebase
- Établit des relations avec les artistes et programmateurs existants
- Collecte toutes les informations nécessaires (date, heure, lieu, statut, prix, etc.)

## Structure des collections créées

Lorsque vous utilisez les formulaires d'ajout, les collections suivantes sont créées automatiquement dans Firebase :

### Collection `artists`
```javascript
{
  name: "Nom de l'artiste",
  genre: "Genre musical",
  location: "Ville",
  members: 4, // Nombre de membres
  contactEmail: "email@example.com",
  contactPhone: "06 12 34 56 78",
  bio: "Biographie de l'artiste",
  imageUrl: "https://example.com/image.jpg",
  socialMedia: {
    spotify: "https://open.spotify.com/artist/...",
    instagram: "https://instagram.com/..."
  },
  createdAt: Timestamp // Date de création
}

eol
