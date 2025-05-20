import 'package:cloud_firestore/cloud_firestore.dart';

class UserCredit {
  final String id;
  final String userId;
  final int gymCredits;
  final int intervalCredits;
  final bool isUnlimited;
  final DateTime lastRefilled;
  final DateTime nextRefill;

  UserCredit({
    required this.id,
    required this.userId,
    required this.gymCredits,
    required this.intervalCredits,
    this.isUnlimited = false,
    required this.lastRefilled,
    required this.nextRefill,
  });

  // Create a credit from Firebase document snapshot
  factory UserCredit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserCredit(
      id: doc.id,
      userId: data['userId'] ?? '',
      gymCredits: data['gymCredits'] ?? 0,
      intervalCredits: data['intervalCredits'] ?? 0,
      isUnlimited: data['isUnlimited'] ?? false,
      lastRefilled: (data['lastRefilled'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nextRefill: (data['nextRefill'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
    );
  }

  // Convert credit to a map for Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'gymCredits': gymCredits,
      'intervalCredits': intervalCredits,
      'isUnlimited': isUnlimited,
      'lastRefilled': Timestamp.fromDate(lastRefilled),
      'nextRefill': Timestamp.fromDate(nextRefill),
    };
  }

  // Create copy of credit with updated fields
  UserCredit copyWith({
    String? id,
    String? userId,
    int? gymCredits,
    int? intervalCredits,
    bool? isUnlimited,
    DateTime? lastRefilled,
    DateTime? nextRefill,
  }) {
    return UserCredit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gymCredits: gymCredits ?? this.gymCredits,
      intervalCredits: intervalCredits ?? this.intervalCredits,
      isUnlimited: isUnlimited ?? this.isUnlimited,
      lastRefilled: lastRefilled ?? this.lastRefilled,
      nextRefill: nextRefill ?? this.nextRefill,
    );
  }

  // Default credits for new users or demo purposes
  factory UserCredit.defaultCredits() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    return UserCredit(
      id: 'default',
      userId: 'default',
      gymCredits: 10,
      intervalCredits: 5,
      isUnlimited: false,
      lastRefilled: now,
      nextRefill: nextMonth,
    );
  }
}

class CreditAdjustment {
  final String id;
  final String userId;
  final int gymCreditChange;
  final int intervalCreditChange;
  final String reason;
  final String? relatedBookingId;
  final DateTime adjustedAt;
  final String adjustedBy;

  CreditAdjustment({
    required this.id,
    required this.userId,
    required this.gymCreditChange,
    required this.intervalCreditChange,
    required this.reason,
    this.relatedBookingId,
    required this.adjustedAt,
    required this.adjustedBy,
  });

  // Create a credit adjustment from Firebase document snapshot
  factory CreditAdjustment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CreditAdjustment(
      id: doc.id,
      userId: data['userId'] ?? '',
      gymCreditChange: data['gymCreditChange'] ?? 0,
      intervalCreditChange: data['intervalCreditChange'] ?? 0,
      reason: data['reason'] ?? 'Credit adjustment',
      relatedBookingId: data['relatedBookingId'],
      adjustedAt: (data['adjustedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adjustedBy: data['adjustedBy'] ?? 'system',
    );
  }

  // Convert credit adjustment to a map for Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'gymCreditChange': gymCreditChange,
      'intervalCreditChange': intervalCreditChange,
      'reason': reason,
      'relatedBookingId': relatedBookingId,
      'adjustedAt': Timestamp.fromDate(adjustedAt),
      'adjustedBy': adjustedBy,
    };
  }

  // Get total credit change (sum of gym and interval credits)
  int get totalCreditChange => gymCreditChange + intervalCreditChange;

  // Create sample credit adjustments for demo purposes
  static List<CreditAdjustment> getSampleAdjustments(String userId) {
    final now = DateTime.now();
    
    return [
      CreditAdjustment(
        id: '1',
        userId: userId,
        gymCreditChange: -1,
        intervalCreditChange: 0,
        reason: 'Booked Yoga Session',
        relatedBookingId: 'booking1',
        adjustedAt: now.subtract(const Duration(days: 2)),
        adjustedBy: 'system',
      ),
      CreditAdjustment(
        id: '2',
        userId: userId,
        gymCreditChange: 0,
        intervalCreditChange: -1,
        reason: 'Booked HIIT Session',
        relatedBookingId: 'booking2',
        adjustedAt: now.subtract(const Duration(days: 4)),
        adjustedBy: 'system',
      ),
      CreditAdjustment(
        id: '3',
        userId: userId,
        gymCreditChange: 1,
        intervalCreditChange: 0,
        reason: 'Refund for Cancelled Session',
        relatedBookingId: 'booking3',
        adjustedAt: now.subtract(const Duration(days: 1)),
        adjustedBy: 'admin',
      ),
      CreditAdjustment(
        id: '4',
        userId: userId,
        gymCreditChange: 5,
        intervalCreditChange: 2,
        reason: 'Monthly Credit Refill',
        adjustedAt: now.subtract(const Duration(days: 10)),
        adjustedBy: 'system',
      ),
      CreditAdjustment(
        id: '5',
        userId: userId,
        gymCreditChange: 3,
        intervalCreditChange: 1,
        reason: 'Credit Purchase',
        adjustedAt: now.subtract(const Duration(days: 15)),
        adjustedBy: 'system',
      ),
    ];
  }
}