/// Authentication models for Digital Wallet
class AuthToken {
  final String token;
  final String did;
  final DateTime issuedAt;
  final DateTime expiresAt;

  AuthToken({
    required this.token,
    required this.did,
    required this.issuedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => !isExpired;

  factory AuthToken.fromDID(String did) {
    final now = DateTime.now();
    // Token valid for 24 hours
    final expiry = now.add(const Duration(hours: 24));

    return AuthToken(
      token: _generateJWT(did),
      did: did,
      issuedAt: now,
      expiresAt: expiry,
    );
  }

  static String _generateJWT(String did) {
    // Simple JWT-like token generation
    // In production, this would come from a backend service
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final parts = [
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9', // header
      _base64UrlEncode('{"sub":"$did","iat":$timestamp}'), // payload
      'signature_${timestamp}_$did', // signature
    ];
    return parts.join('.');
  }

  static String _base64UrlEncode(String str) {
    // Simple base64url encoding
    return str.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'did': did,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory AuthToken.fromMap(Map<String, dynamic> map) {
    return AuthToken(
      token: map['token'] as String,
      did: map['did'] as String,
      issuedAt: DateTime.parse(map['issuedAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
    );
  }
}
