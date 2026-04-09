import 'package:flutter/material.dart';
import '../constants/colors.dart';

class LayerItem {
  final String name;
  final String desc;
  final String tech;
  final List<String> details;

  const LayerItem({
    required this.name,
    required this.desc,
    required this.tech,
    required this.details,
  });
}

class ArchLayer {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final Color dimColor;
  final List<LayerItem> items;

  const ArchLayer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.dimColor,
    required this.items,
  });
}

class DataFlowStep {
  final String from;
  final String to;
  final Color color;

  const DataFlowStep({
    required this.from,
    required this.to,
    required this.color,
  });
}

class ApiCost {
  final String api;
  final String free;
  final String paid;
  final String note;

  const ApiCost({
    required this.api,
    required this.free,
    required this.paid,
    required this.note,
  });
}

final List<ArchLayer> layers = [
  ArchLayer(
    id: 'user',
    title: '👤 USER LAYER',
    subtitle: 'Client Side',
    color: AppColors.accent,
    dimColor: AppColors.accentDim,
    items: [
      LayerItem(
        name: 'React Native / WebView App',
        desc: 'Cross-platform mobile app',
        tech: 'React Native + Expo',
        details: [
          'Geolocation API → user ka live lat/lng fetch',
          'Push Notifications → crowd alerts',
          'Offline caching → last known data',
          'Deep links → club page share',
        ],
      ),
      LayerItem(
        name: 'Web PWA (Fallback)',
        desc: 'Browser-based progressive web app',
        tech: 'React + Vite + PWA',
        details: [
          'navigator.geolocation API',
          'Service Worker for offline',
          'Add to Home Screen prompt',
        ],
      ),
    ],
  ),
  ArchLayer(
    id: 'api',
    title: '🔌 API GATEWAY',
    subtitle: 'Request Routing & Auth',
    color: AppColors.info,
    dimColor: AppColors.infoDim,
    items: [
      LayerItem(
        name: 'Firebase Cloud Functions',
        desc: 'Serverless API endpoints',
        tech: 'Node.js + Express',
        details: [
          'POST /api/nearby-clubs → lat/lng se clubs fetch',
          'GET /api/club/:id/crowd → real-time crowd data',
          'POST /api/club/:id/checkin → user check-in',
          'GET /api/club/:id/history → hourly crowd history',
          'WebSocket /ws/live-crowd → real-time updates',
        ],
      ),
      LayerItem(
        name: 'Auth Layer',
        desc: 'User authentication',
        tech: 'Firebase Auth',
        details: [
          'Google/Phone OTP sign-in',
          'Anonymous auth for quick access',
          'Rate limiting per user',
        ],
      ),
    ],
  ),
  ArchLayer(
    id: 'external',
    title: '🌐 EXTERNAL APIs',
    subtitle: '3rd Party Data Sources',
    color: AppColors.warning,
    dimColor: AppColors.warningDim,
    items: [
      LayerItem(
        name: 'Google Places API',
        desc: 'Club discovery + metadata',
        tech: 'Places API (New)',
        details: [
          'Nearby Search → clubs/bars within radius',
          'Place Details → name, photos, rating, hours',
          'Place Photos → venue images',
          'Cost: \$32/1000 requests (Nearby Search)',
        ],
      ),
      LayerItem(
        name: 'Google Maps Popular Times',
        desc: 'Crowd estimation baseline',
        tech: 'Unofficial / Scraping',
        details: [
          'populartimes Python lib (unofficial)',
          'Hourly popularity histogram (0-100)',
          'Live busyness indicator',
          '⚠️ Not official API — use as fallback',
        ],
      ),
      LayerItem(
        name: 'Besttime.app API',
        desc: 'Real-time foot traffic data',
        tech: 'REST API — Best ✅',
        details: [
          'POST /forecasts → crowd forecast by venue',
          'GET /forecasts/live → real-time busyness',
          'Hourly foot traffic predictions',
          'Surge detection & quiet hours',
          'Cost: Free tier 100 req/month, \$79/mo Pro',
        ],
      ),
      LayerItem(
        name: 'SafeGraph / Placer.ai',
        desc: 'Enterprise foot traffic (Plan B)',
        tech: 'REST API',
        details: [
          'Actual device-level foot traffic',
          'Dwell time analytics',
          'Enterprise pricing — for scale',
        ],
      ),
    ],
  ),
  ArchLayer(
    id: 'data',
    title: '💾 DATA LAYER',
    subtitle: 'Storage & Processing',
    color: AppColors.secondary,
    dimColor: AppColors.secondaryDim,
    items: [
      LayerItem(
        name: 'Firestore (Primary DB)',
        desc: 'Real-time NoSQL database',
        tech: 'Firebase Firestore',
        details: [
          'clubs/{clubId} → venue metadata + cached crowd',
          'clubs/{clubId}/crowdHistory → hourly snapshots',
          'clubs/{clubId}/checkins → user check-ins',
          'users/{userId} → preferences, favorites',
          'Real-time listeners for live updates',
        ],
      ),
      LayerItem(
        name: 'Cloud Scheduler + Cron',
        desc: 'Background data refresh',
        tech: 'Firebase Scheduled Functions',
        details: [
          'Every 15 min → fetch Besttime live data',
          'Every 1 hr → update Popular Times cache',
          'Daily → refresh Google Places metadata',
          'Weekly → cleanup stale check-ins',
        ],
      ),
      LayerItem(
        name: 'Groq AI Engine',
        desc: 'Smart crowd predictions',
        tech: 'Groq API + LLaMA 3',
        details: [
          'Input: historical crowd + weather + day/time + events',
          'Output: predicted crowd level next 2 hours',
          "Natural language: 'Abhi chill hai, 11 baje packed hoga'",
          'Event correlation (IPL match → sports bars busy)',
        ],
      ),
    ],
  ),
];

final List<DataFlowStep> dataFlow = [
  DataFlowStep(from: 'User opens app', to: 'Geolocation API → lat/lng', color: AppColors.accent),
  DataFlowStep(from: 'lat/lng sent to', to: 'Firebase Cloud Function /nearby-clubs', color: AppColors.info),
  DataFlowStep(from: 'Cloud Function calls', to: 'Google Places API (Nearby Search)', color: AppColors.warning),
  DataFlowStep(from: 'For each club, fetch', to: 'Besttime.app Live Crowd Data', color: AppColors.warning),
  DataFlowStep(from: 'Merge & cache in', to: 'Firestore clubs collection', color: AppColors.secondary),
  DataFlowStep(from: 'Groq AI predicts', to: 'Next 2hr crowd + Hindi insight', color: AppColors.secondary),
  DataFlowStep(from: 'Final response sent', to: 'App renders club cards with crowd %', color: AppColors.accent),
];

final List<ApiCost> apiCosts = [
  ApiCost(api: 'Google Places API', free: 'Free \$200/mo credit', paid: '\$32/1K nearby searches', note: 'Essential'),
  ApiCost(api: 'Besttime.app', free: '100 req/month free', paid: '\$79/mo (10K req)', note: 'Primary crowd data'),
  ApiCost(api: 'Groq API', free: 'Free tier generous', paid: 'Pay-per-token (very cheap)', note: 'AI predictions'),
  ApiCost(api: 'Firebase', free: 'Spark plan free', paid: 'Blaze (pay as you go)', note: 'Backend + DB'),
  ApiCost(api: 'Google Maps JS', free: 'Free \$200/mo credit', paid: '\$7/1K map loads', note: 'Optional map view'),
];

const String firestoreSchema = '''clubs/
  {clubId}/
    name: "Neon Nights"
    placeId: "ChIJ…"
    location: GeoPoint(lat, lng)
    type: "nightclub"
    rating: 4.3
    currentCrowd: 72        ← Besttime live
    crowdLevel: "busy"
    lastUpdated: Timestamp
    photos: [url1, url2]
    music: "EDM / House"
    cover: "₹1500"

    crowdHistory/
      {hourlyDocId}/
        hour: "2026-04-01T22:00"
        crowd: 72
        source: "besttime"

    checkins/
      {checkinId}/
        userId: "uid_123"
        timestamp: Timestamp
        selfReportedCrowd: "packed"''';

final List<Map<String, String>> techStack = [
  {'cat': 'Frontend', 'val': 'React Native (Expo) + WebView fallback'},
  {'cat': 'Backend', 'val': 'Firebase Cloud Functions (Node.js)'},
  {'cat': 'Database', 'val': 'Firestore (real-time sync)'},
  {'cat': 'AI Layer', 'val': 'Groq API + LLaMA 3.3 70B'},
  {'cat': 'Crowd API', 'val': 'Besttime.app (primary) + Popular Times'},
  {'cat': 'Places', 'val': 'Google Places API (New)'},
  {'cat': 'Auth', 'val': 'Firebase Auth (Phone OTP + Google)'},
  {'cat': 'Hosting', 'val': 'Firebase Hosting + Cloud Functions'},
  {'cat': 'Notifications', 'val': 'FCM (Firebase Cloud Messaging)'},
];

Color getTechStackColor(int index) {
  const colors = [
    AppColors.accent, AppColors.info, AppColors.secondary,
    AppColors.secondary, AppColors.warning, AppColors.warning,
    AppColors.info, AppColors.info, AppColors.accent,
  ];
  return colors[index % colors.length];
}

final List<Map<String, dynamic>> costTiers = [
  {'label': '0 – 500 users', 'cost': '₹0 (Free tiers)', 'color': const Color(0xFF30D158)},
  {'label': '500 – 2K users', 'cost': '~₹5,000/mo', 'color': AppColors.accent},
  {'label': '2K – 10K users', 'cost': '~₹15,000/mo', 'color': AppColors.warning},
  {'label': '10K+ users', 'cost': '₹30,000+/mo', 'color': const Color(0xFFFF2D55)},
];

final List<Map<String, String>> apiPriority = [
  {'phase': 'Phase 1 (MVP)', 'apis': 'Google Places + User Check-ins (crowdsourced)', 'cost': 'Free'},
  {'phase': 'Phase 2 (Beta)', 'apis': 'Add Besttime.app for real crowd data', 'cost': '~\$79/mo'},
  {'phase': 'Phase 3 (Scale)', 'apis': 'Add Groq AI predictions + SafeGraph', 'cost': 'Variable'},
];
