// lib/services/course_service.dart
//
// Pure service layer – NO Flutter / ChangeNotifier dependencies.
// All network logic lives here; controllers call these methods.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

/// Custom exception for HTTP errors from JSONPlaceholder.
class CourseServiceException implements Exception {
  final String message;
  const CourseServiceException(this.message);

  @override
  String toString() => 'CourseServiceException: $message';
}

class CourseService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // ─────────────────── READ ───────────────────

  /// Fetches the first 20 posts as courses (GET /posts?_limit=20).
  Future<List<CourseModel>> fetchCourses({int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl/posts?_limit=$limit');
    final response = await http.get(uri);

    _assertSuccess(response, 'Failed to fetch courses');

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single course by ID (GET /posts/{id}).
  Future<CourseModel> fetchCourse(int id) async {
    final uri = Uri.parse('$_baseUrl/posts/$id');
    final response = await http.get(uri);

    _assertSuccess(response, 'Failed to fetch course #$id');

    return CourseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ─────────────────── CREATE ───────────────────

  /// Creates a new course (POST /posts).
  /// JSONPlaceholder always returns id=101 for new posts.
  Future<CourseModel> addCourse({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/posts');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'title': title, 'body': body, 'userId': userId}),
    );

    _assertSuccess(response, 'Failed to create course');

    return CourseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ─────────────────── UPDATE ───────────────────

  /// Updates an existing course (PUT /posts/{id}).
  Future<CourseModel> updateCourse(CourseModel course) async {
    final uri = Uri.parse('$_baseUrl/posts/${course.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    _assertSuccess(response, 'Failed to update course #${course.id}');

    return CourseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ─────────────────── DELETE ───────────────────

  /// Deletes a course (DELETE /posts/{id}).
  Future<void> deleteCourse(int id) async {
    final uri = Uri.parse('$_baseUrl/posts/$id');
    final response = await http.delete(uri);

    _assertSuccess(response, 'Failed to delete course #$id');
  }

  // ─────────────────── HELPERS ───────────────────

  void _assertSuccess(http.Response response, String message) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CourseServiceException('$message (status ${response.statusCode})');
    }
  }
}
