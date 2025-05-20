import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitsaga/models/credit_model.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _sessionsCollection = FirebaseFirestore.instance.collection('sessions');
  final CollectionReference _tutorialsCollection = FirebaseFirestore.instance.collection('tutorials');
  final CollectionReference _creditsCollection = FirebaseFirestore.instance.collection('credits');

  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal();
  
  // Initialize Firebase
  Future<void> initialize() async {
    await Firebase.initializeApp();
  }
  
  // Authentication methods
  
  // Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Get user data from Firestore
        return await getUserById(result.user!.uid);
      }
      
      return null;
    } catch (e) {
      rethrow; // Let the provider handle the error
    }
  }
  
  // Sign up with email and password
  Future<UserModel?> signUpWithEmail(String email, String password, String name) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Create user model
        final UserModel newUser = UserModel(
          id: result.user!.uid,
          name: name,
          email: email,
          role: UserRole.client, // Default role is client
          photoUrl: null,
          createdAt: DateTime.now(),
        );
        
        // Save user to Firestore
        await _usersCollection.doc(result.user!.uid).set(newUser.toMap());
        
        // Create initial credit record for new user
        await _createInitialCredit(result.user!.uid);
        
        return newUser;
      }
      
      return null;
    } catch (e) {
      rethrow; // Let the provider handle the error
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Check if user is signed in
  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }
  
  // Get current user
  Future<UserModel?> getCurrentUser() async {
    if (_auth.currentUser != null) {
      return getUserById(_auth.currentUser!.uid);
    }
    return null;
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // Firestore CRUD operations
  
  // Create initial credit record for new user
  Future<void> _createInitialCredit(String userId) async {
    // New users get 5 free credits
    final creditRecord = CreditModel(
      id: '', // Will be set by Firestore
      userId: userId,
      amount: 5,
      type: CreditTransactionType.initial,
      description: 'Welcome credits',
      createdAt: DateTime.now(),
    );
    
    await _creditsCollection.add(creditRecord.toMap());
  }
  
  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  // Update user data
  Future<bool> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toMap());
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
  
  // Get all available sessions
  Future<List<SessionModel>> getAllSessions() async {
    try {
      final QuerySnapshot snapshot = await _sessionsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('startTime')
          .get();
      
      return snapshot.docs
          .map((doc) => SessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting sessions: $e');
      return [];
    }
  }
  
  // Get sessions by instructor ID
  Future<List<SessionModel>> getSessionsByInstructor(String instructorId) async {
    try {
      final QuerySnapshot snapshot = await _sessionsCollection
          .where('instructorId', isEqualTo: instructorId)
          .orderBy('startTime')
          .get();
      
      return snapshot.docs
          .map((doc) => SessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting instructor sessions: $e');
      return [];
    }
  }
  
  // Get sessions booked by user
  Future<List<SessionModel>> getUserBookedSessions(String userId) async {
    try {
      final QuerySnapshot snapshot = await _sessionsCollection
          .where('participantIds', arrayContains: userId)
          .orderBy('startTime')
          .get();
      
      return snapshot.docs
          .map((doc) => SessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting user booked sessions: $e');
      return [];
    }
  }
  
  // Create a new session (instructor or admin only)
  Future<String?> createSession(SessionModel session) async {
    try {
      final DocumentReference doc = await _sessionsCollection.add(session.toMap());
      return doc.id;
    } catch (e) {
      print('Error creating session: $e');
      return null;
    }
  }
  
  // Update a session (instructor or admin only)
  Future<bool> updateSession(SessionModel session) async {
    try {
      await _sessionsCollection.doc(session.id).update(session.toMap());
      return true;
    } catch (e) {
      print('Error updating session: $e');
      return false;
    }
  }
  
  // Delete a session (admin only)
  Future<bool> deleteSession(String sessionId) async {
    try {
      await _sessionsCollection.doc(sessionId).delete();
      return true;
    } catch (e) {
      print('Error deleting session: $e');
      return false;
    }
  }
  
  // Book a session
  Future<bool> bookSession(String sessionId, String userId) async {
    try {
      // First, check if user has enough credits
      final int userCredits = await getUserCreditBalance(userId);
      
      if (userCredits < 1) {
        return false; // Not enough credits
      }
      
      // Get the session
      final DocumentSnapshot sessionDoc = await _sessionsCollection.doc(sessionId).get();
      
      if (!sessionDoc.exists) {
        return false; // Session not found
      }
      
      final SessionModel session = SessionModel.fromMap(
        sessionDoc.data() as Map<String, dynamic>,
        sessionDoc.id,
      );
      
      // Check if session is full
      if (session.participantIds.length >= session.maxParticipants) {
        return false; // Session is full
      }
      
      // Check if user is already booked
      if (session.participantIds.contains(userId)) {
        return false; // Already booked
      }
      
      // Add user to participants and update session
      session.participantIds.add(userId);
      await _sessionsCollection.doc(sessionId).update({
        'participantIds': session.participantIds,
      });
      
      // Deduct credit
      await _deductCredit(userId, 'Booking session: ${session.title}');
      
      return true;
    } catch (e) {
      print('Error booking session: $e');
      return false;
    }
  }
  
  // Cancel a session booking
  Future<bool> cancelSessionBooking(String sessionId, String userId) async {
    try {
      // Get the session
      final DocumentSnapshot sessionDoc = await _sessionsCollection.doc(sessionId).get();
      
      if (!sessionDoc.exists) {
        return false; // Session not found
      }
      
      final SessionModel session = SessionModel.fromMap(
        sessionDoc.data() as Map<String, dynamic>,
        sessionDoc.id,
      );
      
      // Check if user is booked
      if (!session.participantIds.contains(userId)) {
        return false; // Not booked
      }
      
      // Remove user from participants and update session
      session.participantIds.remove(userId);
      await _sessionsCollection.doc(sessionId).update({
        'participantIds': session.participantIds,
      });
      
      // Refund credit if cancellation is more than 24 hours before session
      final DateTime now = DateTime.now();
      if (session.startTime.difference(now).inHours > 24) {
        await _addCredit(userId, 1, 'Refund for cancelled session: ${session.title}');
      }
      
      return true;
    } catch (e) {
      print('Error cancelling session: $e');
      return false;
    }
  }
  
  // Get all tutorials
  Future<List<TutorialModel>> getAllTutorials() async {
    try {
      final QuerySnapshot snapshot = await _tutorialsCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => TutorialModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting tutorials: $e');
      return [];
    }
  }
  
  // Get tutorial details
  Future<TutorialModel?> getTutorialById(String tutorialId) async {
    try {
      final DocumentSnapshot doc = await _tutorialsCollection.doc(tutorialId).get();
      
      if (doc.exists) {
        return TutorialModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      
      return null;
    } catch (e) {
      print('Error getting tutorial: $e');
      return null;
    }
  }
  
  // Create a new tutorial (instructor or admin only)
  Future<String?> createTutorial(TutorialModel tutorial) async {
    try {
      final DocumentReference doc = await _tutorialsCollection.add(tutorial.toMap());
      return doc.id;
    } catch (e) {
      print('Error creating tutorial: $e');
      return null;
    }
  }
  
  // Update a tutorial (instructor or admin only)
  Future<bool> updateTutorial(TutorialModel tutorial) async {
    try {
      await _tutorialsCollection.doc(tutorial.id).update(tutorial.toMap());
      return true;
    } catch (e) {
      print('Error updating tutorial: $e');
      return false;
    }
  }
  
  // Delete a tutorial (admin only)
  Future<bool> deleteTutorial(String tutorialId) async {
    try {
      await _tutorialsCollection.doc(tutorialId).delete();
      return true;
    } catch (e) {
      print('Error deleting tutorial: $e');
      return false;
    }
  }
  
  // Get user credit balance
  Future<int> getUserCreditBalance(String userId) async {
    try {
      final QuerySnapshot snapshot = await _creditsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      final List<CreditModel> creditHistory = snapshot.docs
          .map((doc) => CreditModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // Calculate balance
      int balance = 0;
      for (final credit in creditHistory) {
        if (credit.type == CreditTransactionType.purchase || 
            credit.type == CreditTransactionType.initial ||
            credit.type == CreditTransactionType.refund) {
          balance += credit.amount;
        } else if (credit.type == CreditTransactionType.usage) {
          balance -= credit.amount;
        }
      }
      
      return balance;
    } catch (e) {
      print('Error getting user credit balance: $e');
      return 0;
    }
  }
  
  // Get user credit history
  Future<List<CreditModel>> getUserCreditHistory(String userId) async {
    try {
      final QuerySnapshot snapshot = await _creditsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => CreditModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting user credit history: $e');
      return [];
    }
  }
  
  // Add credits (purchase or admin gift)
  Future<bool> _addCredit(String userId, int amount, String description, {CreditTransactionType type = CreditTransactionType.purchase}) async {
    try {
      final creditRecord = CreditModel(
        id: '', // Will be set by Firestore
        userId: userId,
        amount: amount,
        type: type,
        description: description,
        createdAt: DateTime.now(),
      );
      
      await _creditsCollection.add(creditRecord.toMap());
      return true;
    } catch (e) {
      print('Error adding credits: $e');
      return false;
    }
  }
  
  // Deduct credits (session booking)
  Future<bool> _deductCredit(String userId, String description) async {
    try {
      final creditRecord = CreditModel(
        id: '', // Will be set by Firestore
        userId: userId,
        amount: 1, // Each session costs 1 credit
        type: CreditTransactionType.usage,
        description: description,
        createdAt: DateTime.now(),
      );
      
      await _creditsCollection.add(creditRecord.toMap());
      return true;
    } catch (e) {
      print('Error deducting credit: $e');
      return false;
    }
  }
  
  // Purchase credits (client only)
  Future<bool> purchaseCredits(String userId, int amount, String paymentReference) async {
    return _addCredit(
      userId, 
      amount, 
      'Purchase of $amount credits. Ref: $paymentReference',
      type: CreditTransactionType.purchase,
    );
  }
  
  // Gift credits (admin only)
  Future<bool> giftCredits(String userId, int amount, String reason) async {
    return _addCredit(
      userId, 
      amount, 
      'Gift: $reason',
      type: CreditTransactionType.initial,
    );
  }
  
  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _usersCollection.get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }
  
  // Update user role (admin only)
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _usersCollection.doc(userId).update({
        'role': newRole.toString().split('.').last,
      });
      return true;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }
}