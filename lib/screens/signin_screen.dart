import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/auth_provider.dart';

/// Sign-in/Authentication Screen - Entry point for the wallet
class SignInScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final Function onAuthenticated;
  final bool isVerifyMode;
  final Function? onBackToWelcome;

  const SignInScreen({
    super.key,
    required this.authProvider,
    required this.onAuthenticated,
    this.isVerifyMode = false,
    this.onBackToWelcome,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late MobileScannerController _scannerController;
  bool _isScanning = false;
  PermissionStatus? _cameraPermission;
  final TextEditingController _didController = TextEditingController();
  bool _showManualEntry = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _didController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() => _cameraPermission = status);
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() => _cameraPermission = status);

    if (!mounted) return;

    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to scan QR codes'),
          duration: Duration(seconds: 3),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    } else if (status.isGranted) {
      _startScanning();
    }
  }

  void _startScanning() {
    _scannerController.start();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera access to scan QR codes. Please enable camera permissions in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC0000),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _processDID(String did) async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      // Authenticate with the DID
      final success = await widget.authProvider.loginWithDID(did);

      if (!mounted) return;

      if (success) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = 'Invalid DID format. Please try again.';
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error processing DID: $e';
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingDID = widget.authProvider.hasExistingDID;
    final isVerifying = widget.isVerifyMode || hasExistingDID;

    if (_showManualEntry) {
      return _buildManualEntryView(hasExistingDID);
    }

    if (_cameraPermission?.isGranted ?? false) {
      return _buildScannerView(isVerifying);
    }

    return _buildPermissionView(isVerifying);
  }

  Widget _buildPermissionView(bool hasExistingDID) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCC0000),
              Color(0xFF99000B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                  onPressed: widget.onBackToWelcome != null ? () => widget.onBackToWelcome!() : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wallet_giftcard,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'CVS Health Digital Wallet',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hasExistingDID
                              ? 'Welcome back! Verify your identity to continue.'
                              : 'Manage your Digital Identity securely',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),
                        Icon(
                          Icons.camera_alt,
                          size: 60,
                          color: Colors.white30,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Camera Access Required',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'We need camera access to scan your Digital ID QR code',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),
                        ElevatedButton.icon(
                          onPressed: _requestCameraPermission,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Enable Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFCC0000),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() => _showManualEntry = true);
                          },
                          child: const Text(
                            'Enter DID Manually',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildScannerView(bool hasExistingDID) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hasExistingDID ? 'Verify Your Identity' : 'Get Started'),
        centerTitle: true,
        backgroundColor: const Color(0xFFCC0000),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (_isScanning) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null && code.isNotEmpty) {
                  _scannerController.stop();
                  _processDID(code);
                  break;
                }
              }
            },
          ),
          // Overlay with frame guides
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFCC0000),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_2,
                  size: 100,
                  color: Color(0xFFCC0000),
                ),
              ),
            ),
          ),
          // Instructions overlay
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Position QR Code within frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // Loading/Error overlay
          if (_isScanning)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: () {
            _scannerController.stop();
            setState(() => _showManualEntry = true);
          },
          child: const Text(
            'Enter DID Manually',
            style: TextStyle(
              color: Color(0xFF17447C),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntryView(bool hasExistingDID) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hasExistingDID ? 'Verify Your Identity' : 'Get Started'),
        centerTitle: true,
        backgroundColor: const Color(0xFFCC0000),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Your Digital ID',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCC0000),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hasExistingDID
                    ? 'Paste your existing Digital ID to verify your identity'
                    : 'Paste your Digital ID or scan the QR code to get started',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _didController,
                decoration: InputDecoration(
                  hintText: 'e.g., did:cvs:user123abc...',
                  labelText: 'Digital ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                  errorText: _errorMessage,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isScanning
                      ? null
                      : () async {
                          if (_didController.text.isEmpty) {
                            setState(() => _errorMessage = 'Please enter a Digital ID');
                            return;
                          }
                          await _processDID(_didController.text);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isScanning
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          hasExistingDID ? 'Verify Identity' : 'Get Started',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _cameraPermission?.isGranted ?? false
                      ? () {
                          setState(() => _showManualEntry = false);
                          _startScanning();
                        }
                      : null,
                  child: const Text(
                    'Back to QR Scan',
                    style: TextStyle(
                      color: Color(0xFF17447C),
                      fontSize: 14,
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
