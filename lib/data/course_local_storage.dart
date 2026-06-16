// lib/data/course_local_storage.dart
//
// LOCAL DATA SOURCE — pure persistence, no networking, no Flutter UI.
// Caches the course list on-device using SharedPreferences so the app
// can render content while offline. Also records when the cache was last
// synced with the API so the UI can show a "last updated" hint.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';

class CourseLocalStorage {
  static const String _coursesKey = 'cached_courses_v1';
  static const String _syncedAtKey = 'cached_courses_synced_at_v1';

  final SharedPreferences _prefs;

  CourseLocalStorage(this._prefs);

  /// Convenience factory so callers don't need to import SharedPreferences.
  static Future<CourseLocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CourseLocalStorage(prefs);
  }

  // ─────────────────── WRITE ───────────────────

  /// Persists the full course list as a JSON string and stamps the sync time.
  Future<void> saveCourses(List<CourseModel> courses) async {
    final jsonList = courses.map((c) => c.toJson()).toList();
    await _prefs.setString(_coursesKey, jsonEncode(jsonList));
    await _prefs.setString(
      _syncedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  // ─────────────────── READ ───────────────────

  /// Returns the cached courses, or an empty list if nothing is stored yet.
  List<CourseModel> loadCourses() {
    final raw = _prefs.getString(_coursesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted cache — treat as empty rather than crashing.
      return [];
    }
  }

  /// True when there is at least one course in the cache.
  bool get hasCache {
    final raw = _prefs.getString(_coursesKey);
    return raw != null && raw.isNotEmpty && raw != '[]';
  }

  /// When the cache was last refreshed from the API (null if never).
  DateTime? get lastSyncedAt {
    final raw = _prefs.getString(_syncedAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ─────────────────── CLEAR ───────────────────

  Future<void> clear() async {
    await _prefs.remove(_coursesKey);
    await _prefs.remove(_syncedAtKey);
  }
}
