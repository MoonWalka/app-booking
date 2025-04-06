const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const EmailSchema = new Schema({
  sender: {
    type: String,
    required: [true, 'L\'expéditeur est requis'],
    trim: true
  },
  recipient: {
    type: String,
    required: [true, 'Le destinataire est requis'],
    trim: true
  },
  programmerId: {
    type: Schema.Types.ObjectId,
    ref: 'Programmer'
  },
  subject: {
    type: String,
    required: [true, 'L\'objet est requis'],
    trim: true
  },
  body: {
    type: String,
    required: [true, 'Le corps du message est requis']
  },
  sentAt: {
    type: Date,
    default: Date.now
  },
  attachments: [{
    filename: String,
    path: String,
    contentType: String
  }],
  status: {
    type: String,
    enum: ['envoyé', 'livré', 'ouvert', 'échec'],
    default: 'envoyé'
  },
  relatedTo: {
    type: Schema.Types.ObjectId,
    ref: 'Concert'
  }
});

// Index pour les requêtes fréquentes
EmailSchema.index({ programmerId: 1 });
EmailSchema.index({ sentAt: -1 });

// Méthode statique pour trouver les emails par programmateur
EmailSchema.statics.findByProgrammer = function(programmerId) {
  return this.find({ programmerId })
    .sort({ sentAt: -1 });
};

// Méthode pour formater l'objet email
EmailSchema.methods.formatForDisplay = function() {
  return {
    _id: this._id,
    sender: this.sender,
    recipient: this.recipient,
    programmerId: this.programmerId,
    subject: this.subject,
    body: this.body,
    sentAt: this.sentAt,
    attachments: this.attachments,
    status: this.status,
    relatedTo: this.relatedTo
  };
};

module.exports = mongoose.model('Email', EmailSchema);
