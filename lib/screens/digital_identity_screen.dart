import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

/// Digital Identity Screen - Displays user's DID, profile info, and QR code for sharing
class DigitalIdentityScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const DigitalIdentityScreen({
    super.key,
    required this.authProvider,
  });

  @override
  State<DigitalIdentityScreen> createState() => _DigitalIdentityScreenState();
}

class _DigitalIdentityScreenState extends State<DigitalIdentityScreen> {
  static const mockDID = 'did:cvs:z6MkhaXgBZDvotDkL5257faWxcqACaJz7n7bXrV8k4jPB9g9';

  @override
  Widget build(BuildContext context) {
    final userInfo = UserInfo.mockUser();
    const qrCodeUrl = 'https://en.wikipedia.org/wiki/Digital_wallet';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Identity'),
        backgroundColor: const Color(0xFFCC0000),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Integrated Profile Header with QR Code
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFCC0000),
                    const Color(0xFFCC0000).withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[400]!,
                              Colors.blue[800]!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${userInfo.firstName[0]}${userInfo.lastName[0]}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userInfo.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // QR Code in Header
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: qrCodeUrl,
                          version: QrVersions.auto,
                          size: 100,
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0066CC),
                          embeddedImage: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Scan to Connect text
                  const Text(
                    'Scan the QR code to learn more about Digital Wallets',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // DID - Compact inline format
                  _CompactInfoField(
                    icon: Icons.badge,
                    label: 'DID',
                    value: mockDID,
                    isMonospace: true,
                  ),
                  const SizedBox(height: 10),
                  // Full Name
                  _CompactInfoField(
                    icon: Icons.person,
                    label: 'Full Name',
                    value: userInfo.fullName,
                  ),
                  const SizedBox(height: 10),
                  // Date of Birth
                  _CompactInfoField(
                    icon: Icons.calendar_today,
                    label: 'Date of Birth',
                    value: userInfo.formattedDOB,
                  ),
                  const SizedBox(height: 10),
                  // Country
                  _CompactInfoField(
                    icon: Icons.public,
                    label: 'Country',
                    value: userInfo.country,
                  ),
                  const SizedBox(height: 16),
                  // Security Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your Digital Identity is secured by your DID. Share your QR code to build verified connections.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact Info Field Widget - Inline display for demographic information
class _CompactInfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  const _CompactInfoField({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFCC0000).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFFCC0000),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isMonospace && value.length > 45 ? '${value.substring(0, 45)}...' : value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
