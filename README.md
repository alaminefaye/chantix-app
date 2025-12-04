# 📱 Chantix Mobile App

Application mobile Flutter pour la gestion de chantiers BTP.

## 🎯 Vue d'Ensemble

Cette application mobile permet aux utilisateurs de :
- Se connecter et gérer leurs projets
- Effectuer le pointage (check-in/check-out)
- Mettre à jour l'avancement des travaux
- Gérer les matériaux et employés
- Déclarer des dépenses
- Consulter les rapports
- Communiquer via le chat interne

## 🏗️ Architecture

### Structure du Projet
```
lib/
├── main.dart                 # Point d'entrée
├── config/                   # Configuration
│   ├── api_config.dart      # Configuration API
│   └── theme.dart           # Thème de l'application
├── core/                     # Code réutilisable
│   ├── constants/           # Constantes
│   ├── utils/               # Utilitaires
│   └── widgets/             # Widgets réutilisables
├── data/                     # Couche données
│   ├── models/              # Modèles de données
│   ├── repositories/        # Repositories
│   └── services/            # Services (API, Local Storage)
├── domain/                   # Logique métier
│   ├── entities/            # Entités
│   └── usecases/           # Cas d'usage
└── presentation/             # Interface utilisateur
    ├── auth/                # Module authentification
    ├── dashboard/           # Module dashboard
    ├── projects/            # Module projets
    ├── attendance/          # Module pointage
    ├── progress/            # Module avancement
    ├── materials/           # Module matériaux
    ├── employees/           # Module employés
    ├── expenses/            # Module dépenses
    ├── tasks/               # Module tâches
    ├── comments/            # Module commentaires
    └── reports/             # Module rapports
```

## 📦 Packages Utilisés

### HTTP & API
- `dio` : Client HTTP avancé
- `retrofit` : Client REST pour Dart/Flutter

### Gestion d'État
- `provider` : Gestion d'état simple et efficace

### Stockage Local
- `shared_preferences` : Stockage simple (clé-valeur)
- `sqflite` : Base de données SQLite locale

### UI & Navigation
- `flutter_screenutil` : Responsive design
- `go_router` : Navigation déclarative

### Médias & Fichiers
- `image_picker` : Sélection d'images
- `camera` : Appareil photo
- `file_picker` : Sélection de fichiers
- `cached_network_image` : Images en cache

### Géolocalisation
- `geolocator` : Géolocalisation GPS
- `permission_handler` : Gestion des permissions

### Notifications
- `flutter_local_notifications` : Notifications locales
- `firebase_messaging` : Notifications push (optionnel)

### Autres
- `flutter_sound` : Enregistrement audio
- `video_player` : Lecture vidéo
- `url_launcher` : Ouvrir des URLs
- `flutter_map` : Cartes interactives

## 🚀 Installation

1. Installer les dépendances :
```bash
flutter pub get
```

2. Configurer l'API :
   - Modifier `lib/config/api_config.dart` avec l'URL de votre API Laravel

3. Lancer l'application :
```bash
flutter run
```

## 📋 Modules à Développer

### Phase 1 : Configuration & Authentification ✅
- [x] Création du projet
- [ ] Configuration de l'architecture
- [ ] Module d'authentification
- [ ] Gestion du token
- [ ] Écran de profil

### Phase 2 : Dashboard & Navigation
- [ ] Écran Dashboard
- [ ] Navigation principale
- [ ] Sélection d'entreprise
- [ ] Notifications

### Phase 3 : Projets
- [ ] Liste des projets
- [ ] Détails projet
- [ ] Création/Modification
- [ ] Carte avec géolocalisation

### Phase 4 : Pointage
- [ ] Check-in avec photo et GPS
- [ ] Check-out avec photo et GPS
- [ ] Historique des pointages

### Phase 5 : Avancement
- [ ] Création de mise à jour
- [ ] Upload photos/vidéos
- [ ] Enregistrement audio
- [ ] Galerie de médias

### Phase 6 : Matériaux & Employés
- [ ] Liste des matériaux
- [ ] Gestion des stocks
- [ ] Liste des employés

### Phase 7 : Dépenses & Tâches
- [ ] Déclaration de dépenses
- [ ] Upload de factures
- [ ] Liste des tâches

### Phase 8 : Communication
- [ ] Chat/Commentaires
- [ ] Mentions
- [ ] Pièces jointes

### Phase 9 : Rapports
- [ ] Consultation des rapports
- [ ] Export PDF/Excel

### Phase 10 : Mode Hors Ligne
- [ ] Stockage local
- [ ] Synchronisation automatique

## 🔗 API Backend

L'application communique avec l'API Laravel via :
- **Base URL** : `http://chantix.test/api` (à configurer)
- **Authentification** : Laravel Sanctum (Token-based)

## 📝 Notes

- Le développement se fait module par module
- Chaque module est indépendant et testable
- La synchronisation avec l'API se fait en arrière-plan
- Le mode hors ligne sera implémenté dans la phase finale

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2024
# chantix-app
