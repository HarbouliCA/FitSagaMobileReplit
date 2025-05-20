import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/services/credit_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CreditService _creditService = CreditService();
  
  // Get bookings by user
  Future<List<BookingModel>> getBookingsByUser(String userId) async {
    try {
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('bookedAt', descending: true)
          .get();
      
      return bookingsSnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot bookingDoc = await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .get();
      
      if (bookingDoc.exists) {
        return BookingModel.fromFirestore(bookingDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get active (upcoming) bookings by user
  Future<List<BookingModel>> getActiveBookingsByUser(String userId) async {
    try {
      final now = DateTime.now();
      
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: BookingStatus.confirmed.value)
          .where('sessionStartTime', isGreaterThanOrEqualTo: now)
          .orderBy('sessionStartTime')
          .get();
      
      return bookingsSnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Check if user has already booked a session
  Future<bool> hasUserBookedSession(String userId, String sessionId) async {
    try {
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('userId', isEqualTo: userId)
          .where('sessionId', isEqualTo: sessionId)
          .where('status', isEqualTo: BookingStatus.confirmed.value)
          .limit(1)
          .get();
      
      return bookingsSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Book a session
  Future<String?> bookSession(String userId, SessionModel session) async {
    // Run in a transaction to ensure data consistency
    try {
      String? bookingId;
      
      await _firestore.runTransaction((transaction) async {
        // 1. Check if session is available
        DocumentReference sessionRef = _firestore
            .collection(AppConstants.sessionsCollection)
            .doc(session.id);
            
        DocumentSnapshot sessionSnap = await transaction.get(sessionRef);
        
        if (!sessionSnap.exists) {
          throw Exception('Session does not exist');
        }
        
        SessionModel currentSession = SessionModel.fromFirestore(sessionSnap);
        
        if (currentSession.status != AppConstants.sessionStatusScheduled) {
          throw Exception('Session is no longer available for booking');
        }
        
        if (currentSession.enrolledCount >= currentSession.capacity) {
          throw Exception('Session is at full capacity');
        }
        
        // 2. Check if user has already booked this session
        QuerySnapshot existingBookings = await _firestore
            .collection(AppConstants.bookingsCollection)
            .where('userId', isEqualTo: userId)
            .where('sessionId', isEqualTo: session.id)
            .where('status', isEqualTo: BookingStatus.confirmed.value)
            .get();
            
        if (existingBookings.docs.isNotEmpty) {
          throw Exception('You have already booked this session');
        }
        
        // 3. Check if user has sufficient credits
        DocumentReference userRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId);
            
        DocumentSnapshot userSnap = await transaction.get(userRef);
        
        if (!userSnap.exists) {
          throw Exception('User does not exist');
        }
        
        Map<String, dynamic> userData = userSnap.data() as Map<String, dynamic>;
        dynamic userCredits = userData['credits'];
        bool hasUnlimitedCredits = false;
        
        if (userCredits is String && userCredits == 'unlimited') {
          hasUnlimitedCredits = true;
        } else if (userCredits is int && userCredits < session.requiredCredits) {
          throw Exception('Insufficient credits to book this session');
        }
        
        // 4. Create booking
        DocumentReference bookingRef = _firestore.collection(AppConstants.bookingsCollection).doc();
        
        transaction.set(bookingRef, {
          'userId': userId,
          'sessionId': session.id,
          'activityName': session.activityName,
          'sessionStartTime': session.startTime,
          'sessionEndTime': session.endTime,
          'status': BookingStatus.confirmed.value,
          'creditsUsed': session.requiredCredits,
          'bookedAt': FieldValue.serverTimestamp(),
        });
        
        // 5. Update session enrolled count
        transaction.update(sessionRef, {
          'enrolledCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // 6. Deduct credits if not unlimited
        if (!hasUnlimitedCredits) {
          transaction.update(userRef, {
            'credits': FieldValue.increment(-session.requiredCredits),
            'lastActive': FieldValue.serverTimestamp(),
          });
          
          // Also check and update client collection if it exists
          DocumentReference clientRef = _firestore
              .collection(AppConstants.clientsCollection)
              .doc(userId);
              
          DocumentSnapshot clientSnap = await transaction.get(clientRef);
          
          if (clientSnap.exists) {
            // Handle both simple and complex credit models
            Map<String, dynamic> clientData = clientSnap.data() as Map<String, dynamic>;
            
            if (clientData['creditDetails'] != null) {
              transaction.update(clientRef, {
                'creditDetails.total': FieldValue.increment(-session.requiredCredits),
                'credits': FieldValue.increment(-session.requiredCredits),
                'lastActive': FieldValue.serverTimestamp(),
              });
            } else {
              transaction.update(clientRef, {
                'credits': FieldValue.increment(-session.requiredCredits),
                'lastActive': FieldValue.serverTimestamp(),
              });
            }
          }
        }
        
        bookingId = bookingRef.id;
      });
      
      return bookingId;
    } catch (e) {
      rethrow;
    }
  }
  
  // Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      // Find the booking first
      DocumentSnapshot bookingDoc = await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .get();
          
      if (!bookingDoc.exists) {
        return false;
      }
      
      BookingModel booking = BookingModel.fromFirestore(bookingDoc);
      
      // Check if the booking is cancellable
      if (!booking.isCancellable) {
        return false;
      }
      
      // Run in a transaction
      await _firestore.runTransaction((transaction) async {
        // 1. Update booking status
        transaction.update(bookingDoc.reference, {
          'status': BookingStatus.cancelled.value,
          'cancelledAt': FieldValue.serverTimestamp(),
          'cancellationReason': reason,
        });
        
        // 2. Update session enrolled count
        DocumentReference sessionRef = _firestore
            .collection(AppConstants.sessionsCollection)
            .doc(booking.sessionId);
            
        transaction.update(sessionRef, {
          'enrolledCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // 3. Refund credits to user
        DocumentReference userRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(booking.userId);
            
        DocumentSnapshot userSnap = await transaction.get(userRef);
        
        // Only refund if user document exists
        if (userSnap.exists) {
          transaction.update(userRef, {
            'credits': FieldValue.increment(booking.creditsUsed),
          });
          
          // Also update client collection if it exists
          DocumentReference clientRef = _firestore
              .collection(AppConstants.clientsCollection)
              .doc(booking.userId);
              
          DocumentSnapshot clientSnap = await transaction.get(clientRef);
          
          if (clientSnap.exists) {
            // Handle both simple and complex credit models
            Map<String, dynamic> clientData = clientSnap.data() as Map<String, dynamic>;
            
            if (clientData['creditDetails'] != null) {
              transaction.update(clientRef, {
                'creditDetails.total': FieldValue.increment(booking.creditsUsed),
                'credits': FieldValue.increment(booking.creditsUsed),
              });
            } else {
              transaction.update(clientRef, {
                'credits': FieldValue.increment(booking.creditsUsed),
              });
            }
          }
          
          // 4. Create credit adjustment record
          await _creditService.recordCreditAdjustment(
            booking.userId,
            0, // Previous value unknown here
            0, // Previous interval credits unknown here
            booking.creditsUsed, // Adding back credits
            0, // No change to interval credits
            'Booking cancellation refund',
            'system',
          );
        }
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get upcoming bookings for a session
  Future<List<BookingModel>> getBookingsBySession(String sessionId) async {
    try {
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('sessionId', isEqualTo: sessionId)
          .where('status', isEqualTo: BookingStatus.confirmed.value)
          .get();
      
      return bookingsSnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
