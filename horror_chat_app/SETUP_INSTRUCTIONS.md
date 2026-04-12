# SETUP INSTRUCTIONS FOR HORROR CHAT APP

## Prerequisites
- Flutter SDK 3.0+ installed
- Android Studio with Android SDK
- A physical Android device (recommended for camera/flash features)

## Step 1: Project Setup

1. Navigate to the project directory:
```bash
cd horror_chat_app
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

## Step 2: Audio Assets Setup

Create placeholder audio files in `assets/audio/`:

You need to add these audio files:
- `ambient_hum.mp3` - Low background hum (loop)
- `notification.mp3` - Message notification sound
- `glitch.mp3` - Static/glitch sound effect

You can generate these using:
- Audacity (free audio editor)
- Online sound generators
- Or download from free sound libraries like freesound.org

## Step 3: Android Configuration

The AndroidManifest.xml is already configured with all necessary permissions:
- CAMERA
- RECORD_AUDIO
- VIBRATE
- FLASHLIGHT
- INTERNET

## Step 4: Build and Run

### For Debug Mode:
```bash
flutter run
```

### For Release APK:
```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Step 5: Testing on Device

1. Enable USB debugging on your Android device
2. Connect via USB
3. Run `flutter devices` to verify connection
4. Run `flutter run`

## Features Implemented

### Core Features:
✅ Realistic WhatsApp-style chat UI
✅ Typing animation with realistic delays
✅ Auto-progressing story (7 phases)

### Advanced Horror Features:

1. **Real-Time Personalization**
   - Uses system time in messages
   - Detects device model and brand
   - Shows current time dynamically

2. **App Background Detection**
   - Detects when user minimizes app
   - Shows "Kaha chale gaye the?" on return

3. **Message Morphing**
   - Messages transform after appearing
   - Visual red border on morphed messages

4. **Glitch & Chaos Effects**
   - Screen flicker overlay
   - Contact name changes randomly
   - Screen shake effect
   - White flash glitches

5. **Camera Horror**
   - Requests camera permission
   - Shows live camera feed briefly
   - Cuts to black with message

6. **Microphone Reaction**
   - Requests mic permission
   - Simulates sound detection
   - Triggers response message

7. **Vibration + Haptic Feedback**
   - Pattern-based vibrations
   - Strong vibration at jump scares
   - Subtle vibrations during tension

8. **Flash Effect**
   - Torch light flashes at key moments
   - Double-flash pattern for maximum impact

9. **Fullscreen Immersion**
   - Extends body behind app bar
   - Immersive mode enabled

10. **Shadow/Parallax Effect**
    - Custom shadow painter
    - Reacts to touch/drag movement
    - Intensity increases with story phase

11. **Audio System**
    - Ambient background hum (looping)
    - Notification sounds per message
    - Glitch/static sound effects

12. **Story Flow**
    - Phase 1: Normal chat
    - Phase 2: Slightly weird
    - Phase 3: Personal info reveal
    - Phase 4: Threat increases
    - Phase 5: User feels watched (camera)
    - Phase 6: Chaos (glitch + spam)
    - Phase 7: Final break (ending)

13. **Ending**
    - Black screen transition
    - Flash effect
    - Red text reveal
    - Share button for viral hook

14. **Viral Hook**
    - "Share this with someone who is alone" button
    - Uses Android share intent

## Troubleshooting

### Camera not working?
- Ensure camera permission is granted
- Check if device has camera
- Try on physical device (emulator camera support varies)

### Flash not working?
- Some devices don't support torch_light plugin
- Fallback: visual flash effect still works

### Audio not playing?
- Ensure audio files exist in assets/audio/
- Check volume settings
- Try on physical device

### App crashes on startup?
- Run `flutter clean` then `flutter pub get`
- Check Android SDK version compatibility
- Ensure minSdkVersion >= 21

## Performance Optimization

The app is optimized for:
- Smooth 60fps animations
- Efficient timer management
- Proper disposal of resources
- Minimal memory footprint

## Customization

To modify the story:
- Edit `_storyMessages` map in `main.dart`
- Adjust delays, text, and phase progression
- Add new phases or messages

To change visual style:
- Modify colors in theme data
- Adjust ChatBubble decoration
- Change glitch intensity

## Distribution

1. Create release keystore
2. Update build.gradle with signing config
3. Build release APK
4. Distribute via Google Play or direct APK

## Safety Note

This is a horror entertainment app. Consider adding:
- Age rating (13+)
- Content warning for sensitive users
- Option to skip intense sequences

Enjoy creating terror! 👻
