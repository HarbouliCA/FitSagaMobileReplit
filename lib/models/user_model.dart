import 'package:cloud_firestore/cloud_firestore.dart';

class UserCredits {
  final int gymCredits;
  final int intervalCredits;

  UserCredits({
    required this.gymCredits,
    required this.intervalCredits,
  });

  factory UserCredits.fromJson(Map<String, dynamic> json) {
    return UserCredits(
      gymCredits: json['gymCredits'] ?? 0,
      intervalCredits: json['intervalCredits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gymCredits': gymCredits,
      'intervalCredits': intervalCredits,
    };
  }

  UserCredits copyWith({
    int? gymCredits,
    int? intervalCredits,
  }) {
    return UserCredits(
      gymCredits: gymCredits ?? this.gymCredits,
      intervalCredits: intervalCredits ?? this.intervalCredits,
    );
  }
}

class UserMembership {
  final String plan;
  final DateTime expiryDate;
  final bool autoRenew;
  final int monthlyGymCredits;
  final int monthlyIntervalCredits;

  UserMembership({
    required this.plan,
    required this.expiryDate,
    required this.autoRenew,
    required this.monthlyGymCredits,
    required this.monthlyIntervalCredits,
  });

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    return UserMembership(
      plan: json['plan'] ?? 'Basic',
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
      autoRenew: json['autoRenew'] ?? false,
      monthlyGymCredits: json['monthlyGymCredits'] ?? 0,
      monthlyIntervalCredits: json['monthlyIntervalCredits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'autoRenew': autoRenew,
      'monthlyGymCredits': monthlyGymCredits,
      'monthlyIntervalCredits': monthlyIntervalCredits,
    };
  }

  bool get isExpiringSoon {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    return difference <= 7; // Expiring in 7 days or less
  }

  int get daysRemaining {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String role;
  final UserCredits credits;
  final UserMembership? membership;
  final String? photoUrl;
  final List<String> favoriteInstructors;
  final List<String> favoriteWorkouts;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.role,
    required this.credits,
    this.membership,
    this.photoUrl,
    List<String>? favoriteInstructors,
    List<String>? favoriteWorkouts,
    this.preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) : 
    this.favoriteInstructors = favoriteInstructors ?? [],
    this.favoriteWorkouts = favoriteWorkouts ?? [],
    this.createdAt = createdAt ?? DateTime.now(),
    this.lastLoginAt = lastLoginAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'client',
      credits: UserCredits.fromJson(json['credits'] ?? {}),
      membership: json['membership'] != null 
          ? UserMembership.fromJson(json['membership']) 
          : null,
      photoUrl: json['photoUrl'],
      favoriteInstructors: List<String>.from(json['favoriteInstructors'] ?? []),
      favoriteWorkouts: List<String>.from(json['favoriteWorkouts'] ?? []),
      preferences: json['preferences'],
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null 
          ? (json['lastLoginAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role,
      'credits': credits.toJson(),
      'membership': membership?.toJson(),
      'photoUrl': photoUrl,
      'favoriteInstructors': favoriteInstructors,
      'favoriteWorkouts': favoriteWorkouts,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? role,
    UserCredits? credits,
    UserMembership? membership,
    String? photoUrl,
    List<String>? favoriteInstructors,
    List<String>? favoriteWorkouts,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      credits: credits ?? this.credits,
      membership: membership ?? this.membership,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteInstructors: favoriteInstructors ?? this.favoriteInstructors,
      favoriteWorkouts: favoriteWorkouts ?? this.favoriteWorkouts,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
  
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isInstructor => role.toLowerCase() == 'instructor';
  bool get isClient => role.toLowerCase() == 'client';
  bool get hasMembership => membership != null;
  
  String get firstName {
    return displayName.split(' ').first;
  }
  
  String get initials {
    if (displayName.isEmpty) return '';
    
    final parts = displayName.split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}';
    }
    return parts.first.isNotEmpty ? parts.first[0] : '';
  }
  
  static UserModel empty() {
    return UserModel(
      uid: '',
      email: '',
      displayName: '',
      phoneNumber: '',
      role: 'client',
      credits: UserCredits(gymCredits: 0, intervalCredits: 0),
    );
  }
}