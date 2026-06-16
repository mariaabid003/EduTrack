import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_multi_screen_app/data/course_local_storage.dart';
import 'package:flutter_multi_screen_app/main.dart';
import 'package:flutter_multi_screen_app/repositories/course_repository.dart';
import 'package:flutter_multi_screen_app/services/course_service.dart';

void main() {
  testWidgets('app boots to the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = CourseRepository(
      api: CourseService(),
      local: CourseLocalStorage(prefs),
    );

    await tester.pumpWidget(MyApp(courseRepository: repository));

    expect(find.text('EduTrack'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
