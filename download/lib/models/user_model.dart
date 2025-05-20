import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing user roles in the FitSAGA app
enum UserRole {
  /// Admin users can manage all aspects of the system
  admin,
  
  /// Instructors can create and manage sessions and tutorials
  instructor,
  
  /// Regular gym clients who book sessions and view tutorials
  client,
}

/// Extension to convert string to UserRole enum
extension UserRoleExtension on String {
  UserRole toUserRole() {
    switch (this.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'instructor':
        return UserRole.instructor;
      case 'client':
      default:
        return UserRole.client;
    }
  }
}

/// Model class representing a user in the FitSAGA app
class UserModel {
  /// Unique user identifier, typically from Firebase Auth
  final String id;
  
  /// User's full name
  String name;
  
  /// User's email address, used for authentication
  final String email;
  
  /// User's role in the system (admin, instructor, client)
  UserRole role;
  
  /// URL to user's profile photo (optional)
  String? photoUrl;
  
  /// Timestamp when the user account was created
  final DateTime createdAt;
  
  /// Constructor for creating a new UserModel
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.createdAt,
  });
  
  /// Creates a UserModel from a Firebase document map
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: (map['role'] as String? ?? 'client').toUserRole(),
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  /// Converts the UserModel to a map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  /// Checks if user has admin privileges
  bool get isAdmin => role == UserRole.admin;
  
  /// Checks if user has instructor privileges
  bool get isInstructor => role == UserRole.instructor || role == UserRole.admin;
  
  /// Checks if user is a regular client
  bool get isClient => role == UserRole.client;
  
  /// Creates a copy of this UserModel with optional new values
  UserModel copyWith({
    String? name,
    UserRole? role,
    String? photoUrl,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      email: this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }
}