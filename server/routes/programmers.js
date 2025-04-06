const express = require('express');
const router = express.Router();
const { check, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const Programmer = require('../models/Programmer');
const ContactHistory = require('../models/ContactHistory');
const Email = require('../models/Email');
const Concert = require('../models/Concert');

// @route   GET api/programmers
// @desc    Obtenir tous les programmateurs
// @access  Privé
router.get('/', auth, async (req, res) => {
  try {
    const { city, region, musicStyle } = req.query;
    
    let query = {};
    
    // Filtrage par ville
    if (city) {
      query.city = { $regex: city, $options: 'i' };
    }
    
    // Filtrage par région
    if (region) {
      query.region = { $regex: region, $options: 'i' };
    }
    
    // Filtrage par style musical
    if (musicStyle) {
      query.musicStyle = { $regex: musicStyle, $options: 'i' };
    }
    
    const programmers = await Programmer.find(query).sort({ name: 1 });
    res.json(programmers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Erreur serveur');
  }
});

// @route   GET api/programmers/search/map
// @desc    Rechercher des programmateurs par rayon géographique
// @access  Privé
router.get('/search/map', auth, async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;
    
    if (!lat || !lng || !radius) {
      return res.status(400).json({ msg: 'Latitude, longitude et rayon sont requis' });
    }
    
    // Convertir les paramètres en nombres
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    const searchRadius = parseInt(radius);
    
    // Recherche approximative en utilisant les coordonnées
    // En production, utiliser un vrai index géospatial pour une recherche précise
    const programmers = await Programmer.find({
      'coordinates.lat': { $exists: true },
      'coordinates.lng': { $exists: true }
    });
    
    // Filtrer les programmateurs dans le rayon recherché
    // Distance approximative en utilisant la formule haversine
    const earth_radius = 6371; // Rayon de la Terre en km
    
    const filtered = programmers.filter(programmer => {
      const dLat = (programmer.coordinates.lat - latitude) * Math.PI / 180;
      const dLon = (programmer.coordinates.lng - longitude) * Math.PI / 180;
      const a = 
        Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(latitude * Math.PI / 180) * Math.cos(programmer.coordinates.lat * Math.PI / 180) * 
        Math.sin(dLon/2) * Math.sin(dLon/2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      const distance =
