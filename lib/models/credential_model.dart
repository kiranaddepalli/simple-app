/// Credential types supported in the wallet
enum CredentialType {
  identityCredential,
  insuranceCard,
  patientIdentity,
  allergyCredential,
  medicationCredential,
  minuteClinicAppointment,
  aetnaCllaim,
}

extension CredentialTypeExt on CredentialType {
  String get displayName {
    switch (this) {
      case CredentialType.identityCredential:
        return 'Identity Credential';
      case CredentialType.insuranceCard:
        return 'Insurance Card';
      case CredentialType.patientIdentity:
        return 'Patient Identity';
      case CredentialType.allergyCredential:
        return 'Allergy Credential';
      case CredentialType.medicationCredential:
        return 'Medication Credential';
      case CredentialType.minuteClinicAppointment:
        return 'Minute Clinic Appointment';
      case CredentialType.aetnaCllaim:
        return 'Aetna Claim';
    }
  }

  String get icon {
    switch (this) {
      case CredentialType.identityCredential:
        return '🪪';
      case CredentialType.insuranceCard:
        return '🏥';
      case CredentialType.patientIdentity:
        return '👤';
      case CredentialType.allergyCredential:
        return '⚠️';
      case CredentialType.medicationCredential:
        return '💊';
      case CredentialType.minuteClinicAppointment:
        return '📅';
      case CredentialType.aetnaCllaim:
        return '📄';
    }
  }
}

/// Model for Verifiable Credentials
class VerifiableCredential {
  final String id;
  final CredentialType type;
  final String issuer;
  final String subject;
  final DateTime issuanceDate;
  final DateTime expirationDate;
  final Map<String, dynamic> credentialSubject;
  final bool isVerified;

  VerifiableCredential({
    required this.id,
    required this.type,
    required this.issuer,
    required this.subject,
    required this.issuanceDate,
    required this.expirationDate,
    required this.credentialSubject,
    this.isVerified = true,
  });

  /// Mock credential from QR code
  factory VerifiableCredential.fromQrCode(String qrData) {
    final now = DateTime.now();
    return VerifiableCredential(
      id: 'vc:${now.millisecondsSinceEpoch}',
      type: CredentialType.identityCredential,
      issuer: 'CVS Health',
      subject: 'did:cvs:user_${qrData.hashCode.abs().toString().substring(0, 8)}',
      issuanceDate: now,
      expirationDate: now.add(const Duration(days: 365 * 3)),
      credentialSubject: {
        'name': 'John Doe',
        'memberId': 'CVS${now.millisecondsSinceEpoch.toString().substring(0, 10)}',
        'status': 'Active',
        'coverage': 'Premium Plus',
      },
      isVerified: true,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expirationDate);

  int get daysUntilExpiry {
    return expirationDate.difference(DateTime.now()).inDays;
  }

  String get displayName {
    return credentialSubject['name'] ?? 'Unknown';
  }

  String get memberId {
    return credentialSubject['memberId'] ?? 'N/A';
  }
}
