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

![Home](screenshots/home.png)

### API Screen

![API Screen](screenshots/api_screen.png)

---

# Extension: Offline Support & State Management Upgrade

This extension builds on the CRUD API integration by adding **offline-first
data persistence**, a **repository pattern**, an upgraded **Provider** state
machine, and **optimistic UI updates** for a responsive, real-world feel.

## Branch Name

```
feature/offline-cache-and-state-manangement
```

## Tools & Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | State management (`ChangeNotifier`) — UI state only |
| `shared_preferences` | ^2.2.2 | Local persistence / offline cache of the course list |
| `http` | ^1.2.1 | REST calls to the JSONPlaceholder API |

> No extra packages were needed — `provider` and `shared_preferences` were
> already in the project, so the upgrade is dependency-light and easy to build.

## Architecture (Clean Separation of Concerns)

The app follows a strict layered flow. Each layer only talks to the layer
directly below it:

```
UI (Screens / Widgets)
        │   reads state, calls intents
        ▼
State Management  ──  CourseController  (ChangeNotifier / Provider)
        │   no networking, no persistence — UI state only
        ▼
Repository  ──  CourseRepository
        │   decides: network first, fall back to cache; keeps cache in sync
        ├────────────────────────────┐
        ▼                            ▼
API Service                   Local Database
CourseService                 CourseLocalStorage
(HTTP only)                   (SharedPreferences)
```

```
lib/
├── main.dart                         # Builds the dependency chain, injects repository
├── models/
│   └── course_model.dart             # CourseModel + CourseState enum (idle/loading/success/failure/empty)
├── services/
│   └── course_service.dart           # API LAYER — pure HTTP (GET/POST/PUT/DELETE), no Flutter
├── data/
│   └── course_local_storage.dart     # LOCAL DB — caches courses as JSON via SharedPreferences
├── repositories/
│   └── course_repository.dart        # REPOSITORY — chooses API vs cache, syncs both
├── controllers/
│   └── course_controller.dart        # STATE — Provider; loading/success/error/empty + offline flag
└── screens/
    └── courses_screen.dart           # UI — list, search, pull-to-refresh, empty & offline states
```

**Responsibilities**

- **`CourseService`** only builds requests and parses responses. It knows
  nothing about caching or UI.
- **`CourseLocalStorage`** only reads/writes the cached list and the
  last-sync timestamp. It knows nothing about HTTP.
- **`CourseRepository`** is the single source of truth. On read it tries the
  API, saves the result to the cache, and returns it; if the request fails it
  transparently returns the cached copy. On write it calls the API and mirrors
  the change into the cache.
- **`CourseController`** holds UI state only and exposes intents
  (`loadCourses`, `addCourse`, `updateCourse`, `deleteCourse`, `search`).

## Offline Approach

The app is **offline-first via a network-then-cache strategy**:

1. On every load, the repository requests fresh data from the API.
2. On success, the list is written to `SharedPreferences` (as JSON) along with
   a "last synced" timestamp, then returned to the UI.
3. If the request fails (no internet / server error) **and** a cache exists,
   the repository returns the cached list and flags the result as
   `DataSource.cache`. The UI then shows a **"Offline · showing data saved X
   ago"** banner.
4. If the request fails and there is **no** cache, the error bubbles up and the
   UI shows a retry screen.
5. Every create/update/delete also updates the cache, so the next offline
   launch reflects the user's latest changes (data stays synchronized).

This means a user who has opened the app at least once can keep browsing their
courses with no connection.

## State Management Approach

State is managed with **Provider** (`ChangeNotifier`), with business logic kept
out of the widgets entirely:

- `CourseState` models five explicit states: **loading, success, empty,
  failure**, plus an **`isOffline`** flag for cache-served data.
- Widgets are "dumb": they read `controller.courses` / `controller.state` and
  call intent methods. They never touch the service or storage.
- Search/filtering is computed in the controller (`search()` →
  `courses` getter filters by title/description), keeping the UI declarative.

## Optimistic UI Updates

Both **delete** and **update** apply changes to the in-memory list and call
`notifyListeners()` *before* the network request completes, so the UI feels
instant:

- **Delete** — the card is removed immediately; if the API call fails the
  previous list is restored (rollback) and an error snackbar is shown.
- **Update** — the edited course replaces the old one immediately; on failure
  the original value is restored.

## UX Improvements

- **Pull-to-refresh** on the course list (re-syncs with the API).
- **Search / filter** courses by title or description in real time.
- **Empty-state UI** when there are no courses, and a separate **no-results**
  state when a search matches nothing.
- **Offline banner** with a friendly "last synced" hint.
- Loading and retry indicators for each async state.

## How to Run

```bash
flutter pub get
flutter run
```

To test offline mode: run the app once with internet (so it caches), then
enable airplane mode / disable Wi-Fi and pull-to-refresh — the cached courses
load with the offline banner.

## Screenshots (Extension)

### Course list (online)

![Courses Online](screenshots/courses_online.png)

### Offline mode (cached data + banner)

![Offline](screenshots/offline_banner.png)

### Search / filter

![Search](screenshots/search.png)

### Empty state

![Empty](screenshots/empty_state.png)
