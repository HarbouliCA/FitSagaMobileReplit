import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Types of credit transactions
enum CreditTransactionType {
  purchase,    // User purchased credits
  booking,     // User spent credits on booking
  cancellation, // Credits refunded due to cancellation
  expiration,  // Credits expired
  adjustment,  // Manual adjustment by admin
  bonus,       // Bonus credits (promotions, referrals)
  transfer,    // Credits transferred between users
}

/// Model for credit transactions
class CreditTransactionModel extends Equatable {
  final String id;
  final String userId;
  final int amount;
  final CreditTransactionType type;
  final String reason;
  final int previousBalance;
  final int newBalance;
  final DateTime timestamp;
  final String? sessionId;
  final String? adminId;
  final Map<String, dynamic>? metadata;

  const CreditTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.reason,
    required this.previousBalance,
    required this.newBalance,
    required this.timestamp,
    this.sessionId,
    this.adminId,
    this.metadata,
  });

  // Factory method to create a CreditTransactionModel from Firestore document
  factory CreditTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CreditTransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: data['amount'] ?? 0,
      type: _parseTransactionType(data['type']),
      reason: data['reason'] ?? '',
      previousBalance: data['previousBalance'] ?? 0,
      newBalance: data['newBalance'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      sessionId: data['sessionId'],
      adminId: data['adminId'],
      metadata: data['metadata'],
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'type': _transactionTypeToString(type),
      'reason': reason,
      'previousBalance': previousBalance,
      'newBalance': newBalance,
      'timestamp': Timestamp.fromDate(timestamp),
      'sessionId': sessionId,
      'adminId': adminId,
      'metadata': metadata,
    };
  }

  // Helper methods for transaction type conversion
  static CreditTransactionType _parseTransactionType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'purchase':
        return CreditTransactionType.purchase;
      case 'booking':
        return CreditTransactionType.booking;
      case 'cancellation':
        return CreditTransactionType.cancellation;
      case 'expiration':
        return CreditTransactionType.expiration;
      case 'adjustment':
        return CreditTransactionType.adjustment;
      case 'bonus':
        return CreditTransactionType.bonus;
      case 'transfer':
        return CreditTransactionType.transfer;
      default:
        return CreditTransactionType.adjustment;
    }
  }

  static String _transactionTypeToString(CreditTransactionType type) {
    switch (type) {
      case CreditTransactionType.purchase:
        return 'purchase';
      case CreditTransactionType.booking:
        return 'booking';
      case CreditTransactionType.cancellation:
        return 'cancellation';
      case CreditTransactionType.expiration:
        return 'expiration';
      case CreditTransactionType.adjustment:
        return 'adjustment';
      case CreditTransactionType.bonus:
        return 'bonus';
      case CreditTransactionType.transfer:
        return 'transfer';
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    amount,
    type,
    reason,
    previousBalance,
    newBalance,
    timestamp,
    sessionId,
    adminId,
  ];

  @override
  String toString() {
    return 'CreditTransaction(id: $id, userId: $userId, amount: $amount, type: ${_transactionTypeToString(type)})';
  }
}

/// Model for credit packages available for purchase
class CreditPackageModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final int creditAmount;
  final double price;
  final bool isActive;
  final bool isPromotional;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const CreditPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creditAmount,
    required this.price,
    this.isActive = true,
    this.isPromotional = false,
    this.validFrom,
    this.validUntil,
    this.imageUrl,
    this.metadata,
  });

  // Check if package is currently valid
  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return true;
  }

  // Calculate price per credit
  double get pricePerCredit => price / creditAmount;

  // Calculate savings percentage compared to a reference price
  double calculateSavings(double referencePrice) {
    if (referencePrice <= 0) return 0;
    final regularTotal = referencePrice * creditAmount;
    return ((regularTotal - price) / regularTotal) * 100;
  }

  // Factory method to create a CreditPackageModel from Firestore document
  factory CreditPackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CreditPackageModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creditAmount: data['creditAmount'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      isPromotional: data['isPromotional'] ?? false,
      validFrom: data['validFrom'] != null 
          ? (data['validFrom'] as Timestamp).toDate() 
          : null,
      validUntil: data['validUntil'] != null 
          ? (data['validUntil'] as Timestamp).toDate() 
          : null,
      imageUrl: data['imageUrl'],
      metadata: data['metadata'],
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'creditAmount': creditAmount,
      'price': price,
      'isActive': isActive,
      'isPromotional': isPromotional,
      'validFrom': validFrom != null ? Timestamp.fromDate(validFrom!) : null,
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    creditAmount,
    price,
    isActive,
    isPromotional,
    validFrom,
    validUntil,
    imageUrl,
  ];
}

/// Model for user credit balance and history
class UserCreditModel extends Equatable {
  final String userId;
  final int balance;
  final DateTime lastUpdated;
  final List<CreditTransactionModel> transactions;

  const UserCreditModel({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
    required this.transactions,
  });

  // Get recent transactions
  List<CreditTransactionModel> getRecentTransactions([int limit = 10]) {
    final sorted = List<CreditTransactionModel>.from(transactions);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  // Get transactions by type
  List<CreditTransactionModel> getTransactionsByType(CreditTransactionType type) {
    return transactions.where((t) => t.type == type).toList();
  }

  // Get transactions in date range
  List<CreditTransactionModel> getTransactionsInDateRange(DateTime start, DateTime end) {
    return transactions.where((t) => 
      t.timestamp.isAfter(start) && t.timestamp.isBefore(end)
    ).toList();
  }

  // Calculate total spent credits
  int get totalSpent {
    return transactions
        .where((t) => t.amount < 0)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }

  // Calculate total earned credits
  int get totalEarned {
    return transactions
        .where((t) => t.amount > 0)
        .fold(0, (sum, t) => sum + t.amount);
  }

  @override
  List<Object?> get props => [
    userId,
    balance,
    lastUpdated,
    transactions,
  ];
}