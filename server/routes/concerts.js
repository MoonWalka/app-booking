const express = require('express');
const router = express.Router();
const { check, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const Concert = require('../models/Concert');
const Artist = require('../models/Artist');
const Programmer = require('../models/Programmer');
const ContactHistory = require('../models/ContactHistory');

// @route   GET api/concerts
// @desc    Obtenir tous les concerts
// @access  Privé
router.get('/', auth, async (req, res) => {
  try {
    const { status, artist, fromDate, toDate, city } = req.query;
    
    let query = {};
    
    // Filtrage par statut
    if (status) {
      query.status = { $in: status.split(',') };
    }
    
    // Filtrage par artiste
    if (artist) {
      query.artist = artist;
    }
    
    // Filtrage par date
    if (fromDate || toDate) {
      query.date = {};
      if (fromDate) {
        query.date.$gte = new Date(fromDate);
      }
      if (toDate) {
        query.date.$lte = new Date(toDate);
      }
    }
    
    // Filtrage par ville
    if (city) {
      query.city = { $regex: city, $options: 'i' };
    }
    
    const concerts = await Concert.find(query)
      .populate('artist', 'name genre')
      .populate('programmer', 'name structure email')
      .sort({ date: 1 });
    
    res.json(concerts);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Erreur serveur');
  }
});

// @route   GET api/concerts/:id
// @desc    Obtenir un concert par son ID
// @access  Privé
router.get('/:id', auth, async (req, res) => {
  try {
    const concert = await Concert.findById(req.params.id)
      .populate('artist', 'name genre contactPerson email phone bio technicalRider hospitalityRider')
      .populate('programmer', 'name structure email phone city region');
    
    if (!concert) {
      return res.status(404).json({ msg: 'Concert non trouvé' });
    }
    
    // Obtenir l'historique des contacts lié à ce concert
    const contactHistory = await ContactHistory.find({ 
      $or: [
        { programmerId: concert.programmer._id },
        { relatedTo: concert._id }
      ]
    })
    .sort({ date: -1 })
    .populate('user', 'name');
    
    res.json({
      concert,
      contactHistory
    });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Concert non trouvé' });
    }
    res.status(500).send('Erreur serveur');
  }
});

// @route   POST api/concerts
// @desc    Créer un concert
// @access  Privé
router.post('/', [
  auth,
  [
    check('artist', 'L\'artiste est requis').not().isEmpty(),
    check('programmer', 'Le programmateur est requis').not().isEmpty(),
    check('date', 'La date est requise').not().isEmpty(),
    check('venue', 'Le lieu est requis').not().isEmpty(),
    check('address', 'L\'adresse est requise').not().isEmpty(),
    check('city', 'La ville est requise').not().isEmpty(),
    check('time', 'L\'heure est requise').not().isEmpty(),
    check('price', 'Le prix est requis').isNumeric()
  ]
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    // Vérifier si l'artiste existe
    const artist = await Artist.findById(req.body.artist);
    if (!artist) {
      return res.status(404).json({ msg: 'Artiste non trouvé' });
    }

    // Vérifier si le programmateur existe
    const programmer = await Programmer.findById(req.body.programmer);
    if (!programmer) {
      return res.status(404).json({ msg: 'Programmateur non trouvé' });
    }

    const {
      date,
      venue,
      address,
      city,
      time,
      price,
      status,
      hospitalityNeeds,
      technicalRequirements,
      notes
    } = req.body;

    // Créer l'objet concert
    const concertFields = {
      artist: req.body.artist,
      programmer: req.body.programmer,
      date,
      venue,
      address,
      city,
      time,
      price,
      status: status || 'prospection',
      hospitalityNeeds,
      technicalRequirements,
      notes,
      lastContact: new Date()
    };

    const concert = new Concert(concertFields);
    await concert.save();

    // Ajouter une entrée dans l'historique des contacts
    const contactHistory = new ContactHistory({
      programmerId: programmer._id,
      type: 'note',
      content: `Concert créé : ${artist.name} à ${venue} le ${new Date(date).toLocaleDateString('fr-FR')}`,
      user: req.user.id,
      relatedTo: concert._id
    });
    await contactHistory.save();

    res.json(concert);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Erreur serveur');
  }
});

// @route   PUT api/concerts/:id
// @desc    Mettre à jour un concert
// @access  Privé
router.put('/:id', auth, async (req, res) => {
  try {
    let concert = await Concert.findById(req.params.id);
    
    if (!concert) {
      return res.status(404).json({ msg: 'Concert non trouvé' });
    }

    // Extraire les champs à mettre à jour
    const {
      artist,
      programmer,
      date,
      venue,
      address,
      city,
      time,
      price,
      status,
      hospitalityNeeds,
      technicalRequirements,
      notes
    } = req.body;

    // Vérifier si le statut a changé
    const statusChanged = concert.status !== status && status;
    const oldStatus = concert.status;

    // Construire l'objet de mise à jour
    const concertFields = {};
    if (artist) concertFields.artist = artist;
    if (programmer) concertFields.programmer = programmer;
    if (date) concertFields.date = date;
    if (venue) concertFields.venue = venue;
    if (address) concertFields.address = address;
    if (city) concertFields.city = city;
    if (time) concertFields.time = time;
    if (price) concertFields.price = price;
    if (status) concertFields.status = status;
    if (hospitalityNeeds) concertFields.hospitalityNeeds = hospitalityNeeds;
    if (technicalRequirements) concertFields.technicalRequirements = technicalRequirements;
    if (notes) concertFields.notes = notes;
    
    // Mettre à jour le champ lastContact
    concertFields.lastContact = new Date();
    concertFields.updatedAt = new Date();

    // Mettre à jour le concert
    concert = await Concert.findByIdAndUpdate(
      req.params.id,
      { $set: concertFields },
      { new: true }
    ).populate('artist', 'name').populate('programmer', 'name structure');

    // Si le statut a changé, ajouter une entrée dans l'historique des contacts
    if (statusChanged) {
      const statusMap = {
        'prospection': 'Prospection',
        'en_attente': 'En attente',
        'confirme': 'Confirmé',
        'contrat_envoye': 'Contrat envoyé',
        'acompte_recu': 'Acompte reçu',
        'solde_paye': 'Solde payé'
      };

      const contactHistory = new ContactHistory({
        programmerId: concert.programmer._id,
        type: 'note',
        content: `Statut changé de "${statusMap[oldStatus] || oldStatus}" à "${statusMap[status] || status}"`,
        user: req.user.id,
        relatedTo: concert._id
      });
      await contactHistory.save();
    }

    res.json(concert);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Concert non trouvé' });
    }
    res.status(500).send('Erreur serveur');
  }
});

// @route   DELETE api/concerts/:id
// @desc    Supprimer un concert
// @access  Privé
router.delete('/:id', auth, async (req, res) => {
  try {
    const concert = await Concert.findById(req.params.id);
    
    if (!concert) {
      return res.status(404).json({ msg: 'Concert non trouvé' });
    }

    await concert.remove();
    
    // Supprimer les historiques de contact associés
    await ContactHistory.deleteMany({ relatedTo: req.params.id });

    res.json({ msg: 'Concert supprimé' });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Concert non trouvé' });
    }
    res.status(500).send('Erreur serveur');
  }
});

module.exports = router;
            
