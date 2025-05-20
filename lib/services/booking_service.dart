import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/models/credit_model.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final FirebaseService _firebaseService;
  
  BookingService(this._firebaseService);
  
  // Book a session
  Future<BookingResult> bookSession({
    required String userId,
    required String sessionId,
  }) async {
    final firestore = _firebaseService.firestore;
    
    try {
      // Use transaction to ensure consistency
      return await firestore.runTransaction((transaction) async {
        // Get session
        final sessionDoc = await transaction.get(
          firestore.collection('sessions').doc(sessionId),
        );
        
        if (!sessionDoc.exists) {
          return BookingResult.error('Session not found');
        }
        
        final sessionData = sessionDoc.data() as Map<String, dynamic>;
        final SessionModel session = SessionModel.fromJson({
          'id': sessionDoc.id,
          ...sessionData,
        });
        
        // Check if session is bookable
        if (!session.isActive) {
          return BookingResult.error('This session is not active');
        }
        
        if (session.startTime.isBefore(DateTime.now())) {
          return BookingResult.error('Cannot book a session that has already started');
        }
        
        // Check capacity
        if (session.currentBookings >= session.maxCapacity) {
          return BookingResult.error('Session is full');
        }
        
        // Get user document to check credits
        final userDoc = await transaction.get(
          firestore.collection('clients').doc(userId),
        );
        
        if (!userDoc.exists) {
          return BookingResult.error('User not found');
        }
        
        final userData = userDoc.data() as Map<String, dynamic>;
        final UserCredit userCredit = UserCredit.fromFirestore(userDoc);
        
        // Get required credits for the session
        final int requiredCredits = session.creditCost;
        
        // Check if user has enough credits
        if (!userCredit.hasSufficientCredits(requiredCredits)) {
          return BookingResult.error('Insufficient credits');
        }
        
        // Check if user has already booked this session
        final existingBookingQuery = await firestore
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .where('sessionId', isEqualTo: sessionId)
            .where('status', isEqualTo: 'confirmed')
            .get();
        
        if (existingBookingQuery.docs.isNotEmpty) {
          return BookingResult.error('You have already booked this session');
        }
        
        // Create booking document
        final String bookingId = const Uuid().v4();
        final bookingRef = firestore.collection('bookings').doc(bookingId);
        
        final BookingModel booking = BookingModel(
          id: bookingId,
          userId: userId,
          sessionId: sessionId,
          status: BookingStatus.confirmed,
          creditsUsed: requiredCredits,
          bookedAt: DateTime.now(),
          sessionTitle: session.title,
          sessionStartTime: session.startTime,
          sessionEndTime: session.endTime,
          instructorId: session.instructorId,
          instructorName: session.instructorName,
        );
        
        transaction.set(bookingRef, booking.toFirestore());
        
        // Deduct credits from user account if not unlimited
        if (!userCredit.isUnlimited) {
          // Try to use interval credits first, then gym credits
          int newGymCredits = userCredit.gymCredits;
          int newIntervalCredits = userCredit.intervalCredits;
          
          if (userCredit.intervalCredits >= requiredCredits) {
            // Use interval credits
            newIntervalCredits = userCredit.intervalCredits - requiredCredits;
          } else {
            // Use gym credits
            newGymCredits = userCredit.gymCredits - requiredCredits;
          }
          
          // Update user document
          transaction.update(userDoc.reference, {
            'gymCredits': newGymCredits,
            'intervalCredits': newIntervalCredits,
          });
          
          // Create credit adjustment record
          final adjustmentRef = firestore.collection('creditAdjustments').doc();
          transaction.set(adjustmentRef, {
            'clientId': userId,
            'previousGymCredits': userCredit.gymCredits,
            'previousIntervalCredits': userCredit.intervalCredits,
            'newGymCredits': newGymCredits,
            'newIntervalCredits': newIntervalCredits,
            'reason': 'Session booking: ${session.title}',
            'adjustedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Update session booking count
        transaction.update(sessionDoc.reference, {
          'currentBookings': FieldValue.increment(1),
        });
        
        return BookingResult.success(bookingId);
      });
    } catch (e) {
      return BookingResult.error('Failed to book session: $e');
    }
  }
  
  // Cancel a booking
  Future<BookingResult> cancelBooking({
    required String userId,
    required String bookingId,
  }) async {
    final firestore = _firebaseService.firestore;
    
    try {
      return await firestore.runTransaction((transaction) async {
        // Get booking
        final bookingDoc = await transaction.get(
          firestore.collection('bookings').doc(bookingId),
        );
        
        if (!bookingDoc.exists) {
          return BookingResult.error('Booking not found');
        }
        
        final bookingData = bookingDoc.data() as Map<String, dynamic>;
        final BookingModel booking = BookingModel.fromFirestore(bookingDoc);
        
        // Verify ownership
        if (booking.userId != userId) {
          return BookingResult.error('You do not have permission to cancel this booking');
        }
        
        // Check if booking is already cancelled
        if (booking.status == BookingStatus.cancelled) {
          return BookingResult.error('Booking is already cancelled');
        }
        
        // Check cancellation deadline
        if (!booking.canBeCancelled()) {
          return BookingResult.error('Cannot cancel booking less than 24 hours before the session');
        }
        
        // Get session
        final sessionDoc = await transaction.get(
          firestore.collection('sessions').doc(booking.sessionId),
        );
        
        if (!sessionDoc.exists) {
          return BookingResult.error('Session not found');
        }
        
        // Get user to refund credits
        final userDoc = await transaction.get(
          firestore.collection('clients').doc(userId),
        );
        
        if (!userDoc.exists) {
          return BookingResult.error('User not found');
        }
        
        final UserCredit userCredit = UserCredit.fromFirestore(userDoc);
        
        // Update booking status
        transaction.update(bookingDoc.reference, {
          'status': BookingStatus.cancelled.toStringValue(),
          'cancelledAt': FieldValue.serverTimestamp(),
        });
        
        // Update session booking count
        transaction.update(sessionDoc.reference, {
          'currentBookings': FieldValue.increment(-1),
        });
        
        // Refund credits if not unlimited
        if (!userCredit.isUnlimited) {
          final newGymCredits = userCredit.gymCredits + booking.creditsUsed;
          
          transaction.update(userDoc.reference, {
            'gymCredits': newGymCredits,
          });
          
          // Create credit adjustment record for refund
          final adjustmentRef = firestore.collection('creditAdjustments').doc();
          transaction.set(adjustmentRef, {
            'clientId': userId,
            'previousGymCredits': userCredit.gymCredits,
            'previousIntervalCredits': userCredit.intervalCredits,
            'newGymCredits': newGymCredits,
            'newIntervalCredits': userCredit.intervalCredits,
            'reason': 'Booking cancellation refund: ${booking.sessionTitle ?? booking.sessionId}',
            'adjustedAt': FieldValue.serverTimestamp(),
          });
        }
        
        return BookingResult.success(bookingId);
      });
    } catch (e) {
      return BookingResult.error('Failed to cancel booking: $e');
    }
  }
  
  // Get bookings for a user
  Future<List<BookingModel>> getUserBookings({
    required String userId,
    bool upcoming = true,
    int limit = 10,
  }) async {
    try {
      final firestore = _firebaseService.firestore;
      
      Query query = firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .limit(limit);
      
      if (upcoming) {
        // Only get bookings for future sessions
        query = query.where('sessionStartTime', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()));
      } else {
        // Get past bookings
        query = query.where('sessionStartTime', isLessThan: Timestamp.fromDate(DateTime.now()));
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Log error
      print('Error getting user bookings: $e');
      return [];
    }
  }
  
  // Get bookings for a session
  Future<List<BookingModel>> getSessionBookings({
    required String sessionId,
  }) async {
    try {
      final firestore = _firebaseService.firestore;
      
      final querySnapshot = await firestore
          .collection('bookings')
          .where('sessionId', isEqualTo: sessionId)
          .where('status', isEqualTo: 'confirmed')
          .get();
      
      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Log error
      print('Error getting session bookings: $e');
      return [];
    }
  }
  
  // Mark booking as attended (admin only)
  Future<BookingResult> markBookingAsAttended({
    required String bookingId,
    required String adminId,
  }) async {
    final firestore = _firebaseService.firestore;
    
    try {
      // Admin permission check should be done at UI level or through Firebase Rules
      
      // Update booking status
      await firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.attended.toStringValue(),
        'attendedAt': FieldValue.serverTimestamp(),
        'markedBy': adminId,
      });
      
      return BookingResult.success(bookingId);
    } catch (e) {
      return BookingResult.error('Failed to mark booking as attended: $e');
    }
  }
  
  // Get credit history for a user
  Future<List<CreditAdjustment>> getUserCreditHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final firestore = _firebaseService.firestore;
      
      final querySnapshot = await firestore
          .collection('creditAdjustments')
          .where('clientId', isEqualTo: userId)
          .orderBy('adjustedAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CreditAdjustment.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Log error
      print('Error getting credit history: $e');
      return [];
    }
  }
}