import '../services/auth_service.dart';
import '../services/bookmark_service.dart';

class ServiceLocator {
  // Private constructor
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();

  factory ServiceLocator() => _instance;

  // Services
  AuthService _authService = AuthService();
  BookmarkService _bookmarkService = BookmarkService();

  // Getters for services
  static AuthService get authService => _instance._authService;
  static BookmarkService get bookmarkService => _instance._bookmarkService;

  // Optional: A method to initialize services if needed (e.g., for async setup)
  static Future<void> initialize() async {
    // Perform any async initialization for services if required
    // For now, our services are instantiated directly.
  }
}
