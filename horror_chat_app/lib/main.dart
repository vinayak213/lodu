import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Global variables for camera
List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cameras
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Camera initialization error: $e');
  }
  
  runApp(const HorrorChatApp());
}

class HorrorChatApp extends StatelessWidget {
  const HorrorChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unknown Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D1117),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        fontFamily: 'monospace',
      ),
      home: const HorrorExperience(),
    );
  }
}

enum StoryPhase {
  normal,
  strange,
  personal,
  threat,
  watched,
  chaos,
  ending,
}

class HorrorExperience extends StatefulWidget {
  const HorrorExperience({super.key});

  @override
  State<HorrorExperience> createState() => _HorrorExperienceState();
}

class _HorrorExperienceState extends State<HorrorExperience> with WidgetsBindingObserver, TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  
  bool _isTyping = false;
  String _contactName = "Unknown";
  String _contactStatus = "online";
  StoryPhase _currentPhase = StoryPhase.normal;
  int _messageIndex = 0;
  
  bool _cameraPermissionGranted = false;
  bool _micPermissionGranted = false;
  bool _showCameraPreview = false;
  CameraController? _cameraController;
  
  bool _glitchActive = false;
  bool _screenShaking = false;
  double _shadowOffsetX = 0;
  double _shadowOffsetY = 0;
  
  Timer? _ambientTimer;
  Timer? _glitchTimer;
  Timer? _micListener;
  
  String _deviceModel = "Unknown Device";
  String _currentTime = "";
  
  // Story messages organized by phase
  final Map<StoryPhase, List<Map<String, dynamic>>> _storyMessages = {
    StoryPhase.normal: [
      {"text": "Hello?", "delay": 1000},
      {"text": "Is anyone there?", "delay": 2000},
      {"text": "I can see you're online...", "delay": 2500},
    ],
    StoryPhase.strange: [
      {"text": "Do you know what time it is?", "delay": 2000},
      {"text": "Too late to be awake...", "delay": 2000},
      {"text": "Don't look behind you.", "morph": "DON'T LOOK BEHIND YOU", "delay": 2500},
    ],
    StoryPhase.personal: [
      {"text": "I know your device: $_deviceModel", "delay": 2000},
      {"text": "It's $_currentTime right now...", "delay": 2000},
      {"text": "You're alone, aren't you?", "delay": 2500},
    ],
    StoryPhase.threat: [
      {"text": "Why did you minimize the app?", "delay": 1500},
      {"text": "You can't hide from me.", "delay": 2000},
      {"text": "I'm closer than you think.", "delay": 2500},
    ],
    StoryPhase.watched: [
      {"text": "I can see your camera...", "delay": 2000},
      {"text": "Let me see you too.", "delay": 2000, "requestCamera": true},
      {"text": "Main tumhe dekh raha hoon.", "delay": 3000},
    ],
    StoryPhase.chaos: [
      {"text": "LISTEN TO ME", "delay": 500},
      {"text": "LISTEN TO ME", "delay": 500},
      {"text": "THERE'S NO ESCAPE", "delay": 500},
      {"text": "RUN RUN RUN", "delay": 400},
      {"text": "HEAR THAT SOUND?", "delay": 1500, "requestMic": true},
      {"text": "Maine suna... tumne kuch bola.", "delay": 2000},
    ],
    StoryPhase.ending: [
      {"text": "This was not a simulation.", "delay": 3000},
      {"text": "Main tumhare peeche hoon.", "delay": 4000},
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDevice();
    _startStory();
    _startAmbientSound();
    _setupGlitchEffects();
  }
  
  Future<void> _initializeDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        _deviceModel = "${androidInfo.brand} ${androidInfo.model}";
      });
    }
    _updateTime();
  }
  
  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User returned to app
      if (_messages.isNotEmpty && _currentPhase != StoryPhase.ending) {
        _addMessage("Kaha chale gaye the?", delay: 500);
        _triggerVibration(pattern: [0, 100, 50, 100]);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _audioPlayer.dispose();
    _ambientPlayer.dispose();
    _ambientTimer?.cancel();
    _glitchTimer?.cancel();
    _micListener?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  void _startAmbientSound() async {
    // Create low ambient hum using audio player
    // In production, you'd have actual audio files
    await _ambientPlayer.setSourceAsset('audio/ambient_hum.mp3');
    await _ambientPlayer.setVolume(0.3);
    await _ambientPlayer.resume();
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _playNotificationSound() async {
    await _audioPlayer.play(AssetSource('audio/notification.mp3'));
  }

  Future<void> _playGlitchSound() async {
    await _audioPlayer.play(AssetSource('audio/glitch.mp3'));
  }

  void _startStory() {
    _advancePhase();
  }

  void _advancePhase() {
    if (_currentPhase.index >= StoryPhase.ending.index) return;
    
    final messages = _storyMessages[_currentPhase]!;
    for (var msg in messages) {
      _scheduleMessage(msg);
    }
    
    // Schedule phase advancement
    final totalDelay = messages.fold<int>(
      0, 
      (sum, msg) => sum + (msg['delay'] as int) + 500
    );
    
    Timer(Duration(milliseconds: totalDelay), () {
      setState(() {
        if (_currentPhase.index < StoryPhase.ending.index) {
          _currentPhase = StoryPhase.values[_currentPhase.index + 1];
        }
        if (_currentPhase == StoryPhase.ending) {
          _triggerEnding();
        }
      });
    });
  }

  void _scheduleMessage(Map<String, dynamic> msgData) {
    final delay = msgData['delay'] as int;
    Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        if (msgData['requestCamera'] == true) {
          _requestCameraPermission();
        } else if (msgData['requestMic'] == true) {
          _requestMicPermission();
        } else {
          _addMessage(
            msgData['text'] as String,
            morphText: msgData['morph'] as String?,
          );
        }
      }
    });
  }

  void _addMessage(String text, {String? morphText, int? delay}) {
    setState(() {
      _isTyping = true;
    });
    
    final actualDelay = delay ?? Random().nextInt(800) + 400;
    
    Timer(Duration(milliseconds: actualDelay), () {
      if (!mounted) return;
      
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: text,
          isReceived: true,
          timestamp: DateTime.now(),
          morphText: morphText,
        ));
      });
      
      _playNotificationSound();
      _triggerVibration(pattern: [0, 50]);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    
    if (status.isGranted) {
      setState(() {
        _cameraPermissionGranted = true;
      });
      _showCameraFeed();
    }
  }

  Future<void> _showCameraFeed() async {
    if (cameras == null || cameras!.isEmpty) return;
    
    setState(() {
      _showCameraPreview = true;
    });
    
    _cameraController = CameraController(
      cameras!.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    
    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
      
      // Show for 2 seconds then cut to black
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        await _cameraController!.dispose();
        setState(() {
          _showCameraPreview = false;
          _cameraController = null;
        });
        
        // Cut to black effect
        _triggerFlash();
        _triggerVibration(pattern: [0, 500, 200, 500]);
        _addMessage("Main tumhe dekh raha hoon.", delay: 1000);
      }
    } catch (e) {
      print('Camera error: $e');
    }
  }

  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    
    if (status.isGranted) {
      setState(() {
        _micPermissionGranted = true;
      });
      _listenForSound();
    }
  }

  void _listenForSound() {
    // Simulate sound detection (actual implementation would use audio stream)
    // For horror effect, we'll trigger after a random delay
    final delay = Random().nextInt(3000) + 2000;
    _micListener = Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        _addMessage("Maine suna... tumne kuch bola.", delay: 500);
        _triggerVibration(pattern: [0, 200, 100, 200]);
      }
    });
  }

  void _triggerVibration({List<int>? pattern}) {
    if (pattern != null) {
      Vibration.vibrate(pattern: pattern);
    } else {
      Vibration.vibrate(duration: 100);
    }
  }

  Future<void> _triggerFlash() async {
    try {
      await TorchLight.turnOn();
      await Future.delayed(const Duration(milliseconds: 200));
      await TorchLight.turnOff();
      await Future.delayed(const Duration(milliseconds: 100));
      await TorchLight.turnOn();
      await Future.delayed(const Duration(milliseconds: 200));
      await TorchLight.turnOff();
    } catch (e) {
      print('Flash error: $e');
    }
  }

  void _setupGlitchEffects() {
    _glitchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPhase.index >= StoryPhase.threat.index && 
          _currentPhase != StoryPhase.ending) {
        _triggerGlitch();
      }
    });
  }

  void _triggerGlitch() {
    setState(() {
      _glitchActive = true;
      _screenShaking = true;
      _contactName = ["UNKNOWN", "HELP", "RUN", "666"][Random().nextInt(4)];
    });
    
    _playGlitchSound();
    _triggerVibration(pattern: [0, 100, 50, 100, 50, 100]);
    
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _glitchActive = false;
          _screenShaking = false;
          _contactName = "Unknown";
        });
      }
    });
  }

  void _triggerEnding() async {
    setState(() {
      _currentPhase = StoryPhase.ending;
    });
    
    _triggerFlash();
    _triggerVibration(pattern: [0, 1000]);
    
    await Future.delayed(const Duration(seconds: 4));
    
    if (mounted) {
      _showEndScreen();
    }
  }

  void _showEndScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EndScreen(onShare: _shareApp),
    );
  }

  void _shareApp() async {
    await Share.share(
      'Check out this terrifying horror chat experience... if you dare! 😱',
      subject: 'Horror Chat Challenge',
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _shadowOffsetX = details.delta.dx * 0.5;
      _shadowOffsetY = details.delta.dy * 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F24),
        elevation: 0,
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.black),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _contactName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _contactStatus,
              style: TextStyle(
                color: _glitchActive ? Colors.red : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // Main chat area
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0D1117),
                    const Color(0xFF161B22),
                    const Color(0xFF0D1117),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 60, bottom: 20),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return const TypingIndicator();
                        }
                        return ChatBubble(message: _messages[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Shadow overlay with parallax
          Positioned.fill(
            child: CustomPaint(
              painter: ShadowPainter(
                offsetX: _shadowOffsetX,
                offsetY: _shadowOffsetY,
                intensity: _currentPhase.index / StoryPhase.values.length,
              ),
            ),
          ),
          
          // Glitch overlay
          if (_glitchActive)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.1),
                child: CustomPaint(
                  painter: GlitchPainter(),
                ),
              ),
            ),
          
          // Screen shake effect
          if (_screenShaking)
            Positioned.fill(
              child: TweenAnimationBuilder(
                tween: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(5, 5),
                ),
                duration: const Duration(milliseconds: 50),
                builder: (context, Offset offset, child) {
                  return Transform.translate(
                    offset: Offset(
                      (Random().nextDouble() - 0.5) * 10,
                      (Random().nextDouble() - 0.5) * 10,
                    ),
                    child: child,
                  );
                },
                child: const SizedBox.shrink(),
              ),
            ),
          
          // Camera preview overlay
          if (_showCameraPreview && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            ),
          
          // Black screen cut
          if (_showCameraPreview && _cameraController == null)
            Positioned.fill(
              child: Container(color: Colors.black),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isReceived;
  final DateTime timestamp;
  final String? morphText;
  
  ChatMessage({
    required this.text,
    required this.isReceived,
    required this.timestamp,
    this.morphText,
  });
}

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  
  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  String _displayText = "";
  bool _morphed = false;
  
  @override
  void initState() {
    super.initState();
    _typeMessage();
  }
  
  void _typeMessage() {
    final text = widget.message.text;
    for (int i = 0; i < text.length; i++) {
      Timer(Duration(milliseconds: i * 30), () {
        if (mounted) {
          setState(() {
            _displayText = text.substring(0, i + 1);
          });
        }
      });
    }
    
    // Morph effect
    if (widget.message.morphText != null) {
      Timer(Duration(milliseconds: text.length * 30 + 1000), () {
        if (mounted) {
          setState(() {
            _displayText = widget.message.morphText!;
            _morphed = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: widget.message.isReceived 
            ? MainAxisAlignment.start 
            : MainAxisAlignment.end,
        children: [
          if (widget.message.isReceived) ...[
            const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.message.isReceived 
                    ? const Color(0xFF1F2933)
                    : const Color(0xFF005C4B),
                borderRadius: BorderRadius.circular(16),
                border: _morphed 
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayText,
                    style: TextStyle(
                      color: _morphed ? Colors.red : Colors.white,
                      fontSize: 15,
                      fontWeight: _morphed ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.message.timestamp.hour.toString().padLeft(2, '0')}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!widget.message.isReceived) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2933),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final opacity = (Math.sin((_controller.value * 2 * pi) + (index * pi / 3)) + 1) / 2;
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(opacity * 0.7 + 0.3),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShadowPainter extends CustomPainter {
  final double offsetX;
  final double offsetY;
  final double intensity;
  
  ShadowPainter({
    required this.offsetX,
    required this.offsetY,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (size.width / 2 + offsetX) / size.width * 2 - 1,
          (size.height / 2 + offsetY) / size.height * 2 - 1,
        ),
        radius: 1.5,
        colors: [
          Colors.black.withOpacity(0.3 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant ShadowPainter oldDelegate) {
    return oldDelegate.offsetX != offsetX || 
           oldDelegate.offsetY != offsetY ||
           oldDelegate.intensity != intensity;
  }
}

class GlitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random();
    
    for (int i = 0; i < 20; i++) {
      paint.color = Colors.white.withOpacity(random.nextDouble() * 0.3);
      final height = random.nextDouble() * 50 + 10;
      final y = random.nextDouble() * size.height;
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EndScreen extends StatelessWidget {
  final VoidCallback onShare;
  
  const EndScreen({super.key, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This was not a simulation.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Main tumhare peeche hoon.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: const Text('Share this with someone who is alone'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Restart or exit
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
