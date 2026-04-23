// lib/enums/app_enums.dart

enum Gender {
  male,
  female,
  preferNotToSay;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

enum AuthState {
  idle,
  loading,
  success,
  failure,
}

enum PasswordVisibility {
  visible,
  hidden,
}

enum Subject {
  mobileAppDevelopment,
  softwareReengineering,
  mis,
  uiUxDevelopment,
  fypPartII;

  String get displayName {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Mobile App Development';
      case Subject.softwareReengineering:
        return 'Software Re-engineering';
      case Subject.mis:
        return 'MIS';
      case Subject.uiUxDevelopment:
        return 'UI/UX Development';
      case Subject.fypPartII:
        return 'FYP Part II';
    }
  }

  String get description {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'This course covers the fundamentals and advanced concepts of mobile application development. '
            'Students will learn to build cross-platform apps using Flutter & Dart, '
            'focusing on UI/UX design, state management, API integration, and deployment.';
      case Subject.softwareReengineering:
        return 'Software Re-engineering focuses on analyzing, restructuring, and modernizing legacy systems. '
            'Topics include reverse engineering, code refactoring, migration strategies, '
            'and applying modern design patterns to existing codebases.';
      case Subject.mis:
        return 'Management Information Systems (MIS) explores the strategic use of information technology '
            'in organizations. Topics cover database management, decision support systems, '
            'ERP solutions, and business intelligence tools.';
      case Subject.uiUxDevelopment:
        return 'UI/UX Development blends design aesthetics with functional coding. '
            'Students will learn user research, wireframing, prototyping in Figma, and '
            'implementing responsive, accessible, and beautiful interfaces in code.';
      case Subject.fypPartII:
        return 'Final Year Project (Part II) is the culmination of your degree. '
            'It focuses on the implementation, testing, and deployment phases of your '
            'proposed solution, concluding with a comprehensive documentation and defense.';
    }
  }

  String get schedule {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Monday & Wednesday — 10:00 AM to 11:30 AM\nLab: Friday — 2:00 PM to 4:00 PM';
      case Subject.softwareReengineering:
        return 'Tuesday & Thursday — 9:00 AM to 10:30 AM\nLab: Wednesday — 1:00 PM to 3:00 PM';
      case Subject.mis:
        return 'Monday, Wednesday & Friday — 12:00 PM to 1:00 PM\nNo Lab Session';
      case Subject.uiUxDevelopment:
        return 'Tuesday & Thursday — 11:00 AM to 12:30 PM\nLab: Monday — 2:00 PM to 4:00 PM';
      case Subject.fypPartII:
        return 'Friday — 9:00 AM to 12:00 PM\nAdvisor Meeting: By Appointment';
    }
  }

  String get bannerEmoji {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return '📱';
      case Subject.softwareReengineering:
        return '🔧';
      case Subject.mis:
        return '📊';
      case Subject.uiUxDevelopment:
        return '✨';
      case Subject.fypPartII:
        return '🎓';
    }
  }

  int get colorValue {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 0xFF6C63FF;
      case Subject.softwareReengineering:
        return 0xFF2EC4B6;
      case Subject.mis:
        return 0xFFFF6B6B;
      case Subject.uiUxDevelopment:
        return 0xFFFFB3C6; // Soft pastel pink
      case Subject.fypPartII:
        return 0xFFFFD166; // Golden yellow
    }
  }
}
