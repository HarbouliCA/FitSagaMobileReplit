import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service class to manage Firebase interactions
/// This provides a single point of access to Firebase services
class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  bool _initialized = false;
  
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal() :
    _auth = FirebaseAuth.instance,
    _firestore = FirebaseFirestore.instance,
    _storage = FirebaseStorage.instance;
  
  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  bool get isInitialized => _initialized;
  
  /// Initialize Firebase with the default options
  Future<void> initialize() async {
    if (!_initialized) {
      await Firebase.initializeApp();
      _initialized = true;
    }
  }
  
  /// Get Firestore collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }
  
  /// Get Firestore document reference
  DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }
  
  /// Create document with custom ID
  Future<void> setDoc(String path, Map<String, dynamic> data) {
    return document(path).set(data);
  }
  
  /// Create document with auto-generated ID
  Future<DocumentReference<Map<String, dynamic>>> addDoc(String collection, Map<String, dynamic> data) {
    return this.collection(collection).add(data);
  }
  
  /// Update document
  Future<void> updateDoc(String path, Map<String, dynamic> data) {
    return document(path).update(data);
  }
  
  /// Delete document
  Future<void> deleteDoc(String path) {
    return document(path).delete();
  }
  
  /// Get document by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(String path) {
    return document(path).get();
  }
  
  /// Get collection
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String path) {
    return collection(path).get();
  }
  
  /// Sign in anonymously
  Future<UserCredential> signInAnonymously() {
    return _auth.signInAnonymously();
  }
  
  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }
  
  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }
  
  /// Sign out
  Future<void> signOut() {
    return _auth.signOut();
  }
  
  /// Get current user
  User? get currentUser => _auth.currentUser;
  
  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Get storage reference
  Reference getStorageRef(String path) {
    return _storage.ref(path);
  }
  
  /// Upload file to storage
  UploadTask uploadFile(String path, dynamic file) {
    return getStorageRef(path).putFile(file);
  }
  
  /// Upload bytes to storage
  UploadTask uploadBytes(String path, List<int> bytes, {String? contentType}) {
    return getStorageRef(path).putData(
      Uint8List.fromList(bytes),
      contentType != null ? SettableMetadata(contentType: contentType) : null,
    );
  }
  
  /// Get download URL for a file
  Future<String> getDownloadURL(String path) {
    return getStorageRef(path).getDownloadURL();
  }
  
  /// Delete file from storage
  Future<void> deleteFile(String path) {
    return getStorageRef(path).delete();
  }
}