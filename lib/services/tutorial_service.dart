import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/models/tutorial_model.dart';

class TutorialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all tutorials
  Future<List<TutorialModel>> getAllTutorials() async {
    try {
      QuerySnapshot tutorialsSnapshot = await _firestore
          .collection(AppConstants.tutorialsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get tutorial by ID
  Future<TutorialModel?> getTutorialById(String tutorialId) async {
    try {
      DocumentSnapshot tutorialDoc = await _firestore
          .collection(AppConstants.tutorialsCollection)
          .doc(tutorialId)
          .get();
      
      if (tutorialDoc.exists) {
        return TutorialModel.fromFirestore(tutorialDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get tutorials by category
  Future<List<TutorialModel>> getTutorialsByCategory(String category) async {
    try {
      QuerySnapshot tutorialsSnapshot = await _firestore
          .collection(AppConstants.tutorialsCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();
      
      return tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get tutorials by difficulty
  Future<List<TutorialModel>> getTutorialsByDifficulty(String difficulty) async {
    try {
      QuerySnapshot tutorialsSnapshot = await _firestore
          .collection(AppConstants.tutorialsCollection)
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('createdAt', descending: true)
          .get();
      
      return tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Search tutorials
  Future<List<TutorialModel>> searchTutorials(String query) async {
    try {
      // Search by title
      QuerySnapshot titleSnapshot = await _firestore
          .collection(AppConstants.tutorialsCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('title')
          .limit(10)
          .get();
          
      // Search by author
      QuerySnapshot authorSnapshot = await _firestore
          .collection(AppConstants.tutorialsCollection)
          .where('author', isGreaterThanOrEqualTo: query)
          .where('author', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('author')
          .limit(10)
          .get();
          
      // Combine results and remove duplicates
      Map<String, TutorialModel> uniqueTutorials = {};
      
      for (var doc in titleSnapshot.docs) {
        uniqueTutorials[doc.id] = TutorialModel.fromFirestore(doc);
      }
      
      for (var doc in authorSnapshot.docs) {
        uniqueTutorials[doc.id] = TutorialModel.fromFirestore(doc);
      }
      
      return uniqueTutorials.values.toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get featured tutorials
  Future<List<TutorialModel>> getFeaturedTutorials() async {
    try {
      // In a real app, you might have a "featured" field
      // For this implementation, just returning the most recent tutorials
      
      QuerySnapshot tutorialsSnapshot = await _firestore
          .collection(AppConstants.tutorialsCollection)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      
      return tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
