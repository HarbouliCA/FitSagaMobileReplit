import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/models/credit_model.dart';

class CreditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get user credits
  Future<UserCredit?> getUserCredits(String userId) async {
    try {
      // Try client collection first (which has more detailed credit info)
      DocumentSnapshot clientDoc = await _firestore
          .collection(AppConstants.clientsCollection)
          .doc(userId)
          .get();
          
      if (clientDoc.exists) {
        return UserCredit.fromFirestore(clientDoc);
      }
      
      // Fallback to users collection
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
          
      if (userDoc.exists) {
        return UserCredit.fromFirestore(userDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get credit adjustment history
  Future<List<CreditAdjustment>> getCreditAdjustmentHistory(String userId) async {
    try {
      QuerySnapshot adjustmentsSnapshot = await _firestore
          .collection(AppConstants.creditAdjustmentsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('adjustedAt', descending: true)
          .get();
      
      return adjustmentsSnapshot.docs
          .map((doc) => CreditAdjustment.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Add credits (admin only)
  Future<bool> addCredits(String userId, int amount) async {
    try {
      // Update both users and clients collections in a transaction
      await _firestore.runTransaction((transaction) async {
        // Get current credit values
        DocumentReference userRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId);
            
        DocumentSnapshot userSnap = await transaction.get(userRef);
        
        if (!userSnap.exists) {
          throw Exception('User does not exist');
        }
        
        Map<String, dynamic> userData = userSnap.data() as Map<String, dynamic>;
        dynamic currentCredits = userData['credits'];
        int previousCredits = 0;
        
        // Handle unlimited credits case
        if (currentCredits is String && currentCredits == 'unlimited') {
          // No need to update unlimited credits
          return;
        } else if (currentCredits is int) {
          previousCredits = currentCredits;
        }
        
        // Update users collection
        transaction.update(userRef, {
          'credits': previousCredits + amount,
        });
        
        // Also update clients collection if it exists
        DocumentReference clientRef = _firestore
            .collection(AppConstants.clientsCollection)
            .doc(userId);
            
        DocumentSnapshot clientSnap = await transaction.get(clientRef);
        
        if (clientSnap.exists) {
          Map<String, dynamic> clientData = clientSnap.data() as Map<String, dynamic>;
          int previousClientCredits = 0;
          int previousIntervalCredits = 0;
          
          // Handle complex credit model
          if (clientData['creditDetails'] != null && clientData['creditDetails']['total'] is int) {
            previousClientCredits = clientData['creditDetails']['total'];
            previousIntervalCredits = clientData['creditDetails']['intervalCredits'] ?? 0;
            
            transaction.update(clientRef, {
              'creditDetails.total': previousClientCredits + amount,
              'credits': previousClientCredits + amount,
            });
          } else {
            // Handle simple credit model
            if (clientData['credits'] is int) {
              previousClientCredits = clientData['credits'];
            }
            
            if (clientData['intervalCredits'] is int) {
              previousIntervalCredits = clientData['intervalCredits'];
            }
            
            transaction.update(clientRef, {
              'credits': previousClientCredits + amount,
            });
          }
          
          // Record the adjustment
          await recordCreditAdjustment(
            userId,
            previousClientCredits,
            previousIntervalCredits,
            previousClientCredits + amount,
            previousIntervalCredits,
            'Manual credit adjustment',
            'admin',
          );
        }
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Reset credits based on subscription (automated)
  Future<bool> resetCredits(String userId, String subscriptionPlan) async {
    try {
      int newTotalCredits = 0;
      int newIntervalCredits = 0;
      dynamic unlimitedCredits;
      
      // Determine credit values based on subscription plan
      switch (subscriptionPlan.toLowerCase()) {
        case 'premium':
          unlimitedCredits = 'unlimited';
          newIntervalCredits = 4;
          break;
        case 'gold':
          newTotalCredits = 8;
          newIntervalCredits = 4;
          break;
        case 'basic':
          newTotalCredits = 8;
          newIntervalCredits = 0;
          break;
        default:
          newTotalCredits = 0;
          newIntervalCredits = 0;
      }
      
      // Update both users and clients collections in a transaction
      await _firestore.runTransaction((transaction) async {
        // Get current credit values first
        DocumentReference userRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId);
            
        DocumentSnapshot userSnap = await transaction.get(userRef);
        
        if (!userSnap.exists) {
          throw Exception('User does not exist');
        }
        
        Map<String, dynamic> userData = userSnap.data() as Map<String, dynamic>;
        dynamic previousCredits = userData['credits'];
        int prevCreditsInt = 0;
        
        if (previousCredits is int) {
          prevCreditsInt = previousCredits;
        }
        
        // Update users collection
        transaction.update(userRef, {
          'credits': unlimitedCredits ?? newTotalCredits,
          'lastCreditReset': FieldValue.serverTimestamp(),
        });
        
        // Also update clients collection if it exists
        DocumentReference clientRef = _firestore
            .collection(AppConstants.clientsCollection)
            .doc(userId);
            
        DocumentSnapshot clientSnap = await transaction.get(clientRef);
        
        if (clientSnap.exists) {
          Map<String, dynamic> clientData = clientSnap.data() as Map<String, dynamic>;
          int previousClientCredits = 0;
          int previousIntervalCredits = 0;
          
          // Handle complex credit model
          if (clientData['creditDetails'] != null) {
            if (clientData['creditDetails']['total'] is int) {
              previousClientCredits = clientData['creditDetails']['total'];
            }
            
            if (clientData['creditDetails']['intervalCredits'] is int) {
              previousIntervalCredits = clientData['creditDetails']['intervalCredits'];
            }
            
            transaction.update(clientRef, {
              'creditDetails.total': unlimitedCredits ?? newTotalCredits,
              'creditDetails.intervalCredits': newIntervalCredits,
              'creditDetails.lastRefilled': FieldValue.serverTimestamp(),
              'credits': unlimitedCredits ?? newTotalCredits,
              'intervalCredits': newIntervalCredits,
              'lastCreditReset': FieldValue.serverTimestamp(),
            });
          } else {
            // Handle simple credit model
            if (clientData['credits'] is int) {
              previousClientCredits = clientData['credits'];
            }
            
            if (clientData['intervalCredits'] is int) {
              previousIntervalCredits = clientData['intervalCredits'];
            }
            
            transaction.update(clientRef, {
              'credits': unlimitedCredits ?? newTotalCredits,
              'intervalCredits': newIntervalCredits,
              'lastCreditReset': FieldValue.serverTimestamp(),
            });
          }
          
          // Record the adjustment
          await recordCreditAdjustment(
            userId,
            previousClientCredits,
            previousIntervalCredits,
            unlimitedCredits != null ? -1 : newTotalCredits, // -1 represents unlimited
            newIntervalCredits,
            'Scheduled credit reset based on subscription',
            'system',
          );
        }
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Record credit adjustment
  Future<void> recordCreditAdjustment(
    String userId,
    int previousGymCredits,
    int previousIntervalCredits,
    int newGymCredits,
    int newIntervalCredits,
    String reason,
    String adjustedBy,
  ) async {
    try {
      await _firestore.collection(AppConstants.creditAdjustmentsCollection).add({
        'userId': userId,
        'previousGymCredits': previousGymCredits,
        'previousIntervalCredits': previousIntervalCredits,
        'newGymCredits': newGymCredits,
        'newIntervalCredits': newIntervalCredits,
        'reason': reason,
        'adjustedBy': adjustedBy,
        'adjustedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent failure for adjustment recording
    }
  }
}
