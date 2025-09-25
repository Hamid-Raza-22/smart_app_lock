# SMART APP LOCK

# SMART APP LOCK - Troubleshooting Guide

## Problem 1: Lock Screen Not Showing
### Solutions:
1. **Check Usage Stats Permission:**
   - Go to Settings → Apps → Special Access → Usage Access
   - Enable for SMART APP LOCK

2. **Check Accessibility Service:**
   - Go to Settings → Accessibility
   - Enable SMART APP LOCK Service

3. **Ensure Service is Running:**
   - Check notification bar for "SMART APP LOCK Active"
   - If not, open app and toggle Advanced Mode

## Problem 2: App Not Uninstalling After 3 Failed Attempts
### Solutions:
1. **Check Device Admin:**
   - Go to Settings → Security → Device Administrators
   - Enable SMART APP LOCK

2. **Manual Uninstall:**
   - The app opens uninstall dialog
   - User must confirm uninstall manually

## Problem 3: Service Stops Working
### Solutions:
1. **Battery Optimization:**
   - Settings → Battery → SMART APP LOCK
   - Disable battery optimization

2. **Auto-Start Permission:**
   - Settings → Apps → SMART APP LOCK → Permissions
   - Enable Auto-start

3. **Lock App in Recent Apps:**
   - Open recent apps
   - Lock SMART APP LOCK app (pin icon)

## Testing Steps:
1. Install app
2. Grant all permissions when prompted
3. Set password in Advanced Mode
4. Select apps to lock
5. Close SMART APP LOCK
6. Try opening locked app
7. Enter wrong password 3 times
8. App should prompt for uninstall

## Important Notes:
- Some devices (Xiaomi, Oppo, Vivo) have aggressive battery optimization
- Factory reset requires Device Owner privileges (not available on all devices)
- Uninstall protection works only with Device Admin enabled
  // ============================================
  // ARCHITECTURE FLOW DIAGRAM
  // ============================================
```

┌──────────────────────────────────────────────────────────────────────┐
│                        SMART APP LOCK ARCHITECTURE                   │
│                              MVVM + Clean                            │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │
│  │   HOME VIEW  │  │ PASSWORD VIEW│  │SETTINGS VIEW │                │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                │
│         │                 │                 │                        │
│         ▼                 ▼                 ▼                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │
│  │     HOME     │  │   PASSWORD   │  │   SETTINGS   │                │
│  │  CONTROLLER  │  │ CONTROLLERS  │  │  CONTROLLER  │                │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                │
│         │                 │                 │                        │
│         └─────────────────┴─────────────────┘                        │
│                           │                                          │
│                           ▼                                          │
│                     ┌─────────────┐                                  │
│                     │   BINDINGS  │                                  │
│                     └─────────────┘                                  │
└──────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                                │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │
│  │   APP INFO   │  │   APP MODE   │  │   SECURITY   │                │
│  │    MODEL     │  │     ENUM     │  │   MODELS     │                │
│  └──────────────┘  └──────────────┘  └──────────────┘                │
│                                                                      │
│  ┌─────────────────────────────────────────────────────┐             │
│  │              REPOSITORY INTERFACES                  │             │
│  │  - AppRepository                                    │             │
│  │  - SecurityRepository                               │             │
│  └─────────────────────────────────────────────────────┘             │
└──────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                 │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────┐             │
│  │           REPOSITORY IMPLEMENTATIONS                │             │
│  ├─────────────────────────────────────────────────────┤             │
│  │  ┌──────────────┐        ┌──────────────┐           │             │
│  │  │     APP      │        │   SECURITY   │           │             │
│  │  │  REPOSITORY  │        │  REPOSITORY  │           │             │
│  │  └──────┬───────┘        └──────┬───────┘           │             │
│  │         │                       │                   │             │
│  └─────────┼───────────────────────┼───────────────────┘             │
│            │                       │                                 │
│            ▼                       ▼                                 │
│  ┌─────────────────────────────────────────────────────┐             │
│  │                    SERVICES                         │             │
│  ├─────────────────────────────────────────────────────┤             │
│  │  ┌──────────────┐        ┌──────────────┐           │             │
│  │  │   STORAGE    │        │   SECURITY   │           │             │
│  │  │   SERVICE    │        │   SERVICE    │           │             │
│  │  └──────────────┘        └──────────────┘           │             │
│  └─────────────────────────────────────────────────────┘             │
│                                                                      │
│  ┌─────────────────────────────────────────────────────┐             │
│  │              EXTERNAL DATA SOURCES                  │             │
│  ├─────────────────────────────────────────────────────┤             │
│  │  - SharedPreferences                                │             │
│  │  - Platform Channels (for system features)          │             │
│  │  - Crypto Libraries                                 │             │
│  └─────────────────────────────────────────────────────┘             │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                         CORE/SHARED LAYER                            │
├──────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │
│  │    THEME     │  │  CONSTANTS   │  │    UTILS     │                │
│  └──────────────┘  └──────────────┘  └──────────────┘                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │
│  │   BINDINGS   │  │    ROUTES    │  │  VALIDATORS  │                │
│  └──────────────┘  └──────────────┘  └──────────────┘                │
└──────────────────────────────────────────────────────────────────────┘
```
## DATA FLOW:
═════════
1. User Interaction → View
2. View → Controller (via GetX reactive state)
3. Controller → Repository (business logic)
4. Repository → Service (data operations)
5. Service → External Sources (storage, platform)
6. Response flows back through the same layers

## KEY PRINCIPLES:
══════════════
• Separation of Concerns
• Dependency Injection via GetX
• Reactive State Management
• Clean Architecture Layers
• SOLID Principles
• Testability & Maintainability


### FOLDER STRUCTURE

```
lib/
├── main.dart
└── app/
├── app.dart                    # Main app export file
├── core/
│   ├── core.dart              # Core exports
│   ├── theme/
│   │   └── app_theme.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── storage_keys.dart
│   │   └── api_endpoints.dart
│   ├── bindings/
│   │   └── initial_binding.dart
│   └── utils/
│       ├── validators.dart
│       ├── helpers.dart
│       └── extensions.dart
├── data/
│   ├── data.dart              # Data layer exports
│   ├── models/
│   │   ├── models.dart        # Models exports
│   │   ├── app_info_model.dart
│   │   ├── app_mode.dart
│   │   ├── user_preferences.dart
│   │   └── security_settings.dart
│   ├── repositories/
│   │   ├── repositories.dart  # Repositories exports
│   │   ├── app_repository.dart
│   │   ├── security_repository.dart
│   │   └── settings_repository.dart
│   ├── services/
│   │   ├── services.dart      # Services exports
│   │   ├── storage_service.dart
│   │   ├── security_service.dart
│   │   ├── notification_service.dart
│   │   └── platform_service.dart
│   └── providers/
│       ├── providers.dart      # Providers exports
│       ├── local_data_provider.dart
│       └── remote_data_provider.dart
├── modules/
│   ├── modules.dart           # All modules exports
│   ├── home/
│   │   ├── home.dart          # Home module exports
│   │   ├── bindings/
│   │   │   └── home_binding.dart
│   │   ├── controllers/
│   │   │   └── home_controller.dart
│   │   └── views/
│   │       ├── home_view.dart
│   │       └── widgets/
│   │           ├── widgets.dart
│   │           ├── app_card_widget.dart
│   │           ├── mode_selector_widget.dart
│   │           └── dashboard_stats_widget.dart
│   ├── password/
│   │   ├── password.dart      # Password module exports
│   │   ├── bindings/
│   │   │   └── password_binding.dart
│   │   ├── controllers/
│   │   │   ├── password_setup_controller.dart
│   │   │   └── password_verify_controller.dart
│   │   └── views/
│   │       ├── password_setup_view.dart
│   │       ├── password_verify_view.dart
│   │       └── widgets/
│   │           └── widgets.dart
│   └── settings/
│       ├── settings.dart      # Settings module exports
│       ├── bindings/
│       │   └── settings_binding.dart
│       ├── controllers/
│       │   └── settings_controller.dart
│       └── views/
│           ├── settings_view.dart
│           └── widgets/
│               └── widgets.dart
└── routes/
├── routes.dart            # Routes exports
├── app_pages.dart
└── app_routes.dart
```