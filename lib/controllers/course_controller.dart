// lib/controllers/course_controller.dart
//
// STATE MANAGEMENT (Provider / ChangeNotifier).
//
// Holds ONLY UI state and orchestrates calls to the repository. It contains
// no networking and no persistence logic -- that lives in the service and
// local-storage layers behind the repository. This keeps UI logic cleanly
// separated from business logic.
//
//   UI  ->  CourseController (this)  ->  CourseRepository  ->  API / LocalDB
//
// Manages five UI states: loading, success, empty, failure, plus an
// `isOffline` flag for when data is served from the on-device cache.

import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';
import '../services/course_service.dart' show CourseServiceException;

class CourseController extends ChangeNotifier {
  final CourseRepository _repository;

  CourseController(this._repository);

  // State
  List<CourseModel> _courses = [];
  CourseState _state = CourseState.idle;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isOffline = false;
  DateTime? _lastSyncedAt;

  // Getters
  /// Full list (unfiltered). UI normally reads [courses] (filtered).
  List<CourseModel> get allCourses => List.unmodifiable(_courses);

  /// The list the UI renders -- respects the active search query.
  List<CourseModel> get courses {
    if (_searchQuery.isEmpty) return List.unmodifiable(_courses);
    final q = _searchQuery.toLowerCase();
    return List.unmodifiable(
      _courses.where(
        (c) =>
            c.title.toLowerCase().contains(q) ||
            c.body.toLowerCase().contains(q),
      ),
    );
  }

  CourseState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CourseState.loading;
  String get searchQuery => _searchQuery;

  /// True when the currently-shown data came from the local cache.
  bool get isOffline => _isOffline;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// True when a search yields no matches even though courses exist.
  bool get isSearchEmpty =>
      _searchQuery.isNotEmpty && courses.isEmpty && _courses.isNotEmpty;

  // SEARCH / FILTER

  void search(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  // READ (offline-first)

  /// Loads courses via the repository. Network is preferred; on failure the
  /// repository falls back to cached data and we flag the session offline.
  Future<void> loadCourses() async {
    _setState(CourseState.loading);
    _errorMessage = null;

    try {
      final result = await _repository.getCourses();
      _courses = result.courses;
      _isOffline = result.isFromCache;
      _lastSyncedAt = result.lastSyncedAt;
      _setState(_courses.isEmpty ? CourseState.empty : CourseState.success);
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _isOffline = true;
      _setState(CourseState.failure);
    }
  }

  // CREATE

  Future<bool> addCourse({
    required String title,
    required String body,
  }) async {
    _errorMessage = null;
    try {
      final created = await _repository.addCourse(title: title, body: body);
      _courses.insert(0, created);
      _isOffline = false;
      _setState(CourseState.success);
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _setState(CourseState.failure);
      return false;
    }
  }

  // UPDATE (optimistic)

  /// Optimistically replaces the item in the list, then calls the API.
  /// Rolls back to the previous value if the request fails.
  Future<bool> updateCourse(CourseModel course) async {
    final idx = _courses.indexWhere((c) => c.id == course.id);
    if (idx == -1) return false;

    final previous = _courses[idx];
    // Optimistic update -- UI reflects the change immediately.
    _courses[idx] = course;
    notifyListeners();

    try {
      final saved = await _repository.updateCourse(course);
      _courses[idx] = saved;
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback.
      _courses[idx] = previous;
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  // DELETE (optimistic)

  /// Optimistically removes the item then calls the API. Rolls back on error.
  Future<bool> deleteCourse(int id) async {
    final backup = List<CourseModel>.from(_courses);
    final idx = _courses.indexWhere((c) => c.id == id);
    if (idx != -1) _courses.removeAt(idx);
    // Re-evaluate empty state after an optimistic removal.
    _state = _courses.isEmpty ? CourseState.empty : CourseState.success;
    notifyListeners();

    try {
      await _repository.deleteCourse(id);
      return true;
    } catch (e) {
      // Rollback.
      _courses = backup;
      _errorMessage = _friendlyError(e);
      _setState(CourseState.success);
      return false;
    }
  }

  // HELPERS

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
