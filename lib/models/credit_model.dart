import 'package:cloud_firestore/cloud_firestore.dart';

class UserCredit {
  final int gymCredits;
  final int intervalCredits;
  final bool isUnlimited;
  final DateTime lastRefilled;

  UserCredit({
    required this.gymCredits,
    required this.intervalCredits,
    this.isUnlimited = false,
    required this.lastRefilled,
  });

  factory UserCredit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Check if user has unlimited credits (premium tier)
    final bool isUnlimited = data['subscriptionTier'] == 'premium';
    
    return UserCredit(
      gymCredits: data['gymCredits'] ?? 0,
      intervalCredits: data['intervalCredits'] ?? 0,
      isUnlimited: isUnlimited,
      lastRefilled: data['lastRefilled'] != null 
          ? (data['lastRefilled'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  int get totalCredits => gymCredits + intervalCredits;

  // Check if user has sufficient credits for a session
  bool hasSufficientCredits(int requiredCredits) {
    if (isUnlimited) return true;
    return totalCredits >= requiredCredits;
  }

  // Get a formatted display of available credits
  String getDisplayText() {
    if (isUnlimited) {
      return 'Unlimited';
    } else {
      final totalStr = totalCredits.toString();
      if (intervalCredits > 0) {
        return '$totalStr ($gymCredits + $intervalCredits)';
      }
      return totalStr;
    }
  }

  // Copy with new values
  UserCredit copyWith({
    int? gymCredits,
    int? intervalCredits,
    bool? isUnlimited,
    DateTime? lastRefilled,
  }) {
    return UserCredit(
      gymCredits: gymCredits ?? this.gymCredits,
      intervalCredits: intervalCredits ?? this.intervalCredits,
      isUnlimited: isUnlimited ?? this.isUnlimited,
      lastRefilled: lastRefilled ?? this.lastRefilled,
    );
  }

  // For testing/preview
  factory UserCredit.defaultCredits() {
    return UserCredit(
      gymCredits: 8,
      intervalCredits: 4,
      isUnlimited: false,
      lastRefilled: DateTime.now(),
    );
  }
}

// Credit adjustment model for tracking credit changes
class CreditAdjustment {
  final String id;
  final String clientId;
  final int previousGymCredits;
  final int previousIntervalCredits;
  final int newGymCredits;
  final int newIntervalCredits;
  final String reason;
  final String? adjustedBy;
  final DateTime adjustedAt;

  CreditAdjustment({
    required this.id,
    required this.clientId,
    required this.previousGymCredits,
    required this.previousIntervalCredits,
    required this.newGymCredits,
    required this.newIntervalCredits,
    required this.reason,
    this.adjustedBy,
    required this.adjustedAt,
  });

  factory CreditAdjustment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CreditAdjustment(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      previousGymCredits: data['previousGymCredits'] ?? 0,
      previousIntervalCredits: data['previousIntervalCredits'] ?? 0,
      newGymCredits: data['newGymCredits'] ?? 0, 
      newIntervalCredits: data['newIntervalCredits'] ?? 0,
      reason: data['reason'] ?? '',
      adjustedBy: data['adjustedBy'],
      adjustedAt: data['adjustedAt'] != null 
          ? (data['adjustedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'previousGymCredits': previousGymCredits,
      'previousIntervalCredits': previousIntervalCredits,
      'newGymCredits': newGymCredits,
      'newIntervalCredits': newIntervalCredits,
      'reason': reason,
      'adjustedBy': adjustedBy,
      'adjustedAt': Timestamp.fromDate(adjustedAt),
    };
  }

  int get gymCreditChange => newGymCredits - previousGymCredits;
  int get intervalCreditChange => newIntervalCredits - previousIntervalCredits;
  int get totalCreditChange => gymCreditChange + intervalCreditChange;
}