const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ProgrammerSchema = new Schema({
  name: {
    type: String,
    required: [true, 'Le nom est requis'],
    trim: true
  },
  structure: {
    type: String,
    trim: true
  },
  email: {
    type: String,
    required: [true, 'L\'email est requis'],
    trim: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Veuillez fournir un email valide']
  },
  phone: {
    type: String,
    trim: true
  },
  city: {
    type: String,
    required: [true, 'La ville est requise'],
    trim: true
  },
  region: {
    type: String,
    trim: true
  },
  coordinates: {
    lat: { type: Number },
    lng: { type: Number }
  },
  musicStyle: [{
    type: String,
    trim: true
  }],
  notes: {
    type: String
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
ProgrammerSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Middleware pour créer un index géospatial si des coordonnées sont présentes
ProgrammerSchema.pre('save', function(next) {
  if (this.coordinates && this.coordinates.lat && this.coordinates.lng) {
    this.coordinates = {
      lat: this.coordinates.lat,
      lng: this.coordinates.lng
    };
  }
  next();
});

// Méthode pour formater l'objet programmateur
ProgrammerSchema.methods.formatForDisplay = function() {
  return {
    _id: this._id,
    name: this.name,
    structure: this.structure,
    email: this.email,
    phone: this.phone,
    city: this.city,
    region: this.region,
    coordinates: this.coordinates,
    musicStyle: this.musicStyle,
    notes: this.notes,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt
  };
};

module.exports = mongoose.model('Programmer', ProgrammerSchema);
            
