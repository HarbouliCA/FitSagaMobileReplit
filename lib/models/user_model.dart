import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user in the FitSAGA app with role-based permissions and credit system
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String phoneNumber;
  final String role; // 'admin', 'instructor', 'client'
  final Map<String, dynamic> preferences;
  final List<String> favoriteSessionTypes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final CreditBalance credits;
  final UserMembership? membership;
  final Map<String, dynamic>? healthData;
  final String? fcmToken; // Firebase Cloud Messaging token for push notifications
  
  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.phoneNumber,
    required this.role,
    required this.preferences,
    required this.favoriteSessionTypes,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    required this.credits,
    this.membership,
    this.healthData,
    this.fcmToken,
  });
  
  /// Create from Firebase Auth User and additional Firestore data
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse nested objects
    final creditsData = data['credits'] as Map<String, dynamic>? ?? {};
    final membershipData = data['membership'] as Map<String, dynamic>?;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'FitSAGA User',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ?? 'client',
      preferences: data['preferences'] as Map<String, dynamic>? ?? {},
      favoriteSessionTypes: data['favoriteSessionTypes'] != null 
          ? List<String>.from(data['favoriteSessionTypes']) 
          : [],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      credits: CreditBalance.fromMap(creditsData),
      membership: membershipData != null ? UserMembership.fromMap(membershipData) : null,
      healthData: data['healthData'] as Map<String, dynamic>?,
      fcmToken: data['fcmToken'],
    );
  }
  
  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'role': role,
      'preferences': preferences,
      'favoriteSessionTypes': favoriteSessionTypes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'credits': credits.toMap(),
      'membership': membership?.toMap(),
      'healthData': healthData,
      'fcmToken': fcmToken,
    };
  }
  
  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? role,
    Map<String, dynamic>? preferences,
    List<String>? favoriteSessionTypes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    CreditBalance? credits,
    UserMembership? membership,
    Map<String, dynamic>? healthData,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      favoriteSessionTypes: favoriteSessionTypes ?? this.favoriteSessionTypes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      credits: credits ?? this.credits,
      membership: membership ?? this.membership,
      healthData: healthData ?? this.healthData,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
  
  /// Check if user is an admin
  bool get isAdmin => role == 'admin';
  
  /// Check if user is an instructor
  bool get isInstructor => role == 'instructor';
  
  /// Check if user is a client
  bool get isClient => role == 'client';
  
  /// Check if user has an active membership
  bool get hasMembership => membership != null && membership!.isActive;
  
  /// Get first name
  String get firstName {
    final parts = displayName.split(' ');
    return parts.isNotEmpty ? parts.first : displayName;
  }
  
  /// Get avatar initials for display when photo is not available
  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return 'U';
  }
  
  /// Create a sample user for demo purposes
  static UserModel createDemoUser({
    String id = 'demo-user',
    String role = 'client',
    bool isAdmin = false,
    bool isInstructor = false,
  }) {
    final String actualRole;
    if (isAdmin) {
      actualRole = 'admin';
    } else if (isInstructor) {
      actualRole = 'instructor';
    } else {
      actualRole = role;
    }
    
    return UserModel(
      id: id,
      email: 'demo@fitsaga.com',
      displayName: isAdmin 
          ? 'Admin User' 
          : (isInstructor ? 'Instructor Demo' : 'Client Demo'),
      photoUrl: null,
      phoneNumber: '+1234567890',
      role: actualRole,
      preferences: {
        'theme': 'light',
        'notifications': true,
        'emailUpdates': true,
      },
      favoriteSessionTypes: ['yoga', 'hiit', 'strength'],
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
      credits: CreditBalance(
        gymCredits: 10,
        intervalCredits: 5,
        creditHistory: [
          CreditTransaction(
            id: 'tx1',
            creditType: 'gym',
            amount: 10,
            date: DateTime.now().subtract(const Duration(days: 10)),
            source: 'purchase',
            note: 'Initial credit package',
          ),
          CreditTransaction(
            id: 'tx2',
            creditType: 'interval',
            amount: 5,
            date: DateTime.now().subtract(const Duration(days: 5)),
            source: 'membership',
            note: 'Monthly membership allocation',
          ),
        ],
      ),
      membership: UserMembership(
        plan: 'premium',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 335)),
        isActive: true,
        paymentMethod: 'card_ending_1234',
        autoRenew: true,
        monthlyGymCredits: 10,
        monthlyIntervalCredits: 5,
      ),
      healthData: {
        'height': 175,
        'weight': 70,
        'fitnessGoal': 'strength',
        'activityLevel': 'moderate',
      },
      fcmToken: 'demo-fcm-token',
    );
  }
}

/// Represents a user's credit balance and transaction history
class CreditBalance {
  final int gymCredits;
  final int intervalCredits;
  final List<CreditTransaction> creditHistory;
  
  CreditBalance({
    this.gymCredits = 0,
    this.intervalCredits = 0,
    this.creditHistory = const [],
  });
  
  /// Create from map
  factory CreditBalance.fromMap(Map<String, dynamic> map) {
    List<CreditTransaction> history = [];
    if (map['creditHistory'] != null) {
      history = (map['creditHistory'] as List)
          .map((tx) => CreditTransaction.fromMap(tx as Map<String, dynamic>))
          .toList();
    }
    
    return CreditBalance(
      gymCredits: map['gymCredits'] ?? 0,
      intervalCredits: map['intervalCredits'] ?? 0,
      creditHistory: history,
    );
  }
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'gymCredits': gymCredits,
      'intervalCredits': intervalCredits,
      'creditHistory': creditHistory.map((tx) => tx.toMap()).toList(),
    };
  }
  
  /// Create a copy with updated fields
  CreditBalance copyWith({
    int? gymCredits,
    int? intervalCredits,
    List<CreditTransaction>? creditHistory,
  }) {
    return CreditBalance(
      gymCredits: gymCredits ?? this.gymCredits,
      intervalCredits: intervalCredits ?? this.intervalCredits,
      creditHistory: creditHistory ?? this.creditHistory,
    );
  }
  
  /// Add new credits and record the transaction
  CreditBalance addCredits({
    required String creditType,
    required int amount,
    required String source,
    String? note,
  }) {
    if (amount <= 0) return this;
    
    final newTransaction = CreditTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      creditType: creditType,
      amount: amount,
      date: DateTime.now(),
      source: source,
      note: note,
    );
    
    final updatedHistory = [...creditHistory, newTransaction];
    
    if (creditType == 'gym') {
      return copyWith(
        gymCredits: gymCredits + amount,
        creditHistory: updatedHistory,
      );
    } else if (creditType == 'interval') {
      return copyWith(
        intervalCredits: intervalCredits + amount,
        creditHistory: updatedHistory,
      );
    }
    
    return this;
  }
  
  /// Deduct credits from balance
  CreditBalance useCredits({
    required String creditType,
    required int amount,
    required String reason,
    String? note,
  }) {
    if (amount <= 0) return this;
    
    final newTransaction = CreditTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      creditType: creditType,
      amount: -amount,  // Negative amount for deduction
      date: DateTime.now(),
      source: reason,
      note: note,
    );
    
    final updatedHistory = [...creditHistory, newTransaction];
    
    if (creditType == 'gym') {
      if (gymCredits < amount) {
        throw Exception('Insufficient gym credits');
      }
      return copyWith(
        gymCredits: gymCredits - amount,
        creditHistory: updatedHistory,
      );
    } else if (creditType == 'interval') {
      if (intervalCredits < amount) {
        throw Exception('Insufficient interval credits');
      }
      return copyWith(
        intervalCredits: intervalCredits - amount,
        creditHistory: updatedHistory,
      );
    }
    
    return this;
  }
  
  /// Check if user has enough credits of a given type
  bool hasEnoughCredits({required String creditType, required int amount}) {
    if (creditType == 'gym') {
      return gymCredits >= amount;
    } else if (creditType == 'interval') {
      return intervalCredits >= amount;
    }
    return false;
  }
  
  /// Get recent credit transactions
  List<CreditTransaction> getRecentTransactions({int limit = 10}) {
    final sortedTransactions = List<CreditTransaction>.from(creditHistory)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return sortedTransactions.take(limit).toList();
  }
}

/// Represents a credit transaction
class CreditTransaction {
  final String id;
  final String creditType; // 'gym' or 'interval'
  final int amount; // Positive for additions, negative for deductions
  final DateTime date;
  final String source; // 'purchase', 'membership', 'booking', 'refund', etc.
  final String? note;
  
  CreditTransaction({
    required this.id,
    required this.creditType,
    required this.amount,
    required this.date,
    required this.source,
    this.note,
  });
  
  /// Create from map
  factory CreditTransaction.fromMap(Map<String, dynamic> map) {
    return CreditTransaction(
      id: map['id'] ?? '',
      creditType: map['creditType'] ?? 'gym',
      amount: map['amount'] ?? 0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      source: map['source'] ?? '',
      note: map['note'],
    );
  }
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creditType': creditType,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'source': source,
      'note': note,
    };
  }
  
  /// Check if this transaction is a credit addition
  bool get isAddition => amount > 0;
  
  /// Check if this transaction is a credit deduction
  bool get isDeduction => amount < 0;
  
  /// Get formatted amount string with sign
  String get formattedAmount => isAddition ? '+$amount' : '$amount';
}

/// Represents a user's membership plan
class UserMembership {
  final String plan; // 'basic', 'premium', 'platinum'
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? paymentMethod;
  final bool autoRenew;
  final int monthlyGymCredits;
  final int monthlyIntervalCredits;
  
  UserMembership({
    required this.plan,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.paymentMethod,
    this.autoRenew = true,
    this.monthlyGymCredits = 0,
    this.monthlyIntervalCredits = 0,
  });
  
  /// Create from map
  factory UserMembership.fromMap(Map<String, dynamic> map) {
    return UserMembership(
      plan: map['plan'] ?? 'basic',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
      isActive: map['isActive'] ?? true,
      paymentMethod: map['paymentMethod'],
      autoRenew: map['autoRenew'] ?? true,
      monthlyGymCredits: map['monthlyGymCredits'] ?? 0,
      monthlyIntervalCredits: map['monthlyIntervalCredits'] ?? 0,
    );
  }
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'paymentMethod': paymentMethod,
      'autoRenew': autoRenew,
      'monthlyGymCredits': monthlyGymCredits,
      'monthlyIntervalCredits': monthlyIntervalCredits,
    };
  }
  
  /// Create a copy with updated fields
  UserMembership copyWith({
    String? plan,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? paymentMethod,
    bool? autoRenew,
    int? monthlyGymCredits,
    int? monthlyIntervalCredits,
  }) {
    return UserMembership(
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      autoRenew: autoRenew ?? this.autoRenew,
      monthlyGymCredits: monthlyGymCredits ?? this.monthlyGymCredits,
      monthlyIntervalCredits: monthlyIntervalCredits ?? this.monthlyIntervalCredits,
    );
  }
  
  /// Get days remaining in current membership period
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
  
  /// Check if membership is about to expire soon (within 7 days)
  bool get isExpiringSoon {
    return isActive && daysRemaining <= 7;
  }
  
  /// Get membership duration in months
  int get durationMonths {
    return endDate.difference(startDate).inDays ~/ 30;
  }
}