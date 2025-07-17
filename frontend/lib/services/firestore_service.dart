import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/muhasiba_model.dart';
import '../models/heart_state_model.dart';
import '../models/chat_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's UID
  String? get currentUserUid => _auth.currentUser?.uid;

  // MUHASIBA METHODS

  /// Save muhasiba result to Firestore
  Future<void> saveMuhasibaResult(DailyRecord record) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    final userDoc = _firestore.collection('users').doc(currentUserUid);
    
    await userDoc.update({
      'muhasibaResults': FieldValue.arrayUnion([record.toJson()])
    });
  }

  /// Get filtered muhasiba results based on date range
  Future<List<DailyRecord>> getMuhasibaResults({int? lastDays}) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(currentUserUid).get();
    
    if (!userDoc.exists) return [];

    final data = userDoc.data();
    final muhasibaResults = List<dynamic>.from(data?['muhasibaResults'] ?? []);
    
    // Convert to DailyRecord objects
    List<DailyRecord> records = muhasibaResults
        .map((json) => DailyRecord.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    // Filter by date range if specified
    if (lastDays != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: lastDays));
      records = records.where((record) {
        final recordDate = DateTime.parse(record.date);
        return recordDate.isAfter(cutoffDate) || 
               _isSameDay(recordDate, cutoffDate);
      }).toList();
    }

    // Sort by date (newest first)
    records.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return records;
  }

  /// Check if user has completed muhasiba today
  Future<bool> hasCompletedMuhasibaToday() async {
    final records = await getMuhasibaResults(lastDays: 1);
    final today = DateTime.now().toString().split(' ')[0];
    return records.any((record) => record.date == today);
  }

  // QALB STATE METHODS

  /// Save qalb state to Firestore
  Future<void> saveQalbState(HeartState heartState) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    final userDoc = _firestore.collection('users').doc(currentUserUid);
    
    await userDoc.update({
      'qalbStateHistory': FieldValue.arrayUnion([heartState.toJson()])
    });
  }

  /// Get filtered qalb state history based on date range
  Future<List<HeartState>> getQalbStateHistory({int? lastDays}) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(currentUserUid).get();
    
    if (!userDoc.exists) return [];

    final data = userDoc.data();
    final qalbStateHistory = List<dynamic>.from(data?['qalbStateHistory'] ?? []);
    
    // Convert to HeartState objects
    List<HeartState> states = qalbStateHistory
        .map((json) => HeartState.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    // Filter by date range if specified
    if (lastDays != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: lastDays));
      states = states.where((state) {
        final stateDate = DateTime.parse(state.date);
        return stateDate.isAfter(cutoffDate) || 
               _isSameDay(stateDate, cutoffDate);
      }).toList();
    }

    // Sort by date (newest first)
    states.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return states;
  }

  /// Get the most recent qalb state
  Future<HeartState?> getLatestQalbState() async {
    final states = await getQalbStateHistory(lastDays: 1);
    return states.isNotEmpty ? states.first : null;
  }

  /// Check if user has completed qalb state assessment today
  Future<bool> hasCompletedQalbStateToday() async {
    final states = await getQalbStateHistory(lastDays: 1);
    final today = DateTime.now().toString().split(' ')[0];
    return states.any((state) => state.date == today);
  }

  // GEM POINTS METHODS

  /// Add gem points for completing muhasiba (10 points)
  Future<void> addMuhasibaPoints() async {
    if (currentUserUid == null) throw Exception('User not authenticated');
    
    final userDoc = _firestore.collection('users').doc(currentUserUid);
    await userDoc.update({
      'gemPoints': FieldValue.increment(10)
    });
  }

  /// Add gem points for completing qalb state (50 points)
  Future<void> addQalbStatePoints() async {
    if (currentUserUid == null) throw Exception('User not authenticated');
    
    final userDoc = _firestore.collection('users').doc(currentUserUid);
    await userDoc.update({
      'gemPoints': FieldValue.increment(50)
    });
  }

  /// Get current gem points
  Future<int> getGemPoints() async {
    if (currentUserUid == null) throw Exception('User not authenticated');
    
    final userDoc = await _firestore.collection('users').doc(currentUserUid).get();
    if (!userDoc.exists) return 0;
    
    final data = userDoc.data();
    return data?['gemPoints'] ?? 0;
  }

  /// Deduct points for VAPI call (100,000 points)
  Future<void> deductVapiCallPoints() async {
    if (currentUserUid == null) throw Exception('User not authenticated');
    
    final userDoc = _firestore.collection('users').doc(currentUserUid);
    await userDoc.update({
      'gemPoints': FieldValue.increment(-100000)
    });
  }

  /// Deduct points for extended VAPI call (200 points per minute)
  Future<void> deductVapiExtendedPoints(int minutes) async {
    if (currentUserUid == null) throw Exception('User not authenticated');
    
    final pointsToDeduct = minutes * 200;
    final userDoc = _firestore.collection('users').doc(currentUserUid);
    await userDoc.update({
      'gemPoints': FieldValue.increment(-pointsToDeduct)
    });
  }

  /// Check if user has sufficient points for VAPI call
  Future<bool> hasVapiCallPoints() async {
    final points = await getGemPoints();
    return points >= 100000;
  }

  /// Calculate available VAPI call time in minutes
  Future<int> getVapiCallTimeInMinutes() async {
    final points = await getGemPoints();
    if (points < 100000) return 0;
    
    final extraPoints = points - 100000;
    final extraMinutes = extraPoints ~/ 200;
    return extraMinutes;
  }

  // CHAT SESSION METHODS

  /// Save chat session to Firestore
  Future<void> saveChatSession(ChatSession session) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('chatSessions')
        .doc(session.id)
        .set(session.toMap());
  }

  /// Get all chat sessions for current user
  Future<List<ChatSession>> getChatSessions() async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('chatSessions')
        .orderBy('lastUpdated', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ChatSession.fromMap(doc.data()))
        .toList();
  }

  /// Get a specific chat session
  Future<ChatSession?> getChatSession(String sessionId) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    final doc = await _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('chatSessions')
        .doc(sessionId)
        .get();

    if (doc.exists) {
      return ChatSession.fromMap(doc.data()!);
    }
    return null;
  }

  /// Update an existing chat session
  Future<void> updateChatSession(ChatSession session) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('chatSessions')
        .doc(session.id)
        .update(session.toMap());
  }

  /// Delete a chat session
  Future<void> deleteChatSession(String sessionId) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('chatSessions')
        .doc(sessionId)
        .delete();
  }

  /// Add message to existing chat session
  Future<void> addMessageToSession(String sessionId, ChatMessage message) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    final sessionRef = _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('chatSessions')
        .doc(sessionId);

    await sessionRef.update({
      'messages': FieldValue.arrayUnion([message.toMap()]),
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  // UTILITY METHODS

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Clean up old records (optional - can be called periodically)
  Future<void> cleanupOldRecords({int keepDays = 90}) async {
    if (currentUserUid == null) throw Exception('User not authenticated');

    final userDoc = _firestore.collection('users').doc(currentUserUid);
    final userData = await userDoc.get();
    
    if (!userData.exists) return;

    final data = userData.data()!;
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));

    // Clean muhasiba results
    final muhasibaResults = List<dynamic>.from(data['muhasibaResults'] ?? []);
    final filteredMuhasiba = muhasibaResults.where((record) {
      final recordDate = DateTime.parse(record['date']);
      return recordDate.isAfter(cutoffDate);
    }).toList();

    // Clean qalb state history
    final qalbStateHistory = List<dynamic>.from(data['qalbStateHistory'] ?? []);
    final filteredQalb = qalbStateHistory.where((state) {
      final stateDate = DateTime.parse(state['date']);
      return stateDate.isAfter(cutoffDate);
    }).toList();

    // Update if there are changes
    if (filteredMuhasiba.length != muhasibaResults.length ||
        filteredQalb.length != qalbStateHistory.length) {
      await userDoc.update({
        'muhasibaResults': filteredMuhasiba,
        'qalbStateHistory': filteredQalb,
      });
    }
  }
}
