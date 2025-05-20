import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole {
  client,
  instructor,
  admin
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final int credits;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.credits,
    required this.createdAt,
    this.updatedAt,
    this.photoUrl,
    this.phoneNumber,
    this.isActive = true,
    this.metadata,
  });

  // Role checkers
  bool get isAdmin => role == UserRole.admin;
  bool get isInstructor => role == UserRole.instructor;
  bool get isClient => role == UserRole.client;
  
  // Role-based permissions
  bool get canManageSessions => isAdmin || isInstructor;
  bool get canManageAllUsers => isAdmin;
  bool get canAccessAdmin => isAdmin;
  bool get canCreateTutorials => isAdmin || isInstructor;
  bool get canBookSessions => isClient || isAdmin;

  // Factory method to create a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: _parseRole(data['role']),
      credits: data['credits'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      isActive: data['isActive'] ?? true,
      metadata: data['metadata'],
    );
  }

  // Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    int? credits,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photoUrl,
    String? phoneNumber,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': _roleToString(role),
      'credits': credits,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  // Helper methods for role conversion
  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'instructor':
        return UserRole.instructor;
      case 'client':
      default:
        return UserRole.client;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.instructor:
        return 'instructor';
      case UserRole.client:
        return 'client';
    }
  }

  // For equality comparison
  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    credits,
    createdAt,
    updatedAt,
    photoUrl,
    phoneNumber,
    isActive,
  ];

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, role: ${_roleToString(role)})';
  }
}