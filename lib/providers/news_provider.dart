import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsProvider extends ChangeNotifier {
  // Simple list of news
  List<Map<String, String>> _news = [];
  bool _hasUnreadNews = false;
  DateTime? _lastReadDate;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, String>> get news => _news;
  bool get hasUnreadNews => _hasUnreadNews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load news (hardcoded for hackathon)
  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _news = [
        {
          'id': '1',
          'title': ' مبادرة تشجير الأحياء السكنية',
          'content': 'بلدية حائل تطلق مبادرة لتشجير 100 شارع في مختلف الأحياء. شارك بزراعة الأشجار في منطقتك وساهم في تحسين البيئة المحلية.',
          'date': DateTime.now().toIso8601String(),
          'category': 'مبادرات',
        },
        {
          'id': '2',
          'title': ' ازرع شجرة ',
          'content': 'فرصة تطوعية لزراعة الأشجار في الشوارع الرئيسية التي تهدف لزراعة 5000 شجرة.',
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'category': 'تطوع',
        },
        {
          'id': '3',
          'title': ' مسابقة أجمل حي مزروع',
          'content': 'انضموا لمسابقة أجمل حي مزروع! الفائزون سيحصلون على جوائز قيمة. التقييم بناءً على عدد الأشجار وجودة الزراعة.',
          'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'category': 'مسابقات',
        },
        {
          'id': '4',
          'title': ' إنجازات المجتمع: 50 شجرة جديدة',
          'content': 'بفضل متطوعينا، تم زراعة 50 شجرة جديدة في الشوارع والأماكن العامة خلال الشهر الماضي. استمر في المشاركة!',
          'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'category': 'إنجازات',
        },
        {
          'id': '5',
          'title': '🌿 أنواع الأشجار المناسبة للشوارع',
          'content': 'تعرف على أفضل أنواع الأشجار للزراعة في الأماكن العامة: النخيل، الجوري، الياسمين.',
          'date': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          'category': 'تعليم',
        },
      ];

      _checkUnreadNews();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _checkUnreadNews() {
    if (_lastReadDate == null) {
      _hasUnreadNews = _news.isNotEmpty;
    } else {
      _hasUnreadNews = _news.any((news) =>
          DateTime.parse(news['date']!).isAfter(_lastReadDate!));
    }
  }

  // 👇 NEW: Check if popup should show today
  Future<bool> shouldShowPopup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPopupDate = prefs.getString('last_popup_date');
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    if (lastPopupDate == null) {
      return true; // Never shown before
    }

    return lastPopupDate != today; // Show if not shown today
  }

  Future<void> markPopupShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_popup_date', today);
  }

  void markAsRead() {
    _lastReadDate = DateTime.now();
    _hasUnreadNews = false;
    notifyListeners();
  }

  Map<String, String>? getLatestNews() {
    return _news.isNotEmpty ? _news.first : null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}