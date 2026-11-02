import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../core/constants/app_colors.dart';

class ApplicationItem {
  final String title;
  final String category;
  final IconData icon;
  final String problem;
  final String whyAnn;
  final String inputData;
  final String outputData;
  final String workflow;
  final String benefits;
  final String limitations;

  ApplicationItem({
    required this.title,
    required this.category,
    required this.icon,
    required this.problem,
    required this.whyAnn,
    required this.inputData,
    required this.outputData,
    required this.workflow,
    required this.benefits,
    required this.limitations,
  });
}

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final List<ApplicationItem> _apps = [
    ApplicationItem(
      title: 'Medical Image & Disease Classification',
      category: 'Healthcare',
      icon: Icons.local_hospital_rounded,
      problem: 'Detecting pathological anomalies (tumors, lesions) in diagnostic X-rays, MRIs, and CT scans.',
      whyAnn: 'ANNs model high-dimensional non-linear feature maps to differentiate subtle pixel patterns.',
      inputData: 'Normalized pixel intensity matrix (e.g. 256x256 image arrays).',
      outputData: 'Probability distributions across diagnostic disease classes (e.g. 92% Benign, 8% Malignant).',
      workflow: 'Image Preprocessing → Feature Extraction via Conv/Dense Layers → Softmax Output → Radiologist Review.',
      benefits: 'High consistency, rapid triage screening, reduces diagnostic fatigue.',
      limitations: 'Requires large labeled datasets; sensitivity to distribution shifts across scan machines.',
    ),
    ApplicationItem(
      title: 'Automated Visual Inspection',
      category: 'Computer Vision',
      icon: Icons.remove_red_eye_rounded,
      problem: 'Identifying micro-defects and cracks on high-speed industrial manufacturing lines.',
      whyAnn: 'Subtle scratches and solder bridge defects vary randomly; traditional rule-based algorithms fail.',
      inputData: 'High-speed camera sensor frames & depth sensors.',
      outputData: 'Defect location bounding box and Pass/Fail classification flag.',
      workflow: 'Frame Capture → Normalization → Layer Forward Pass → Real-time Actuator Trigger.',
      benefits: 'Sub-millisecond latency, operates 24/7 with uniform quality standards.',
      limitations: 'Lighting variations can affect inference accuracy; requires edge TPU hardware.',
    ),
    ApplicationItem(
      title: 'Sentiment & Intent Classification',
      category: 'Natural Language Processing',
      icon: Icons.chat_bubble_rounded,
      problem: 'Categorizing customer feedback and support queries into emotional sentiment and actionable intent.',
      whyAnn: 'Non-linear word embedding matrices map semantic context beyond simple keyword matching.',
      inputData: 'Tokenized text vector embeddings (TF-IDF or dense embeddings).',
      outputData: 'Sentiment score (Positive / Negative / Neutral) and Routing department category.',
      workflow: 'Tokenization → Vector Embedding → Dense Network Layers → Softmax Category Output.',
      benefits: 'Automates support ticket routing, scales to millions of reviews instantly.',
      limitations: 'Sarcasm and double negatives can occasionally misguide classification.',
    ),
    ApplicationItem(
      title: 'Credit Risk & Loan Default Scoring',
      category: 'Finance',
      icon: Icons.account_balance_rounded,
      problem: 'Evaluating financial risk profiles to predict loan repayment probability.',
      whyAnn: 'ANNs combine multi-variate non-linear interactions across income, debt, history, and macros.',
      inputData: 'Normalized financial features (Debt ratio, Credit Score, Employment duration, Income).',
      outputData: 'Continuous default risk score between 0.0 and 1.0.',
      workflow: 'Feature Preprocessing → Standard Scaling → Forward Pass → Risk Thresholding.',
      benefits: 'Outperforms logistic regression on non-linear risk interactions.',
      limitations: 'Model explainability challenges under financial regulatory audit requirements.',
    ),
    ApplicationItem(
      title: 'Predictive Equipment Maintenance',
      category: 'Manufacturing',
      icon: Icons.precision_manufacturing_rounded,
      problem: 'Predicting industrial turbine component failures before catastrophic mechanical breakdown.',
      whyAnn: 'Multi-sensor temporal telemetry exhibits complex vibrational patterns prior to structural failure.',
      inputData: 'Vibration amplitude, motor temperature, RPM, and lubricant pressure time-series.',
      outputData: 'Remaining Useful Life (RUL) estimation in operational hours.',
      workflow: 'Sensor Telemetry Streaming → Sliding Window Feature Vector → ANN Regression → Alert Trigger.',
      benefits: 'Prevents costly factory downtime and extends machinery longevity.',
      limitations: 'Rare failure modes may lack sufficient historical training samples.',
    ),
    ApplicationItem(
      title: 'Robot Arm Inverse Kinematics',
      category: 'Robotics',
      icon: Icons.smart_toy_rounded,
      problem: 'Computing exact joint angles needed to place a robotic end-effector at target Cartesian (x,y,z).',
      whyAnn: 'Analytical inverse kinematics are computationally intense and multi-valued for redundant joints.',
      inputData: 'Target Cartesian coordinate vector (x, y, z) and payload weight.',
      outputData: 'Target joint angle vector [θ1, θ2, θ3, θ4].',
      workflow: 'Target Coordinate Input → Forward Pass through ANN → Servo Controller Vector.',
      benefits: 'Real-time microsecond calculation speed for smooth kinematic trajectory planning.',
      limitations: 'Precision bounded by training dataset sampling density across physical workspace.',
    ),
  ];

  ApplicationItem? _selectedApp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANN Applications Explorer',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Discover how Artificial Neural Networks power 12 modern industrial & scientific domains',
            style: TextStyle(
              color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Applications Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _apps.length,
            itemBuilder: (context, idx) {
              final app = _apps[idx];
              final isSelected = _selectedApp == app;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedApp = app;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : (isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0)),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(app.icon, color: isSelected ? AppColors.gold : AppColors.electricBlue, size: 28),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.electricBlue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                app.category,
                                style: const TextStyle(fontSize: 10, color: AppColors.electricBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          app.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Detailed Selected Application Viewer
          if (_selectedApp != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withOpacity(0.6), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_selectedApp!.icon, color: AppColors.gold, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedApp!.title,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailSection('Problem Being Solved', _selectedApp!.problem, isDark),
                  _buildDetailSection('Why Artificial Neural Networks Help', _selectedApp!.whyAnn, isDark),
                  _buildDetailSection('Input Feature Vector', _selectedApp!.inputData, isDark),
                  _buildDetailSection('Network Output', _selectedApp!.outputData, isDark),
                  _buildDetailSection('Example Workflow', _selectedApp!.workflow, isDark),
                  _buildDetailSection('Key Benefits', _selectedApp!.benefits, isDark),
                  _buildDetailSection('Limitations & Considerations', _selectedApp!.limitations, isDark),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }
}
