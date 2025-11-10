import 'package:flutter/material.dart';

/// Verification Screen - Shown while processing QR code
class VerificationScreen extends StatefulWidget {
  final Future<void> Function() onVerify;
  final String verificationMessage;

  const VerificationScreen({
    super.key,
    required this.onVerify,
    this.verificationMessage = 'Verifying Digital ID...',
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _performVerification();
  }

  Future<void> _performVerification() async {
    try {
      await widget.onVerify();
      _animationController.stop();
      setState(() => _verified = true);

      // Auto-pop after success
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _animationController.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
        Navigator.pop(context, false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_verified)
              Column(children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verified Successfully!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ])
            else
              Column(
                children: [
                  RotationTransition(
                    turns: _animationController,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFCC0000).withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        size: 50,
                        color: Color(0xFFCC0000),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.verificationMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait a moment...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
