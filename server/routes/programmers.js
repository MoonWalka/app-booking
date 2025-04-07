const express = require('express');
const router = express.Router();

// Données simulées
const programmers = [
  {
    _id: '1',
    name: 'Jean Dupont',
    venue: 'La Cigale',
    city: 'Paris',
    email: 'jean.dupont@lacigale.fr',
    phone: '+33123456789',
    website: 'https://www.lacigale.fr',
    notes: 'Programmateur principal'
  },
  {
    _id: '2',
    name: 'Marie Martin',
    venue: 'Festival Les Vieilles Charrues',
    city: 'Carhaix',
    email: 'marie.martin@vieillescharrues.fr',
    phone: '+33987654321',
    website: 'https://www.vieillescharrues.fr',
    notes: 'Responsable programmation scène principale'
  }
];

// Obtenir tous les programmateurs
router.get('/', (req, res)  => {
  res.json(programmers);
});

// Obtenir un programmateur par ID
router.get('/:id', (req, res) => {
  const programmer = programmers.find(p => p._id === req.params.id);
  if (!programmer) {
    return res.status(404).json({ message: 'Programmateur non trouvé' });
  }
  res.json(programmer);
});

module.exports = router;
