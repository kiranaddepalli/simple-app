/// Model for Digital Identity (DID)
class DigitalIdentity {
  final String did;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String issuer;
  final bool isVerified;

  DigitalIdentity({
    required this.did,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.issuedDate,
    required this.expiryDate,
    required this.issuer,
    this.isVerified = false,
  });

  /// Mock DID from QR code
  factory DigitalIdentity.fromQrCode(String qrData) {
    // In real implementation, this would parse actual DID data
    return DigitalIdentity(
      did: 'did:example:${qrData.substring(0, 20)}',
      name: 'John Doe',
      email: 'john.doe@cvs.com',
      phoneNumber: '+1-555-0123',
      issuedDate: DateTime.now().subtract(const Duration(days: 365)),
      expiryDate: DateTime.now().add(const Duration(days: 365 * 4)),
      issuer: 'CVS Health Identity Authority',
      isVerified: true,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }
}
