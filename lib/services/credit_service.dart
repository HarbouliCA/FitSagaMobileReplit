import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/user_model.dart';

/// Model for credit transactions
class CreditTransaction {
  final String id;
  final String userId;
  final int gymCredits;
  final int intervalCredits;
  final String type; // 'purchase', 'booking', 'refund', 'gift', 'membership', 'admin'
  final String? relatedEntityId; // Booking ID, membership ID, etc.
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  CreditTransaction({
    required this.id,
    required this.userId,
    required this.gymCredits,
    required this.intervalCredits,
    required this.type,
    this.relatedEntityId,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'],
      userId: json['userId'],
      gymCredits: json['gymCredits'],
      intervalCredits: json['intervalCredits'],
      type: json['type'],
      relatedEntityId: json['relatedEntityId'],
      description: json['description'],
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate() 
          : DateTime.parse(json['timestamp'].toString()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'gymCredits': gymCredits,
      'intervalCredits': intervalCredits,
      'type': type,
      'relatedEntityId': relatedEntityId,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}

/// Model for credit packages that users can purchase
class CreditPackage {
  final String id;
  final String name;
  final String description;
  final int gymCredits;
  final int intervalCredits;
  final double price;
  final double? discountPrice;
  final bool isActive;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  CreditPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.gymCredits,
    required this.intervalCredits,
    required this.price,
    this.discountPrice,
    required this.isActive,
    this.imageUrl,
    this.metadata,
  });

  factory CreditPackage.fromJson(Map<String, dynamic> json) {
    return CreditPackage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      gymCredits: json['gymCredits'],
      intervalCredits: json['intervalCredits'],
      price: json['price'].toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'gymCredits': gymCredits,
      'intervalCredits': intervalCredits,
      'price': price,
      'discountPrice': discountPrice,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  // Check if this package is on discount
  bool get isOnDiscount => discountPrice != null && discountPrice! < price;

  // Get the discount percentage if applicable
  int? get discountPercentage {
    if (isOnDiscount) {
      return ((price - discountPrice!) / price * 100).round();
    }
    return null;
  }

  // Get the current price (discount or regular)
  double get currentPrice => discountPrice ?? price;

  // Calculate credit value per dollar
  double get valuePerDollar {
    final totalCredits = gymCredits + intervalCredits;
    return totalCredits / currentPrice;
  }

  // Get best value label if this package has highest valuePerDollar
  bool isBestValue(List<CreditPackage> allPackages) {
    if (allPackages.isEmpty) return false;
    
    final sorted = List<CreditPackage>.from(allPackages)
      ..sort((a, b) => b.valuePerDollar.compareTo(a.valuePerDollar));
    
    return sorted.first.id == id;
  }

  // Static method to get sample packages
  static List<CreditPackage> getSamplePackages() {
    return [
      CreditPackage(
        id: 'basic',
        name: 'Basic Package',
        description: 'Great starter pack for occasional gym goers',
        gymCredits: 10,
        intervalCredits: 0,
        price: 29.99,
        isActive: true,
        imageUrl: 'https://via.placeholder.com/100?text=Basic',
      ),
      CreditPackage(
        id: 'standard',
        name: 'Standard Package',
        description: 'Perfect for regular training sessions',
        gymCredits: 25,
        intervalCredits: 5,
        price: 59.99,
        discountPrice: 49.99,
        isActive: true,
        imageUrl: 'https://via.placeholder.com/100?text=Standard',
      ),
      CreditPackage(
        id: 'premium',
        name: 'Premium Package',
        description: 'Our best value for committed fitness enthusiasts',
        gymCredits: 50,
        intervalCredits: 15,
        price: 99.99,
        isActive: true,
        imageUrl: 'https://via.placeholder.com/100?text=Premium',
      ),
      CreditPackage(
        id: 'interval',
        name: 'Interval Package',
        description: 'Focused on interval training sessions',
        gymCredits: 5,
        intervalCredits: 20,
        price: 69.99,
        isActive: true,
        imageUrl: 'https://via.placeholder.com/100?text=Interval',
      ),
    ];
  }
}

/// Service to handle all credit-related operations
class CreditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  final CollectionReference _usersCollection;
  final CollectionReference _transactionsCollection;
  final CollectionReference _packagesCollection;
  
  CreditService() 
    : _usersCollection = FirebaseFirestore.instance.collection('users'),
      _transactionsCollection = FirebaseFirestore.instance.collection('creditTransactions'),
      _packagesCollection = FirebaseFirestore.instance.collection('creditPackages');
  
  // Get credit packages
  Future<List<CreditPackage>> getActivePackages() async {
    try {
      final QuerySnapshot snapshot = await _packagesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('price')
          .get();
      
      if (snapshot.docs.isEmpty) {
        return CreditPackage.getSamplePackages();
      }
      
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CreditPackage.fromJson(data);
      }).toList();
    } catch (e) {
      // For demo purposes, return sample packages
      return CreditPackage.getSamplePackages();
    }
  }
  
  // Purchase credits with a package
  Future<CreditTransaction> purchaseCreditsPackage(
    String userId, 
    CreditPackage package,
    {String? paymentMethod, String? paymentId}
  ) async {
    try {
      // Start a Firestore batch operation
      final WriteBatch batch = _firestore.batch();
      
      // Create transaction record
      final String transactionId = _firestore.collection('creditTransactions').doc().id;
      final CreditTransaction transaction = CreditTransaction(
        id: transactionId,
        userId: userId,
        gymCredits: package.gymCredits,
        intervalCredits: package.intervalCredits,
        type: 'purchase',
        description: 'Purchased ${package.name}',
        timestamp: DateTime.now(),
        metadata: {
          'packageId': package.id,
          'packageName': package.name,
          'price': package.discountPrice ?? package.price,
          'paymentMethod': paymentMethod,
          'paymentId': paymentId,
        },
      );
      
      // Add transaction
      batch.set(
        _transactionsCollection.doc(transactionId),
        transaction.toJson(),
      );
      
      // Update user credits
      batch.update(
        _usersCollection.doc(userId),
        {
          'credits.gymCredits': FieldValue.increment(package.gymCredits),
          'credits.intervalCredits': FieldValue.increment(package.intervalCredits),
        },
      );
      
      // Commit batch
      await batch.commit();
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to purchase credits: ${e.toString()}');
    }
  }
  
  // Get user credit transactions
  Future<List<CreditTransaction>> getUserTransactions(
    String userId, {
    int limit = 20,
    String? type,
  }) async {
    try {
      Query query = _transactionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit);
      
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      
      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CreditTransaction.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get transactions: ${e.toString()}');
    }
  }
  
  // Add credits (admin or system operation)
  Future<CreditTransaction> addCredits(
    String userId,
    int gymCredits,
    int intervalCredits,
    String reason,
    {String type = 'admin', Map<String, dynamic>? metadata}
  ) async {
    try {
      // Start a Firestore batch operation
      final WriteBatch batch = _firestore.batch();
      
      // Create transaction record
      final String transactionId = _firestore.collection('creditTransactions').doc().id;
      final CreditTransaction transaction = CreditTransaction(
        id: transactionId,
        userId: userId,
        gymCredits: gymCredits,
        intervalCredits: intervalCredits,
        type: type,
        description: reason,
        timestamp: DateTime.now(),
        metadata: metadata,
      );
      
      // Add transaction
      batch.set(
        _transactionsCollection.doc(transactionId),
        transaction.toJson(),
      );
      
      // Update user credits
      batch.update(
        _usersCollection.doc(userId),
        {
          'credits.gymCredits': FieldValue.increment(gymCredits),
          'credits.intervalCredits': FieldValue.increment(intervalCredits),
        },
      );
      
      // Commit batch
      await batch.commit();
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to add credits: ${e.toString()}');
    }
  }
  
  // Deduct credits with transaction recording
  Future<CreditTransaction> deductCredits(
    String userId,
    int gymCredits,
    int intervalCredits,
    String reason,
    {String type = 'booking', String? relatedEntityId, Map<String, dynamic>? metadata}
  ) async {
    try {
      // Check user has enough credits first
      final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final userCredits = UserCredits.fromJson(userData['credits'] ?? {});
      
      if (userCredits.gymCredits < gymCredits || userCredits.intervalCredits < intervalCredits) {
        throw Exception('Not enough credits');
      }
      
      // Start a Firestore batch operation
      final WriteBatch batch = _firestore.batch();
      
      // Create transaction record
      final String transactionId = _firestore.collection('creditTransactions').doc().id;
      final CreditTransaction transaction = CreditTransaction(
        id: transactionId,
        userId: userId,
        gymCredits: -gymCredits, // Negative because this is a deduction
        intervalCredits: -intervalCredits,
        type: type,
        relatedEntityId: relatedEntityId,
        description: reason,
        timestamp: DateTime.now(),
        metadata: metadata,
      );
      
      // Add transaction
      batch.set(
        _transactionsCollection.doc(transactionId),
        transaction.toJson(),
      );
      
      // Update user credits
      batch.update(
        _usersCollection.doc(userId),
        {
          'credits.gymCredits': FieldValue.increment(-gymCredits),
          'credits.intervalCredits': FieldValue.increment(-intervalCredits),
        },
      );
      
      // Commit batch
      await batch.commit();
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to deduct credits: ${e.toString()}');
    }
  }
  
  // Process membership monthly allocation
  Future<void> processMembershipCredits(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      if (userData['membership'] == null) {
        return; // User doesn't have a membership
      }
      
      final membership = UserMembership.fromJson(userData['membership']);
      
      // Check if membership is active
      if (membership.expiryDate.isBefore(DateTime.now())) {
        return; // Membership expired
      }
      
      // Add monthly credits
      await addCredits(
        userId,
        membership.monthlyGymCredits,
        membership.monthlyIntervalCredits,
        'Monthly membership credits',
        type: 'membership',
        metadata: {
          'membershipPlan': membership.plan,
          'membershipExpiry': membership.expiryDate.toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to process membership credits: ${e.toString()}');
    }
  }
  
  // Gift credits to another user
  Future<CreditTransaction> giftCredits(
    String fromUserId,
    String toUserId,
    int gymCredits,
    int intervalCredits,
    String message
  ) async {
    try {
      // Check sender has enough credits first
      final DocumentSnapshot userDoc = await _usersCollection.doc(fromUserId).get();
      
      if (!userDoc.exists) {
        throw Exception('Sender not found');
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final userCredits = UserCredits.fromJson(userData['credits'] ?? {});
      
      if (userCredits.gymCredits < gymCredits || userCredits.intervalCredits < intervalCredits) {
        throw Exception('Not enough credits to gift');
      }
      
      // Check if recipient exists
      final DocumentSnapshot recipientDoc = await _usersCollection.doc(toUserId).get();
      
      if (!recipientDoc.exists) {
        throw Exception('Recipient not found');
      }
      
      // Start a Firestore batch operation
      final WriteBatch batch = _firestore.batch();
      
      // Create sender transaction record (deduction)
      final String senderTransactionId = _firestore.collection('creditTransactions').doc().id;
      final CreditTransaction senderTransaction = CreditTransaction(
        id: senderTransactionId,
        userId: fromUserId,
        gymCredits: -gymCredits,
        intervalCredits: -intervalCredits,
        type: 'gift',
        relatedEntityId: toUserId,
        description: 'Gifted credits to another user',
        timestamp: DateTime.now(),
        metadata: {
          'recipientId': toUserId,
          'message': message,
        },
      );
      
      // Create recipient transaction record (addition)
      final String recipientTransactionId = _firestore.collection('creditTransactions').doc().id;
      final CreditTransaction recipientTransaction = CreditTransaction(
        id: recipientTransactionId,
        userId: toUserId,
        gymCredits: gymCredits,
        intervalCredits: intervalCredits,
        type: 'gift',
        relatedEntityId: fromUserId,
        description: 'Received gifted credits',
        timestamp: DateTime.now(),
        metadata: {
          'senderId': fromUserId,
          'message': message,
        },
      );
      
      // Add transactions
      batch.set(
        _transactionsCollection.doc(senderTransactionId),
        senderTransaction.toJson(),
      );
      
      batch.set(
        _transactionsCollection.doc(recipientTransactionId),
        recipientTransaction.toJson(),
      );
      
      // Update sender credits
      batch.update(
        _usersCollection.doc(fromUserId),
        {
          'credits.gymCredits': FieldValue.increment(-gymCredits),
          'credits.intervalCredits': FieldValue.increment(-intervalCredits),
        },
      );
      
      // Update recipient credits
      batch.update(
        _usersCollection.doc(toUserId),
        {
          'credits.gymCredits': FieldValue.increment(gymCredits),
          'credits.intervalCredits': FieldValue.increment(intervalCredits),
        },
      );
      
      // Commit batch
      await batch.commit();
      
      return senderTransaction;
    } catch (e) {
      throw Exception('Failed to gift credits: ${e.toString()}');
    }
  }
  
  // Get credit balance for a user
  Future<UserCredits> getUserCredits(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      return UserCredits.fromJson(userData['credits'] ?? {});
    } catch (e) {
      throw Exception('Failed to get user credits: ${e.toString()}');
    }
  }
  
  // Calculate credit usage statistics
  Future<Map<String, dynamic>> getUserCreditStatistics(String userId) async {
    try {
      final List<CreditTransaction> transactions = await getUserTransactions(
        userId,
        limit: 100, // Get a reasonable number of transactions for statistics
      );
      
      // Initialize statistics
      int totalGymCreditsUsed = 0;
      int totalIntervalCreditsUsed = 0;
      Map<String, int> gymCreditsByType = {};
      Map<String, int> intervalCreditsByType = {};
      int totalPurchased = 0;
      double totalSpent = 0;
      
      for (final transaction in transactions) {
        // Track credit usage by type
        final String type = transaction.type;
        
        if (!gymCreditsByType.containsKey(type)) {
          gymCreditsByType[type] = 0;
          intervalCreditsByType[type] = 0;
        }
        
        // Handle negative (usage) and positive (additions) values differently
        if (transaction.gymCredits < 0) {
          totalGymCreditsUsed += -transaction.gymCredits;
          gymCreditsByType[type] = (gymCreditsByType[type] ?? 0) + -transaction.gymCredits;
        }
        
        if (transaction.intervalCredits < 0) {
          totalIntervalCreditsUsed += -transaction.intervalCredits;
          intervalCreditsByType[type] = (intervalCreditsByType[type] ?? 0) + -transaction.intervalCredits;
        }
        
        // Track purchases
        if (transaction.type == 'purchase' && transaction.metadata != null) {
          totalPurchased += transaction.gymCredits + transaction.intervalCredits;
          totalSpent += (transaction.metadata!['price'] as num).toDouble();
        }
      }
      
      return {
        'totalGymCreditsUsed': totalGymCreditsUsed,
        'totalIntervalCreditsUsed': totalIntervalCreditsUsed,
        'gymCreditsByType': gymCreditsByType,
        'intervalCreditsByType': intervalCreditsByType,
        'totalCreditsPurchased': totalPurchased,
        'totalSpent': totalSpent,
        'averageCostPerCredit': totalSpent > 0 ? totalSpent / totalPurchased : 0,
      };
    } catch (e) {
      throw Exception('Failed to get credit statistics: ${e.toString()}');
    }
  }
}