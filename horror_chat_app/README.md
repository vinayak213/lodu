# Horror Chat App - Flutter Project Structure

```
horror_chat_app/
├── lib/
│   └── main.dart              # Complete app logic (895 lines)
├── android/
│   ├── app/
│   │   ├── build.gradle       # App-level build config
│   │   └── src/main/
│   │       ├── AndroidManifest.xml  # Permissions & config
│   │       └── kotlin/.../MainActivity.kt
│   └── build.gradle           # Project-level build config
├── assets/
│   ├── audio/                 # Sound effects (add MP3 files)
│   └── images/                # Optional images
├── pubspec.yaml               # Dependencies
└── SETUP_INSTRUCTIONS.md      # Detailed setup guide
```

## Quick Start

```bash
cd horror_chat_app
flutter pub get
flutter run
```

## Required Audio Files

Add these to `assets/audio/`:
- `ambient_hum.mp3`
- `notification.mp3`
- `glitch.mp3`

See SETUP_INSTRUCTIONS.md for details.
