import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/credit_model.dart';
import 'package:fitsaga/models/tutorial_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Collections
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _sessionsCollection = FirebaseFirestore.instance.collection('sessions');
  final CollectionReference _bookingsCollection = FirebaseFirestore.instance.collection('bookings');
  final CollectionReference _creditsCollection = FirebaseFirestore.instance.collection('credits');
  final CollectionReference _creditTransactionsCollection = FirebaseFirestore.instance.collection('creditTransactions');
  final CollectionReference _creditPackagesCollection = FirebaseFirestore.instance.collection('creditPackages');
  final CollectionReference _tutorialsCollection = FirebaseFirestore.instance.collection('tutorials');
  final CollectionReference _tutorialDaysCollection = FirebaseFirestore.instance.collection('tutorialDays');
  final CollectionReference _exercisesCollection = FirebaseFirestore.instance.collection('exercises');
  final CollectionReference _tutorialProgressCollection = FirebaseFirestore.instance.collection('tutorialProgress');

  // Initialization
  Future<void> initialize() async {
    // Any additional initialization can be done here
  }

  // Authentication methods
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<UserCredential> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      final userId = userCredential.user!.uid;
      await _usersCollection.doc(userId).set({
        'id': userId,
        'email': email,
        'name': name,
        'role': 'client', // Default role is client
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      
      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  // User methods
  Future<UserModel> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      final userData = await _usersCollection.doc(user.uid).get();
      if (!userData.exists) {
        throw Exception('User data not found');
      }
      
      return UserModel.fromMap(userData.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<UserModel> getUserById(String userId) async {
    try {
      final userData = await _usersCollection.doc(userId).get();
      if (!userData.exists) {
        throw Exception('User not found');
      }
      
      return UserModel.fromMap(userData.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Session methods
  Future<List<SessionModel>> getSessions({
    String? instructorId,
    DateTime? startDate,
    DateTime? endDate,
    String? activityType,
    bool onlyAvailable = false,
  }) async {
    try {
      Query query = _sessionsCollection;
      
      if (instructorId != null) {
        query = query.where('instructorId', isEqualTo: instructorId);
      }
      
      if (startDate != null) {
        query = query.where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      if (activityType != null) {
        query = query.where('activityType', isEqualTo: activityType);
      }
      
      if (onlyAvailable) {
        query = query.where('status', isEqualTo: 'active');
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        return SessionModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get sessions: ${e.toString()}');
    }
  }

  Future<SessionModel> getSessionById(String sessionId) async {
    try {
      final sessionDoc = await _sessionsCollection.doc(sessionId).get();
      if (!sessionDoc.exists) {
        throw Exception('Session not found');
      }
      
      return SessionModel.fromMap(sessionDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get session: ${e.toString()}');
    }
  }

  Future<List<SessionModel>> getUserBookedSessions(String userId) async {
    try {
      final bookingQuery = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();
      
      final sessionIds = bookingQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['sessionId'] as String;
      }).toList();
      
      if (sessionIds.isEmpty) {
        return [];
      }
      
      final sessionSnapshots = await Future.wait(
        sessionIds.map((id) => _sessionsCollection.doc(id).get())
      );
      
      return sessionSnapshots
          .where((doc) => doc.exists)
          .map((doc) => SessionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user booked sessions: ${e.toString()}');
    }
  }

  Future<bool> hasUserBookedSession(String userId, String sessionId) async {
    try {
      final bookingQuery = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .where('sessionId', isEqualTo: sessionId)
          .where('status', isEqualTo: 'active')
          .get();
      
      return bookingQuery.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if user booked session: ${e.toString()}');
    }
  }

  Future<BookingModel> bookSession(String userId, String sessionId, int creditsUsed) async {
    try {
      // Check if session exists and is available
      final sessionDoc = await _sessionsCollection.doc(sessionId).get();
      if (!sessionDoc.exists) {
        throw Exception('Session not found');
      }
      
      final session = SessionModel.fromMap(sessionDoc.data() as Map<String, dynamic>);
      
      if (session.status != 'active') {
        throw Exception('Session is not available for booking');
      }
      
      if (session.isFull) {
        throw Exception('Session is fully booked');
      }
      
      if (session.isPast) {
        throw Exception('Cannot book a past session');
      }
      
      // Check if user already booked this session
      final existingBooking = await hasUserBookedSession(userId, sessionId);
      if (existingBooking) {
        throw Exception('You have already booked this session');
      }
      
      // Create booking
      final bookingId = _uuid.v4();
      final booking = BookingModel(
        id: bookingId,
        sessionId: sessionId,
        userId: userId,
        status: 'active',
        creditsUsed: creditsUsed,
        bookingTime: DateTime.now(),
      );
      
      await _bookingsCollection.doc(bookingId).set(booking.toMap());
      
      // Update session enrolled count
      await _sessionsCollection.doc(sessionId).update({
        'enrolledCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return booking;
    } catch (e) {
      throw Exception('Failed to book session: ${e.toString()}');
    }
  }

  Future<void> cancelBooking(String bookingId, String? reason) async {
    try {
      // Get booking
      final bookingDoc = await _bookingsCollection.doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }
      
      final booking = BookingModel.fromMap(bookingDoc.data() as Map<String, dynamic>);
      
      // Check if booking is already cancelled
      if (booking.status != 'active') {
        throw Exception('Booking is already cancelled');
      }
      
      // Check if session already started
      final sessionDoc = await _sessionsCollection.doc(booking.sessionId).get();
      if (sessionDoc.exists) {
        final session = SessionModel.fromMap(sessionDoc.data() as Map<String, dynamic>);
        if (session.isInProgress || session.isPast) {
          throw Exception('Cannot cancel a booking for a session that has already started');
        }
      }
      
      // Update booking status
      await _bookingsCollection.doc(bookingId).update({
        'status': 'cancelled',
        'cancelledTime': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
      });
      
      // Update session enrolled count
      await _sessionsCollection.doc(booking.sessionId).update({
        'enrolledCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }

  // Credit methods
  Future<List<CreditModel>> getUserCredits(String userId) async {
    try {
      final creditsQuery = await _creditsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .orderBy('expiryDate')
          .get();
      
      return creditsQuery.docs.map((doc) {
        return CreditModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user credits: ${e.toString()}');
    }
  }

  Future<int> getUserTotalCredits(String userId) async {
    try {
      final credits = await getUserCredits(userId);
      
      // Check if user has unlimited credits
      final hasUnlimited = credits.any((credit) => credit.isUnlimited);
      if (hasUnlimited) {
        return -1; // -1 represents unlimited credits
      }
      
      return credits.fold(0, (sum, credit) => sum + credit.credits);
    } catch (e) {
      throw Exception('Failed to get user total credits: ${e.toString()}');
    }
  }

  Future<bool> hasUserSufficientCredits(String userId, int requiredCredits) async {
    try {
      final totalCredits = await getUserTotalCredits(userId);
      
      // If totalCredits is -1, it means user has unlimited credits
      if (totalCredits == -1) {
        return true;
      }
      
      return totalCredits >= requiredCredits;
    } catch (e) {
      throw Exception('Failed to check if user has sufficient credits: ${e.toString()}');
    }
  }

  Future<void> deductCredits(String userId, int amount, String description, String? reference) async {
    try {
      final credits = await getUserCredits(userId);
      
      // If user has unlimited credits, don't deduct anything
      if (credits.any((credit) => credit.isUnlimited)) {
        return;
      }
      
      int remainingToDeduct = amount;
      int totalCreditsAfter = credits.fold(0, (sum, credit) => sum + credit.credits);
      
      if (totalCreditsAfter < amount) {
        throw Exception('Insufficient credits');
      }
      
      totalCreditsAfter -= amount;
      
      // Sort credits by expiry date (oldest first)
      credits.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      
      for (final credit in credits) {
        if (remainingToDeduct <= 0) {
          break;
        }
        
        final deduction = remainingToDeduct > credit.credits ? credit.credits : remainingToDeduct;
        remainingToDeduct -= deduction;
        
        // Update credit
        await _creditsCollection.doc(credit.id).update({
          'credits': FieldValue.increment(-deduction),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Create transaction record
        final transactionId = _uuid.v4();
        await _creditTransactionsCollection.doc(transactionId).set({
          'id': transactionId,
          'userId': userId,
          'creditId': credit.id,
          'type': 'used',
          'amount': -deduction,
          'balanceAfter': totalCreditsAfter,
          'description': description,
          'reference': reference,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to deduct credits: ${e.toString()}');
    }
  }

  Future<List<CreditPackageModel>> getCreditPackages() async {
    try {
      final packagesQuery = await _creditPackagesCollection
          .where('isActive', isEqualTo: true)
          .get();
      
      final packages = packagesQuery.docs.map((doc) {
        return CreditPackageModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      
      // Filter packages based on validity period
      final now = DateTime.now();
      return packages.where((package) {
        return (package.validFrom == null || package.validFrom!.isBefore(now)) &&
               (package.validUntil == null || package.validUntil!.isAfter(now));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get credit packages: ${e.toString()}');
    }
  }

  // Tutorial methods
  Future<List<TutorialModel>> getAllTutorials() async {
    try {
      final tutorialsQuery = await _tutorialsCollection.get();
      
      final tutorials = <TutorialModel>[];
      
      for (final doc in tutorialsQuery.docs) {
        final tutorialData = doc.data() as Map<String, dynamic>;
        final tutorialId = tutorialData['id'] as String;
        
        // Get tutorial days
        final daysQuery = await _tutorialDaysCollection
            .where('tutorialId', isEqualTo: tutorialId)
            .orderBy('dayNumber')
            .get();
        
        final days = <TutorialDayModel>[];
        
        for (final dayDoc in daysQuery.docs) {
          final dayData = dayDoc.data() as Map<String, dynamic>;
          final dayId = dayData['id'] as String;
          
          // Get exercises for this day
          final exercisesQuery = await _exercisesCollection
              .where('dayId', isEqualTo: dayId)
              .orderBy('order')
              .get();
          
          final exercises = exercisesQuery.docs.map((exerciseDoc) {
            return ExerciseModel.fromMap(exerciseDoc.data() as Map<String, dynamic>);
          }).toList();
          
          days.add(TutorialDayModel.fromMap(dayData, exercises));
        }
        
        tutorials.add(TutorialModel.fromMap(tutorialData, days));
      }
      
      return tutorials;
    } catch (e) {
      throw Exception('Failed to get tutorials: ${e.toString()}');
    }
  }

  Future<TutorialModel> getTutorialById(String tutorialId) async {
    try {
      final tutorialDoc = await _tutorialsCollection.doc(tutorialId).get();
      if (!tutorialDoc.exists) {
        throw Exception('Tutorial not found');
      }
      
      final tutorialData = tutorialDoc.data() as Map<String, dynamic>;
      
      // Get tutorial days
      final daysQuery = await _tutorialDaysCollection
          .where('tutorialId', isEqualTo: tutorialId)
          .orderBy('dayNumber')
          .get();
      
      final days = <TutorialDayModel>[];
      
      for (final dayDoc in daysQuery.docs) {
        final dayData = dayDoc.data() as Map<String, dynamic>;
        final dayId = dayData['id'] as String;
        
        // Get exercises for this day
        final exercisesQuery = await _exercisesCollection
            .where('dayId', isEqualTo: dayId)
            .orderBy('order')
            .get();
        
        final exercises = exercisesQuery.docs.map((exerciseDoc) {
          return ExerciseModel.fromMap(exerciseDoc.data() as Map<String, dynamic>);
        }).toList();
        
        days.add(TutorialDayModel.fromMap(dayData, exercises));
      }
      
      return TutorialModel.fromMap(tutorialData, days);
    } catch (e) {
      throw Exception('Failed to get tutorial: ${e.toString()}');
    }
  }

  Future<TutorialProgressModel> getUserTutorialProgress(String userId, String tutorialId) async {
    try {
      final progressId = '$userId-$tutorialId';
      final progressDoc = await _tutorialProgressCollection.doc(progressId).get();
      
      if (!progressDoc.exists) {
        // Create new progress record
        final newProgress = TutorialProgressModel.initial(
          userId: userId,
          tutorialId: tutorialId,
        );
        
        await _tutorialProgressCollection.doc(progressId).set(newProgress.toMap());
        
        return newProgress;
      }
      
      return TutorialProgressModel.fromMap(progressDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get user tutorial progress: ${e.toString()}');
    }
  }

  Future<void> updateTutorialProgress(TutorialProgressModel progress) async {
    try {
      await _tutorialProgressCollection.doc(progress.id).update(progress.toMap());
    } catch (e) {
      throw Exception('Failed to update tutorial progress: ${e.toString()}');
    }
  }

  Future<void> markExerciseAsCompleted(String userId, String tutorialId, String exerciseId, TutorialModel tutorial) async {
    try {
      final progressId = '$userId-$tutorialId';
      
      // Get current progress
      final progressDoc = await _tutorialProgressCollection.doc(progressId).get();
      
      TutorialProgressModel progress;
      if (!progressDoc.exists) {
        progress = TutorialProgressModel.initial(
          userId: userId,
          tutorialId: tutorialId,
        );
      } else {
        progress = TutorialProgressModel.fromMap(progressDoc.data() as Map<String, dynamic>);
      }
      
      // Add exercise to completed exercises
      final updatedExercises = List<String>.from(progress.completedExercises);
      if (!updatedExercises.contains(exerciseId)) {
        updatedExercises.add(exerciseId);
      }
      
      // Check if day is completed
      final completedDays = <int>[];
      for (final day in tutorial.days) {
        final dayExerciseIds = day.exercises.map((e) => e.id).toList();
        final isCompleted = dayExerciseIds.every((id) => updatedExercises.contains(id));
        
        if (isCompleted && !completedDays.contains(day.dayNumber)) {
          completedDays.add(day.dayNumber);
        }
      }
      
      // Calculate progress percentage
      final totalExercises = tutorial.totalExercises;
      final completedExercisesCount = updatedExercises.length;
      final progressPercentage = totalExercises > 0 
          ? (completedExercisesCount / totalExercises) * 100 
          : 0.0;
      
      // Check if tutorial is completed
      final isCompleted = progressPercentage >= 100;
      
      // Update progress
      final updatedProgress = progress.copyWith(
        completedExercises: updatedExercises,
        completedDays: completedDays,
        progressPercentage: progressPercentage,
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
        lastUpdatedAt: DateTime.now(),
      );
      
      await _tutorialProgressCollection.doc(progressId).set(updatedProgress.toMap());
    } catch (e) {
      throw Exception('Failed to mark exercise as completed: ${e.toString()}');
    }
  }
}