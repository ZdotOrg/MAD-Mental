import 'package:flutter/material.dart';
import 'package:mental_zen/services/auth_service.dart';
import 'package:mental_zen/services/mood_service.dart';

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  final MoodService _moodService = MoodService();
  final AuthService _authService = AuthService();
  final TextEditingController _notesController = TextEditingController();

  double _sliderValue = 0; // -5 to +5
  final List<String> _selectedTags = [];
  bool _isLoading = false;

  final List<String> _availableTags = [
    'Happy',
    'Sad',
    'Anxious',
    'Calm',
    'Energetic',
    'Tired',
    'Stressed',
    'Grateful',
    'Angry',
    'Peaceful',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _starRating => _sliderValue.abs().round();
  bool get _isPositive => _sliderValue > 0;
  bool get _isNeutral => _sliderValue == 0;

  Future<void> _saveMoodEntry() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _moodService.createMoodEntry(
        userId: user.uid,
        moodValue: _sliderValue.round(),
        tags: _selectedTags,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood entry saved!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form
        setState(() {
          _sliderValue = 0;
          _selectedTags.clear();
          _notesController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save mood: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Your Mood'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Move the slider to rate your mood',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Star Display
            Center(
              child: _buildStarDisplay(),
            ),
            const SizedBox(height: 24),

            // Mood Slider
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Very Negative',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Neutral',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Very Positive',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _sliderValue,
                      min: -5,
                      max: 5,
                      divisions: 10,
                      label: _sliderValue.round().toString(),
                      activeColor: _isPositive 
                          ? Colors.amber 
                          : (_isNeutral ? Colors.grey : Colors.black),
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                    ),
                    Text(
                      'Current: ${_sliderValue.round()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Mood Tags
            const Text(
              'Add Tags (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF667EEA).withOpacity(0.3),
                  checkmarkColor: const Color(0xFF667EEA),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Notes
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMoodEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Mood Entry',
                        style: TextStyle(
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

  Widget _buildStarDisplay() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isActive = starNumber <= _starRating;
            
            // Determine star color
            Color starColor;
            if (_isNeutral || !isActive) {
              starColor = Colors.grey[300]!;
            } else if (_isPositive) {
              starColor = Colors.amber;
            } else {
              starColor = Colors.black87;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                isActive ? Icons.star : Icons.star_border,
                size: 48,
                color: starColor,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          _getMoodLabel(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _isPositive 
                ? Colors.amber[700] 
                : (_isNeutral ? Colors.grey : Colors.black87),
          ),
        ),
      ],
    );
  }

  String _getMoodLabel() {
    if (_isNeutral) return 'Neutral';
    
    final rating = _starRating;
    if (_isPositive) {
      switch (rating) {
        case 1:
          return 'Slightly Positive';
        case 2:
          return 'Positive';
        case 3:
          return 'Good';
        case 4:
          return 'Very Good';
        case 5:
          return 'Excellent';
        default:
          return 'Positive';
      }
    } else {
      switch (rating) {
        case 1:
          return 'Slightly Negative';
        case 2:
          return 'Negative';
        case 3:
          return 'Bad';
        case 4:
          return 'Very Bad';
        case 5:
          return 'Terrible';
        default:
          return 'Negative';
      }
    }
  }
}