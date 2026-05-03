import 'package:flutter/material.dart';
import 'package:mental_zen/services/auth_service.dart';
import 'package:mental_zen/services/mood_service.dart';
import 'package:mental_zen/models/mood_model.dart';
import 'package:mental_zen/screens/login_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final MoodService _moodService = MoodService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Zen'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.displayName ?? user?.email?.split('@')[0] ?? 'User',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Mood Card
                if (user != null) ...[
                  FutureBuilder<MoodModel?>(
                    future: _moodService.getTodaysMoodEntry(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      final todaysMood = snapshot.data;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.today,
                                    color: Color(0xFF667EEA),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Today\'s Mood',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (todaysMood != null) ...[
                                _buildMoodDisplay(todaysMood),
                              ] else ...[
                                Text(
                                  'You haven\'t tracked your mood today yet.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tap the Mood tab to track how you\'re feeling!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF667EEA),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Recent Moods
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.history,
                                color: Color(0xFF667EEA),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Recent Moods',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<MoodModel>>(
                            stream: _moodService.getMoodEntriesStream(user.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text(
                                  'No mood entries yet. Start tracking today!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                );
                              }

                              final recentMoods = snapshot.data!.take(5).toList();

                              return Column(
                                children: recentMoods.map((mood) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: _buildMoodListItem(mood),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statistics Card
                  FutureBuilder<Map<String, dynamic>>(
                    future: _moodService.getMoodStatistics(user.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final stats = snapshot.data!;
                      final totalEntries = stats['totalEntries'] as int;

                      if (totalEntries == 0) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.analytics,
                                    color: Color(0xFF667EEA),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '30-Day Summary',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Total Entries',
                                    totalEntries.toString(),
                                    Icons.edit_note,
                                  ),
                                  _buildStatItem(
                                    'Avg Mood',
                                    (stats['averageMood'] as double).toStringAsFixed(1),
                                    Icons.trending_up,
                                  ),
                                  _buildStatItem(
                                    'Positive Days',
                                    stats['positiveCount'].toString(),
                                    Icons.sunny,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodDisplay(MoodModel mood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isActive = starNumber <= mood.starRating;
            
            Color starColor;
            if (!isActive) {
              starColor = Colors.grey[300]!;
            } else if (mood.isPositive) {
              starColor = Colors.amber;
            } else if (mood.isNeutral) {
              starColor = Colors.grey[300]!;
            } else {
              starColor = Colors.black87;
            }

            return Icon(
              isActive ? Icons.star : Icons.star_border,
              size: 28,
              color: starColor,
            );
          }),
        ),
        if (mood.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: mood.tags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
        if (mood.notes != null && mood.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            mood.notes!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoodListItem(MoodModel mood) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Star display
          Row(
            children: List.generate(mood.starRating, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color: mood.isPositive 
                    ? Colors.amber 
                    : (mood.isNeutral ? Colors.grey : Colors.black87),
              );
            }),
          ),
          const SizedBox(width: 12),
          // Date
          Expanded(
            child: Text(
              DateFormat('MMM dd, yyyy - h:mm a').format(mood.timestamp),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Tags count
          if (mood.tags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${mood.tags.length} tag${mood.tags.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF667EEA),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}