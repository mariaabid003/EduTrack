// lib/controllers/course_controller.dart
//
// State management for all CRUD operations on courses.
// Delegates every network call to CourseService (clean architecture).

import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';

class CourseController extends ChangeNotifier {
  final CourseService _service = CourseService();

  // ─── State ───
  List<CourseModel> _courses = [];
  CourseState _state = CourseState.idle;
  String? _errorMessage;

  // ─── Getters ───
  List<CourseModel> get courses => List.unmodifiable(_courses);
  CourseState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CourseState.loading;

  // ─────────────────── READ ───────────────────

  /// Loads all courses from JSONPlaceholder. Safe to call on refresh.
  Future<void> loadCourses() async {
    _setState(CourseState.loading);
    _errorMessage = null;

    try {
      _courses = await _service.fetchCourses();
      _setState(CourseState.success);
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _setState(CourseState.failure);
    }
  }

  // ─────────────────── CREATE ───────────────────

  /// Adds a new course via POST and inserts it at the top of the list.
  Future<bool> addCourse({
    required String title,
    required String body,
  }) async {
    _setState(CourseState.loading);
    _errorMessage = null;

    try {
      final created = await _service.addCourse(title: title, body: body);
      // JSONPlaceholder always returns id=101; prepend with a unique
      // timestamp-derived id so it renders distinctly in the list.
      final localId = DateTime.now().millisecondsSinceEpoch % 100000;
      _courses.insert(0, created.copyWith(id: localId));
      _setState(CourseState.success);
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _setState(CourseState.failure);
      return false;
    }
  }

  // ─────────────────── UPDATE ───────────────────

  /// Sends a PUT request and replaces the matching item in the local list.
  Future<bool> updateCourse(CourseModel course) async {
    _setState(CourseState.loading);
    _errorMessage = null;

    try {
      final updated = await _service.updateCourse(course);
      final idx = _courses.indexWhere((c) => c.id == course.id);
      if (idx != -1) {
        _courses[idx] = updated.copyWith(id: course.id);
      }
      _setState(CourseState.success);
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _setState(CourseState.failure);
      return false;
    }
  }

  // ─────────────────── DELETE ───────────────────

  /// Optimistically removes the item then sends DELETE. Rolls back on error.
  Future<bool> deleteCourse(int id) async {
    final backup = List<CourseModel>.from(_courses);
    final idx = _courses.indexWhere((c) => c.id == id);
    if (idx != -1) _courses.removeAt(idx);
    notifyListeners();

    try {
      await _service.deleteCourse(id);
      _setState(CourseState.success);
      return true;
    } catch (e) {
      // Rollback
      _courses = backup;
      _errorMessage = _friendlyError(e);
      _setState(CourseState.failure);
      return false;
    }
  }

  // ─────────────────── HELPERS ───────────────────

  void clearError() {
    _errorMessage = null;
    if (_state == CourseState.failure) _setState(CourseState.idle);
  }

  void _setState(CourseState newState) {
    _state = newState;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    if (e is CourseServiceException) return e.message;
    return 'Something went wrong. Please check your connection.';
  }
}
