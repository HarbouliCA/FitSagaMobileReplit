import 'package:cloud_firestore/cloud_firestore.dart';

class BankDetailsModel {
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String? iban;
  
  BankDetailsModel({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    this.iban,
  });
  
  factory BankDetailsModel.fromMap(Map<String, dynamic> map) {
    return BankDetailsModel(
      bankName: map['bankName'] ?? '',
      accountHolder: map['accountHolder'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      iban: map['iban'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'iban': iban,
    };
  }
}

class InstructorModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime dateOfBirth;
  final String telephone;
  final DateTime workingSince;
  final String address;
  final BankDetailsModel bankDetails;
  final String role;
  final String? photoURL;
  final String? bio;
  final List<String>? specialties;
  final String accessStatus;
  
  InstructorModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.telephone,
    required this.workingSince,
    required this.address,
    required this.bankDetails,
    required this.role,
    this.photoURL,
    this.bio,
    this.specialties,
    required this.accessStatus,
  });
  
  factory InstructorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return InstructorModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as Timestamp).toDate() 
          : DateTime.now(),
      telephone: data['telephone'] ?? '',
      workingSince: data['workingSince'] != null 
          ? (data['workingSince'] as Timestamp).toDate() 
          : DateTime.now(),
      address: data['address'] ?? '',
      bankDetails: data['bankDetails'] != null 
          ? BankDetailsModel.fromMap(data['bankDetails']) 
          : BankDetailsModel(
              bankName: '', 
              accountHolder: '', 
              accountNumber: ''
            ),
      role: data['role'] ?? 'instructor',
      photoURL: data['photoURL'],
      bio: data['bio'],
      specialties: data['specialties'] != null 
          ? List<String>.from(data['specialties']) 
          : null,
      accessStatus: data['accessStatus'] ?? 'green',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'telephone': telephone,
      'workingSince': workingSince,
      'address': address,
      'bankDetails': bankDetails.toMap(),
      'role': role,
      'photoURL': photoURL,
      'bio': bio,
      'specialties': specialties,
      'accessStatus': accessStatus,
    };
  }
}
