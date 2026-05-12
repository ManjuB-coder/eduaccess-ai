import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SimplifyScreen extends StatefulWidget {
  const SimplifyScreen({super.key});

  @override
  State<SimplifyScreen> createState() => _SimplifyScreenState();
}

class _SimplifyScreenState extends State<SimplifyScreen> {
  final TextEditingController inputController = TextEditingController();

  final FlutterTts flutterTts = FlutterTts();

  String simplifiedText = "";

  bool isLoading = false;

  // 💾 SAVED NOTES
  List<Map<String, String>> savedNotes = [];

  // 🔑 API KEY
  final String apiKey = "";

  // 📄 PICK PDF
  Future<void> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;

        if (fileBytes != null) {
          extractTextFromPDF(fileBytes);
        }
      }
    } catch (e) {
      showMessage("PDF Upload Failed");
    }
  }

  // 📄 EXTRACT PDF
  Future<void> extractTextFromPDF(Uint8List bytes) async {
    try {
      setState(() {
        isLoading = true;
      });

      PdfDocument document = PdfDocument(inputBytes: bytes);

      String text = PdfTextExtractor(document).extractText();

      document.dispose();

      inputController.text = text;

      await simplifyText();
    } catch (e) {
      showMessage("PDF Reading Failed");

      setState(() {
        isLoading = false;
      });
    }
  }

  // 🧠 SIMPLIFY
  Future<void> simplifyText() async {
    if (inputController.text.trim().isEmpty) {
      showMessage("Please enter some text");

      return;
    }

    setState(() {
      isLoading = true;

      simplifiedText = "";
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
You are an educational AI assistant.

Simplify the study material.

Provide:
1. Easy Explanation
2. Summary
3. Important Points
4. Exam Notes
5. Quick Revision Notes

Keep language:
- simple
- easy
- student friendly
""",
            },

            {"role": "user", "content": inputController.text},
          ],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["choices"] != null) {
        String result =
            data["choices"][0]["message"]["content"] ?? "No response";

        setState(() {
          simplifiedText = result;

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        showMessage("Invalid API Response");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showMessage("API Error");
    }
  }

  // 🔊 SPEAK
  Future<void> speakText() async {
    if (simplifiedText.isEmpty) {
      showMessage("No simplified text available");

      return;
    }

    await flutterTts.stop();

    await flutterTts.setSpeechRate(0.45);

    await flutterTts.speak(simplifiedText);
  }

  // 📋 COPY
  void copyText() {
    if (simplifiedText.isEmpty) {
      showMessage("Nothing to copy");

      return;
    }

    Clipboard.setData(ClipboardData(text: simplifiedText));

    showMessage("Copied Successfully");
  }

  // 💾 SAVE NOTE
  void saveNote() {
    if (simplifiedText.isEmpty) {
      showMessage("Nothing to save");

      return;
    }

    String title = "Note ${savedNotes.length + 1}";

    setState(() {
      savedNotes.add({"title": title, "content": simplifiedText});
    });

    showMessage("Saved Successfully");
  }

  // 🗑 DELETE NOTE
  void deleteNote(int index) {
    setState(() {
      savedNotes.removeAt(index);
    });

    showMessage("Deleted Successfully");
  }

  // ✏ RENAME NOTE
  void renameNote(int index) {
    TextEditingController renameController = TextEditingController(
      text: savedNotes[index]["title"],
    );

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Rename Note"),

          content: TextField(controller: renameController),

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
                  savedNotes[index]["title"] = renameController.text;
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

  // 📖 OPEN NOTE
  void openSavedNote(Map<String, String> note) {
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
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,

        icon: Icon(icon),

        label: Text(text),

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B7BFE),

          foregroundColor: Colors.white,

          elevation: 0,

          padding: const EdgeInsets.symmetric(vertical: 15),

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
          "Simplify Learning",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          // 🔊 SPEAK
          IconButton(
            onPressed: speakText,

            icon: const Icon(Icons.volume_up, color: Colors.white),
          ),

          // 📋 COPY
          IconButton(
            onPressed: copyText,

            icon: const Icon(Icons.copy, color: Colors.white),
          ),

          // 💾 SAVE
          IconButton(
            onPressed: saveNote,

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
              "AI Study Simplifier",

              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Convert difficult study material into simple notes.",

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

                maxLines: 10,

                decoration: InputDecoration(
                  hintText: "Paste notes or upload PDF...",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),

                    borderSide: BorderSide.none,
                  ),

                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 BUTTONS
            Row(
              children: [
                customButton(
                  onPressed: pickPDF,

                  icon: Icons.picture_as_pdf,

                  text: "Upload PDF",
                ),

                const SizedBox(width: 14),

                customButton(
                  onPressed: simplifyText,

                  icon: Icons.auto_awesome,

                  text: "Simplify",
                ),
              ],
            ),

            const SizedBox(height: 28),

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
                  : simplifiedText.isEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 30),

                        Icon(
                          Icons.auto_stories_rounded,

                          size: 90,

                          color: Colors.grey.shade300,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Simplified notes will appear here",

                          style: TextStyle(
                            fontSize: 17,

                            color: Colors.grey.shade500,
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    )
                  : SelectableText(
                      simplifiedText,

                      style: const TextStyle(fontSize: 16, height: 1.8),
                    ),
            ),

            const SizedBox(height: 30),

            // 💾 SAVED NOTES
            if (savedNotes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Saved Notes",

                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  ListView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: savedNotes.length,

                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          openSavedNote(savedNotes[index]);
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
                                    Icons.bookmark,

                                    color: Color(0xFF5B7BFE),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      savedNotes[index]["title"] ?? "",

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
                                savedNotes[index]["content"] ?? "",

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
                                      renameNote(index);
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
                                              savedNotes[index]["content"] ??
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
                                      deleteNote(index);
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
