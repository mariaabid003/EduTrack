# EduTrack

EduTrack is a Flutter multi-screen course app with authentication, CRUD API integration, offline course caching, Provider state management, and a repository-based architecture.

## Branch Name

```text
feature/offline-cache-and-state-manangement
```

## Tools And Packages Used

| Package | Purpose |
| --- | --- |
| `provider` | App state management using `ChangeNotifier` controllers |
| `shared_preferences` | Persistent local cache for auth data and offline course data |
| `http` | REST API calls to JSONPlaceholder |
| `flutter_lints` | Static analysis and lint checks |

## Features

- Splash screen with remember-me auto login
- Registration and login with validation
- Dashboard with subject cards and course navigation
- Course CRUD using JSONPlaceholder `/posts`
- Offline course persistence with local cache fallback
- Pull-to-refresh for API re-sync
- Search/filter by course title or description
- Loading, success, empty, error, and offline states
- Optimistic update/delete with rollback on API failure

## Frontend

<img width="302" height="661" alt="image" src="https://github.com/user-attachments/assets/1b9070db-a5cf-48a0-88e0-ac94d4bd88cd" />
<img width="347" height="742" alt="image" src="https://github.com/user-attachments/assets/28c799a1-80c2-476e-b9c1-c3c693bd9612" />
<img width="312" height="727" alt="image" src="https://github.com/user-attachments/assets/3984a69d-0e7b-4985-9891-e1990458b3ef" />
<img width="347" height="736" alt="image" src="https://github.com/user-attachments/assets/df26388c-cf0c-4c60-bb51-77c15c236515" />







## Architecture

The course feature follows the required layered structure:

```text
UI -> State Management -> Repository -> API Service -> Local Database
```

Project structure:

```text
lib/
  main.dart                         # App startup and dependency injection
  models/
    course_model.dart               # CourseModel and CourseState enum
  services/
    course_service.dart             # HTTP-only API layer
  data/
    course_local_storage.dart       # SharedPreferences local cache
  repositories/
    course_repository.dart          # API/cache decision and sync logic
  controllers/
    course_controller.dart          # Provider state and UI intents
  screens/
    courses_screen.dart             # Course list, search, refresh, offline UI
    course_form_screen.dart         # Add/edit course form
```

## Offline And State Management Approach

`CourseService` only performs HTTP requests. `CourseLocalStorage` only reads and writes local data. `CourseRepository` is the single source of truth: it fetches from the API when possible, saves successful API results locally, and falls back to cached data when the API is unavailable.

Because JSONPlaceholder accepts create/update/delete requests but does not persist them on the server, the repository also stores locally changed and deleted course IDs. On the next refresh, fresh API data is merged with accepted local changes so added, edited, and deleted courses do not disappear.

`CourseController` uses Provider/`ChangeNotifier` to expose loading, success, empty, failure, search, and offline state to the UI. Course screens call controller methods instead of calling the API or local storage directly.

## Optimistic UI Updates

- Update: the edited course is shown immediately. If the API request fails, the controller restores the previous course.
- Delete: the course card is removed immediately. If the API request fails, the controller restores the previous list.

## Screenshots

Add final submission screenshots in a `screenshots/` folder using these names:

| Screen | File |
| --- | --- |
| Course list online | `screenshots/courses_online.png` |
| Offline cached data banner | `screenshots/offline_banner.png` |
| Search/filter | `screenshots/search.png` |
| Empty state | `screenshots/empty_state.png` |

## How To Run

```bash
flutter pub get
flutter run
```

To test offline mode, open the course screen once with internet access so data is cached. Then disable the internet connection and pull to refresh. The app will show cached courses with the offline banner.

## Verification

```bash
flutter analyze
flutter test
flutter build apk --debug
```
