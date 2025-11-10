import 'package:flutter/material.dart';
import '../models/credential_model.dart';

/// Health Agent Screen - Interactive conversational agent experience
class HealthAgentScreen extends StatefulWidget {
  final String? did;
  final Function(VerifiableCredential)? onAppointmentBooked;

  const HealthAgentScreen({
    super.key,
    this.did,
    this.onAppointmentBooked,
  });

  @override
  State<HealthAgentScreen> createState() => _HealthAgentScreenState();
}

class _HealthAgentScreenState extends State<HealthAgentScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AgentMessage> messages = [];

  int currentStep = 0; // 0: Intro, 1: Agent DID, 2: Request User DID, 3: Permissions, 4: Ask Symptoms, 5: Conversation
  bool isTyping = false;
  bool permissionsGranted = false;
  bool showAppointmentFlow = false;
  SelectedAppointment? selectedAppointment;

  static const mockDID = 'did:agent:z6MkhaXgBZDvotDkL5257faWxcqACaJz7n7bXrV8k4jPB9g9';
  static const agentName = 'HealthAI Agent';

  final List<String> permissions = [
    'Identity Verification',
    'Medical History',
    'Medication Records',
    'Pharmacy Information',
    'Insurance Details',
  ];

  final List<TimeSlot> timeSlots = [
    TimeSlot(time: '09:00 AM', date: 'Today', available: true),
    TimeSlot(time: '02:30 PM', date: 'Today', available: true),
    TimeSlot(time: '10:00 AM', date: 'Tomorrow', available: true),
  ];

  final List<ClinicLocation> clinicLocations = [
    ClinicLocation(
      name: 'MinuteClinic - Downtown',
      address: '123 Main St, Downtown',
      distance: 2.3,
      rating: 4.8,
    ),
    ClinicLocation(
      name: 'MinuteClinic - Shopping Center',
      address: '456 Oak Ave, Shopping District',
      distance: 4.7,
      rating: 4.6,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAgentFlow();
  }

  void _startAgentFlow() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _addAgentMessage(
        'Hello! I\'m $agentName, your personal health assistant. I\'m designed to help you with medical consultations, appointments, and health records on your behalf.',
        step: 0,
      );
    });
  }

  void _addAgentMessage(String text, {int step = -1, bool isStreaming = false}) {
    setState(() {
      messages.add(AgentMessage(
        text: text,
        isAgent: true,
        timestamp: DateTime.now(),
        isStreaming: isStreaming,
      ));
    });
    _scrollToBottom();

    if (step >= 0) {
      currentStep = step;
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      messages.add(AgentMessage(
        text: text,
        isAgent: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleUserInput(String text) {
    if (text.trim().isEmpty) return;

    _addUserMessage(text);
    _messageController.clear();

    if (currentStep == 0) {
      // Agent introduces itself, now reveal DID
      Future.delayed(const Duration(milliseconds: 1000), () {
        _addAgentMessage(
          'Now let me verify my identity. My DID: $mockDID',
          step: 1,
        );
        Future.delayed(const Duration(milliseconds: 800), () {
          _addAgentMessage(
            '✓ Identity verified successfully',
            step: 1,
          );
          Future.delayed(const Duration(milliseconds: 800), () {
            _addAgentMessage(
              'Now, what is your identity? Please provide your name or DID.',
              step: 2,
            );
          });
        });
      });
    } else if (currentStep == 2) {
      // User provided their identity, request permissions
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showPermissionRequest();
      });
    } else if (currentStep == 3) {
      // Permissions granted, now ask for symptoms
      _grantPermissions();
    } else if (currentStep == 4) {
      // User described symptoms, start health conversation
      _handleHealthConversation(text);
    }
  }

  void _showPermissionRequest() {
    setState(() {
      currentStep = 3;
    });
    _addAgentMessage(
      'To better assist you, I need permission to access:',
      step: 3,
    );
    _scrollToBottom();
  }

  void _grantPermissions() {
    setState(() {
      permissionsGranted = true;
      currentStep = 4;
    });
    _addUserMessage('✓ Permissions granted');
    Future.delayed(const Duration(milliseconds: 800), () {
      _addAgentMessage(
        'Perfect! I\'m now connected and ready to help. Please describe your symptoms or health concerns.',
        step: 4,
      );
    });
  }

  void _handleHealthConversation(String userInput) {
    setState(() => isTyping = true);

    // Simulate streaming responses
    _simulateStreamingResponse(userInput);
  }

  void _simulateStreamingResponse(String userInput) {
    final List<String> streamingMessages = [
      'Analyzing your symptoms...',
      'Checking your medical history...',
      'Based on your symptoms, I recommend visiting an urgent care clinic.',
      'I found available appointments at MinuteClinic nearby.',
    ];

    var delay = Duration.zero;
    for (final message in streamingMessages) {
      Future.delayed(delay, () {
        if (!mounted) return;
        _addAgentMessage(message, isStreaming: true);
      });
      delay += const Duration(milliseconds: 1500);
    }

    // Show appointment options after streaming
    Future.delayed(delay, () {
      if (!mounted) return;
      setState(() => isTyping = false);
      _showAppointmentSelection();
    });
  }

  void _showAppointmentSelection() {
    setState(() => showAppointmentFlow = true);
  }

  void _selectTimeSlot(TimeSlot slot) {
    setState(() {
      selectedAppointment = SelectedAppointment(timeSlot: slot);
    });
  }

  void _selectLocation(ClinicLocation location) {
    if (selectedAppointment != null) {
      setState(() {
        selectedAppointment = SelectedAppointment(
          timeSlot: selectedAppointment!.timeSlot,
          location: location,
        );
      });
    }
  }

  void _confirmAppointment() {
    if (selectedAppointment == null || selectedAppointment!.location == null) return;

    final appointment = selectedAppointment!;
    _addUserMessage(
      '✓ Confirmed appointment at ${appointment.location!.name} at ${appointment.timeSlot.time}',
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      // Create appointment VC
      final appointmentVC = _createAppointmentVC(appointment);

      // Call callback to add VC to credentials
      if (widget.onAppointmentBooked != null) {
        widget.onAppointmentBooked!(appointmentVC);
      }

      _addAgentMessage(
        'Great! Your appointment is confirmed. I\'ve created a Verifiable Credential (VC) for your appointment booking.',
        step: 3,
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        _addAgentMessage(
          'Your appointment VC has been added to your Credentials. You can view it anytime from your profile.',
        );
      });
    });

    setState(() => showAppointmentFlow = false);
  }

  /// Create an appointment VC
  VerifiableCredential _createAppointmentVC(SelectedAppointment appointment) {
    final now = DateTime.now();
    final appointmentDate = now.add(const Duration(days: 1)); // Mock future appointment

    return VerifiableCredential(
      id: 'vc:appointment:${now.millisecondsSinceEpoch}',
      type: CredentialType.minuteClinicAppointment,
      issuer: appointment.location!.name,
      subject: 'did:user:${now.millisecondsSinceEpoch}',
      issuanceDate: now,
      expirationDate: appointmentDate.add(const Duration(hours: 24)),
      credentialSubject: {
        'appointmentId': 'APPT${now.millisecondsSinceEpoch.toString().substring(0, 10)}',
        'clinicName': appointment.location!.name,
        'address': appointment.location!.address,
        'time': appointment.timeSlot.time,
        'date': appointment.timeSlot.date,
        'distance': '${appointment.location!.distance} miles',
        'reason': 'Health Consultation',
        'status': 'Confirmed',
      },
      isVerified: true,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assistant'),
        backgroundColor: const Color(0xFFCC0000),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Agent DID: $mockDID'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          if (permissionsGranted)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green[50],
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Agent connected and ready to assist',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          // Permission Request UI
          if (currentStep == 2 && !permissionsGranted)
            _PermissionRequestWidget(
              permissions: permissions,
              onGrant: _grantPermissions,
            ),
          // Appointment Selection UI
          if (showAppointmentFlow && permissionsGranted)
            _AppointmentSelectionWidget(
              timeSlots: timeSlots,
              locations: clinicLocations,
              selectedAppointment: selectedAppointment,
              onSelectTimeSlot: _selectTimeSlot,
              onSelectLocation: _selectLocation,
              onConfirm: _confirmAppointment,
            ),
          // Message Input - Always visible to allow user interaction
          _MessageInputField(
            controller: _messageController,
            onSend: _handleUserInput,
            isEnabled: !isTyping && !showAppointmentFlow,
            placeholder: currentStep == 0
                ? 'Click here to start conversation...'
                : currentStep == 2
                    ? 'Enter your name or DID...'
                    : currentStep == 3
                        ? 'Grant permissions below first'
                        : 'Describe your symptoms or health concerns...',
          ),
        ],
      ),
    );
  }
}

/// Message Bubble Widget
class _MessageBubble extends StatelessWidget {
  final AgentMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isAgent ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isAgent) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[400]!, Colors.blue[800]!],
                ),
              ),
              child: const Center(
                child: Text(
                  '🤖',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: message.isAgent ? Colors.grey[200] : const Color(0xFFCC0000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isAgent ? Colors.black87 : Colors.white,
                      height: 1.4,
                    ),
                  ),
                  if (message.isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: SizedBox(
                        height: 4,
                        width: 30,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            message.isAgent ? Colors.blue[400] : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!message.isAgent) const SizedBox(width: 8),
          if (!message.isAgent)
            Text(
              '👤',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }
}

/// Permission Request Widget
class _PermissionRequestWidget extends StatelessWidget {
  final List<String> permissions;
  final VoidCallback onGrant;

  const _PermissionRequestWidget({
    required this.permissions,
    required this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(top: BorderSide(color: Colors.blue[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Permissions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF17447C),
            ),
          ),
          const SizedBox(height: 12),
          ...permissions.map(
            (perm) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    perm,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onGrant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Grant Permissions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Appointment Selection Widget
class _AppointmentSelectionWidget extends StatefulWidget {
  final List<TimeSlot> timeSlots;
  final List<ClinicLocation> locations;
  final SelectedAppointment? selectedAppointment;
  final Function(TimeSlot) onSelectTimeSlot;
  final Function(ClinicLocation) onSelectLocation;
  final VoidCallback onConfirm;

  const _AppointmentSelectionWidget({
    required this.timeSlots,
    required this.locations,
    required this.selectedAppointment,
    required this.onSelectTimeSlot,
    required this.onSelectLocation,
    required this.onConfirm,
  });

  @override
  State<_AppointmentSelectionWidget> createState() => _AppointmentSelectionWidgetState();
}

class _AppointmentSelectionWidgetState extends State<_AppointmentSelectionWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedAppointment = widget.selectedAppointment;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step 1: Time Slots
          if (selectedAppointment?.timeSlot == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Time Slot',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.timeSlots.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final slot = widget.timeSlots[index];
                      return _TimeSlotCard(
                        slot: slot,
                        onTap: () => widget.onSelectTimeSlot(slot),
                      );
                    },
                  ),
                ),
              ],
            ),
          // Step 2: Locations
          if (selectedAppointment?.timeSlot != null && selectedAppointment?.location == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Clinic Location (within 5 miles)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.locations.map(
                  (location) => _LocationCard(
                    location: location,
                    isSelected: widget.selectedAppointment?.location == location,
                    onTap: () => widget.onSelectLocation(location),
                  ),
                ),
              ],
            ),
          // Step 3: Confirmation
          if (selectedAppointment?.location != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Appointment',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAppointment!.location!.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '📍 ${selectedAppointment.location!.address}',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '🕐 ${selectedAppointment.timeSlot.time} - ${selectedAppointment.timeSlot.date}',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Confirm Appointment'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Time Slot Card
class _TimeSlotCard extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onTap;

  const _TimeSlotCard({
    required this.slot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              slot.date,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Location Card
class _LocationCard extends StatelessWidget {
  final ClinicLocation location;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationCard({
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue[500]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[500],
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 12, color: Colors.white),
                ),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.orange[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${location.distance} mi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star, size: 14, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${location.rating}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[600],
                        ),
                      ),
                    ],
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

/// Message Input Field
class _MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool isEnabled;
  final String placeholder;

  const _MessageInputField({
    required this.controller,
    required this.onSend,
    required this.isEnabled,
    this.placeholder = 'Describe your symptoms...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEnabled,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: isEnabled ? onSend : null,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: isEnabled ? () => onSend(controller.text) : null,
            backgroundColor: const Color(0xFFCC0000),
            child: const Icon(Icons.send, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Data Models
class AgentMessage {
  final String text;
  final bool isAgent;
  final DateTime timestamp;
  final bool isStreaming;

  AgentMessage({
    required this.text,
    required this.isAgent,
    required this.timestamp,
    this.isStreaming = false,
  });
}

class TimeSlot {
  final String time;
  final String date;
  final bool available;

  TimeSlot({
    required this.time,
    required this.date,
    required this.available,
  });
}

class ClinicLocation {
  final String name;
  final String address;
  final double distance;
  final double rating;

  ClinicLocation({
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
  });
}

class SelectedAppointment {
  final TimeSlot timeSlot;
  final ClinicLocation? location;

  SelectedAppointment({
    required this.timeSlot,
    this.location,
  });
}
