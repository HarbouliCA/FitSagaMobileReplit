enum UserRole {
  admin,
  instructor,
  client,
}

class User {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final UserCredits credits;
  final String? photoUrl;
  final String? phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.credits,
    this.photoUrl,
    this.phoneNumber,
  });

  User copyWith({
    String? displayName,
    UserCredits? credits,
    String? photoUrl,
    String? phoneNumber,
  }) {
    return User(
      id: this.id,
      email: this.email,
      displayName: displayName ?? this.displayName,
      role: this.role,
      credits: credits ?? this.credits,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class UserCredits {
  final int gymCredits;
  final int intervalCredits;

  UserCredits({
    required this.gymCredits,
    required this.intervalCredits,
  });

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

// Test user data
final Map<String, User> testUsers = {
  'admin@test.com': User(
    id: 'admin1',
    email: 'admin@test.com',
    displayName: 'Admin User',
    role: UserRole.admin,
    credits: UserCredits(gymCredits: 0, intervalCredits: 0),
    photoUrl: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857',
    phoneNumber: '+1 (555) 123-4567',
  ),
  'instructor@test.com': User(
    id: 'instructor1',
    email: 'instructor@test.com',
    displayName: 'Instructor User',
    role: UserRole.instructor,
    credits: UserCredits(gymCredits: 0, intervalCredits: 0),
    photoUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
    phoneNumber: '+1 (555) 234-5678',
  ),
  'client@test.com': User(
    id: 'client1',
    email: 'client@test.com',
    displayName: 'Client User',
    role: UserRole.client,
    credits: UserCredits(gymCredits: 15, intervalCredits: 5),
    photoUrl: 'https://images.unsplash.com/photo-1534308143481-c55f00be8bd7',
    phoneNumber: '+1 (555) 345-6789',
  ),
};

// Password mapping for test logins
final Map<String, String> testPasswords = {
  'admin@test.com': 'admin123',
  'instructor@test.com': 'instructor123',
  'client@test.com': 'client123',
};