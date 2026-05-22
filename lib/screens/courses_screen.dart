// lib/screens/courses_screen.dart
//
// Main CRUD hub — lists courses from JSONPlaceholder with
// create, edit, and delete operations.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/course_controller.dart';
import '../models/course_model.dart';
import '../widgets/app_theme.dart';
import 'course_form_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch courses after first frame so the provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseController>().loadCourses();
    });
  }

  Future<void> _refresh() => context.read<CourseController>().loadCourses();

  Future<void> _openAddForm() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CourseFormScreen()),
    );
  }

  Future<void> _openEditForm(CourseModel course) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CourseFormScreen(course: course)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CourseModel course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Course',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
                color: AppTheme.textMedium, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Are you sure you want to delete\n'),
              TextSpan(
                text: '"${course.title}"',
                style: const TextStyle(
                    color: AppTheme.textDark, fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '?\n\nThis action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMedium)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 42),
              backgroundColor: AppTheme.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ctrl = context.read<CourseController>();
      final ok = await ctrl.deleteCourse(course.id);
      if (context.mounted) {
        _showSnackbar(
          context,
          ok ? 'Course deleted.' : ctrl.errorMessage ?? 'Delete failed.',
          ok ? AppTheme.success : AppTheme.error,
          ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
        );
      }
    }
  }

  void _showSnackbar(
      BuildContext ctx, String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'API Courses',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Powered by JSONPlaceholder REST API',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add button
                        GestureDetector(
                          onTap: _openAddForm,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: Consumer<CourseController>(
                builder: (context, controller, _) {
                  // ── Loading state ──
                  if (controller.state == CourseState.loading &&
                      controller.courses.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTheme.primary),
                          SizedBox(height: 16),
                          Text(
                            'Fetching courses from API...',
                            style: TextStyle(
                              color: AppTheme.textMedium,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // ── Error state ──
                  if (controller.state == CourseState.failure &&
                      controller.courses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.wifi_off_rounded,
                                color: AppTheme.error,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Could not load courses',
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.errorMessage ??
                                  'An error occurred.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.textMedium,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh_rounded,
                                  size: 18),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(160, 48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ── Success / List state ──
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppTheme.primary,
                    child: CustomScrollView(
                      slivers: [
                        // Stats bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                            child: Row(
                              children: [
                                _StatPill(
                                  label:
                                      '${controller.courses.length} courses',
                                  icon: Icons.library_books_rounded,
                                ),
                                const SizedBox(width: 10),
                                _StatPill(
                                  label: 'GET /posts',
                                  icon: Icons.cloud_done_rounded,
                                  color: AppTheme.success,
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: _openAddForm,
                                  icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 16),
                                  label: const Text('Add'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primary,
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Course list
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final course = controller.courses[index];
                              return TweenAnimationBuilder<double>(
                                duration: Duration(
                                    milliseconds: 300 + (index * 40).clamp(0, 600)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutCubic,
                                builder: (ctx, val, child) => Opacity(
                                  opacity: val,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - val)),
                                    child: child,
                                  ),
                                ),
                                child: _CourseCard(
                                  course: course,
                                  onEdit: () => _openEditForm(course),
                                  onDelete: () =>
                                      _confirmDelete(context, course),
                                ),
                              );
                            },
                            childCount: controller.courses.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB: add course
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Course',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 4,
      ),
    );
  }
}

// ── Course Card ──────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Pick a consistent accent colour per course based on id.
    final accentColors = [
      const Color(0xFF6C63FF),
      const Color(0xFF2EC4B6),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFB3C6),
      const Color(0xFFFFD166),
      const Color(0xFF06D6A0),
      AppTheme.primary,
    ];
    final color = accentColors[course.id % accentColors.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left colour bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${course.id}',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // userId badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.textLight.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'User ${course.userId}',
                          style: const TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Edit & Delete actions
                      _ActionIcon(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFF6C63FF),
                        tooltip: 'Edit course',
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 6),
                      _ActionIcon(
                        icon: Icons.delete_outline_rounded,
                        color: AppTheme.error,
                        tooltip: 'Delete course',
                        onTap: onDelete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    course.body,
                    style: const TextStyle(
                      color: AppTheme.textMedium,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Bottom divider + API method label
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppTheme.success.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'GET',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '/posts/${course.id}',
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatPill({
    required this.label,
    required this.icon,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
