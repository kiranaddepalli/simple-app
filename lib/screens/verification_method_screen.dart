import 'package:flutter/material.dart';

class VerificationMethodScreen extends StatefulWidget {
  final VoidCallback onMethodSelected;

  const VerificationMethodScreen({
    Key? key,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  State<VerificationMethodScreen> createState() => _VerificationMethodScreenState();
}

class _VerificationMethodScreenState extends State<VerificationMethodScreen> {
  final List<VerificationMethod> methods = [
    VerificationMethod(
      id: 'private_id',
      title: 'Private ID',
      description: 'Face Scan + Document Verification',
      icon: '🆔',
    ),
    VerificationMethod(
      id: 'jumio',
      title: 'Jumio',
      description: 'Face Scan + Document Verification',
      icon: '📸',
    ),
    VerificationMethod(
      id: 'google_wallet',
      title: 'Google Wallet',
      description: 'Verify with your Google account',
      icon: '🔐',
    ),
    VerificationMethod(
      id: 'mobile_license',
      title: 'Mobile Driver\'s License',
      description: 'Use your state-issued digital ID',
      icon: '🚗',
    ),
    VerificationMethod(
      id: 'cvs_account',
      title: 'CVS Account',
      description: 'Verify with your existing cvs.com ID',
      icon: '💳',
    ),
  ];

  String? selectedMethodId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Verification Method'),
        backgroundColor: const Color(0xFFCC0000),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFCC0000),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Select Your Verification Method',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose how you\'d like to verify your identity',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: methods.map((method) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMethodId = method.id;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedMethodId == method.id ? const Color(0xFFCC0000) : Colors.grey[300]!,
                            width: selectedMethodId == method.id ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color:
                              selectedMethodId == method.id ? const Color(0xFFCC0000).withOpacity(0.05) : Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              method.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selectedMethodId == method.id ? const Color(0xFFCC0000) : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedMethodId == method.id)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFCC0000),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedMethodId != null
                    ? () {
                        widget.onMethodSelected();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC0000),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue with ${selectedMethodId != null ? methods.firstWhere((m) => m.id == selectedMethodId).title : 'Selected Method'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationMethod {
  final String id;
  final String title;
  final String description;
  final String icon;

  VerificationMethod({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
