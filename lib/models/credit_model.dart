import 'package:cloud_firestore/cloud_firestore.dart';

enum CreditTransactionType {
  initial,   // Initial credits given to new users
  purchase,  // Credits purchased by user
  booking,   // Credits used for booking a session
  refund,    // Credits refunded for a canceled session
  admin,     // Credits manually added/removed by admin
}

class CreditTransaction {
  final String id;
  final String userId;
  final int amount;
  final bool isCredit; // true for credits added, false for credits used
  final CreditTransactionType type;
  final String description;
  final String? sessionId; // Optional reference to session if related to a booking
  final String? referenceId; // Optional reference to a payment or other transaction
  final DateTime createdAt;

  const CreditTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.isCredit,
    required this.type,
    required this.description,
    this.sessionId,
    this.referenceId,
    required this.createdAt,
  });

  // Factory method to create a CreditTransaction from Firestore document
  factory CreditTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CreditTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: data['amount'] ?? 0,
      isCredit: data['isCredit'] ?? true,
      type: _transactionTypeFromString(data['type'] ?? 'admin'),
      description: data['description'] ?? '',
      sessionId: data['sessionId'],
      referenceId: data['referenceId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'isCredit': isCredit,
      'type': _transactionTypeToString(type),
      'description': description,
      'sessionId': sessionId,
      'referenceId': referenceId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper methods for type conversion
  static CreditTransactionType _transactionTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'initial':
        return CreditTransactionType.initial;
      case 'purchase':
        return CreditTransactionType.purchase;
      case 'booking':
        return CreditTransactionType.booking;
      case 'refund':
        return CreditTransactionType.refund;
      case 'admin':
      default:
        return CreditTransactionType.admin;
    }
  }

  static String _transactionTypeToString(CreditTransactionType type) {
    switch (type) {
      case CreditTransactionType.initial:
        return 'initial';
      case CreditTransactionType.purchase:
        return 'purchase';
      case CreditTransactionType.booking:
        return 'booking';
      case CreditTransactionType.refund:
        return 'refund';
      case CreditTransactionType.admin:
        return 'admin';
    }
  }

  @override
  String toString() {
    return 'CreditTransaction(id: $id, userId: $userId, amount: $amount, '
        'isCredit: $isCredit, type: $type, description: $description)';
  }
}

class CreditPackage {
  final String id;
  final String name;
  final int credits;
  final double price;
  final String? description;
  final bool isActive;
  final bool isFeatured;
  final String? imageUrl;

  const CreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.price,
    this.description,
    required this.isActive,
    required this.isFeatured,
    this.imageUrl,
  });

  // Factory method to create a CreditPackage from Firestore document
  factory CreditPackage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CreditPackage(
      id: doc.id,
      name: data['name'] ?? '',
      credits: data['credits'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'],
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'credits': credits,
      'price': price,
      'description': description,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'imageUrl': imageUrl,
    };
  }

  // Calculate the price per credit (useful for comparing packages)
  double get pricePerCredit => price / credits;

  // Calculate savings compared to the base price (if applicable)
  double calculateSavings(double basePrice) {
    final regularTotal = basePrice * credits;
    return regularTotal - price;
  }

  // Calculate savings percentage
  double calculateSavingsPercentage(double basePrice) {
    final regularTotal = basePrice * credits;
    return (regularTotal - price) / regularTotal * 100;
  }

  @override
  String toString() {
    return 'CreditPackage(id: $id, name: $name, credits: $credits, '
        'price: \$${price.toStringAsFixed(2)})';
  }
}