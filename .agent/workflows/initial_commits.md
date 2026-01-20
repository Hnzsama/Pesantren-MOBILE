---
description: Create 13 initial commits and push to main
---

// turbo-all

1. Commit 1: Core Config

```bash
git add .metadata .gitignore README.md analysis_options.yaml pesantren_mobile.iml
git commit -m "chore: initial project configuration"
```

1. Commit 2: Android

```bash
git add android/
git commit -m "feat: add android platform configuration"
```

1. Commit 3: iOS

```bash
git add ios/
git commit -m "feat: add ios platform configuration"
```

1. Commit 4: Web

```bash
git add web/
git commit -m "feat: add web platform configuration"
```

1. Commit 5: Desktop

```bash
git add windows/ linux/ macos/
git commit -m "feat: add desktop platforms configuration"
```

1. Commit 6: Dependencies

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add dependencies (google_fonts, flutter_animate)"
```

1. Commit 7: Assets

```bash
git add assets/
git commit -m "style: add application logo"
```

1. Commit 8: Constants

```bash
git add lib/src/constants/
git commit -m "feat: define app colors and theme constants"
```

1. Commit 9: Models

```bash
git add lib/src/features/home/models/
git commit -m "feat: add santri data model and mock data"
```

1. Commit 10: Widgets

```bash
git add lib/src/features/home/widgets/
git commit -m "feat: create reusable home dashboard widgets"
```

1. Commit 11: Splash Screen

```bash
git add lib/src/features/splash/
git commit -m "feat: implement splash screen with auth check logic"
```

1. Commit 12: Login Page

```bash
git add lib/src/features/auth/
git commit -m "feat: implement login page with lms style"
```

1. Commit 13: Main & Home

```bash
git add lib/
git commit -m "feat: connect main entry point and home dashboard"
```

1. Push to Main

```bash
git push -u origin main
```
