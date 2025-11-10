import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/credential_model.dart';
import '../providers/wallet_provider.dart';

/// Scan QR Code Wizard - Multi-step wizard for scanning credentials
class ScanQRWizardScreen extends StatefulWidget {
  final WalletProvider walletProvider;

  const ScanQRWizardScreen({
    super.key,
    required this.walletProvider,
  });

  @override
  State<ScanQRWizardScreen> createState() => _ScanQRWizardScreenState();
}

class _ScanQRWizardScreenState extends State<ScanQRWizardScreen> {
  int _currentStep = 0; // 0: Scan, 1: Select Type, 2: Confirm, 3: Success
  String? _scannedData;
  VerifiableCredential? _credential;
  late MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _handleScan(BarcodeCapture capture) {
    if (_scannedData == null) {
      final barcode = capture.barcodes.firstOrNull;
      if (barcode != null && barcode.rawValue != null) {
        setState(() {
          _scannedData = barcode.rawValue;
          _currentStep = 1;
        });
        _cameraController.stop();
      }
    }
  }

  void _selectCredentialType(CredentialType type) {
    setState(() {
      _credential = _createCredentialOfType(type, _scannedData!);
      _currentStep = 2;
    });
  }

  VerifiableCredential _createCredentialOfType(CredentialType type, String qrData) {
    final now = DateTime.now();
    return VerifiableCredential(
      id: 'vc:${now.millisecondsSinceEpoch}',
      type: type,
      issuer: 'CVS Health',
      subject: 'did:cvs:user_${qrData.hashCode.abs().toString().substring(0, 8)}',
      issuanceDate: now,
      expirationDate: now.add(const Duration(days: 365 * 3)),
      credentialSubject: _generateCredentialData(type),
      isVerified: true,
    );
  }

  Map<String, dynamic> _generateCredentialData(CredentialType type) {
    final now = DateTime.now();
    final memberId = 'CVS${now.millisecondsSinceEpoch.toString().substring(0, 10)}';

    switch (type) {
      case CredentialType.identityCredential:
        return {
          'name': 'John Thompson',
          'memberId': memberId,
          'status': 'Active',
          'coverage': 'Premium Plus',
        };
      case CredentialType.insuranceCard:
        return {
          'name': 'John Thompson',
          'memberId': memberId,
          'groupNumber': 'GRP123456',
          'planName': 'CVS Select',
          'copay': '\$20',
        };
      case CredentialType.patientIdentity:
        return {
          'name': 'John Thompson',
          'memberId': memberId,
          'dateOfBirth': '06/15/1985',
          'healthSystemId': 'HS${memberId}',
        };
      case CredentialType.allergyCredential:
        return {
          'patientName': 'John Thompson',
          'memberId': memberId,
          'allergies': ['Peanuts', 'Penicillin', 'Shellfish'],
          'severity': 'High',
          'lastUpdated': '01/15/2024',
        };
      case CredentialType.medicationCredential:
        return {
          'patientName': 'John Thompson',
          'memberId': memberId,
          'medications': [
            {'name': 'Lisinopril', 'dosage': '10mg', 'frequency': 'Daily'},
            {'name': 'Metformin', 'dosage': '500mg', 'frequency': 'Twice Daily'},
          ],
          'pharmacyId': memberId,
        };
      case CredentialType.minuteClinicAppointment:
        return {
          'patientName': 'John Thompson',
          'memberId': memberId,
          'appointmentDate': '02/20/2024',
          'appointmentTime': '2:30 PM',
          'location': 'CVS MinuteClinic - Downtown',
          'serviceType': 'Annual Physical',
        };
      case CredentialType.aetnaCllaim:
        return {
          'claimantName': 'John Thompson',
          'memberId': memberId,
          'claimNumber': 'CLM${memberId}',
          'claimDate': '01/10/2024',
          'claimAmount': '\$2,450.00',
          'status': 'Approved',
        };
    }
  }

  void _confirmCredential() {
    if (_credential != null) {
      widget.walletProvider.addCredential(_credential!);
      setState(() {
        _currentStep = 3;
      });
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _scannedData = null;
      _credential = null;
    });
    _cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getTitleForStep(),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentStep,
        children: [
          _buildScanStep(),
          _buildSelectTypeStep(),
          _buildConfirmStep(),
          _buildSuccessStep(),
        ],
      ),
    );
  }

  Widget _getTitleForStep() {
    switch (_currentStep) {
      case 0:
        return const Text('Scan QR Code');
      case 1:
        return const Text('Select Credential Type');
      case 2:
        return const Text('Confirm Information');
      case 3:
        return const Text('Credential Added');
      default:
        return const Text('Scan QR');
    }
  }

  Widget _buildScanStep() {
    return Stack(
      children: [
        MobileScanner(
          controller: _cameraController,
          onDetect: _handleScan,
        ),
        // Semi-transparent overlay with cutout for QR code area
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: CustomPaint(
              painter: QRScannerOverlay(),
              size: Size.infinite,
            ),
          ),
        ),
        // Instructions and buttons
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.qr_code_2, size: 32, color: Color(0xFFCC0000)),
                    SizedBox(height: 8),
                    Text(
                      'Position QR code within the frame',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFCC0000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectTypeStep() {
    const credentialTypes = CredentialType.values;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Credential Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What type of credential did you scan?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: credentialTypes.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    child: InkWell(
                      onTap: () => _selectCredentialType(type),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFCC0000).withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              type.icon,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                type.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFCC0000)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConfirmStep() {
    if (_credential == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review the credential details before adding',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Credential Card
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCC0000).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _credential!.type.icon,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _credential!.type.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                _credential!.issuer,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    ..._buildCredentialDetails(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmCredential,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC0000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Credential',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCredentialDetails() {
    final details = _credential!.credentialSubject;
    final widgets = <Widget>[];

    details.forEach((key, value) {
      String displayKey = key
          .replaceAllMapped(
            RegExp(r'([A-Z])'),
            (Match m) => ' ${m.group(0)}',
          )
          .trim();
      displayKey = displayKey[0].toUpperCase() + displayKey.substring(1);

      String displayValue = '';

      // Handle different value types
      if (value is List) {
        // For list of maps (like medications), show each item
        displayValue = value.map((item) {
          if (item is Map) {
            return item.values.join(' - ');
          }
          return item.toString();
        }).join(', ');
      } else if (value is Map) {
        // For nested maps, show key-value pairs
        displayValue = value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      } else {
        displayValue = value.toString();
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  displayKey,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });

    return widgets;
  }

  Widget _buildSuccessStep() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Credential Added!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${_credential!.type.displayName} has been successfully added to your wallet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for QR scanner overlay
class QRScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerLength = 40.0;
    const cornerWidth = 4.0;
    const squareSize = 250.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final left = centerX - squareSize / 2;
    final top = centerY - squareSize / 2;
    final right = centerX + squareSize / 2;
    final bottom = centerY + squareSize / 2;

    // Draw semi-transparent overlays on all four sides (instead of using BlendMode.clear)
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);

    // Top overlay
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), overlayPaint);

    // Bottom overlay
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), overlayPaint);

    // Left overlay
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), overlayPaint);

    // Right overlay
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), overlayPaint);

    // Draw corner lines
    final cornerPaint = Paint()
      ..color = const Color(0xFFCC0000)
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(right, top), Offset(right - cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(right, top + cornerLength), Offset(right, top), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, bottom - cornerLength), Offset(left, bottom), cornerPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(right, bottom), Offset(right - cornerLength, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom - cornerLength), Offset(right, bottom), cornerPaint);
  }

  @override
  bool shouldRepaint(QRScannerOverlay oldDelegate) => false;
}
