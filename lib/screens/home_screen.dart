import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/colors.dart';
import '../models/club.dart';
import '../services/club_service.dart';
import '../services/places_service.dart';
import '../services/besttime_service.dart';
import '../services/groq_service.dart';
import '../services/location_service.dart';
import '../widgets/club_card.dart';
import 'club_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Club> clubs = [];
  bool isLoading = true;
  String? errorMessage;
  String sortBy = 'distance'; // distance, crowd, rating
  String filterType = 'all'; // all, nightclub, bar, pub, lounge
  double userLat = 12.9716; // Default: Bangalore
  double userLng = 77.5946;
  late ClubService _clubService;

  @override
  void initState() {
    super.initState();
    _initServices();
    _loadClubs();
  }

  void _initServices() {
    final googleKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    final besttimeKey = dotenv.env['BESTTIME_API_KEY'] ?? '';
    final groqKey = dotenv.env['GROQ_API_KEY'] ?? '';

    _clubService = ClubService(
      placesService: googleKey.isNotEmpty ? PlacesService(apiKey: googleKey) : null,
      besttimeService: besttimeKey.isNotEmpty ? BesttimeService(apiKey: besttimeKey) : null,
      groqService: groqKey.isNotEmpty ? GroqService(apiKey: groqKey) : null,
    );
  }

  Future<void> _loadClubs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try to get real location
      try {
        final position = await LocationService.getCurrentLocation();
        userLat = position.latitude;
        userLng = position.longitude;
      } catch (_) {
        // Use default Bangalore coords
      }

      final results = await _clubService.getNearbyClubs(
        lat: userLat,
        lng: userLng,
      );

      setState(() {
        clubs = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Club> get filteredClubs {
    var result = clubs.toList();

    // Filter by type
    if (filterType != 'all') {
      result = result.where((c) => c.type == filterType).toList();
    }

    // Sort
    switch (sortBy) {
      case 'crowd':
        result.sort((a, b) => b.currentCrowd.compareTo(a.currentCrowd));
        break;
      case 'rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildApiStatus(),
            _buildFilters(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            AppColors.accent.withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLUB RUSH',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nearby nightlife — live crowd data',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _loadClubs,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLoading ? Icons.hourglass_top : Icons.refresh,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiStatus() {
    final statuses = <Widget>[];
    if (_clubService.hasPlacesApi) {
      statuses.add(_statusChip('Places', true));
    } else {
      statuses.add(_statusChip('Places', false));
    }
    if (_clubService.hasBesttimeApi) {
      statuses.add(_statusChip('Besttime', true));
    } else {
      statuses.add(_statusChip('Besttime', false));
    }
    if (_clubService.hasGroqApi) {
      statuses.add(_statusChip('Groq AI', true));
    } else {
      statuses.add(_statusChip('Groq AI', false));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'APIs: ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: AppColors.textDim,
            ),
          ),
          ...statuses,
          const Spacer(),
          if (!_clubService.hasPlacesApi && !_clubService.hasBesttimeApi)
            Text(
              'Using demo data',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF30D158).withValues(alpha: 0.15)
            : AppColors.warningDim,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFF30D158) : AppColors.warning,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF30D158) : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Type filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', 'all'),
                _filterChip('Nightclub', 'nightclub'),
                _filterChip('Bar', 'bar'),
                _filterChip('Pub', 'pub'),
                _filterChip('Lounge', 'lounge'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Sort options
          Row(
            children: [
              Text('Sort: ', style: TextStyle(fontSize: 11, color: AppColors.textDim)),
              _sortChip('Nearest', 'distance'),
              _sortChip('Most Crowded', 'crowd'),
              _sortChip('Top Rated', 'rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String type) {
    final isActive = filterType == type;
    return GestureDetector(
      onTap: () => setState(() => filterType = type),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withValues(alpha: 0.15) : AppColors.card,
          border: Border.all(
            color: isActive ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.accent : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String label, String sort) {
    final isActive = sortBy == sort;
    return GestureDetector(
      onTap: () => setState(() => sortBy = sort),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryDim : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? AppColors.secondary : AppColors.textDim,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Finding nearby clubs...',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fetching crowd data from APIs',
              style: TextStyle(fontSize: 11, color: AppColors.textDim),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.warning, size: 48),
              const SizedBox(height: 16),
              Text('Error loading clubs', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(errorMessage!, style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _loadClubs,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Retry', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayClubs = filteredClubs;

    if (displayClubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nightlife, color: AppColors.textDim, size: 48),
            const SizedBox(height: 16),
            Text('No clubs found', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      onRefresh: _loadClubs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
        itemCount: displayClubs.length,
        itemBuilder: (context, i) {
          return ClubCard(
            club: displayClubs[i],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClubDetailScreen(club: displayClubs[i]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
