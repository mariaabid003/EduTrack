# EduTrack

A complete Flutter multi-screen application featuring user authentication, form validation, and navigation.

## Features

- **Splash Screen** — Auto-login check with animation
- **Registration Screen** — Full form with validation
- **Login Screen** — Email/password with remember me
- **Dashboard Screen** — User profile + subject list
- **Detail Screen** — Subject info, schedule, description

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

---

## API Used

**JSONPlaceholder API**

> <https://jsonplaceholder.typicode.com/>

Used for simulating RESTful course data (fetch, create, update, delete) without a real backend.

## Documentation Followed

> <https://jsonplaceholder.typicode.com/guide/>

## Branch Name

```
feature/course-api-integration
```

## Screenshots

### Home

<img width="323" height="735" alt="1" src="https://github.com/user-attachments/assets/4bc8cb7d-02c8-49ea-8ceb-3ba9381c3032" />


### API Screen

<img width="347" height="746" alt="2" src="https://github.com/user-attachments/assets/6cd282ed-87e3-4c4d-b79b-e1285e81e4e4" />
<img width="335" height="730" alt="3" src="https://github.com/user-attachments/assets/6bb10afe-53e2-4a20-bfa9-86a36c8d0d2b" />
<img width="327" height="746" alt="5" src="https://github.com/user-attachments/assets/6d7e2b28-f539-4ee2-b44e-1c0e3595bf2a" />
<img width="336" height="733" alt="6" src="https://github.com/user-attachments/assets/1badbdde-1dbc-49d9-ad70-6b101f9ecb3b" />



