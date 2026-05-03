import 'package:cloud_firestore/cloud_firestore.dart';

class MoodModel {
  final String id;
  final String userId;
  final int moodValue; // -5 to +5
  final List<String> tags;
  final String? notes;
  final DateTime timestamp;

  MoodModel({
    required this.id,
    required this.userId,
    required this.moodValue,
    required this.tags,
    this.notes,
    required this.timestamp,
  });

  // Convert from Firestore
  factory MoodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodModel(
      id: doc.id,
      userId: data['userId'] as String,
      moodValue: data['moodValue'] as int,
      tags: List<String>.from(data['tags'] ?? []),
      notes: data['notes'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'moodValue': moodValue,
      'tags': tags,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Helper: Get star rating (1-5)
  int get starRating => moodValue.abs();

  // Helper: Check if mood is positive
  bool get isPositive => moodValue > 0;

  // Helper: Check if mood is neutral
  bool get isNeutral => moodValue == 0;
}