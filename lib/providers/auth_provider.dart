import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';

/// Provider for authentication state management
class AuthProvider extends ChangeNotifier {
  AuthToken? _authToken;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  AuthToken? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _authToken!.isValid;
  bool get hasExistingDID => _authToken != null;
  bool get isInitialized => _isInitialized;

  /// Initialize the auth provider and load stored token
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStoredToken();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load token from local storage
  Future<void> _loadStoredToken() async {
    final storedDID = _prefs.getString('auth_did');
    final storedToken = _prefs.getString('auth_token');
    final issuedAtStr = _prefs.getString('auth_issued_at');
    final expiresAtStr = _prefs.getString('auth_expires_at');

    if (storedDID != null && storedToken != null && issuedAtStr != null && expiresAtStr != null) {
      try {
        _authToken = AuthToken(
          token: storedToken,
          did: storedDID,
          issuedAt: DateTime.parse(issuedAtStr),
          expiresAt: DateTime.parse(expiresAtStr),
        );

        // If token expired, clear it
        if (_authToken!.isExpired) {
          _authToken = null;
        }
      } catch (e) {
        // Token invalid or corrupted
        _authToken = null;
      }
    }
  }

  /// Login with a scanned DID
  Future<bool> loginWithDID(String did) async {
    try {
      // Accept any QR code - no validation required
      if (did.trim().isEmpty) {
        return false;
      }

      // Create new auth token
      _authToken = AuthToken.fromDID(did);

      // Store token locally
      await _saveToken();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify existing DID
  Future<bool> verifyExistingDID(String did) async {
    try {
      // Accept any QR code - no validation required
      if (did.trim().isEmpty) {
        return false;
      }

      // In production, verify DID with backend
      // For now, just accept it
      _authToken = AuthToken.fromDID(did);
      await _saveToken();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save token to local storage
  Future<void> _saveToken() async {
    if (_authToken != null) {
      // In production, use proper JSON encoding
      // For now, store the DID and key info
      await _prefs.setString('auth_did', _authToken!.did);
      await _prefs.setString('auth_token', _authToken!.token);
      await _prefs.setString('auth_issued_at', _authToken!.issuedAt.toIso8601String());
      await _prefs.setString('auth_expires_at', _authToken!.expiresAt.toIso8601String());
    }
  }

  /// Logout and clear stored data
  Future<void> logout() async {
    _authToken = null;
    await _prefs.remove('auth_did');
    await _prefs.remove('auth_token');
    await _prefs.remove('auth_issued_at');
    await _prefs.remove('auth_expires_at');
    notifyListeners();
  }

  /// Get the current DID
  String? getDID() => _authToken?.did;
}
