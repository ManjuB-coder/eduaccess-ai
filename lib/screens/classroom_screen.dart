import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/ai_service.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  stt.SpeechToText speech = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();

  bool isListening = false;
  bool isLoading = false;

  String lectureText = "Press Start Listening and speak...";
  String selectedLanguage = "English";

  final List<String> languages = [
    "Hindi",
    "Kannada",
    "Tamil",
    "Telugu",
    "Malayalam",
    "Marathi",
    "Bengali",
    "English",
    "Urdu",
    "Gujarati",
  ];

  final Map<String, String> languageCodes = {
    "English": "en-US",
    "Hindi": "hi-IN",
    "Kannada": "kn-IN",
    "Tamil": "ta-IN",
    "Telugu": "te-IN",
    "Malayalam": "ml-IN",
    "Marathi": "mr-IN",
    "Bengali": "bn-IN",
    "Urdu": "ur-IN",
    "Gujarati": "gu-IN",
  };

  void startListening() async {
    if (!isListening) {
      bool available = await speech.initialize();

      if (available) {
        setState(() => isListening = true);

        speech.listen(
          onResult: (result) {
            setState(() {
              lectureText = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  void simplifyText() async {
    try {
      setState(() => isLoading = true);

      String simplified = await AIService.simplifyText(lectureText);

      setState(() {
        lectureText = simplified;
      });
    } catch (e) {
      showError("Failed to simplify text");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void translateText(String language) async {
    try {
      setState(() => isLoading = true);

      String translated = await AIService.translateText(lectureText, language);

      setState(() {
        lectureText = translated;
        selectedLanguage = language;
      });
    } catch (e) {
      showError("Translation failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void simplifyAndTranslate(String language) async {
    try {
      setState(() => isLoading = true);

      String simplified = await AIService.simplifyText(lectureText);
      String translated = await AIService.translateText(simplified, language);

      setState(() {
        lectureText = translated;
        selectedLanguage = language;
      });
    } catch (e) {
      showError("Operation failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void speakText() async {
    try {
      String langCode = languageCodes[selectedLanguage] ?? "en-US";

      await flutterTts.setLanguage(langCode);
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);

      await flutterTts.stop();
      await flutterTts.speak(lectureText);
    } catch (e) {
      showError("TTS not supported for this language");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void openLanguageSheet({bool combined = false}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];

              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(
                  lang,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  combined ? "Simplify + Translate" : "Translate to $lang",
                ),
                onTap: () {
                  Navigator.pop(context);

                  if (combined) {
                    simplifyAndTranslate(lang);
                  } else {
                    translateText(lang);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Classroom")),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: SingleChildScrollView(
                    child: Text(
                      lectureText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.mic),
                      label: Text(
                        isListening ? "Stop Listening" : "Start Listening",
                      ),
                      onPressed: startListening,
                    ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.menu_book),
                      label: const Text("Simplify"),
                      onPressed: simplifyText,
                    ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.translate),
                      label: const Text("Translate"),
                      onPressed: () => openLanguageSheet(),
                    ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text("Simplify + Translate"),
                      onPressed: () => openLanguageSheet(combined: true),
                    ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up),
                      label: const Text("Speak"),
                      onPressed: speakText,
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
