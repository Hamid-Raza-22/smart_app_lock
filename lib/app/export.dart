// lib/app/app.dart
// ============================================
// SINGLE COMPREHENSIVE EXPORT FILE
// All app components in one export file
// ============================================
export 'package:get/get.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:crypto/crypto.dart';
export 'package:device_apps/device_apps.dart';
export 'package:app_settings/app_settings.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:installed_apps/installed_apps.dart';
export 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'dart:convert';
export 'dart:typed_data';


// ============================================
// CORE LAYER EXPORTS
// ============================================

// Theme
export 'core/theme/app_theme.dart';

// Constants
export 'core/constants/app_constants.dart';
export 'core/constants/storage_keys.dart';
export 'core/constants/api_endpoints.dart';

// Bindings
export 'core/bindings/initial_binding.dart';

// Utils
export 'core/utils/validators.dart';
export 'core/utils/helpers.dart';
export 'core/utils/extensions.dart';

// ============================================
// DATA LAYER EXPORTS
// ============================================

// Models
export 'data/models/app_info_model.dart';
export 'data/models/app_mode.dart';
export 'data/models/user_preferences.dart';
export 'data/models/security_settings.dart';

// Repositories
export 'data/repositories/app_repository.dart';
export 'data/repositories/security_repository.dart';
export 'data/repositories/settings_repository.dart';

// Services
export 'data/services/storage_service.dart';
export 'data/services/security_service.dart';
export 'data/services/notification_service.dart';
export 'data/services/platform_service.dart';

// Providers
export 'data/providers/local_data_provider.dart';
export 'data/providers/remote_data_provider.dart';

// ============================================
// HOME MODULE EXPORTS
// ============================================

// Home Bindings
export 'modules/home/bindings/home_binding.dart';

// Home Controllers
export 'modules/home/controllers/home_controller.dart';

// Home Views
export 'modules/home/views/home_view.dart';

// Home Widgets
export 'modules/home/views/widgets/app_card_widget.dart';
export 'modules/home/views/widgets/mode_selector_widget.dart';
export 'modules/home/views/widgets/dashboard_stats_widget.dart';

// ============================================
// PASSWORD MODULE EXPORTS
// ============================================

// Password Bindings
export 'modules/password/bindings/password_binding.dart';

// Password Controllers
export 'modules/password/controllers/password_setup_controller.dart';
export 'modules/password/controllers/password_verify_controller.dart';

// Password Views
export 'modules/password/views/password_setup_view.dart';
export 'modules/password/views/password_verify_view.dart';

// Password Widgets (add when created)
export 'modules/password/views/widgets/password_input_widget.dart';
export 'modules/password/views/widgets/password_strength_indicator.dart';
export 'modules/password/views/widgets/failed_attempts_widget.dart';

// ============================================
// SETTINGS MODULE EXPORTS
// ============================================

// Settings Bindings
export 'modules/settings/bindings/settings_binding.dart';

// Settings Controllers
export 'modules/settings/controllers/settings_controller.dart';

// Settings Views
export 'modules/settings/views/settings_view.dart';

// Settings Widgets (add when created)
export 'modules/settings/views/widgets/settings_tile_widget.dart';
export 'modules/settings/views/widgets/settings_section_widget.dart';
export 'modules/settings/views/widgets/theme_selector_widget.dart';

// ============================================
// ROUTES EXPORTS
// ============================================

// Navigation and Routing
export 'routes/app_pages.dart';
// export 'routes/app_routes.dart';





// ============================================
// USAGE EXAMPLE
// ============================================
