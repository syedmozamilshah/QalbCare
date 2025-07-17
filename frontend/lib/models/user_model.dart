import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final String whatsappNumber;
  final String selectedAvatar;
  final List<dynamic> chatHistory;
  final List<dynamic> muhasibaResults;
  final List<dynamic> qalbStateHistory;
  final int gemPoints;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.whatsappNumber,
    this.selectedAvatar = 'man2',
    required this.chatHistory,
    required this.muhasibaResults,
    required this.qalbStateHistory,
    required this.gemPoints,
    required this.createdAt,
  });

  // Convert UserProfile to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'whatsappNumber': whatsappNumber,
      'selectedAvatar': selectedAvatar,
      'chatHistory': chatHistory,
      'muhasibaResults': muhasibaResults,
      'qalbStateHistory': qalbStateHistory,
      'gemPoints': gemPoints,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create UserProfile from Map (from Firestore)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      whatsappNumber: map['whatsappNumber'] ?? '',
      selectedAvatar: map['selectedAvatar'] ?? 'man2',
      chatHistory: List<dynamic>.from(map['chatHistory'] ?? []),
      muhasibaResults: List<dynamic>.from(map['muhasibaResults'] ?? []),
      qalbStateHistory: List<dynamic>.from(map['qalbStateHistory'] ?? []),
      gemPoints: map['gemPoints'] ?? 0,
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
    );
  }

  // Copy with method for updating user profile
  UserProfile copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? whatsappNumber,
    String? selectedAvatar,
    List<dynamic>? chatHistory,
    List<dynamic>? muhasibaResults,
    List<dynamic>? qalbStateHistory,
    int? gemPoints,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      chatHistory: chatHistory ?? this.chatHistory,
      muhasibaResults: muhasibaResults ?? this.muhasibaResults,
      qalbStateHistory: qalbStateHistory ?? this.qalbStateHistory,
      gemPoints: gemPoints ?? this.gemPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, fullName: $fullName, whatsappNumber: $whatsappNumber, gemPoints: $gemPoints, createdAt: $createdAt)';
  }
}
