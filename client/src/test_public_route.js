// Script de test pour vérifier le fonctionnement des routes publiques
console.log("Test de la route publique /form/:token");

// Simuler une navigation vers une route publique
const testPublicRoute = () => {
  // Vérifier si la route actuelle est une route publique
  const isPublicRoute = (pathname) => {
    return pathname.startsWith('/form/') || pathname === '/form-submitted';
  };

  // Tester avec différentes routes
  const testRoutes = [
    '/form/abc123',
    '/form-submitted',
    '/',
    '/login'
  ];

  testRoutes.forEach(route => {
    console.log(`Route: ${route}, Est une route publique: ${isPublicRoute(route)}`);
  });

  console.log("\nTest de la logique de détection des routes publiques terminé.");
};

testPublicRoute();
