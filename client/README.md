# App Booking - Client

## Mode de test avec bypass d'authentification

Cette application utilise un mode de bypass d'authentification pour faciliter les tests et le développement. Ce mode permet d'accéder à toutes les fonctionnalités de l'application sans avoir à s'authentifier.

### Configuration

Le mode bypass d'authentification est configuré dans le fichier `.env` à la racine du projet client :

```
REACT_APP_BYPASS_AUTH=true
```

- `true` : Le bypass d'authentification est activé (mode test)
- `false` : Le bypass d'authentification est désactivé (authentification réelle)

### Utilisateur de test

Lorsque le mode bypass est activé, l'application utilise un utilisateur de test avec les informations suivantes :

```javascript
{
  uid: 'test-user-id',
  email: 'test@example.com',
  name: 'Utilisateur Test',
  role: 'admin',
  isAuthenticated: true
}
```

### Désactiver le mode bypass

Pour désactiver le mode bypass et utiliser l'authentification réelle, modifiez la valeur de `REACT_APP_BYPASS_AUTH` dans le fichier `.env` :

```
REACT_APP_BYPASS_AUTH=false
```

Puis reconstruisez l'application :

```
npm run build
```
