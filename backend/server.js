import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import OpenAI from "openai";

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// ✅ GROQ CONFIG
const client = new OpenAI({
  apiKey: process.env.GROQ_API_KEY,
  baseURL: "https://api.groq.com/openai/v1",
});

app.get("/", (req, res) => {
  res.send("EduAccess AI backend is running");
});

// ✅ SIMPLIFY
app.post("/simplify", async (req, res) => {
  try {
    const { text } = req.body;

    if (!text || !text.trim()) {
      return res.status(400).json({ error: "Text is required" });
    }

    const response = await client.chat.completions.create({
      model: "llama-3.1-8b-instant",
      messages: [
        {
          role: "system",
          content:
            "Simplify the given educational text into very easy language for a student. Keep meaning same.",
        },
        {
          role: "user",
          content: text,
        },
      ],
    });

    res.json({
      result: response.choices[0].message.content.trim(),
    });
  } catch (error) {
    console.error("Simplify error:", error);
    res.status(500).json({
      error: error?.message || "Failed to simplify text",
    });
  }
});

// ✅ TRANSLATE
app.post("/translate", async (req, res) => {
  try {
    const { text, language } = req.body;

    if (!text || !text.trim()) {
      return res.status(400).json({ error: "Text is required" });
    }

    if (!language || !language.trim()) {
      return res.status(400).json({ error: "Language is required" });
    }

    const response = await client.chat.completions.create({
      model: "llama-3.1-8b-instant",
      messages: [
        {
          role: "system",
          content:
            "Translate the user text to the given language. Only return translated text.",
        },
        {
          role: "user",
          content: `Translate this to ${language}:\n\n${text}`,
        },
      ],
    });

    res.json({
      result: response.choices[0].message.content.trim(),
    });
  } catch (error) {
    console.error("Translate error:", error);
    res.status(500).json({
      error: error?.message || "Failed to translate text",
    });
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});