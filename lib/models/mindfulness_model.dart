import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MindfulnessType {
  audio,
  video,
}

enum MindfulnessCategory {
  relaxation,
  meditation,
  breathing,
  sleep,
  anxiety,
  focus,
}

class MindfulnessResource {
  final String id;
  final String title;
  final String description;
  final MindfulnessType type;
  final MindfulnessCategory category;
  final String fileUrl; // Firebase Storage URL
  final String? thumbnailUrl;
  final int durationSeconds; // Duration in seconds
  final bool isPremium;
  final int viewCount;
  final DateTime createdAt;

  MindfulnessResource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    this.isPremium = false,
    this.viewCount = 0,
    required this.createdAt,
  });

  factory MindfulnessResource.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MindfulnessResource(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      type: MindfulnessType.values.firstWhere(
        (e) => e.toString() == 'MindfulnessType.${data['type']}',
      ),
      category: MindfulnessCategory.values.firstWhere(
        (e) => e.toString() == 'MindfulnessCategory.${data['category']}',
      ),
      fileUrl: data['fileUrl'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      durationSeconds: data['durationSeconds'] as int,
      isPremium: data['isPremium'] as bool? ?? false,
      viewCount: data['viewCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'isPremium': isPremium,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get categoryLabel {
    switch (category) {
      case MindfulnessCategory.relaxation:
        return 'Relaxation';
      case MindfulnessCategory.meditation:
        return 'Meditation';
      case MindfulnessCategory.breathing:
        return 'Breathing';
      case MindfulnessCategory.sleep:
        return 'Sleep';
      case MindfulnessCategory.anxiety:
        return 'Anxiety Relief';
      case MindfulnessCategory.focus:
        return 'Focus';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case MindfulnessCategory.relaxation:
        return Icons.spa;
      case MindfulnessCategory.meditation:
        return Icons.self_improvement;
      case MindfulnessCategory.breathing:
        return Icons.air;
      case MindfulnessCategory.sleep:
        return Icons.bedtime;
      case MindfulnessCategory.anxiety:
        return Icons.favorite;
      case MindfulnessCategory.focus:
        return Icons.center_focus_strong;
    }
  }
}