import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreditModel extends Equatable {
  final String id;
  final String userId;
  final int credits;
  final DateTime expiryDate;
  final String packageName;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? transactionId;

  const CreditModel({
    required this.id,
    required this.userId,
    required this.credits,
    required this.expiryDate,
    required this.packageName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.transactionId,
  });

  CreditModel copyWith({
    String? id,
    String? userId,
    int? credits,
    DateTime? expiryDate,
    String? packageName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? transactionId,
  }) {
    return CreditModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      credits: credits ?? this.credits,
      expiryDate: expiryDate ?? this.expiryDate,
      packageName: packageName ?? this.packageName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  factory CreditModel.fromMap(Map<String, dynamic> map) {
    return CreditModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      credits: map['credits'] as int,
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      packageName: map['packageName'] as String,
      status: map['status'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      transactionId: map['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'credits': credits,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'packageName': packageName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'transactionId': transactionId,
    };
  }

  bool get isActive => status == 'active' && expiryDate.isAfter(DateTime.now());
  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isUnlimited => credits == -1;

  @override
  List<Object?> get props => [
    id,
    userId,
    credits,
    expiryDate,
    packageName,
    status,
    createdAt,
    updatedAt,
    transactionId,
  ];
}

class CreditTransactionModel extends Equatable {
  final String id;
  final String userId;
  final String creditId;
  final String type; // 'purchase', 'used', 'refund', 'expiry', 'adjustment'
  final int amount;
  final int balanceAfter;
  final String description;
  final String? reference; // sessionId, packageId, etc.
  final DateTime timestamp;

  const CreditTransactionModel({
    required this.id,
    required this.userId,
    required this.creditId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    this.reference,
    required this.timestamp,
  });

  CreditTransactionModel copyWith({
    String? id,
    String? userId,
    String? creditId,
    String? type,
    int? amount,
    int? balanceAfter,
    String? description,
    String? reference,
    DateTime? timestamp,
  }) {
    return CreditTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      creditId: creditId ?? this.creditId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory CreditTransactionModel.fromMap(Map<String, dynamic> map) {
    return CreditTransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      creditId: map['creditId'] as String,
      type: map['type'] as String,
      amount: map['amount'] as int,
      balanceAfter: map['balanceAfter'] as int,
      description: map['description'] as String,
      reference: map['reference'] as String?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'creditId': creditId,
      'type': type,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'description': description,
      'reference': reference,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  bool get isDebit => amount < 0;
  bool get isCredit => amount > 0;

  @override
  List<Object?> get props => [
    id,
    userId,
    creditId,
    type,
    amount,
    balanceAfter,
    description,
    reference,
    timestamp,
  ];
}

class CreditPackageModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final int credits;
  final double price;
  final int validityDays;
  final bool isActive;
  final bool isSpecial;
  final bool isUnlimited;
  final DateTime? validFrom;
  final DateTime? validUntil;

  const CreditPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.price,
    required this.validityDays,
    required this.isActive,
    this.isSpecial = false,
    this.isUnlimited = false,
    this.validFrom,
    this.validUntil,
  });

  CreditPackageModel copyWith({
    String? id,
    String? name,
    String? description,
    int? credits,
    double? price,
    int? validityDays,
    bool? isActive,
    bool? isSpecial,
    bool? isUnlimited,
    DateTime? validFrom,
    DateTime? validUntil,
  }) {
    return CreditPackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      price: price ?? this.price,
      validityDays: validityDays ?? this.validityDays,
      isActive: isActive ?? this.isActive,
      isSpecial: isSpecial ?? this.isSpecial,
      isUnlimited: isUnlimited ?? this.isUnlimited,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
    );
  }

  factory CreditPackageModel.fromMap(Map<String, dynamic> map) {
    return CreditPackageModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      credits: map['credits'] as int,
      price: (map['price'] as num).toDouble(),
      validityDays: map['validityDays'] as int,
      isActive: map['isActive'] as bool,
      isSpecial: map['isSpecial'] as bool? ?? false,
      isUnlimited: map['isUnlimited'] as bool? ?? false,
      validFrom: map['validFrom'] != null 
          ? (map['validFrom'] as Timestamp).toDate() 
          : null,
      validUntil: map['validUntil'] != null 
          ? (map['validUntil'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'credits': credits,
      'price': price,
      'validityDays': validityDays,
      'isActive': isActive,
      'isSpecial': isSpecial,
      'isUnlimited': isUnlimited,
      'validFrom': validFrom != null ? Timestamp.fromDate(validFrom!) : null,
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
    };
  }

  bool get isCurrentlyValid => 
      isActive && 
      (validFrom == null || validFrom!.isBefore(DateTime.now())) &&
      (validUntil == null || validUntil!.isAfter(DateTime.now()));

  double get creditUnitPrice => isUnlimited ? price : price / credits;
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    credits,
    price,
    validityDays,
    isActive,
    isSpecial,
    isUnlimited,
    validFrom,
    validUntil,
  ];
}