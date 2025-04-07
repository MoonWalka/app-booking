const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

// Route de connexion (simulée)
router.post('/login', (req, res) => {
  const { email, password } = req.body;
  
  // Simuler une vérification d'identifiants
  if (email === 'admin@example.com' && password === 'password') {
    const user = {
      id: 1,
      name: 'Admin User',
      email: 'admin@example.com',
      role: 'admin'
    };
    
    // Créer un token JWT
    const token = jwt.sign(
      { id: user.id, name: user.name, email: user.email, role: user.role },
      'votre_secret_jwt',
      { expiresIn: '1h' }
    );
    
    res.json({ token, user });
  } else {
    res.status(401).json({ message: 'Identifiants invalides' });
  }
});

module.exports = router;
