import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LiveLectureScreen extends StatefulWidget {
  const LiveLectureScreen({super.key});

  @override
  State<LiveLectureScreen> createState() => _LiveLectureScreenState();
}

class _LiveLectureScreenState extends State<LiveLectureScreen> {
  final stt.SpeechToText speech = stt.SpeechToText();

  bool isListening = false;

  String spokenText = "Tap the microphone and start speaking...";

  // 🎤 START LISTENING
  void startListening() async {
    bool available = await speech.initialize();

    if (available) {
      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            spokenText = result.recognizedWords;
          });
        },
      );
    }
  }

  // 🛑 STOP LISTENING
  void stopListening() async {
    await speech.stop();

    setState(() {
      isListening = false;
    });
  }

  // 📋 COPY TEXT
  void copyText() {
    Clipboard.setData(ClipboardData(text: spokenText));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Text copied successfully")));
  }

  // 💾 SAVE LECTURE
  void saveLectureDialog() {
    final subjectController = TextEditingController();

    final topicController = TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text("Save Lecture"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: subjectController,

                decoration: const InputDecoration(labelText: "Subject Name"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: topicController,

                decoration: const InputDecoration(labelText: "Topic Name"),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                if (subjectController.text.isEmpty ||
                    topicController.text.isEmpty) {
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;

                  await FirebaseFirestore.instance
                      .collection("lecture_notes")
                      .add({
                        "userId": user?.uid,

                        "subject": subjectController.text.trim(),

                        "topic": topicController.text.trim(),

                        "content": spokenText,

                        "createdAt": Timestamp.now(),
                      });

                  if (!mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lecture saved successfully")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B7BFE),
              ),

              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 📖 OPEN SAVED NOTE
  void openSavedLecture(String content) {
    setState(() {
      spokenText = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF5B7BFE),

        elevation: 0,

        title: const Text(
          "Live Lecture",
          style: TextStyle(color: Colors.white),
        ),

        actions: [
          // 📋 COPY BUTTON
          IconButton(
            onPressed: copyText,

            icon: const Icon(Icons.copy_rounded, color: Colors.white),
          ),

          // 💾 SAVE BUTTON
          IconButton(
            onPressed: saveLectureDialog,

            icon: const Icon(Icons.save_rounded, color: Colors.white),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // 🎤 MICROPHONE CARD
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B9BFF), Color(0xFF5B7BFE)],
                ),

                borderRadius: BorderRadius.circular(28),
              ),

              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isListening) {
                        stopListening();
                      } else {
                        startListening();
                      }
                    },

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      height: isListening ? 95 : 85,

                      width: isListening ? 95 : 85,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),

                            blurRadius: 12,
                          ),
                        ],
                      ),

                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,

                        size: 42,

                        color: const Color(0xFF5B7BFE),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    isListening ? "Listening..." : "Tap microphone to start",

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 18,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📄 LIVE TEXT OUTPUT
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),

                      blurRadius: 10,
                    ),
                  ],
                ),

                child: SingleChildScrollView(
                  child: Text(
                    spokenText,

                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📚 SAVED LECTURES
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved Lectures",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("lecture_notes")
                    .where("userId", isEqualTo: user?.uid)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final lectures = snapshot.data!.docs;

                  if (lectures.isEmpty) {
                    return const Center(child: Text("No saved lectures yet"));
                  }

                  return ListView.builder(
                    itemCount: lectures.length,

                    itemBuilder: (context, index) {
                      final lecture = lectures[index];

                      return GestureDetector(
                        onTap: () {
                          openSavedLecture(lecture["content"]);
                        },

                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(20),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),

                                blurRadius: 8,
                              ),
                            ],
                          ),

                          child: Row(
                            children: [
                              // 📘 ICON
                              Container(
                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF5B7BFE,
                                  ).withValues(alpha: 0.12),

                                  shape: BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.menu_book,
                                  color: Color(0xFF5B7BFE),
                                ),
                              ),

                              const SizedBox(width: 15),

                              // 📄 DETAILS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      lecture["subject"],

                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      lecture["topic"],

                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ⚙️ OPTIONS
                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,

                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25),
                                      ),
                                    ),

                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20),

                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,

                                          children: [
                                            // 📖 OPEN
                                            ListTile(
                                              leading: const Icon(
                                                Icons.open_in_new,
                                                color: Color(0xFF5B7BFE),
                                              ),

                                              title: const Text("Open Lecture"),

                                              onTap: () {
                                                Navigator.pop(context);

                                                openSavedLecture(
                                                  lecture["content"],
                                                );
                                              },
                                            ),

                                            // ✏️ RENAME
                                            ListTile(
                                              leading: const Icon(
                                                Icons.edit_rounded,
                                                color: Colors.orange,
                                              ),

                                              title: const Text(
                                                "Rename Lecture",
                                              ),

                                              onTap: () {
                                                Navigator.pop(context);

                                                final subjectController =
                                                    TextEditingController(
                                                      text: lecture["subject"],
                                                    );

                                                final topicController =
                                                    TextEditingController(
                                                      text: lecture["topic"],
                                                    );

                                                showDialog(
                                                  context: context,

                                                  builder: (context) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),

                                                      title: const Text(
                                                        "Rename Lecture",
                                                      ),

                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,

                                                        children: [
                                                          TextField(
                                                            controller:
                                                                subjectController,

                                                            decoration:
                                                                const InputDecoration(
                                                                  labelText:
                                                                      "Subject",
                                                                ),
                                                          ),

                                                          const SizedBox(
                                                            height: 15,
                                                          ),

                                                          TextField(
                                                            controller:
                                                                topicController,

                                                            decoration:
                                                                const InputDecoration(
                                                                  labelText:
                                                                      "Topic",
                                                                ),
                                                          ),
                                                        ],
                                                      ),

                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },

                                                          child: const Text(
                                                            "Cancel",
                                                          ),
                                                        ),

                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                  "lecture_notes",
                                                                )
                                                                .doc(lecture.id)
                                                                .update({
                                                                  "subject":
                                                                      subjectController
                                                                          .text
                                                                          .trim(),

                                                                  "topic":
                                                                      topicController
                                                                          .text
                                                                          .trim(),
                                                                });

                                                            if (!mounted) {
                                                              return;
                                                            }

                                                            Navigator.pop(
                                                              context,
                                                            );

                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  "Lecture updated",
                                                                ),
                                                              ),
                                                            );
                                                          },

                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    const Color(
                                                                      0xFF5B7BFE,
                                                                    ),
                                                              ),

                                                          child: const Text(
                                                            "Save",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),

                                            // 🗑 DELETE
                                            ListTile(
                                              leading: const Icon(
                                                Icons.delete_rounded,
                                                color: Colors.red,
                                              ),

                                              title: const Text(
                                                "Delete Lecture",
                                              ),

                                              onTap: () async {
                                                Navigator.pop(context);

                                                await FirebaseFirestore.instance
                                                    .collection("lecture_notes")
                                                    .doc(lecture.id)
                                                    .delete();

                                                if (!mounted) return;

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Lecture deleted",
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },

                                icon: const Icon(Icons.more_vert_rounded),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
