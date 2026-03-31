import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  final String apiKey;
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  GroqService({required this.apiKey});

  /// Get AI-powered crowd prediction and insight in Hindi/Hinglish
  Future<CrowdPrediction> getCrowdPrediction({
    required String clubName,
    required String clubType,
    required int currentCrowd,
    required List<int> recentHourlyCrowds,
    required String dayOfWeek,
    required int currentHour,
  }) async {
    final prompt = '''You are a nightlife crowd prediction AI for Indian cities.
Analyze this club's crowd data and predict the next 2 hours.

Club: $clubName ($clubType)
Current Crowd Level: $currentCrowd%
Day: $dayOfWeek
Time: ${currentHour}:00
Recent hourly crowds: ${recentHourlyCrowds.join(', ')}%

Respond in this exact JSON format (use Hinglish for insight):
{
  "predicted_1hr": <number 0-100>,
  "predicted_2hr": <number 0-100>,
  "trend": "rising" | "falling" | "stable" | "peak",
  "insight_hindi": "<one line Hinglish insight, casual tone, like talking to a friend>",
  "best_time_to_go": "<time recommendation in Hinglish>",
  "vibe": "<one word vibe: chill/hype/dead/lit/packed>"
}

Only respond with valid JSON, nothing else.''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 256,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'];
    final prediction = jsonDecode(content);

    return CrowdPrediction(
      predicted1hr: (prediction['predicted_1hr'] as num).toInt().clamp(0, 100),
      predicted2hr: (prediction['predicted_2hr'] as num).toInt().clamp(0, 100),
      trend: prediction['trend'] ?? 'stable',
      insightHindi: prediction['insight_hindi'] ?? 'Data available nahi hai abhi',
      bestTimeToGo: prediction['best_time_to_go'] ?? '',
      vibe: prediction['vibe'] ?? 'chill',
    );
  }
}

class CrowdPrediction {
  final int predicted1hr;
  final int predicted2hr;
  final String trend;
  final String insightHindi;
  final String bestTimeToGo;
  final String vibe;

  CrowdPrediction({
    required this.predicted1hr,
    required this.predicted2hr,
    required this.trend,
    required this.insightHindi,
    required this.bestTimeToGo,
    required this.vibe,
  });
}
