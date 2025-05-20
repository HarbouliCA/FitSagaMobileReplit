import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String type;
  final String name;
  final String? description;
  final int capacity;
  final int duration;
  final int creditValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  ActivityModel({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.capacity,
    required this.duration,
    required this.creditValue,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return ActivityModel(
      id: doc.id,
      type: data['type'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      capacity: data['capacity'] ?? 0,
      duration: data['duration'] ?? 0,
      creditValue: data['creditValue'] ?? 1,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'capacity': capacity,
      'duration': duration,
      'creditValue': creditValue,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to get appropriate activity icon
  String get activityIcon {
    switch (type) {
      case 'ENTREMIENTO_PERSONAL':
        return 'user';
      case 'KICK_BOXING':
        return 'boxing-glove';
      case 'SALE_FITNESS':
        return 'dumbbell';
      case 'CLASES_DERIGIDAS':
        return 'users';
      default:
        return 'activity';
    }
  }
}
