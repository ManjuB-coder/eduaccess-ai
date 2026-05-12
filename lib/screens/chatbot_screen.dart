import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final FlutterTts flutterTts = FlutterTts();

  final SpeechToText speechToText = SpeechToText();

  bool isLoading = false;
  bool isListening = false;
  bool isDarkMode = false;

  String extractedPDFText = "";

  // 🔑 API KEY
  final String apiKey =
      "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";

  // 💬 CHAT MEMORY
  List<Map<String, String>> messages = [];

  // 🧠 QUIZ DATA
  List<Map<String, dynamic>> quizQuestions = [];

  Map<int, int> selectedAnswers = {};

  // 🎤 START LISTENING
  Future<void> startListening() async {
    bool available = await speechToText.initialize();

    if (available) {
      setState(() {
        isListening = true;
      });

      speechToText.listen(
        onResult: (result) {
          setState(() {
            messageController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  // 🛑 STOP LISTENING
  Future<void> stopListening() async {
    await speechToText.stop();

    setState(() {
      isListening = false;
    });
  }

  // 📄 PICK PDF
  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      Uint8List? bytes = result.files.first.bytes;

      if (bytes != null) {
        extractPDFText(bytes);
      }
    }
  }

  // 📄 EXTRACT PDF
  void extractPDFText(Uint8List bytes) {
    PdfDocument document = PdfDocument(inputBytes: bytes);

    String text = PdfTextExtractor(document).extractText();

    document.dispose();

    setState(() {
      extractedPDFText = text;
    });

    showMessage("PDF Uploaded Successfully");
  }

  // 🤖 SEND MESSAGE
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    String userMessage = messageController.text;

    setState(() {
      messages.add({"role": "user", "message": userMessage});

      isLoading = true;
    });

    messageController.clear();

    scrollToBottom();

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
                  "You are EduAccess AI, a smart educational assistant for students. If PDF content is available, answer from the PDF context. PDF Context: $extractedPDFText",
            },

            // 🔥 CHAT MEMORY
            ...messages.map(
              (msg) => {"role": msg["role"], "content": msg["message"]},
            ),
          ],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["choices"] != null) {
        String aiReply =
            data["choices"][0]["message"]["content"] ?? "No response";

        setState(() {
          messages.add({"role": "assistant", "message": aiReply});

          isLoading = false;
        });

        // 🔊 SPEAK AI RESPONSE
        await flutterTts.speak(aiReply);

        scrollToBottom();
      } else {
        setState(() {
          isLoading = false;
        });

        showMessage("Failed to get response");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showMessage("API Error");
    }
  }

  // 🧠 GENERATE QUIZ
  Future<void> generateQuiz() async {
    if (extractedPDFText.isEmpty) {
      showMessage("Please upload PDF first");

      return;
    }

    setState(() {
      isLoading = true;

      quizQuestions.clear();

      selectedAnswers.clear();
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

              "content": """
Generate 5 multiple choice questions from the study material.

Return ONLY valid JSON format like this:

[
  {
    "question": "What is AI?",
    "options": [
      "Robot",
      "Machine Learning",
      "Artificial Intelligence",
      "Computer"
    ],
    "answer": 2
  }
]
""",
            },

            {"role": "user", "content": extractedPDFText},
          ],
        }),
      );

      final data = jsonDecode(response.body);

      String quizText = data["choices"][0]["message"]["content"];

      quizText = quizText.replaceAll("```json", "").replaceAll("```", "");

      List<dynamic> decodedQuiz = jsonDecode(quizText);

      setState(() {
        quizQuestions = decodedQuiz
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        isLoading = false;
      });

      showMessage("Quiz Generated");
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showMessage("Quiz Generation Failed");
    }
  }

  // 📜 SCROLL
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,

          duration: const Duration(milliseconds: 300),

          curve: Curves.easeOut,
        );
      }
    });
  }

  // 💬 MESSAGE
  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // 🧹 CLEAR CHAT
  void clearChat() {
    setState(() {
      messages.clear();

      quizQuestions.clear();

      selectedAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF111827)
          : const Color(0xFFF5F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF5B7BFE),

        elevation: 0,

        title: const Text(
          "EduAccess AI Chatbot",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          // 🌙 DARK MODE
          IconButton(
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },

            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,

              color: Colors.white,
            ),
          ),

          // 📄 PDF
          IconButton(
            onPressed: pickPDF,

            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          ),

          // 🧠 QUIZ
          IconButton(
            onPressed: generateQuiz,

            icon: const Icon(Icons.quiz, color: Colors.white),
          ),

          // 🧹 CLEAR
          IconButton(
            onPressed: clearChat,

            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),

      body: Column(
        children: [
          // 💬 CHAT AREA
          Expanded(
            child: ListView(
              controller: scrollController,

              padding: const EdgeInsets.all(16),

              children: [
                // 💬 MESSAGES
                ...messages.map((message) {
                  bool isUser = message["role"] == "user";

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),

                      padding: const EdgeInsets.all(16),

                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),

                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF5B7BFE)
                            : isDarkMode
                            ? const Color(0xFF1F2937)
                            : Colors.white,

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Text(
                        message["message"] ?? "",

                        style: TextStyle(
                          fontSize: 15,

                          height: 1.5,

                          color: isUser
                              ? Colors.white
                              : isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),

                // 🧠 QUIZ AREA
                if (quizQuestions.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: quizQuestions.length,

                    itemBuilder: (context, index) {
                      final quiz = quizQuestions[index];

                      List options = quiz["options"];

                      int correctAnswer = quiz["answer"];

                      return Container(
                        margin: const EdgeInsets.all(12),

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1F2937)
                              : Colors.white,

                          borderRadius: BorderRadius.circular(22),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Q${index + 1}. ${quiz["question"]}",

                              style: TextStyle(
                                fontSize: 17,

                                fontWeight: FontWeight.bold,

                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),

                            const SizedBox(height: 18),

                            ...List.generate(options.length, (optionIndex) {
                              bool answered = selectedAnswers.containsKey(
                                index,
                              );

                              bool isCorrect = optionIndex == correctAnswer;

                              bool isSelected =
                                  selectedAnswers[index] == optionIndex;

                              Color optionColor = Colors.grey.shade200;

                              if (answered) {
                                if (isCorrect) {
                                  optionColor = Colors.green;
                                } else if (isSelected) {
                                  optionColor = Colors.red;
                                }
                              }

                              return GestureDetector(
                                onTap: answered
                                    ? null
                                    : () {
                                        setState(() {
                                          selectedAnswers[index] = optionIndex;
                                        });
                                      },

                                child: Container(
                                  width: double.infinity,

                                  margin: const EdgeInsets.only(bottom: 12),

                                  padding: const EdgeInsets.all(14),

                                  decoration: BoxDecoration(
                                    color: optionColor,

                                    borderRadius: BorderRadius.circular(14),
                                  ),

                                  child: Text(
                                    options[optionIndex],

                                    style: TextStyle(
                                      fontSize: 15,

                                      color: answered
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }),

                            if (selectedAnswers.containsKey(index))
                              Padding(
                                padding: const EdgeInsets.only(top: 10),

                                child: Text(
                                  selectedAnswers[index] == correctAnswer
                                      ? "✅ Correct Answer"
                                      : "❌ Correct Answer: ${options[correctAnswer]}",

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // 🤖 LOADING
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),

              child: CircularProgressIndicator(),
            ),

          // ✍ INPUT AREA
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,

              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
              ],
            ),

            child: Row(
              children: [
                // 🎤 MIC
                GestureDetector(
                  onTap: () {
                    if (isListening) {
                      stopListening();
                    } else {
                      startListening();
                    }
                  },

                  child: Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: isListening ? Colors.red : const Color(0xFF5B7BFE),

                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,

                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // ✍ TEXTFIELD
                Expanded(
                  child: TextField(
                    controller: messageController,

                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),

                    decoration: InputDecoration(
                      hintText: "Ask something...",

                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey,
                      ),

                      filled: true,

                      fillColor: isDarkMode
                          ? const Color(0xFF111827)
                          : const Color(0xFFF3F6FF),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 🚀 SEND
                GestureDetector(
                  onTap: sendMessage,

                  child: Container(
                    padding: const EdgeInsets.all(15),

                    decoration: const BoxDecoration(
                      color: Color(0xFF5B7BFE),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
