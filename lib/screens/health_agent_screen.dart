import 'package:flutter/material.dart';

/// Health Agent Screen - CVS Health recommendations
class HealthAgentScreen extends StatefulWidget {
  final String? did;

  const HealthAgentScreen({
    super.key,
    this.did,
  });

  @override
  State<HealthAgentScreen> createState() => _HealthAgentScreenState();
}

class _HealthAgentScreenState extends State<HealthAgentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Agent'),
        centerTitle: true,
        backgroundColor: const Color(0xFFCC0000),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Health Recommendations',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17447C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Personalized health insights from CVS Health',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Connect to CVS Health Delegate to receive personalized recommendations',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Recommendations List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(
                    icon: Icons.favorite,
                    color: const Color(0xFFCC0000),
                    title: 'Wellness Check-up',
                    description: 'Schedule your annual wellness exam',
                    actionLabel: 'Schedule Now',
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationCard(
                    icon: Icons.medication,
                    color: const Color(0xFF17447C),
                    title: 'Medication Review',
                    description: 'Review your current medications with a pharmacist',
                    actionLabel: 'Get Advice',
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationCard(
                    icon: Icons.fitness_center,
                    color: const Color(0xFF4CAF50),
                    title: 'Fitness Goal',
                    description: 'Achieve 150 minutes of moderate activity weekly',
                    actionLabel: 'Learn More',
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationCard(
                    icon: Icons.restaurant,
                    color: const Color(0xFFFF9800),
                    title: 'Nutrition Tips',
                    description: 'Personalized meal plans based on your health profile',
                    actionLabel: 'View Plans',
                  ),
                ],
              ),
            ),
            // Health Agent Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green[700], size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Health Agent Connected',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Last synced: Just now',
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
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$actionLabel tapped'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 0),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
