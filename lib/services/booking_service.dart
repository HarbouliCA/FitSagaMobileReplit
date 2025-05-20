import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/models/credit_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get user bookings
  Future<List<BookingModel>> getUserBookings({
    required String userId,
    bool upcoming = true,
    int limit = 10,
  }) async {
    try {
      // For demo purposes, return sample bookings
      final allBookings = BookingModel.getSampleBookings(userId);
      
      if (upcoming) {
        // Filter upcoming bookings (status is confirmed and date is in the future)
        return allBookings
            .where((booking) => 
                booking.status == BookingStatus.confirmed && 
                booking.sessionDate.isAfter(DateTime.now()))
            .toList();
      } else {
        // Filter past bookings (date is in the past or status is not confirmed)
        return allBookings
            .where((booking) => 
                booking.sessionDate.isBefore(DateTime.now()) || 
                booking.status != BookingStatus.confirmed)
            .toList();
      }
      
      // In a real app, we would query Firestore like this:
      /*
      final now = DateTime.now();
      
      var query = _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .limit(limit);
      
      if (upcoming) {
        query = query
            .where('status', isEqualTo: 'confirmed')
            .where('sessionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
            .orderBy('sessionDate', descending: false);
      } else {
        query = query
            .where('sessionDate', isLessThan: Timestamp.fromDate(now))
            .orderBy('sessionDate', descending: true);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
      */
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }
  
  // Book a session
  Future<BookingResult> bookSession({
    required String userId,
    required String sessionId,
    required String sessionTitle,
    required String? instructorId,
    required String? instructorName,
    required DateTime sessionDate,
    required DateTime startTime,
    required DateTime endTime,
    required int creditsRequired,
  }) async {
    try {
      // Check if user has enough credits
      final userCredit = await _getUserCredit(userId);
      
      if (userCredit == null) {
        return BookingResult.error('User credit information not found');
      }
      
      if (!userCredit.isUnlimited && userCredit.gymCredits < creditsRequired) {
        return BookingResult.error('Not enough credits. Required: $creditsRequired, Available: ${userCredit.gymCredits}');
      }
      
      // Check if session has available slots
      final isAvailable = await _checkSessionAvailability(sessionId);
      if (!isAvailable) {
        return BookingResult.error('Session is fully booked');
      }
      
      // Create booking
      final booking = BookingModel(
        id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        sessionId: sessionId,
        sessionTitle: sessionTitle,
        instructorId: instructorId,
        instructorName: instructorName,
        sessionDate: sessionDate,
        startTime: startTime,
        endTime: endTime,
        creditsUsed: creditsRequired,
        status: BookingStatus.confirmed,
        bookedAt: DateTime.now(),
      );
      
      // In a real app, we would use a Firestore transaction to ensure data consistency
      /*
      await _firestore.runTransaction((transaction) async {
        // Create booking document
        final bookingRef = _firestore.collection('bookings').doc();
        transaction.set(bookingRef, booking.copyWith(id: bookingRef.id).toFirestore());
        
        // Update session capacity
        final sessionRef = _firestore.collection('sessions').doc(sessionId);
        transaction.update(sessionRef, {'currentBookings': FieldValue.increment(1)});
        
        // Deduct credits if not unlimited
        if (!userCredit.isUnlimited) {
          final creditRef = _firestore.collection('userCredits').doc(userCredit.id);
          transaction.update(creditRef, {'gymCredits': FieldValue.increment(-creditsRequired)});
        }
        
        // Create credit adjustment record
        final adjustmentRef = _firestore.collection('creditAdjustments').doc();
        transaction.set(adjustmentRef, CreditAdjustment(
          id: adjustmentRef.id,
          userId: userId,
          gymCreditChange: -creditsRequired,
          intervalCreditChange: 0,
          reason: 'Booked: $sessionTitle',
          relatedBookingId: bookingRef.id,
          adjustedAt: DateTime.now(),
          adjustedBy: 'system',
        ).toFirestore());
      });
      */
      
      // Update remaining credits
      final remainingCredits = userCredit.isUnlimited 
          ? userCredit.gymCredits 
          : userCredit.gymCredits - creditsRequired;
      
      return BookingResult.success(
        bookingId: booking.id,
        creditsUsed: creditsRequired,
        remainingCredits: remainingCredits,
      );
    } catch (e) {
      return BookingResult.error('Failed to book session: $e');
    }
  }
  
  // Cancel a booking
  Future<BookingResult> cancelBooking({
    required String userId,
    required String bookingId,
  }) async {
    try {
      // For demo, find the booking in sample data
      final allBookings = BookingModel.getSampleBookings(userId);
      final bookingIndex = allBookings.indexWhere((b) => b.id == bookingId);
      
      if (bookingIndex == -1) {
        return BookingResult.error('Booking not found');
      }
      
      final booking = allBookings[bookingIndex];
      
      // Check if booking can be cancelled
      if (booking.status != BookingStatus.confirmed) {
        return BookingResult.error('Only confirmed bookings can be cancelled');
      }
      
      // Check cancellation policy (e.g., 24 hours before session)
      if (!booking.canBeCancelled()) {
        return BookingResult.error('Booking cannot be cancelled within 24 hours of the session');
      }
      
      // In a real app, we would use a transaction:
      /*
      await _firestore.runTransaction((transaction) async {
        // Update booking status
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        transaction.update(bookingRef, {
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
        
        // Update session capacity
        final sessionRef = _firestore.collection('sessions').doc(booking.sessionId);
        transaction.update(sessionRef, {'currentBookings': FieldValue.increment(-1)});
        
        // Refund credits
        final userCreditRef = _firestore.collection('userCredits').where('userId', isEqualTo: userId).limit(1);
        final creditSnapshot = await userCreditRef.get();
        
        if (!creditSnapshot.docs.isEmpty) {
          final creditDoc = creditSnapshot.docs.first;
          final creditId = creditDoc.id;
          
          // Update credits
          final creditRef = _firestore.collection('userCredits').doc(creditId);
          transaction.update(creditRef, {'gymCredits': FieldValue.increment(booking.creditsUsed)});
          
          // Create credit adjustment record
          final adjustmentRef = _firestore.collection('creditAdjustments').doc();
          transaction.set(adjustmentRef, CreditAdjustment(
            id: adjustmentRef.id,
            userId: userId,
            gymCreditChange: booking.creditsUsed,
            intervalCreditChange: 0,
            reason: 'Refund for cancelled booking: ${booking.sessionTitle}',
            relatedBookingId: bookingId,
            adjustedAt: DateTime.now(),
            adjustedBy: 'system',
          ).toFirestore());
        }
      });
      */
      
      return BookingResult.success(
        bookingId: bookingId,
        creditsUsed: -booking.creditsUsed, // Negative to indicate refund
        remainingCredits: 0, // We don't know the actual value in this demo
      );
    } catch (e) {
      return BookingResult.error('Failed to cancel booking: $e');
    }
  }
  
  // Get user credit history
  Future<List<CreditAdjustment>> getUserCreditHistory({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // For demo purposes, return sample adjustments
      return CreditAdjustment.getSampleAdjustments(userId);
      
      // In a real app:
      /*
      final querySnapshot = await _firestore
          .collection('creditAdjustments')
          .where('userId', isEqualTo: userId)
          .orderBy('adjustedAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CreditAdjustment.fromFirestore(doc))
          .toList();
      */
    } catch (e) {
      throw Exception('Failed to get credit history: $e');
    }
  }
  
  // Private methods
  
  // Get user credit information
  Future<UserCredit?> _getUserCredit(String userId) async {
    try {
      // For demo purposes, return default credits
      return UserCredit.defaultCredits();
      
      // In a real app:
      /*
      final querySnapshot = await _firestore
          .collection('userCredits')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return UserCredit.fromFirestore(querySnapshot.docs.first);
      */
    } catch (e) {
      throw Exception('Failed to get user credit: $e');
    }
  }
  
  // Check if session has available slots
  Future<bool> _checkSessionAvailability(String sessionId) async {
    try {
      // For demo purposes, assume session is available
      return true;
      
      // In a real app:
      /*
      final docSnapshot = await _firestore.collection('sessions').doc(sessionId).get();
      
      if (!docSnapshot.exists) {
        throw Exception('Session not found');
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      final int capacity = data['capacity'] ?? 0;
      final int currentBookings = data['currentBookings'] ?? 0;
      
      return currentBookings < capacity;
      */
    } catch (e) {
      throw Exception('Failed to check session availability: $e');
    }
  }
}