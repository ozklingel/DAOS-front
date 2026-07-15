import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/core/locale/locale_provider.dart';
import 'package:taskmail/core/di/providers.dart';
import 'package:taskmail/core/errors/app_exception.dart';
import 'package:taskmail/features/auth/domain/entities/user.dart';

final authStateProvider = ChangeNotifierProvider<AuthState>((ref) {
  final state = AuthState(ref);
  state.initialize();
  return state;
});

class AuthState extends ChangeNotifier {
  AuthState(this._ref);

  final Ref _ref;

  bool _isLoading = true;
  bool _isAuthenticated = false;
  User? _user;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final repo = _ref.read(authRepositoryProvider);
      _isAuthenticated = await repo.hasValidSession();
      if (_isAuthenticated) {
        _user = await repo.getCurrentUser();
        try {
          final settings = await _ref.read(settingsRepositoryProvider).getSettings();
          await _ref.read(localeProvider.notifier).setLocale(settings.language);
        } catch (_) {}
      }
    } catch (_) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final tokens = await _ref.read(authRepositoryProvider).signInWithGoogle();
      _user = tokens.user;
      _isAuthenticated = true;
    } on AppException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithOutlook() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final tokens =
          await _ref.read(authRepositoryProvider).signInWithOutlook();
      _user = tokens.user;
      _isAuthenticated = true;
    } on AppException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInDev() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final tokens = await _ref.read(authRepositoryProvider).signInDev();
      _user = tokens.user;
      _isAuthenticated = true;
    } on AppException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> connectGmail() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _ref.read(authRepositoryProvider).connectGmail();
    } on AppException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> connectOutlook() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _ref.read(authRepositoryProvider).connectOutlook();
    } on AppException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnectGmail() async {
    _user = await _ref.read(authRepositoryProvider).disconnectGmail();
    notifyListeners();
  }

  Future<void> disconnectOutlook() async {
    _user = await _ref.read(authRepositoryProvider).disconnectOutlook();
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
