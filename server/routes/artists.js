const express = require('express');
const router = express.Router();

// Données simulées
const artists = [
  {
    _id: '1',
    name: 'The Weeknd',
    genre: 'R&B/Pop',
    origin: 'Canada',
    bio: 'Abel Makkonen Tesfaye, connu sous le nom de The Weeknd, est un auteur-compositeur-interprète canadien.',
    website: 'https://www.theweeknd.com',
    concerts: [
      {
        _id: '101',
        date: '2023-06-15',
        venue: 'Stade de France',
        city: 'Paris'
      }
    ]
  },
  {
    _id: '2',
    name: 'Daft Punk',
    genre: 'Electronic',
    origin: 'France',
    bio: 'Daft Punk était un duo de musique électronique français formé en 1993 à Paris.',
    website: 'https://www.daftpunk.com',
    concerts: []
  }
];

// Obtenir tous les artistes
router.get('/', (req, res)  => {
  res.json(artists);
});

// Obtenir un artiste par ID
router.get('/:id', (req, res) => {
  const artist = artists.find(a => a._id === req.params.id);
  if (!artist) {
    return res.status(404).json({ message: 'Artiste non trouvé' });
  }
  res.json(artist);
});

module.exports = router;
