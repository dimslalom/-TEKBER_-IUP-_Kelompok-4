import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_model.dart';  // Make sure this import is correct

class AuthState extends ChangeNotifier {
  bool _isLoggedIn = false;
  User? _currentUser;
  final Map<String, User> _users = {};
  late SharedPreferences _prefs;

  bool get isLoggedIn => _isLoggedIn;
  String get username => _currentUser?.username ?? '';
  String get bio => _currentUser?.bio ?? 'No bio yet';
  String get profileImage => _currentUser?.profileImage ?? 'default';

  String? get parentPasscode => _currentUser?.parentPasscode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUsers();
  }

  void _loadUsers() {
    try {
      final usersJson = _prefs.getString('users') ?? '{}';
      final usersMap = json.decode(usersJson) as Map<String, dynamic>;
      _users.clear();
      usersMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          _users[key] = User.fromJson(value);
        }
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
      _users.clear();
    }
  }

  Future<void> _saveUsers() async {
    try {
      final usersMap = <String, dynamic>{};
      _users.forEach((key, value) {
        usersMap[key] = value.toJson();
      });
      await _prefs.setString('users', json.encode(usersMap));
    } catch (e) {
      debugPrint('Error saving users: $e');
    }
  }

  Future<bool> register(String username, String password) async {
    if (_users.containsKey(username)) return false;
    
    _users[username] = User(
      username: username,
      password: password,
    );
    await _saveUsers();
    return login(username, password);
  }

  Future<bool> login(String username, String password) async {
    if (!_users.containsKey(username)) return false;
    if (_users[username]?.password != password) return false;

    _currentUser = _users[username];
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? username, String? bio, String? profileImage}) async {
    if (!_isLoggedIn || _currentUser == null) return;

    if (bio != null) _currentUser!.bio = bio;
    if (profileImage != null) {
      _currentUser!.profileImage = profileImage;
    }
    
    await _saveUsers();
    notifyListeners();
  }

  Future<void> updateParentPasscode(String passcode) async {
    if (!_isLoggedIn || _currentUser == null) return;
    _currentUser!.parentPasscode = passcode;
    await _saveUsers();
    notifyListeners();
  }

  Duration get totalScreenTime => _currentUser?.totalScreenTime ?? Duration.zero;

  set totalScreenTime(Duration time) {
    if (_currentUser == null) return;
    _currentUser!.totalScreenTime = time;
    _saveUsers();
    notifyListeners();
  }

  Duration get dailyTimeLimit => _currentUser?.dailyTimeLimit ?? const Duration(hours: 1);

  set dailyTimeLimit(Duration limit) {
    if (_currentUser == null) return;
    _currentUser!.dailyTimeLimit = limit;
    _saveUsers();
    notifyListeners();
  }

  TimeOfDay? get allowedStartTime => _currentUser?.allowedStartTime;

  set allowedStartTime(TimeOfDay? time) {
    if (_currentUser == null) return;
    _currentUser!.allowedStartTime = time;
    _saveUsers();
    notifyListeners();
  }

  TimeOfDay? get allowedEndTime => _currentUser?.allowedEndTime;

  set allowedEndTime(TimeOfDay? time) {
    if (_currentUser == null) return;
    _currentUser!.allowedEndTime = time;
    _saveUsers();
    notifyListeners();
  }

  DateTime? get lastScreenTimeUpdate => _currentUser?.lastScreenTimeUpdate;

  void updateScreenTime(Duration delta) {
    if (_currentUser == null) return;
    _currentUser!.totalScreenTime += delta;
    _currentUser!.lastScreenTimeUpdate = DateTime.now();
    _saveUsers();
    notifyListeners();
  }

  void resetDailyScreenTime() {
    if (_currentUser == null) return;
    _currentUser!.totalScreenTime = Duration.zero;
    _currentUser!.lastScreenTimeUpdate = DateTime.now();
    _saveUsers();
    notifyListeners();
  }

  Future<void> markQuizCompleted() async {
    if (_currentUser == null) return;
    _currentUser!.quizCompletedOn = DateTime.now();
    await _saveUsers();
    notifyListeners();
  }

  bool hasCompletedQuizToday() {
    if (_currentUser == null || _currentUser!.quizCompletedOn == null) return false;
    final now = DateTime.now();
    final lastCompleted = _currentUser!.quizCompletedOn!;
    return now.year == lastCompleted.year &&
           now.month == lastCompleted.month &&
           now.day == lastCompleted.day;
  }
}