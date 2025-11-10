import 'package:flutter/material.dart';
import '../models/did_model.dart';
import '../models/credential_model.dart';

/// Provider for managing wallet state
class WalletProvider extends ChangeNotifier {
  DigitalIdentity? _did;
  final List<VerifiableCredential> _credentials = [];
  bool _isInitialized = false;

  // Getters
  DigitalIdentity? get did => _did;
  List<VerifiableCredential> get credentials => _credentials;
  bool get isInitialized => _isInitialized;
  bool get hasDID => _did != null;

  /// Initialize wallet with DID from QR code
  Future<void> initializeWithDID(String qrData) async {
    // Simulate QR verification delay
    await Future.delayed(const Duration(seconds: 2));

    _did = DigitalIdentity.fromQrCode(qrData);
    _isInitialized = true;

    // Add a mock credential upon initialization
    addCredential(VerifiableCredential.fromQrCode(qrData));

    notifyListeners();
  }

  /// Add a new verifiable credential
  void addCredential(VerifiableCredential credential) {
    _credentials.add(credential);
    notifyListeners();
  }

  /// Remove a credential
  void removeCredential(String credentialId) {
    _credentials.removeWhere((cred) => cred.id == credentialId);
    notifyListeners();
  }

  /// Mock QR scan and credential addition
  Future<void> scanAndAddCredential(String qrData) async {
    // Simulate QR verification delay
    await Future.delayed(const Duration(seconds: 2));

    final newCredential = VerifiableCredential.fromQrCode(qrData);
    addCredential(newCredential);
  }

  /// Get active credentials (not expired)
  List<VerifiableCredential> getActiveCredentials() {
    return _credentials.where((cred) => !cred.isExpired).toList();
  }

  /// Get expired credentials
  List<VerifiableCredential> getExpiredCredentials() {
    return _credentials.where((cred) => cred.isExpired).toList();
  }
}
