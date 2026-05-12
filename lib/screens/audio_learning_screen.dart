import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioLearningScreen extends StatefulWidget {
  const AudioLearningScreen({super.key});

  @override
  State<AudioLearningScreen> createState() => _AudioLearningScreenState();
}

class _AudioLearningScreenState extends State<AudioLearningScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final TextEditingController textController = TextEditingController();

  void speakText() async {
    await flutterTts.setLanguage("en-US");

    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak(textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF5B7BFE),

        title: const Text(
          "Audio Learning",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: textController,
              maxLines: 8,

              decoration: InputDecoration(
                hintText: "Enter text to convert into audio...",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: speakText,

                icon: const Icon(Icons.volume_up),

                label: const Text("Play Audio"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7BFE),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
