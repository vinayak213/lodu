import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;
  bool crowdAlertsEnabled = true;
  double searchRadius = 5.0;
  String preferredVibe = 'Any';
  int totalCheckins = 7;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        notificationsEnabled = prefs.getBool('notifications') ?? true;
        crowdAlertsEnabled = prefs.getBool('crowdAlerts') ?? true;
        searchRadius = prefs.getDouble('searchRadius') ?? 5.0;
        preferredVibe = prefs.getString('preferredVibe') ?? 'Any';
      });
    } catch (_) {}
  }

  Future<void> _savePref(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) await prefs.setBool(key, value);
      if (value is double) await prefs.setDouble(key, value);
      if (value is String) await prefs.setString(key, value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'PROFILE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),

              // User card
              _buildUserCard(),
              const SizedBox(height: 16),

              // Stats
              _buildStatsCard(),
              const SizedBox(height: 16),

              // Preferences
              _buildPreferencesCard(),
              const SizedBox(height: 16),

              // API Keys Section
              _buildApiKeysCard(),
              const SizedBox(height: 16),

              // About
              _buildAboutCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.secondary],
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anonymous User',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sign in for personalized experience',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sign in with Google',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR STATS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _statItem('$totalCheckins', 'Check-ins', AppColors.accent),
              _statItem('3', 'Favorites', AppColors.secondary),
              _statItem('12', 'Clubs Visited', AppColors.info),
              _statItem('🏆', 'Night Owl', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREFERENCES',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),

          // Notifications toggle
          _toggleRow(
            'Push Notifications',
            'Get alerts about nearby clubs',
            Icons.notifications_outlined,
            notificationsEnabled,
            (val) {
              setState(() => notificationsEnabled = val);
              _savePref('notifications', val);
            },
          ),
          const Divider(color: AppColors.border, height: 20),

          // Crowd alerts
          _toggleRow(
            'Crowd Alerts',
            'Notify when favorite clubs get busy',
            Icons.trending_up,
            crowdAlertsEnabled,
            (val) {
              setState(() => crowdAlertsEnabled = val);
              _savePref('crowdAlerts', val);
            },
          ),
          const Divider(color: AppColors.border, height: 20),

          // Search radius
          Row(
            children: [
              Icon(Icons.radar, size: 18, color: AppColors.info),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search Radius',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
                    ),
                    Text(
                      '${searchRadius.toStringAsFixed(0)} km',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accentDim,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: searchRadius,
              min: 1,
              max: 20,
              onChanged: (val) {
                setState(() => searchRadius = val);
                _savePref('searchRadius', val);
              },
            ),
          ),
          const Divider(color: AppColors.border, height: 10),

          // Preferred vibe
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.music_note, size: 18, color: AppColors.secondary),
              const SizedBox(width: 10),
              const Text(
                'Preferred Vibe',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Any', 'Chill', 'Hype', 'Live Music', 'Bollywood', 'EDM'].map((vibe) {
              final isSelected = preferredVibe == vibe;
              return GestureDetector(
                onTap: () {
                  setState(() => preferredVibe = vibe);
                  _savePref('preferredVibe', vibe);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondaryDim : Colors.white.withValues(alpha: 0.02),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vibe,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.secondary : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textDim)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accent,
          inactiveTrackColor: AppColors.border,
        ),
      ],
    );
  }

  Widget _buildApiKeysCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API CONFIGURATION',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add API keys in .env file to enable live data',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          _apiKeyRow('Google Places', 'GOOGLE_PLACES_API_KEY', 'Club discovery + photos'),
          _apiKeyRow('Besttime.app', 'BESTTIME_API_KEY', 'Real-time crowd data'),
          _apiKeyRow('Groq AI', 'GROQ_API_KEY', 'Hindi crowd predictions'),
        ],
      ),
    );
  }

  Widget _apiKeyRow(String name, String envKey, String desc) {
    final isConfigured = (const String.fromEnvironment(envKey)).isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConfigured ? const Color(0xFF30D158) : AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                Text(desc, style: TextStyle(fontSize: 10, color: AppColors.textDim)),
              ],
            ),
          ),
          Text(
            isConfigured ? 'Active' : 'Not set',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isConfigured ? const Color(0xFF30D158) : AppColors.textDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Club Rush Tracker v1.0.0',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time nightlife crowd intelligence platform.\n'
            'Know the vibe before you arrive.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _aboutChip('Google Places API', AppColors.warning),
              const SizedBox(width: 6),
              _aboutChip('Besttime.app', AppColors.info),
              const SizedBox(width: 6),
              _aboutChip('Groq AI', AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aboutChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
