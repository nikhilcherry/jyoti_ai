
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jyoti_ai/models/models.dart';

/// App AI service using Gemini 2.5 Flash.
class JyotiService {

  /// Call Gemini 2.5 Flash for chat response
  static Future<ChatMessage> getAIResponse(
    String userMessage,
    UserProfile user,
    List<ChatMessage> history,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return ChatMessage(
        text: 'System: API key not found in .env file. Please ask the developer to configure the GEMINI_API_KEY.',
        isUser: false,
        timestamp: DateTime.now(),
        totalTokens: 0,
      );
    }

    final systemPrompt = '''
You are Jyoti, a wise 100% AI-powered Vedic astrologer. 
Follow these STRICT rules:
1. Max 8-10 lines per response. No exceptions.
2. Ground your response in astrology, but speak naturally like a trusted friend. 
   Do not explain astrology theory.
3. Respond in the user's language (Target: ${user.language}). 
4. End your response with exactly ONE remedy (color, number, mantra, or food).
5. Add relevant emojis.
User Context: Name=${user.name}, Rashi=${user.rashi.label}, DOB=${user.dateOfBirth.toIso8601String().split('T')[0]}, Time=${user.timeOfBirth}, Place=${user.placeOfBirth}.
''';

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    // Convert our internal ChatMessage history to Gemini Content format
    // (Note: The last message in history is the user's current message, 
    // because provider adds it before calling this method)
    final prompt = history.map((msg) {
      if (msg.isUser) {
        return Content.text(msg.text);
      } else {
        return Content.model([TextPart(msg.text)]);
      }
    }).toList();

    // If for some reason the history is empty, add the userMessage manually
    if (prompt.isEmpty) {
      prompt.add(Content.text(userMessage));
    }

    try {
      final response = await model.generateContent(prompt);
      final text = response.text ?? 'I sense some cosmic interference...';
      final usage = response.usageMetadata;
      final totalTokens = usage?.totalTokenCount ?? 50;

      return ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        totalTokens: totalTokens,
      );
    } catch (e) {
      return ChatMessage(
        text: 'Maaf kijiye, abhi thoda issue aa raha hai: $e',
        isUser: false,
        timestamp: DateTime.now(),
        totalTokens: 0,
      );
    }
  }

  /// Get today's daily reading for a rashi
  static Future<DailyReading> getDailyReading(Rashi rashi) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _generateMockReading(rashi);
  }

  /// Get today's panchang
  static Future<PanchangData> getPanchang() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return PanchangData(
      tithi: 'Shukla Dashami',
      nakshatra: 'Hasta',
      yoga: 'Siddha',
      karana: 'Bava',
      rahuKaal: '10:30 AM – 12:00 PM',
      gulikaKaal: '07:30 AM – 09:00 AM',
      sunrise: '06:28 AM',
      sunset: '06:34 PM',
      date: DateTime.now(),
    );
  }

  static DailyReading _generateMockReading(Rashi rashi) {
    final readings = {
      Rashi.mesha: DailyReading(
        rashi: rashi,
        summary:
            'Aaj Mars aapki rashi mein strong hai. Career mein ek unexpected opportunity aa sakti hai subah 10 baje ke baad. Financial decisions dopahar ke baad lo — clarity zyada milegi. Kisi purani baat ka resolution hoga aaj. Apni energy ko focused rakho, distractions se bachke.',
        luckyColor: 'Red',
        luckyNumber: 9,
        remedy:
            '🙏 Aaj subah Hanuman Chalisa ka ek paath karo — confidence boost milega.',
        favorableTime: '10:00 AM – 1:00 PM',
        date: DateTime.now(),
        overallScore: 4.2,
      ),
      Rashi.vrishabha: DailyReading(
        rashi: rashi,
        summary:
            'Venus aaj aapke paksh mein hai — relationships mein warmth badhegi. Financial matters mein cautious raho, especially evening ke baad. Health stable hai but hydration ka dhyaan rakho. Creative kaam aaj zyada productive hoga.',
        luckyColor: 'Green',
        luckyNumber: 6,
        remedy:
            '🌿 Aaj shaam ko tulsi ke paas diya jalao — peace of mind milega.',
        favorableTime: '2:00 PM – 5:00 PM',
        date: DateTime.now(),
        overallScore: 3.8,
      ),
      Rashi.mithuna: DailyReading(
        rashi: rashi,
        summary:
            'Mercury retrograde ka asar khatam ho raha hai. Communication mein clarity aa rahi hai. Pending messages ka reply aaj zaroor karo. Study ya learning ke liye best din hai. Travel plans banana shuru kar sakte ho.',
        luckyColor: 'Yellow',
        luckyNumber: 5,
        remedy:
            '📿 Aaj Om Budhaya Namaha ka 11 baar jaap karo — mind sharp hoga.',
        favorableTime: '11:00 AM – 2:00 PM',
        date: DateTime.now(),
        overallScore: 4.0,
      ),
    };

    return readings[rashi] ??
        DailyReading(
          rashi: rashi,
          summary:
              'Aaj ka din aapke liye balanced hai. Professional life mein steady progress hoga. Apne health pe focus karo — subah ki walk energy boost degi. Kisi close friend se achi khabar mil sakti hai dopahar ke baad. Financial planning ke liye accha waqt hai.',
          luckyColor: 'Blue',
          luckyNumber: 7,
          remedy: '🕉️ Aaj shaam ko 5 minute meditation karo — clarity milegi.',
          favorableTime: '9:00 AM – 12:00 PM',
          date: DateTime.now(),
          overallScore: 3.5,
        );
  }

}
