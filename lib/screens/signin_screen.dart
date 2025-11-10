import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'verification_method_screen.dart';
import 'user_info_confirmation_screen.dart';
import 'verification_success_screen.dart';
import 'identity_verification_info_screen.dart';

/// Sign-in Screen with Get Started Wizard Flow
/// Steps: QR Scan -> Identity Info -> Method Selection -> Confirm User Info -> Success -> Main App
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
  PermissionStatus? _cameraPermission;
  final TextEditingController _didController = TextEditingController();
  bool _showManualEntry = false;
  String? _errorMessage;

  // Wizard state
  int _currentStep = 0; // 0: QR Scan, 1: Identity Info, 2: Method Selection, 3: Confirm Info, 4: Success
  String? _scannedDid;
  UserInfo? _userInfo;

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
    final status = await Permission.camera.request();
    setState(() {
      _cameraPermission = status;
    });
  }

  void _handleQRScanned(BarcodeCapture capture) {
    if (_currentStep != 0) return; // Only handle scan at step 0

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          _scannedDid = barcode.rawValue;
          _currentStep = 1; // Move to Identity Info screen
        });
        _scannerController.stop();
        break;
      }
    }
  }

  void _handleIdentityInfoContinue() {
    setState(() {
      _currentStep = 2; // Move to Method Selection
    });
  }

  void _handleMethodSelected() {
    setState(() {
      _currentStep = 3; // Move to User Info Confirmation
      _userInfo = UserInfo.mockUser(); // Load mock user for confirmation
    });
  }

  void _handleUserInfoConfirmed() {
    setState(() {
      _currentStep = 4; // Move to Success Screen
    });
  }

  void _handleVerificationSuccess() {
    // Authenticate and move to main app
    if (_scannedDid != null) {
      widget.authProvider.loginWithDID(_scannedDid!);
    } else {
      widget.authProvider.loginWithDID(_didController.text);
    }
    widget.onAuthenticated();
  }

  void _handleManualEntry() {
    if (_didController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a DID';
      });
      return;
    }
    setState(() {
      _scannedDid = _didController.text;
      _currentStep = 1; // Move to Identity Info screen
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine which screen to show based on current step
    if (_currentStep == 0) {
      return _buildQRScanScreen();
    } else if (_currentStep == 1) {
      return IdentityVerificationInfoScreen(
        onContinue: _handleIdentityInfoContinue,
      );
    } else if (_currentStep == 2) {
      return VerificationMethodScreen(
        onMethodSelected: _handleMethodSelected,
      );
    } else if (_currentStep == 3 && _userInfo != null) {
      return UserInfoConfirmationScreen(
        userInfo: _userInfo!,
        onConfirmed: _handleUserInfoConfirmed,
        onEdit: () {
          // For now, go back to method selection
          setState(() {
            _currentStep = 2;
          });
        },
      );
    } else if (_currentStep == 4) {
      return VerificationSuccessScreen(
        onContinueToApp: _handleVerificationSuccess,
      );
    }

    return _buildQRScanScreen();
  }

  Widget _buildQRScanScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVerifyMode ? 'Verify Your Identity' : 'Get Started'),
        backgroundColor: const Color(0xFFCC0000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onBackToWelcome?.call();
          },
        ),
      ),
      body: _cameraPermission == null
          ? const Center(child: CircularProgressIndicator())
          : _cameraPermission!.isGranted
              ? _buildCameraView()
              : _buildPermissionDeniedView(),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _handleQRScanned,
        ),
        // UI Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scanning frame
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFCC0000),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Instruction text with background
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Align QR code within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Top safe area with info
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.isVerifyMode ? 'Scan your existing DID to verify' : 'Scan your credential QR code',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        // Bottom button for manual entry
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_showManualEntry)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _showManualEntry = true;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Enter Manually',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _didController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter DID or credential code',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCC0000),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _handleManualEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCC0000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: Color(0xFFCC0000),
          ),
          const SizedBox(height: 24),
          const Text(
            'Camera Permission Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'We need access to your camera to scan QR codes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              _checkCameraPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC0000),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Open Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
