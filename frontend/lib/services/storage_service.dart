import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qalbcare/models/muhasiba_model.dart';
import 'package:qalbcare/models/heart_state_model.dart';

class StorageService {
  // User related methods
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name.trim());
  }

  Future<void> clearUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
  }

  // Avatar related methods
  Future<String?> getUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userAvatar');
  }

  Future<void> saveUserAvatar(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAvatar', avatar);
  }

  // Muhasiba related methods
  Future<List<DailyRecord>> getWeeklyRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList('weeklyRecords') ?? [];
    return recordsJson
        .map((json) => DailyRecord.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveWeeklyRecords(List<DailyRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson =
        records.map((record) => jsonEncode(record.toJson())).toList();
    await prefs.setStringList('weeklyRecords', recordsJson);
  }

  // Heart state related methods
  Future<HeartState?> getHeartState() async {
    final prefs = await SharedPreferences.getInstance();
    final heartStateJson = prefs.getString('heartState');
    if (heartStateJson == null) return null;
    return HeartState.fromJson(jsonDecode(heartStateJson));
  }

  Future<void> saveHeartState(HeartState heartState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('heartState', jsonEncode(heartState.toJson()));
  }

  Future<bool> hasCompletedHeartJourney() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('completedHeartJourney') ?? false;
  }

  Future<void> setCompletedHeartJourney(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('completedHeartJourney', completed);
  }

  Future<DateTime?> getLastHeartCheckDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('lastHeartCheckDate');
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  Future<void> setLastHeartCheckDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastHeartCheckDate', date.toIso8601String());
  }
}
