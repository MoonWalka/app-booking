const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ArtistSchema = new Schema({
  name: {
    type: String,
    required: [true, 'Le nom est requis'],
    trim: true
  },
  genre: [{
    type: String,
    trim: true
  }],
  contactPerson: {
    type: String,
    trim: true
  },
  email: {
    type: String,
    trim: true,
    lowercase: true
  },
  phone: {
    type: String,
    trim: true
  },
  bio: {
    type: String
  },
  technicalRider: {
    type: String
  },
  hospitalityRider: {
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
ArtistSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Méthode pour formater l'objet artiste
ArtistSchema.methods.formatForDisplay = function() {
  return {
    _id: this._id,
    name: this.name,
    genre: this.genre,
    contactPerson: this.contactPerson,
    email: this.email,
    phone: this.phone,
    bio: this.bio,
    technicalRider: this.technicalRider,
    hospitalityRider: this.hospitalityRider,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt
  };
};

module.exports = mongoose.model('Artist', ArtistSchema);
            
