# 🔐 Module d'Authentification - Chantix App

## ✅ Fonctionnalités Implémentées

### 1. Écran de Connexion (`login_screen.dart`)
- ✅ Formulaire de connexion avec email et mot de passe
- ✅ Validation des champs
- ✅ Affichage/masquage du mot de passe
- ✅ Gestion des erreurs avec messages clairs
- ✅ Indicateur de chargement pendant la connexion
- ✅ Lien vers l'inscription

### 2. Écran d'Inscription (`register_screen.dart`)
- ✅ Formulaire d'inscription complet :
  - Nom complet
  - Email
  - Nom de l'entreprise
  - Mot de passe
  - Confirmation du mot de passe
- ✅ Validation des champs (email, longueur du mot de passe, correspondance)
- ✅ Affichage/masquage des mots de passe
- ✅ Gestion des erreurs
- ✅ Indicateur de chargement
- ✅ Lien vers la connexion

### 3. Gestion de l'État (`auth_provider.dart`)
- ✅ Provider pour gérer l'état d'authentification
- ✅ Méthodes : `login()`, `register()`, `logout()`, `loadUser()`
- ✅ Gestion du chargement et des erreurs
- ✅ Notification des changements d'état

### 4. Repository (`auth_repository.dart`)
- ✅ Communication avec l'API
- ✅ Gestion du token
- ✅ Sauvegarde des données utilisateur
- ✅ Gestion des erreurs réseau

### 5. Services
- ✅ **ApiService** : Service HTTP avec Dio
- ✅ **StorageService** : Gestion du stockage local (token, utilisateur, entreprise)

### 6. Modèle de Données
- ✅ **UserModel** : Modèle utilisateur avec sérialisation JSON
- ✅ Fichier généré : `user_model.g.dart`

### 7. Navigation
- ✅ **AuthWrapper** : Redirection automatique selon l'état d'authentification
- ✅ Redirection vers le dashboard si connecté
- ✅ Redirection vers le login si non connecté

### 8. Dashboard Basique
- ✅ Écran de dashboard avec informations utilisateur
- ✅ Menu de déconnexion
- ✅ Affichage du nom et de l'email de l'utilisateur

## 📁 Structure des Fichiers

```
lib/
├── main.dart                          # Point d'entrée avec AuthWrapper
├── config/
│   └── api_config.dart                # Configuration API
├── core/
│   └── constants/
│       └── app_constants.dart         # Constantes de l'application
├── data/
│   ├── models/
│   │   ├── user_model.dart            # Modèle utilisateur
│   │   └── user_model.g.dart         # Fichier généré
│   ├── repositories/
│   │   └── auth_repository.dart       # Repository d'authentification
│   └── services/
│       ├── api_service.dart           # Service HTTP
│       └── storage_service.dart       # Service de stockage local
└── presentation/
    ├── auth/
    │   ├── auth_provider.dart         # Provider d'authentification
    │   ├── login_screen.dart          # Écran de connexion
    │   └── register_screen.dart       # Écran d'inscription
    └── dashboard/
        └── dashboard_screen.dart      # Écran dashboard
```

## 🔧 Configuration Requise

### 1. Configuration de l'API
Modifier `lib/config/api_config.dart` avec l'URL de votre API Laravel :
```dart
static const String baseUrl = 'http://votre-domaine.com/api';
```

### 2. Installation des Dépendances
```bash
flutter pub get
```

### 3. Génération des Fichiers
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🚀 Utilisation

### Connexion
1. L'utilisateur entre son email et mot de passe
2. Le système envoie une requête à l'API `/api/login`
3. Si succès, le token est sauvegardé et l'utilisateur est redirigé vers le dashboard
4. Si erreur, un message d'erreur est affiché

### Inscription
1. L'utilisateur remplit le formulaire d'inscription
2. Le système envoie une requête à l'API `/api/register` avec :
   - name
   - email
   - password
   - password_confirmation
   - company_name
3. Si succès, le compte est créé, le token est sauvegardé et l'utilisateur est redirigé
4. Si erreur, un message d'erreur est affiché

### Déconnexion
1. L'utilisateur clique sur "Déconnexion" dans le menu
2. Le token et les données sont supprimés du stockage local
3. L'utilisateur est redirigé vers l'écran de connexion

## 📝 Notes Importantes

### Format de Réponse API Attendu

**Login Success:**
```json
{
  "token": "xxx",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "is_super_admin": false,
    "is_verified": true,
    "current_company_id": 1
  }
}
```

**Register Success:**
```json
{
  "token": "xxx",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "is_super_admin": false,
    "is_verified": false,
    "current_company_id": 1
  }
}
```

**Error:**
```json
{
  "message": "Les identifiants fournis ne correspondent pas à nos enregistrements."
}
```

## 🔄 Prochaines Étapes

1. ⏳ Configurer Laravel Sanctum pour l'API
2. ⏳ Créer les routes API dans Laravel
3. ⏳ Tester la connexion avec l'API réelle
4. ⏳ Ajouter la gestion des erreurs réseau (timeout, pas de connexion)
5. ⏳ Implémenter la réinitialisation de mot de passe
6. ⏳ Ajouter la validation d'email

---

**Date de création** : Décembre 2024  
**Statut** : ✅ Fonctionnel (nécessite l'API Laravel)

