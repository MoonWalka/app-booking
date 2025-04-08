#!/bin/bash

# Script pour commit et push des modifications
# Créé le 8 avril 2025

# Vérifier que nous sommes dans le répertoire du projet
if [ ! -d "./client" ] || [ ! -d "./.git" ]; then
  echo "Erreur: Ce script doit être exécuté à la racine du projet app-booking"
  exit 1
fi

# Ajouter les nouveaux fichiers et modifications au staging
git add client/src/components/contracts/ContractsTable.js
git add client/src/components/contracts/ContractsTable.css
git add client/src/services/contractsService.js
git add client/src/components/dashboard/Dashboard.js
git add client/src/components/common/Layout.js
git add client/src/App.js

# Vérifier l'état des fichiers
echo "État des fichiers modifiés:"
git status

# Commit des modifications
echo "Commit des modifications..."
git commit -m "Ajout du module de gestion des contrats et mise à jour du Dashboard"

# Push des modifications vers le dépôt distant
echo "Push des modifications vers le dépôt distant..."
git push origin main

echo "Modifications commitées et pushées avec succès!"
