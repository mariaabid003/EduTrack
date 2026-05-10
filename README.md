# EduTrack — Flutter Multi-Screen App

A complete Flutter multi-screen application featuring user authentication, form validation, and navigation.

## Features

- **Splash Screen** — Auto-login check with animation
- **Registration Screen** — Full form with validation
- **Login Screen** — Email/password with remember me
- **Dashboard Screen** — User profile + subject list
- **Detail Screen** — Subject info, schedule, description

## Frontend

<img width="302" height="661" alt="image" src="https://github.com/user-attachments/assets/1b9070db-a5cf-48a0-88e0-ac94d4bd88cd" />
<img width="347" height="742" alt="image" src="https://github.com/user-attachments/assets/28c799a1-80c2-476e-b9c1-c3c693bd9612" />
<img width="312" height="727" alt="image" src="https://github.com/user-attachments/assets/3984a69d-0e7b-4985-9891-e1990458b3ef" />
<img width="347" height="736" alt="image" src="https://github.com/user-attachments/assets/df26388c-cf0c-4c60-bb51-77c15c236515" />







## Architecture

```
lib/
├── main.dart                        # App entry point
├── enums/
│   └── app_enums.dart               # Gender, AuthState, Subject, PasswordVisibility
├── models/
│   └── user_model.dart              # UserModel with toMap/fromMap
├── validators/
│   └── app_validators.dart          # Reusable validator class (static methods)
├── controllers/
│   └── auth_controller.dart         # Business logic, SharedPreferences, state mgmt
├── widgets/
│   ├── app_theme.dart               # Centralized theme & colors
│   └── common_widgets.dart          # Reusable UI components
└── screens/
    ├── splash_screen.dart           # Animated splash + auto-login
    ├── registration_screen.dart     # Register form
    ├── login_screen.dart            # Login form
    ├── dashboard_screen.dart        # Subject list dashboard
    └── detail_screen.dart           # Subject detail view
```

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Android Studio / VS Code with Flutter plugin
- Android emulator or physical device

### Installation

1. Open Android Studio → **Open an existing project**
2. Navigate to and select this `flutter_multi_screen_app` folder
3. Wait for Gradle sync to complete
4. Run `flutter pub get` in the terminal (or Android Studio will do it automatically)
5. Run the app with `flutter run`

### Dependencies
- `provider: ^6.1.1` — State management
- `shared_preferences: ^2.2.2` — Persistent storage for Remember Me

## Validation Rules

| Field          | Rules |
|----------------|-------|
| Full Name      | Required, min 2 chars, letters/spaces only |
| Email          | Required, valid email format |
| Gender         | Required selection |
| Password       | Required, min 6 chars, 1 uppercase, 1 special char |
| Confirm Password | Required, must match password |
| Login Email    | Required, valid email format |
| Login Password | Required |

## Key Design Decisions

- **`AppValidators`** is a utility class with only static methods — validation logic is fully separated from UI
- **`AuthController`** extends `ChangeNotifier` (Provider) — all business logic and state in one place
- **Enums** used for `Gender`, `AuthState`, `Subject` — type-safe categorical data
- **`SharedPreferences`** stores registered users and remember-me session
- All widgets use named constructors and `const` where possible for performance
