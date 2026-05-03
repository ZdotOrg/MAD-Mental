import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_zen/models/mood_model.dart';

// FULL CRUD operations for mood entries, plus statistics calculation.


class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new mood entry
  Future<void> createMoodEntry({
    required String userId,
    required int moodValue,
    required List<String> tags,
    String? notes,
  }) async {
    try {
      final moodRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc();

      final mood = MoodModel(
        id: moodRef.id,
        userId: userId,
        moodValue: moodValue,
        tags: tags,
        notes: notes,
        timestamp: DateTime.now(),
      );

      await moodRef.set(mood.toFirestore());
    } catch (e) {
      print('Error creating mood entry: $e');
      rethrow;
    }
  }

  // Get all mood entries for a user (stream)
  Stream<List<MoodModel>> getMoodEntriesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('moods')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodModel.fromFirestore(doc))
            .toList());
  }

  // Get mood entries for a specific date range
  Future<List<MoodModel>> getMoodEntriesByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => MoodModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting mood entries by date range: $e');
      rethrow;
    }
  }

  // Get today's mood entry (if exists)
  Future<MoodModel?> getTodaysMoodEntry(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return MoodModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting today\'s mood entry: $e');
      rethrow;
    }
  }

  // Update a mood entry
  Future<void> updateMoodEntry({
    required String userId,
    required String moodId,
    int? moodValue,
    List<String>? tags,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (moodValue != null) updateData['moodValue'] = moodValue;
      if (tags != null) updateData['tags'] = tags;
      if (notes != null) updateData['notes'] = notes;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .update(updateData);
    } catch (e) {
      print('Error updating mood entry: $e');
      rethrow;
    }
  }

  // Delete a mood entry
  Future<void> deleteMoodEntry({
    required String userId,
    required String moodId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .delete();
    } catch (e) {
      print('Error deleting mood entry: $e');
      rethrow;
    }
  }

  // Get mood statistics
  Future<Map<String, dynamic>> getMoodStatistics(String userId) async {
    try {
      final now = DateTime.now();
      final last30Days = now.subtract(const Duration(days: 30));

      final moods = await getMoodEntriesByDateRange(
        userId: userId,
        startDate: last30Days,
        endDate: now,
      );

      if (moods.isEmpty) {
        return {
          'averageMood': 0.0,
          'totalEntries': 0,
          'positiveCount': 0,
          'negativeCount': 0,
          'neutralCount': 0,
        };
      }

      final totalMood = moods.fold<int>(0, (sum, mood) => sum + mood.moodValue);
      final averageMood = totalMood / moods.length;

      final positiveCount = moods.where((m) => m.isPositive).length;
      final negativeCount = moods.where((m) => !m.isPositive && !m.isNeutral).length;
      final neutralCount = moods.where((m) => m.isNeutral).length;

      return {
        'averageMood': averageMood,
        'totalEntries': moods.length,
        'positiveCount': positiveCount,
        'negativeCount': negativeCount,
        'neutralCount': neutralCount,
      };
    } catch (e) {
      print('Error getting mood statistics: $e');
      rethrow;
    }
  }
}