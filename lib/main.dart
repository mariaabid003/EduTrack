// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/auth_controller.dart';
import 'controllers/course_controller.dart';
import 'data/course_local_storage.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
import 'screens/splash_screen.dart';
import 'widgets/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise local storage once at startup so the repository can read the
  // on-device cache synchronously for offline-first behaviour.
  final prefs = await SharedPreferences.getInstance();
  final localStorage = CourseLocalStorage(prefs);

  // Assemble the dependency chain: API + LocalDB -> Repository.
  final courseRepository = CourseRepository(
    api: CourseService(),
    local: localStorage,
  );

  runApp(MyApp(courseRepository: courseRepository));
}

class MyApp extends StatelessWidget {
  final CourseRepository courseRepository;

  const MyApp({super.key, required this.courseRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        // Controller receives the repository (constructor injection) so UI
        // state stays fully decoupled from data sources.
        ChangeNotifierProvider(
          create: (_) => CourseController(courseRepository),
        ),
      ],
      child: MaterialApp(
        title: 'EduTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
