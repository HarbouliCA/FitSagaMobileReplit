import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  
  // Collection references
  final CollectionReference _bookingsCollection;
  final CollectionReference _sessionsCollection;
  final CollectionReference _usersCollection;
  
  BookingService() : 
    _bookingsCollection = FirebaseFirestore.instance.collection('bookings'),
    _sessionsCollection = FirebaseFirestore.instance.collection('sessions'),
    _usersCollection = FirebaseFirestore.instance.collection('users');
  
  /// Book a session for a user
  Future<BookingModel> bookSession(
    UserModel user, 
    SessionModel session,
  ) async {
    // Check if the user has enough credits
    if (user.credits.gymCredits < session.creditsRequired) {
      throw Exception('Not enough credits to book this session');
    }
    
    // Check if the session has available slots
    if (!session.hasAvailableSlots) {
      throw Exception('Session is full');
    }
    
    // Start a Firestore batch operation to ensure atomicity
    final WriteBatch batch = _firestore.batch();
    
    try {
      // Create a new booking
      final String bookingId = _uuid.v4();
      final BookingModel newBooking = BookingModel(
        id: bookingId,
        userId: user.uid,
        sessionId: session.id,
        bookingDate: DateTime.now(),
        creditsUsed: session.creditsRequired,
        status: 'confirmed',
        hasAttended: false,
      );
      
      // Add booking document
      batch.set(
        _bookingsCollection.doc(bookingId),
        newBooking.toJson(),
      );
      
      // Update session document to increment booked count
      batch.update(
        _sessionsCollection.doc(session.id),
        {'bookedCount': FieldValue.increment(1)},
      );
      
      // Update user document to deduct credits and add booking reference
      batch.update(
        _usersCollection.doc(user.uid),
        {
          'credits.gymCredits': FieldValue.increment(-session.creditsRequired),
          'bookings': FieldValue.arrayUnion([bookingId]),
        },
      );
      
      // Commit the batch
      await batch.commit();
      
      return newBooking;
    } catch (e) {
      throw Exception('Failed to book session: ${e.toString()}');
    }
  }
  
  /// Cancel a booking
  Future<void> cancelBooking(
    BookingModel booking, 
    UserModel user,
    SessionModel session,
    {String? reason}
  ) async {
    if (booking.status == 'cancelled') {
      throw Exception('Booking is already cancelled');
    }
    
    // Start a Firestore batch operation to ensure atomicity
    final WriteBatch batch = _firestore.batch();
    
    try {
      // Update booking status
      batch.update(
        _bookingsCollection.doc(booking.id),
        {
          'status': 'cancelled',
          'cancellationReason': reason,
          'cancelledAt': FieldValue.serverTimestamp(),
        },
      );
      
      // Update session document to decrement booked count
      batch.update(
        _sessionsCollection.doc(booking.sessionId),
        {'bookedCount': FieldValue.increment(-1)},
      );
      
      // Return credits to user if cancellation policy allows
      // For example, only refund if cancellation is more than 24 hours before session
      final DateTime sessionDate = session.date;
      final DateTime now = DateTime.now();
      final Duration difference = sessionDate.difference(now);
      
      if (difference.inHours > 24) {
        // Full refund
        batch.update(
          _usersCollection.doc(user.uid),
          {
            'credits.gymCredits': FieldValue.increment(booking.creditsUsed),
          },
        );
      } else if (difference.inHours > 12) {
        // Partial refund (50%)
        batch.update(
          _usersCollection.doc(user.uid),
          {
            'credits.gymCredits': FieldValue.increment(booking.creditsUsed ~/ 2),
          },
        );
      }
      // No refund for cancellations less than 12 hours before
      
      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }
  
  /// Get all bookings for a user
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final QuerySnapshot snapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('bookingDate', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return BookingModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user bookings: ${e.toString()}');
    }
  }
  
  /// Get upcoming bookings for a user
  Future<List<BookingModel>> getUserUpcomingBookings(String userId) async {
    try {
      final QuerySnapshot snapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .get();
      
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return BookingModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming bookings: ${e.toString()}');
    }
  }
  
  /// Get all bookings for a session
  Future<List<BookingModel>> getSessionBookings(String sessionId) async {
    try {
      final QuerySnapshot snapshot = await _bookingsCollection
          .where('sessionId', isEqualTo: sessionId)
          .where('status', isEqualTo: 'confirmed')
          .get();
      
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return BookingModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get session bookings: ${e.toString()}');
    }
  }
  
  /// Set attendance for a booking (used by instructors)
  Future<void> setAttendance(String bookingId, bool hasAttended) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'hasAttended': hasAttended,
        'status': 'completed',
      });
    } catch (e) {
      throw Exception('Failed to update attendance: ${e.toString()}');
    }
  }
  
  /// Get session details by ID
  Future<SessionModel> getSessionById(String sessionId) async {
    try {
      final DocumentSnapshot doc = await _sessionsCollection.doc(sessionId).get();
      
      if (!doc.exists) {
        throw Exception('Session not found');
      }
      
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return SessionModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get session: ${e.toString()}');
    }
  }
  
  /// Stream of all session bookings for live updates
  Stream<List<BookingModel>> streamSessionBookings(String sessionId) {
    return _bookingsCollection
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return BookingModel.fromJson(data);
          }).toList();
        });
  }
  
  /// Stream of user bookings for live updates
  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return BookingModel.fromJson(data);
          }).toList();
        });
  }
  
  /// Check if user has already booked this session
  Future<bool> hasUserBookedSession(String userId, String sessionId) async {
    try {
      final QuerySnapshot snapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .where('sessionId', isEqualTo: sessionId)
          .where('status', whereIn: ['confirmed', 'pending'])
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check booking status: ${e.toString()}');
    }
  }
}