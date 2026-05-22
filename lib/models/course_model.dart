// lib/models/course_model.dart

/// Represents a course fetched from JSONPlaceholder's /posts endpoint.
/// JSONPlaceholder fields:
///   id     → course ID
///   userId → instructor/user ID
///   title  → course title
///   body   → course description
class CourseModel {
  final int id;
  final int userId;
  final String title;
  final String body;

  const CourseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// Deserialise from a JSONPlaceholder JSON map.
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  /// Serialise to a JSON map for POST / PUT requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  /// Returns a new instance with the given fields overridden.
  CourseModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
  }) {
    return CourseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  String toString() =>
      'CourseModel(id: $id, userId: $userId, title: $title)';
}

/// Possible states for any course-related async operation.
enum CourseState { idle, loading, success, failure }
