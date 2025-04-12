// Utilitaire de logging qui désactive les logs en production
// et masque les informations sensibles
const isProduction = process.env.NODE_ENV === 'production';

// Fonction pour masquer les informations sensibles dans les logs
const maskSensitiveInfo = (message) => {
  if (typeof message !== 'string') return message;
  
  // Masquer les tokens, clés API, mots de passe, etc.
  return message
    .replace(/token[=:]\s*([^&\s]+)/gi, 'token=***MASKED***')
    .replace(/api[_-]?key[=:]\s*([^&\s]+)/gi, 'api_key=***MASKED***')
    .replace(/password[=:]\s*([^&\s]+)/gi, 'password=***MASKED***')
    .replace(/secret[=:]\s*([^&\s]+)/gi, 'secret=***MASKED***');
};

// Fonction pour formater les arguments de log
const formatArgs = (args) => {
  return args.map(arg => {
    if (typeof arg === 'string') {
      return maskSensitiveInfo(arg);
    }
    return arg;
  });
};

export const logger = {
  log: (...args) => {
    if (!isProduction) {
      console.log(...formatArgs(args));
    }
  },
  error: (...args) => {
    // Toujours logger les erreurs, même en production, mais masquer les infos sensibles
    console.error(...formatArgs(args));
  },
  warn: (...args) => {
    if (!isProduction) {
      console.warn(...formatArgs(args));
    } else {
      // En production, logger uniquement les avertissements importants
      if (args[0] && args[0].includes('[IMPORTANT]')) {
        console.warn(...formatArgs(args));
      }
    }
  },
  info: (...args) => {
    if (!isProduction) {
      console.info(...formatArgs(args));
    }
  },
  // Fonction spéciale pour les logs de débogage (jamais en production)
  debug: (...args) => {
    if (!isProduction) {
      console.log('[DEBUG]', ...formatArgs(args));
    }
  }
};
