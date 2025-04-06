require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const connectDB = require('./config/db');
const errorHandler = require('./middleware/errorHandler');

// Connexion à la base de données
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes API
app.use('/api/auth', require('./routes/auth'));
app.use('/api/programmers', require('./routes/programmers'));
app.use('/api/artists', require('./routes/artists'));
app.use('/api/concerts', require('./routes/concerts'));
app.use('/api/emails', require('./routes/emails'));
app.use('/api/documents', require('./routes/documents'));
app.use('/api/dashboard', require('./routes/dashboard'));

// Middleware de gestion des erreurs
app.use(errorHandler);

// Servir les fichiers statiques en production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../client/build')));
  
  app.get('*', (req, res) => {
    res.sendFile(path.resolve(__dirname, '../client/build', 'index.html'));
  });
}

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});
            
