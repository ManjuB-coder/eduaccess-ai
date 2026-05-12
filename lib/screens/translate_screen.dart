import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController inputController = TextEditingController();

  final FlutterTts flutterTts = FlutterTts();

  String translatedText = "";

  bool isLoading = false;

  // 💾 SAVED TRANSLATIONS
  List<Map<String, String>> savedTranslations = [];

  // 🔑 API KEY
  final String apiKey =
      "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";

  // 🌍 LANGUAGES
  final List<String> languages = [
    "Hindi",
    "Kannada",
    "Tamil",
    "Telugu",
    "Malayalam",
    "Marathi",
    "Gujarati",
    "Punjabi",
    "Bengali",
    "Urdu",
    "French",
    "German",
    "Spanish",
    "Japanese",
    "Chinese",
    "Arabic",
    "Russian",
  ];

  String selectedLanguage = "Hindi";

  // 🌍 TRANSLATE
  Future<void> translateText() async {
    if (inputController.text.trim().isEmpty) {
      showMessage("Please enter some text");

      return;
    }

    setState(() {
      isLoading = true;

      translatedText = "";
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),

        headers: {
          "Authorization": "Bearer $apiKey",

          "Content-Type": "application/json",
        },

        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",

          "messages": [
            {
              "role": "system",

              "content":
                  "You are a professional translator. Translate the text ONLY into $selectedLanguage. Return ONLY translated text.",
            },

            {"role": "user", "content": inputController.text},
          ],

          "temperature": 0.2,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["choices"] != null) {
        String result =
            data["choices"][0]["message"]["content"] ?? "Translation failed";

        setState(() {
          translatedText = result;

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        showMessage("Translation Failed");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showMessage("API Error");
    }
  }

  // 🔊 SPEAK
  Future<void> speakTranslation() async {
    if (translatedText.isEmpty) {
      showMessage("No translated text");

      return;
    }

    Map<String, String> languageCodes = {
      "Hindi": "hi-IN",
      "Kannada": "kn-IN",
      "Tamil": "ta-IN",
      "Telugu": "te-IN",
      "Malayalam": "ml-IN",
      "Marathi": "mr-IN",
      "Gujarati": "gu-IN",
      "Punjabi": "pa-IN",
      "Bengali": "bn-IN",
      "Urdu": "ur-PK",
      "French": "fr-FR",
      "German": "de-DE",
      "Spanish": "es-ES",
      "Japanese": "ja-JP",
      "Chinese": "zh-CN",
      "Arabic": "ar-SA",
      "Russian": "ru-RU",
    };

    await flutterTts.stop();

    await flutterTts.setLanguage(languageCodes[selectedLanguage] ?? "en-US");

    await flutterTts.setSpeechRate(0.45);

    await flutterTts.speak(translatedText);
  }

  // 📋 COPY
  void copyText() {
    if (translatedText.isEmpty) {
      showMessage("Nothing to copy");

      return;
    }

    Clipboard.setData(ClipboardData(text: translatedText));

    showMessage("Copied Successfully");
  }

  // 💾 SAVE
  void saveTranslation() {
    if (translatedText.isEmpty) {
      showMessage("Nothing to save");

      return;
    }

    String title = "Translation ${savedTranslations.length + 1}";

    setState(() {
      savedTranslations.add({
        "title": title,

        "content": translatedText,

        "language": selectedLanguage,
      });
    });

    showMessage("Saved Successfully");
  }

  // 🗑 DELETE
  void deleteTranslation(int index) {
    setState(() {
      savedTranslations.removeAt(index);
    });

    showMessage("Deleted Successfully");
  }

  // ✏ RENAME
  void renameTranslation(int index) {
    TextEditingController controller = TextEditingController(
      text: savedTranslations[index]["title"],
    );

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Rename Translation"),

          content: TextField(controller: controller),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  savedTranslations[index]["title"] = controller.text;
                });

                Navigator.pop(context);
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // 📖 OPEN
  void openTranslation(Map<String, String> note) {
    showDialog(
      context: context,

      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),

            height: 500,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  note["title"] ?? "",

                  style: const TextStyle(
                    fontSize: 24,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(note["language"] ?? ""),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      note["content"] ?? "",

                      style: const TextStyle(fontSize: 16, height: 1.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 💬 MESSAGE
  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // 🎨 BUTTON
  Widget customButton({
    required VoidCallback onPressed,

    required IconData icon,

    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton.icon(
        onPressed: onPressed,

        icon: Icon(icon),

        label: Text(text),

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B7BFE),

          foregroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF5B7BFE),

        elevation: 0,

        title: const Text(
          "Translate Lesson",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          // 🔊 SPEAK
          IconButton(
            onPressed: speakTranslation,

            icon: const Icon(Icons.volume_up, color: Colors.white),
          ),

          // 📋 COPY
          IconButton(
            onPressed: copyText,

            icon: const Icon(Icons.copy, color: Colors.white),
          ),

          // 💾 SAVE
          IconButton(
            onPressed: saveTranslation,

            icon: const Icon(Icons.bookmark_add, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // 📝 TITLE
            const Text(
              "AI Translator",

              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Translate lessons into multiple languages.",

              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 25),

            // 📄 INPUT
            Container(
              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),

                    blurRadius: 10,
                  ),
                ],
              ),

              child: TextField(
                controller: inputController,

                maxLines: 8,

                decoration: InputDecoration(
                  hintText: "Enter text to translate...",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),

                    borderSide: BorderSide.none,
                  ),

                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🌍 LANGUAGE DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),

                    blurRadius: 8,
                  ),
                ],
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLanguage,

                  isExpanded: true,

                  items: languages.map((language) {
                    return DropdownMenuItem(
                      value: language,

                      child: Text(language),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🔥 TRANSLATE BUTTON
            customButton(
              onPressed: translateText,

              icon: Icons.translate,

              text: "Translate",
            ),

            const SizedBox(height: 30),

            // 📖 OUTPUT
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),

                    blurRadius: 10,
                  ),
                ],
              ),

              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),

                      child: Center(child: CircularProgressIndicator()),
                    )
                  : translatedText.isEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 20),

                        Icon(
                          Icons.translate,

                          size: 90,

                          color: Colors.grey.shade300,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Translated text will appear here",

                          style: TextStyle(
                            fontSize: 17,

                            color: Colors.grey.shade500,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.language,

                              color: Color(0xFF5B7BFE),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              "Translated to $selectedLanguage",

                              style: const TextStyle(
                                fontSize: 20,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SelectableText(
                          translatedText,

                          style: const TextStyle(fontSize: 16, height: 1.8),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 30),

            // 💾 SAVED TRANSLATIONS
            if (savedTranslations.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Saved Translations",

                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  ListView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: savedTranslations.length,

                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          openTranslation(savedTranslations[index]);
                        },

                        child: Container(
                          margin: const EdgeInsets.only(bottom: 18),

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(22),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),

                                blurRadius: 8,
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.language,

                                    color: Color(0xFF5B7BFE),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      savedTranslations[index]["title"] ?? "",

                                      style: const TextStyle(
                                        fontSize: 18,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              Text(
                                savedTranslations[index]["content"] ?? "",

                                maxLines: 4,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(height: 1.6),
                              ),

                              const SizedBox(height: 18),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,

                                children: [
                                  // ✏ RENAME
                                  IconButton(
                                    onPressed: () {
                                      renameTranslation(index);
                                    },

                                    icon: const Icon(
                                      Icons.edit,

                                      color: Colors.orange,
                                    ),
                                  ),

                                  // 📋 COPY
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              savedTranslations[index]["content"] ??
                                              "",
                                        ),
                                      );

                                      showMessage("Copied Successfully");
                                    },

                                    icon: const Icon(
                                      Icons.copy,

                                      color: Color(0xFF5B7BFE),
                                    ),
                                  ),

                                  // 🗑 DELETE
                                  IconButton(
                                    onPressed: () {
                                      deleteTranslation(index);
                                    },

                                    icon: const Icon(
                                      Icons.delete,

                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
