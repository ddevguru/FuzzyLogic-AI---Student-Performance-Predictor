import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/learning_topics_data.dart';
import '../models/learning_topic.dart';
import '../widgets/common/custom_card.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Fundamentals',
    'Core Concepts',
    'Algorithms',
    'Optimization Theory',
    'Analysis',
    'Applications',
    'Comparison',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTopics = LearningTopicsData.topics.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.definition.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.simpleExplanation.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'All' || t.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.school_rounded, color: AppColors.gold, size: 36),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Swarm Intelligence Knowledge Base',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '21 core academic topics prepared for engineering viva and conceptual clarity.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search topics, definitions, or algorithms...',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              filled: true,
              fillColor: isDark ? AppColors.darkCard : AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            onChanged: (val) {
              setState(() => _searchQuery = val);
            },
          ),
          const SizedBox(height: 14),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: isDark ? AppColors.blue : AppColors.primaryNavy,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.mainText),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Topics List
          Text(
            'Showing ${filteredTopics.length} Topics',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTopics.length,
            separatorBuilder: (_, index) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              return _buildTopicCard(filteredTopics[i], isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(LearningTopic topic, bool isDark) {
    return CustomCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.blue : AppColors.primaryNavy).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '#${topic.id}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentCyan : AppColors.primaryNavy,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                topic.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            topic.definition,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        children: [
          const Divider(height: 20),
          _buildDetailRow('Definition:', topic.definition, isDark),
          _buildDetailRow('Simple Explanation:', topic.simpleExplanation, isDark),
          _buildDetailRow('Practical Real-World Example:', topic.practicalExample, isDark),
          if (topic.formula != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1B2E) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mathematical Formula:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    topic.formula!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? AppColors.gold : AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          _buildDetailRow('Visual Explanation:', topic.visualExplanation, isDark),
          _buildDetailRow('How it Relates to This App:', topic.relationToApp, isDark, highlight: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String content, bool isDark, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.green : (isDark ? Colors.white70 : AppColors.mainText),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
