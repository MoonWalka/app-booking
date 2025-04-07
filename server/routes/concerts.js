const express = require('express');
const router = express.Router();

// Données simulées
const concerts = [
  {
    _id: '101',
    artist: {
      _id: '1',
      name: 'The Weeknd'
    },
    date: '2023-06-15',
    time: '20:00',
    venue: 'Stade de France',
    city: 'Paris',
    price: 85,
    status: 'Confirmé',
    notes: 'Concert complet'
  },
  {
    _id: '102',
    artist: {
      _id: '3',
      name: 'Coldplay'
    },
    date: '2023-07-20',
    time: '19:30',
    venue: 'Olympiastadion',
    city: 'Berlin',
    price: 95,
    status: 'En attente',
    notes: 'Négociations en cours'
  }
];

// Obtenir tous les concerts
router.get('/', (req, res) => {
  res.json(concerts);
});

// Obtenir un concert par ID
router.get('/:id', (req, res) => {
  const concert = concerts.find(c => c._id === req.params.id);
  if (!concert) {
    return res.status(404).json({ message: 'Concert non trouvé' });
  }
  res.json(concert);
});

module.exports = router;
