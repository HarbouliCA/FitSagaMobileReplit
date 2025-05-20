import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user
  User? get currentUser => _auth.currentUser;
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last active timestamp
      if (userCredential.user != null) {
        await _firestore.collection(AppConstants.usersCollection).doc(userCredential.user!.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
  
  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      if (userCredential.user != null) {
        await _firestore.collection(AppConstants.usersCollection).doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'name': name,
          'credits': 0,
          'role': AppConstants.roleUser,
          'memberSince': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'onboardingCompleted': false,
          'accessStatus': AppConstants.accessStatusGreen,
        });
        
        // Also create entry in clients collection
        await _firestore.collection(AppConstants.clientsCollection).doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid,
          'email': email,
          'name': name,
          'role': AppConstants.roleClient,
          'memberSince': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'credits': {
            'total': 0,
            'intervalCredits': 0,
            'lastRefilled': FieldValue.serverTimestamp(),
          },
          'accessStatus': AppConstants.accessStatusActive,
          'onboardingCompleted': false,
        });
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get user role
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] ?? AppConstants.roleUser;
      }
      
      return AppConstants.roleUser;
    } catch (e) {
      return AppConstants.roleUser;
    }
  }
  
  // Get user model
  Future<UserModel?> getUserModel(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
