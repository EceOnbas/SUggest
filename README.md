# SUggest
SUggest is the go-to mobile app Sabancı students open when choosing courses. Today, course research is fragmented: official descriptions and syllabus live on separate sites, while student feedback on instructors, workload, and attendance is scattered across unorganized group chats. SUggest unifies basic course info with verified peer reviews and category-based average scores (difficulty, workload, instructor) in a single hub. By providing demographic insights—such as breakdowns by major and class year, along with popular course pairings—it gives students a clear, data-backed roadmap for planning their degree.

## 👥 Contributors

This project was developed by Group 3:

* **Beren Güler** - [GitHub Profile](https://github.com/beren-guler)
* **Nil Sözlü** - [GitHub Profile](https://github.com/nilsozlu)
* **Emine Sena Cesur** - [GitHub Profile](https://github.com/sena-cesur)
* **Ece Önbaş** - [GitHub Profile](https://github.com/EceOnbas)

## 🚀 Getting started

**Flutter version:** 3.47.5 (stable channel), Dart 3.13.4. Check yours with `flutter --version`.

1. Install Flutter: <https://docs.flutter.dev/get-started/install>
2. Clone the repository and open its folder:

   ```bash
   git clone https://github.com/EceOnbas/SUggest.git
   cd SUggest
   ```

3. Download the packages:

   ```bash
   flutter pub get
   ```

4. Start an Android emulator or an iOS simulator, then run the app:

   ```bash
   flutter run
   ```

To run the tests:

```bash
flutter test
```

### Signing in

Step 2 has no backend yet, so sign-in is UI-only and nothing is saved when the app closes.

- **Create account** works with any name before `@sabanciuniv.edu`. On "Check your inbox", the first "I've verified" says "Not verified yet" and the second one passes, so both states can be seen.
- A ready-made demo account is listed in `lib/services/fake_auth_service.dart` (`demoAccounts`).

## 🗂 Project structure

```
lib/
  main.dart, app.dart     app start, theme and routes
  core/
    theme/                colors, text styles, spacing (shared by every screen)
    widgets/              reusable widgets: buttons, inputs, chips, cards, sheet, dialog
    art/                  the sakura branch and the Onigiri mascot
    routes/               every route name in one place
  models/                 Course, Review, UserProfile
  data/                   placeholder data and the course repository
  services/               sign-in service (fake in Step 2, Firebase in Step 3)
  features/
    auth/                 Welcome, Log in, Create account, Check your inbox, Forgot password
    profile_setup/        the four profile setup steps
    course/               course page: Overview, Sections, Reviews
    home/, community/, profile/, shell/   bottom bar tabs
assets/
  fonts/                  Schibsted Grotesk (SIL Open Font License, see OFL.txt)
  images/                 Onigiri mascot (local images)
docs/images/              the Welcome photo, loaded over the network
test/                     widget and unit tests
```

## 🖼 Images and font

- **Local images:** the Onigiri mascot in `assets/images/`, shown with `Image.asset`.
- **Network image:** the campus photo on the Welcome screen, loaded with `Image.network`. Photo: Beren Güler, Sabancı University campus, March 2024. Without internet the screen shows the sakura branch instead.
- **Custom font:** Schibsted Grotesk, bundled in `assets/fonts/`.
