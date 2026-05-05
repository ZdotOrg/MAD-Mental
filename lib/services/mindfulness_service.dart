import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_zen/models/mindfulness_model.dart';

class MindfulnessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all resources stream
  Stream<List<MindfulnessResource>> getResourcesStream() {
    return _firestore
        .collection('mindfulness_resources')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🔍 All resources count: ${snapshot.docs.length}'); // DEBUG
          snapshot.docs.forEach((doc) {
            print('📄 ${doc.id}: ${doc.data()}'); // DEBUG
          });
          return snapshot.docs
              .map((doc) => MindfulnessResource.fromFirestore(doc))
              .toList();
        });
  }

  // Get resources by category
  Stream<List<MindfulnessResource>> getResourcesByCategory(
      MindfulnessCategory category) {
    return _firestore
        .collection('mindfulness_resources')
        .where('category', isEqualTo: category.toString().split('.').last)
        // REMOVED orderBy to fix index issue
        .snapshots()
        .map((snapshot) {
          print('🔍 Category ${category.toString().split('.').last} count: ${snapshot.docs.length}'); // DEBUG
          return snapshot.docs
              .map((doc) => MindfulnessResource.fromFirestore(doc))
              .toList();
        });
  }

  // Get resources by type (audio/video)
  Stream<List<MindfulnessResource>> getResourcesByType(
      MindfulnessType type) {
    return _firestore
        .collection('mindfulness_resources')
        .where('type', isEqualTo: type.toString().split('.').last)
        // REMOVED orderBy to fix index issue
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MindfulnessResource.fromFirestore(doc))
            .toList());
  }

  // Increment view count
  Future<void> incrementViewCount(String resourceId) async {
    try {
      await _firestore
          .collection('mindfulness_resources')
          .doc(resourceId)
          .update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // Get featured resources
  Future<List<MindfulnessResource>> getFeaturedResources() async {
    try {
      final snapshot = await _firestore
          .collection('mindfulness_resources')
          .orderBy('viewCount', descending: true)
          .limit(6)
          .get();

      return snapshot.docs
          .map((doc) => MindfulnessResource.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting featured resources: $e');
      return [];
    }
  }
}