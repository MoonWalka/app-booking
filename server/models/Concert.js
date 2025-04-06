const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ConcertSchema = new Schema({
  artist: {
    type: Schema.Types.ObjectId,
    ref: 'Artist',
    required: [true, 'L\'artiste est requis']
  },
  programmer: {
    type: Schema.Types.ObjectId,
    ref: 'Programmer',
    required: [true, 'Le programmateur est requis']
  },
  date: {
    type: Date,
    required: [true, 'La date est requise']
  },
  venue: {
    type: String,
    required: [true, 'Le lieu est requis'],
    trim: true
  },
  address: {
    type: String,
    required: [true, 'L\'adresse est requise'],
    trim: true
  },
  city: {
    type: String,
    required: [true, 'La ville est requise'],
    trim: true
  },
  time: {
    type: String,
    required: [true, 'L\'heure est requise'],
    trim: true
  },
  price: {
    type: Number,
    required: [true, 'Le prix est requis'],
    min: [0, 'Le prix ne peut pas être négatif']
  },
  status: {
    type: String,
    enum: ['prospection', 'en_attente', 'confirme', 'contrat_envoye', 'acompte_recu', 'solde_paye'],
    default: 'prospection'
  },
  hospitalityNeeds: {
    type: String
  },
  technicalRequirements: {
    type: String
  },
  contractId: {
    type: String
  },
  depositInvoiceId: {
    type: String
  },
  balanceInvoiceId: {
    type: String
  },
  notes: {
    type: String
  },
  lastContact: {
    type: Date
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Middleware pour mettre à jour le champ updatedAt avant la sauvegarde
ConcertSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Index pour les requêtes de date
ConcertSchema.index({ date: 1 });
ConcertSchema.index({ status: 1 });

// Méthode pour formater l'objet concert
ConcertSchema.methods.formatPrice = function() {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(this.price);
};

// Méthode statique pour trouver les concerts à venir
ConcertSchema.statics.findUpcoming = function() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  return this.find({
    date: { $gte: today }
  })
  .sort({ date: 1 })
  .populate('artist', 'name')
  .populate('programmer', 'name structure email');
};

// Méthode statique pour trouver les concerts nécessitant un suivi
ConcertSchema.statics.findNeedingFollowup = function() {
  const twoWeeksAgo = new Date();
  twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);
  
  return this.find({
    $or: [
      { status: 'prospection' },
      { status: 'en_attente' }
    ],
    $or: [
      { lastContact: { $lte: twoWeeksAgo } },
      { lastContact: { $exists: false } }
    ]
  })
  .sort({ date: 1 })
  .populate('artist', 'name')
  .populate('programmer', 'name structure email');
};

module.exports = mongoose.model('Concert', ConcertSchema);
            
