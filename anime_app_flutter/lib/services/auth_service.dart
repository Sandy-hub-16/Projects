/// Simple in-memory authentication service.
///
/// Credentials are stored only for the current session — there is no
/// persistence layer yet. Swap the [login] / [register] implementations
/// with real API calls when a backend is ready.
class AuthService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── State ──────────────────────────────────────────────────────────────────
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // In-memory "database" of registered users: email → AppUser + password
  final Map<String, _StoredUser> _users = {};

  // ── Auth operations ────────────────────────────────────────────────────────

  /// Registers a new user. Throws [AuthException] on validation failure.
  Future<AppUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    // Basic validation
    if (username.trim().isEmpty) throw AuthException('Username is required.');
    if (!_isValidEmail(email)) throw AuthException('Enter a valid email address.');
    if (password.length < 6) throw AuthException('Password must be at least 6 characters.');
    if (_users.containsKey(email.toLowerCase())) {
      throw AuthException('An account with this email already exists.');
    }

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username.trim(),
      email: email.toLowerCase().trim(),
    );
    _users[email.toLowerCase()] = _StoredUser(user: user, password: password);
    _currentUser = user;
    return user;
  }

  /// Signs in an existing user. Throws [AuthException] on failure.
  Future<AppUser> login({
    required String emailOrUsername,
    required String password,
  }) async {
    if (emailOrUsername.trim().isEmpty) {
      throw AuthException('Email or username is required.');
    }
    if (password.isEmpty) throw AuthException('Password is required.');

    // Look up by email first, then by username
    _StoredUser? stored = _users[emailOrUsername.toLowerCase().trim()];
    stored ??= _users.values
          .where((u) =>
              u.user.username.toLowerCase() ==
              emailOrUsername.toLowerCase().trim())
          .firstOrNull;

    if (stored == null || stored.password != password) {
      throw AuthException('Invalid email/username or password.');
    }

    _currentUser = stored.user;
    return stored.user;
  }

  /// Signs out the current user.
  void logout() => _currentUser = null;

  // ── Helpers ────────────────────────────────────────────────────────────────
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}

// ── Models ─────────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String username;
  final String email;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
  });
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class _StoredUser {
  final AppUser user;
  final String password;
  const _StoredUser({required this.user, required this.password});
}
