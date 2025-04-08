#!/bin/bash

# Script pour résoudre le conflit dans firestore.rules
# Créé le 8 avril 2025

echo "Résolution du conflit dans firestore.rules..."

# Vérifier que nous sommes dans le répertoire du projet
if [ ! -d "./.git" ]; then
  echo "Erreur: Ce script doit être exécuté à la racine du projet app-booking"
  exit 1
fi

# Vérifier si le fichier firestore.rules existe
if [ ! -f "./firestore.rules" ]; then
  echo "Erreur: Le fichier firestore.rules n'existe pas"
  exit 1
fi

# Sauvegarde du fichier original
cp ./firestore.rules ./firestore.rules.backup

# Résoudre automatiquement le conflit en acceptant la version locale
git checkout --ours -- firestore.rules

# Ajouter le fichier résolu
git add firestore.rules

echo "Conflit résolu dans firestore.rules"
echo "Vous pouvez maintenant terminer le commit avec les commandes suivantes:"
echo "git commit -m \"Ajout du module de gestion des contrats et mise à jour du Dashboard\""
echo "git push origin main"
