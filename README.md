# CampusRide — Student Car Ride Sharing App

A Flutter + Firebase mobile app that lets verified students post and join
car rides with classmates heading the same direction — built from the
project spec in `Student_Car_Ride_Sharing_App.md`.

## Feature coverage

| Spec section        | Implemented as |
|---|---|
| Student verification / profiles | `AuthService`, `UserModel`, `RegisterScreen`, verified badge on `UserAvatar` |
| Ride posting (start, destination, time, seats, cost) | `CreateRideScreen`, `RideModel`, `FirestoreService.createRide` |
| Ride search & filters | `SearchRideScreen`, `RideProvider`, `FirestoreService.searchRides` |
| GPS matching / radius search | `LocationService` (geocoding + `Geolocator.distanceBetween`) |
| In-app chat | `ChatService`, `ChatScreen` (Firestore `chats/{id}/messages`) |
| Ratings & reviews | `RatingModel`, `FirestoreService.submitRating` (rolling average) |
| Safety (report/block/verified badge) | `UserModel.isVerified`, verified badge widget; report/block hooks are stubbed for a future iteration (see below) |
| MVP scope | Registration/Login, Profile, Create Ride, Search Ride, Join Ride, location filtering — all present |

## Project structure

```
lib/
├── main.dart                  # App entry point, Firebase init, providers, theme
├── firebase_options.dart      # Placeholder — regenerate with `flutterfire configure`
├── core/
│   ├── constants/              # Colors, text styles, user-facing strings
│   ├── theme/                  # Central Material ThemeData
│   ├── utils/                  # Responsive helpers, form validators
│   └── routes/                 # Named route table
├── models/                     # UserModel, RideModel, RatingModel (Firestore <-> Dart)
├── services/                   # AuthService, FirestoreService, LocationService, ChatService
├── providers/                  # AppAuthProvider, RideProvider (ChangeNotifier / Provider)
├── widgets/
│   ├── common/                  # CustomButton, CustomTextField, UserAvatar, RatingStars, EmptyState, LoadingWidget
│   └── ride/                    # RideCard, SeatSelector
└── screens/
    ├── splash/, auth/, home/, ride/, chat/, profile/
```

This separation (constants → theme/utils → models → services → providers →
widgets → screens) keeps each layer independently testable: services never
import widgets, widgets never call Firebase directly, and screens compose
reusable widgets instead of duplicating layout code.

## Responsive design

Every screen is built to adapt across phone, tablet, and desktop/web:

- `core/utils/responsive.dart` defines breakpoints (mobile < 600dp, tablet
  600–1024dp, desktop > 1024dp) and helpers: `Responsive.value()`,
  `ResponsiveBuilder`, and `ResponsiveCenter` (which clamps content width
  and centers it on large screens instead of stretching edge-to-edge).
- `HomeShell` swaps a bottom `NavigationBar` on phones for a side
  `NavigationRail` on tablets/desktop.
- `HomeScreen`'s ride feed becomes a multi-column `GridView` on tablet/desktop
  (`Responsive.gridColumns`) and stays a single scrolling column on phones.
- Forms (`CreateRideScreen`, `LoginScreen`, etc.) sit inside `ResponsiveCenter`
  so they don't become uncomfortably wide on large screens.

## Getting started

### 1. Prerequisites
- Flutter SDK 3.22+ (`flutter --version`)
- A Firebase project (free Spark plan is enough for development)
- `dart pub global activate flutterfire_cli`

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Connect Firebase
```bash
firebase login
flutterfire configure
```
This overwrites `lib/firebase_options.dart` with real project credentials
and registers your Android/iOS/web apps. In the Firebase console, enable:
- **Authentication** → Email/Password sign-in
- **Firestore Database** → start in production mode, then deploy
  `firestore.rules` (`firebase deploy --only firestore:rules`)
- **Storage** (for future profile-photo uploads)

### 4. Google Maps API key
`google_maps_flutter` needs a Maps SDK key:
- Android: add to `android/app/src/main/AndroidManifest.xml`
- iOS: add to `ios/Runner/AppDelegate.swift`
- Web: add to `web/index.html`

See the [google_maps_flutter setup docs](https://pub.dev/packages/google_maps_flutter) for exact steps.

### 5. Run
```bash
flutter run
```

## Data model (Firestore)

- `users/{uid}` — see `UserModel`
- `rides/{rideId}` — see `RideModel` (GeoPoint for start/destination so
  `LocationService.filterByRadius` can do nearby-ride matching)
- `ratings/{ratingId}` — see `RatingModel`
- `chats/{chatId}/messages/{messageId}` — see `ChatService`

`firestore.rules` in the project root mirrors these access patterns —
deploy it alongside your Firestore database.

## Notes & next steps

- **Payments, real-time tracking, SOS, AI matching, multi-university
  support** from the spec's "Future Enhancements" are intentionally left
  out of this MVP build, matching the source document's own MVP scope.
- **Report/Block**: `UserModel`/rules are structured to support a
  `blockedUsers` subcollection and a `reports` collection; add
  `FirestoreService.reportUser()` / `.blockUser()` plus a moderation
  screen when you're ready to build that out.
- **Radius search** currently geocodes on ride creation and filters
  client-side by distance. For large datasets, consider adding geohash
  fields (e.g. via the `geoflutterfire_plus` package) so Firestore can
  do the radius query server-side.
- Replace all `REPLACE_WITH_YOUR_...` placeholders in
  `firebase_options.dart` by running `flutterfire configure` — the app
  will not connect to Firebase until that's done.
