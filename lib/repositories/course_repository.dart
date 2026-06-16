// lib/repositories/course_repository.dart
//
// REPOSITORY LAYER -- the single source of truth for course data.
//
// Architecture:  UI -> Controller (state) -> Repository -> ApiService / LocalDB
//
// The repository is the only layer that decides WHERE data comes from:
//   - On read, it tries the network first. On success it refreshes the
//     local cache and returns fresh data. On failure (offline / server
//     error) it transparently falls back to the cached copy.
//   - On write (create / update / delete) it calls the API and then keeps
//     the local cache in sync so the next offline launch is up to date.
//
// Neither the API service nor the local storage know about each other --
// only the repository coordinates them.

import '../models/course_model.dart';
import '../services/course_service.dart';
import '../data/course_local_storage.dart';

/// Where a returned course list actually came from.
enum DataSource { remote, cache }

/// Wraps a course list with metadata about its origin so the UI can show
/// an "offline / showing cached data" hint.
class CourseFetchResult {
  final List<CourseModel> courses;
  final DataSource source;
  final DateTime? lastSyncedAt;

  const CourseFetchResult({
    required this.courses,
    required this.source,
    this.lastSyncedAt,
  });

  bool get isFromCache => source == DataSource.cache;
}

class CourseRepository {
  static const int _jsonPlaceholderMaxPostId = 100;

  final CourseService _api;
  final CourseLocalStorage _local;

  CourseRepository({
    required CourseService api,
    required CourseLocalStorage local,
  })  : _api = api,
        _local = local;

  /// Whether any data has ever been cached locally.
  bool get hasCache => _local.hasCache;

  /// When the cache was last refreshed from the API.
  DateTime? get lastSyncedAt => _local.lastSyncedAt;

  /// Reads the cached courses without touching the network.
  List<CourseModel> get cachedCourses => _local.loadCourses();

  // READ (offline-first)

  /// Fetches courses, preferring the network and falling back to the
  /// local cache when the device is offline or the request fails.
  Future<CourseFetchResult> getCourses() async {
    try {
      final remote = await _api.fetchCourses();
      final merged = _mergeRemoteWithLocalChanges(remote);
      // Keep the on-device copy in sync for the next offline session. The
      // merged list preserves accepted local mutations because JSONPlaceholder
      // does not persist POST/PUT/DELETE changes between requests.
      await _local.saveCourses(merged);
      return CourseFetchResult(
        courses: merged,
        source: DataSource.remote,
        lastSyncedAt: _local.lastSyncedAt,
      );
    } catch (e) {
      // Network failed -- serve whatever we cached previously.
      final cached = _local.loadCourses();
      if (cached.isNotEmpty) {
        return CourseFetchResult(
          courses: cached,
          source: DataSource.cache,
          lastSyncedAt: _local.lastSyncedAt,
        );
      }
      // No cache to fall back on -> bubble the error up to the controller.
      rethrow;
    }
  }

  // CREATE

  /// Creates a course via the API and appends it to the local cache.
  Future<CourseModel> addCourse({
    required String title,
    required String body,
  }) async {
    final created = await _api.addCourse(title: title, body: body);
    // JSONPlaceholder always returns id=101 and does not persist the record,
    // so give accepted local records stable IDs above the sample API range.
    final localId = _nextLocalId();
    final stored = created.copyWith(id: localId);

    final cache = _local.loadCourses()..insert(0, stored);
    await _local.saveCourses(cache);
    await _local.markChanged(stored.id);
    return stored;
  }

  // UPDATE

  /// Updates a course via the API and mirrors the change in the cache.
  Future<CourseModel> updateCourse(CourseModel course) async {
    final CourseModel result;
    if (_isLocalOnly(course.id)) {
      result = course;
    } else {
      final updated = await _api.updateCourse(course);
      result = updated.copyWith(id: course.id);
    }

    final cache = _local.loadCourses();
    final idx = cache.indexWhere((c) => c.id == course.id);
    if (idx != -1) {
      cache[idx] = result;
      await _local.saveCourses(cache);
    }
    await _local.markChanged(course.id);
    return result;
  }

  // DELETE

  /// Deletes a course via the API and removes it from the cache.
  Future<void> deleteCourse(int id) async {
    if (!_isLocalOnly(id)) {
      await _api.deleteCourse(id);
    }
    final cache = _local.loadCourses()..removeWhere((c) => c.id == id);
    await _local.saveCourses(cache);
    if (_isLocalOnly(id)) {
      await _local.clearChanged(id);
    } else {
      await _local.markDeleted(id);
    }
  }

  List<CourseModel> _mergeRemoteWithLocalChanges(List<CourseModel> remote) {
    final deletedIds = _local.loadDeletedIds();
    final changedIds = _local.loadChangedIds();
    final cachedById = {
      for (final course in _local.loadCourses()) course.id: course,
    };

    final merged = <CourseModel>[
      for (final course in remote)
        if (!deletedIds.contains(course.id)) course,
    ];

    for (final id in changedIds) {
      final changedCourse = cachedById[id];
      if (changedCourse == null || deletedIds.contains(id)) continue;

      final index = merged.indexWhere((course) => course.id == id);
      if (index == -1) {
        merged.insert(0, changedCourse);
      } else {
        merged[index] = changedCourse;
      }
    }

    return merged;
  }

  int _nextLocalId() {
    final ids = _local.cachedIds();
    var nextId = _jsonPlaceholderMaxPostId + 1;
    if (ids.isNotEmpty) {
      final maxCachedId = ids.reduce((a, b) => a > b ? a : b);
      if (maxCachedId >= nextId) nextId = maxCachedId + 1;
    }
    return nextId;
  }

  bool _isLocalOnly(int id) => id > _jsonPlaceholderMaxPostId;
}

extension on CourseLocalStorage {
  Set<int> cachedIds() {
    return loadCourses().map((course) => course.id).toSet();
  }
}
