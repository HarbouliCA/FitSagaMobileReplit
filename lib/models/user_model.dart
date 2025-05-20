import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  instructor,
  client,
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.role,
    this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: _mapStringToUserRole(map['role'] as String),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      lastLogin: map['lastLogin'] != null 
          ? (map['lastLogin'] as Timestamp).toDate() 
          : null,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': _mapUserRoleToString(role),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
    };
  }

  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      role: UserRole.client,
    );
  }

  static UserRole _mapStringToUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'instructor':
        return UserRole.instructor;
      case 'client':
      default:
        return UserRole.client;
    }
  }

  static String _mapUserRoleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.instructor:
        return 'instructor';
      case UserRole.client:
        return 'client';
    }
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isInstructor => role == UserRole.instructor;
  bool get isClient => role == UserRole.client;
  bool get isStaff => role == UserRole.admin || role == UserRole.instructor;

  @override
  List<Object?> get props => [
    id, 
    email, 
    name, 
    photoUrl, 
    role, 
    createdAt, 
    lastLogin, 
    isActive
  ];
}