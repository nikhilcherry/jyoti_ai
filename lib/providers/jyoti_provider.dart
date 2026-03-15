import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jyoti_ai/models/models.dart';
import 'package:jyoti_ai/services/jyoti_service.dart';

class JyotiProvider extends ChangeNotifier {
  JyotiProvider() {
    _initPrefs();
  }

  SharedPreferences? _prefs;
  static const String _chatHistoryKey = 'chat_history';

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final historyStr = _prefs?.getString(_chatHistoryKey);
    if (historyStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyStr);
        _messages.addAll(decoded.map((e) => ChatMessage.fromJson(e)).toList());
        notifyListeners();
      } catch (e) {
        // Handle corrupt data
      }
    }
  }

  Future<void> _saveChatHistory() async {
    if (_prefs == null) return;
    final encoded = jsonEncode(_messages.map((e) => e.toJson()).toList());
    await _prefs!.setString(_chatHistoryKey, encoded);
  }

  // ── User ──
  UserProfile _user = UserProfile(
    name: 'User',
    dateOfBirth: DateTime(1998, 5, 15),
    timeOfBirth: '06:30 AM',
    placeOfBirth: 'Delhi',
    rashi: Rashi.mesha,
    nakshatra: 'Ashwini',
    points: 250,
    lifetimePoints: 850,
    loginStreak: 3,
    language: 'Hindi',
  );

  // ── Chat ──
  final List<ChatMessage> _messages = [];
  bool _isChatLoading = false;

  // ── Daily Reading ──
  DailyReading? _dailyReading;
  PanchangData? _panchang;
  bool _isReadingLoading = false;

  // ── Onboarding ──
  bool _hasCompletedOnboarding = false;

  // ── Getters ──
  UserProfile get user => _user;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isChatLoading => _isChatLoading;
  DailyReading? get dailyReading => _dailyReading;
  PanchangData? get panchang => _panchang;
  bool get isReadingLoading => _isReadingLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // ── Onboarding ──
  void completeOnboarding({
    required String name,
    required DateTime dob,
    required String timeOfBirth,
    required String placeOfBirth,
    required Rashi rashi,
    required String language,
  }) {
    _user = _user.copyWith(
      name: name,
      dateOfBirth: dob,
      timeOfBirth: timeOfBirth,
      placeOfBirth: placeOfBirth,
      rashi: rashi,
      language: language,
    );
    _hasCompletedOnboarding = true;
    notifyListeners();
    loadDailyData();
  }

  void skipOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
    loadDailyData();
  }

  // ── Daily Data ──
  Future<void> loadDailyData() async {
    _isReadingLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        JyotiService.getDailyReading(_user.rashi),
        JyotiService.getPanchang(),
      ]);
      _dailyReading = results[0] as DailyReading;
      _panchang = results[1] as PanchangData;
    } catch (e) {
      // Silently handle — UI shows fallback
    } finally {
      _isReadingLoading = false;
      notifyListeners();
    }
  }

  // ── Chat ──
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (_user.points <= 0) {
      _messages.add(
        ChatMessage(
          text: 'Aapke paas paryapt points nahi hain. Kripya aur prashn poochne ke liye points recharge karein. 💎',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
      return;
    }

    // Add user message
    _messages.add(
      ChatMessage(text: text.trim(), isUser: true, timestamp: DateTime.now()),
    );
    _isChatLoading = true;
    notifyListeners();

    try {
      // Pass the chat history to give the AI memory
      final response = await JyotiService.getAIResponse(text, _user, _messages);
      _messages.add(response);

      // Deduct points dynamically based on AI context usage (tokens)
      int pointsToDeduct = 15; // Default fallback
      if (response.totalTokens != null && response.totalTokens! > 0) {
        // e.g., 1 point per 15 tokens, min 10, max 100
        pointsToDeduct = (response.totalTokens! / 15).ceil().clamp(10, 100);
      }

      if (_user.points >= pointsToDeduct) {
        _user = _user.copyWith(points: _user.points - pointsToDeduct);
      } else {
        _user = _user.copyWith(points: 0);
      }

    } catch (e) {
      _messages.add(
        ChatMessage(
          text:
              'Maaf kijiye, abhi thoda issue aa raha hai. Kripya thodi der baad try karein. 🙏',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isChatLoading = false;
      _saveChatHistory(); // Save locally
      notifyListeners();
    }
  }

  // ── Points ──
  void addPoints(int amount) {
    _user = _user.copyWith(
      points: _user.points + amount,
      lifetimePoints: _user.lifetimePoints + amount,
    );
    notifyListeners();
  }

  void claimDailyLogin() {
    addPoints(10);
    _user = _user.copyWith(loginStreak: _user.loginStreak + 1);
    notifyListeners();
  }

  // ── Language ──
  void setLanguage(String lang) {
    _user = _user.copyWith(language: lang);
    notifyListeners();
  }

  // ── Rashi ──
  void setRashi(Rashi rashi) {
    _user = _user.copyWith(rashi: rashi);
    notifyListeners();
    loadDailyData();
  }
}
