// server/models/Programmer.js

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ProgrammerSchema = new Schema({
  name: { 
    type: String, 
    required: [true, 'Le nom est requis'] 
  },
  structure: { 
    type: String 
  },
  email: { 
    type: String, 
    required: [true, 'L\'email est requis'],
    match: [/^\S+@\S+\.\S+$/, 'Veuillez fournir un email valide']
  },
  phone: { 
    type: String 
  },
  city: { 
    type: String, 
    required: [true, 'La ville est requise'] 
  },
  region: { 
    type: String 
  },
  coordinates: {
    lat: { type: Number },
    lng: { type: Number }
  },
  musicStyle: [{ 
    type: String 
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
}, {
  timestamps: true // Cette option met automatiquement à jour createdAt et updatedAt
});

// Middleware pour mettre à jour le champ updatedAt avant chaque modification
ProgrammerSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Méthode virtuelle pour obtenir le nom complet formaté
ProgrammerSchema.virtual('fullName').get(function() {
  return `${this.name}${this.structure ? ` (${this.structure})` : ''}`;
});

// Méthode pour formater les données avant de les envoyer au client
ProgrammerSchema.methods.toJSON = function() {
  const programmerObject = this.toObject();
  return programmerObject;
};

// Méthode statique pour trouver les programmateurs dans un rayon donné
ProgrammerSchema.statics.findByRadius = async function(centerLat, centerLng, radiusKm) {
  // La formule de conversion approximative de degrés en km sur la latitude est:
  // 1 degré = 111 km (approximativement à l'équateur)
  const latDegrees = radiusKm / 111;
  
  // La formule de conversion de degrés en km sur la longitude dépend de la latitude:
  // 1 degré = 111 * cos(latitude) km
  const lngDegrees = radiusKm / (111 * Math.cos(centerLat * Math.PI / 180));

  return this.find({
    'coordinates.lat': { $gte: centerLat - latDegrees, $lte: centerLat + latDegrees },
    'coordinates.lng': { $gte: centerLng - lngDegrees, $lte: centerLng + lngDegrees }
  }).then(programmers => {
    // Filtrage plus précis en calculant la distance exacte
    return programmers.filter(programmer => {
      if (!programmer.coordinates) return false;
      
      const distance = calculateDistance(
        centerLat, 
        centerLng, 
        programmer.coordinates.lat, 
        programmer.coordinates.lng
      );
      
      return distance <= radiusKm;
    });
  });
};

// Fonction helper pour calculer la distance en km entre deux points (formule de Haversine)
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Rayon de la Terre en km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

// Index géospatial pour améliorer les performances des requêtes de recherche par distance
ProgrammerSchema.index({ 'coordinates.lat': 1, 'coordinates.lng': 1 });

module.exports = mongoose.model('Programmer', ProgrammerSchema);

