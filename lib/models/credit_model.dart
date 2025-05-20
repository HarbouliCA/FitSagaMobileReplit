import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the different types of credit transactions
enum CreditTransactionType {
  /// Initial credits given to new users or as gifts from admin
  initial,
  
  /// Credits purchased by the user
  purchase,
  
  /// Credits used to book a session
  usage,
  
  /// Credits refunded for cancelled sessions
  refund,
}

/// Extension to convert string to CreditTransactionType enum
extension CreditTransactionTypeExtension on String {
  CreditTransactionType toCreditTransactionType() {
    switch (this.toLowerCase()) {
      case 'initial':
        return CreditTransactionType.initial;
      case 'purchase':
        return CreditTransactionType.purchase;
      case 'usage':
        return CreditTransactionType.usage;
      case 'refund':
        return CreditTransactionType.refund;
      default:
        return CreditTransactionType.purchase;
    }
  }
}

/// Model class representing a credit transaction in the FitSAGA app
class CreditModel {
  /// Unique identifier for the credit transaction
  final String id;
  
  /// ID of the user who owns these credits
  final String userId;
  
  /// Number of credits involved in this transaction
  final int amount;
  
  /// Type of credit transaction (initial, purchase, usage, refund)
  final CreditTransactionType type;
  
  /// Description of the transaction (e.g., "Session booking: HIIT Class")
  final String description;
  
  /// When the transaction occurred
  final DateTime createdAt;
  
  /// Payment reference for purchase transactions (optional)
  final String? paymentReference;
  
  /// Constructor for creating a new CreditModel
  CreditModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    this.paymentReference,
  });
  
  /// Creates a CreditModel from a Firebase document map
  factory CreditModel.fromMap(Map<String, dynamic> map, String docId) {
    return CreditModel(
      id: docId,
      userId: map['userId'] ?? '',
      amount: map['amount'] ?? 0,
      type: (map['type'] as String? ?? 'purchase').toCreditTransactionType(),
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      paymentReference: map['paymentReference'],
    );
  }
  
  /// Converts the CreditModel to a map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentReference': paymentReference,
    };
  }
  
  /// Determines if this transaction is a credit (increases balance)
  bool get isCredit => 
      type == CreditTransactionType.initial || 
      type == CreditTransactionType.purchase || 
      type == CreditTransactionType.refund;
  
  /// Determines if this transaction is a debit (decreases balance)
  bool get isDebit => type == CreditTransactionType.usage;
  
  /// Gets the formatted date for display
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
  
  /// Gets the formatted time for display
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  String toString() {
    return 'CreditModel(id: $id, userId: $userId, amount: $amount, type: $type, description: $description)';
  }
}