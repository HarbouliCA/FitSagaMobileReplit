import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/models/instructor_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        return null;
      }
      
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Also update clients collection if exists
      DocumentSnapshot clientDoc = await _firestore
          .collection(AppConstants.clientsCollection)
          .doc(userId)
          .get();
      
      if (clientDoc.exists) {
        await _firestore
            .collection(AppConstants.clientsCollection)
            .doc(userId)
            .update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('memberSince', descending: true)
          .get();
      
      return usersSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get all instructors
  Future<List<InstructorModel>> getAllInstructors() async {
    try {
      QuerySnapshot instructorsSnapshot = await _firestore
          .collection(AppConstants.instructorsCollection)
          .where('accessStatus', isEqualTo: AppConstants.accessStatusGreen)
          .get();
      
      return instructorsSnapshot.docs
          .map((doc) => InstructorModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get instructor by ID
  Future<InstructorModel?> getInstructorById(String instructorId) async {
    try {
      DocumentSnapshot instructorDoc = await _firestore
          .collection(AppConstants.instructorsCollection)
          .doc(instructorId)
          .get();
      
      if (instructorDoc.exists) {
        return InstructorModel.fromFirestore(instructorDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Complete onboarding
  Future<void> completeOnboarding(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'onboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Also update clients collection if exists
      DocumentSnapshot clientDoc = await _firestore
          .collection(AppConstants.clientsCollection)
          .doc(userId)
          .get();
      
      if (clientDoc.exists) {
        await _firestore
            .collection(AppConstants.clientsCollection)
            .doc(userId)
            .update({
          'onboardingCompleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
