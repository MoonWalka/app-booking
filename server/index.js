const express = require('express') ;
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// Routes
const authRoutes = require('./routes/auth');
const artistsRoutes = require('./routes/artists');
const concertsRoutes = require('./routes/concerts');
const programmersRoutes = require('./routes/programmers');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/artists', artistsRoutes);
app.use('/api/concerts', concertsRoutes);
app.use('/api/programmers', programmersRoutes);

// Serve static assets in production
if (process.env.NODE_ENV === 'production') {
  // Set static folder
  app.use(express.static('client/build'));

  app.get('*', (req, res) => {
    res.sendFile(path.resolve(__dirname, '../client', 'build', 'index.html'));
  });
}

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
