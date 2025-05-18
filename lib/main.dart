// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TTS Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TextToSpeechScreen(),
    );
  }
}

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textEditingController = TextEditingController();
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  String? language;
  List<String> languages = [];
  String? voice;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    // Set up TTS engine
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(rate);

    // Get available languages
    try {
      languages = List<String>.from(await flutterTts.getLanguages);
      if (languages.isNotEmpty) {
        await flutterTts.setLanguage(languages.first);
        language = languages.first;
      }
    } catch (e) {
      print('Error getting languages: $e');
    }

    // Set up completion handler
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
  }

  Future<void> speak() async {
    if (textEditingController.text.isNotEmpty) {
      setState(() {
        isPlaying = true;
      });
      await flutterTts.speak(textEditingController.text);
    }
  }

  Future<void> stop() async {
    setState(() {
      isPlaying = false;
    });
    await flutterTts.stop();
  }

  @override
  void dispose() {
    flutterTts.stop();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text to Speech'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: textEditingController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter text to convert to speech',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),

            // Language selection
            if (languages.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Language',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: language,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items:
                            languages.map((String lang) {
                              return DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              );
                            }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            language = value;
                            flutterTts.setLanguage(value!);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Speech parameters
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Speech Parameters',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Volume slider
                    Row(
                      children: [
                        const SizedBox(width: 80, child: Text('Volume:')),
                        Expanded(
                          child: Slider(
                            value: volume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: volume.toString(),
                            onChanged: (value) {
                              setState(() {
                                volume = value;
                              });
                              flutterTts.setVolume(value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(volume.toStringAsFixed(1)),
                        ),
                      ],
                    ),

                    // Pitch slider
                    Row(
                      children: [
                        const SizedBox(width: 80, child: Text('Pitch:')),
                        Expanded(
                          child: Slider(
                            value: pitch,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: pitch.toString(),
                            onChanged: (value) {
                              setState(() {
                                pitch = value;
                              });
                              flutterTts.setPitch(value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(pitch.toStringAsFixed(1)),
                        ),
                      ],
                    ),

                    // Rate slider
                    Row(
                      children: [
                        const SizedBox(width: 80, child: Text('Rate:')),
                        Expanded(
                          child: Slider(
                            value: rate,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            label: rate.toString(),
                            onChanged: (value) {
                              setState(() {
                                rate = value;
                              });
                              flutterTts.setSpeechRate(value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(rate.toStringAsFixed(1)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Play button
            ElevatedButton.icon(
              onPressed: isPlaying ? stop : speak,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? 'Stop' : 'Speak'),
            ),
          ],
        ),
      ),
    );
  }
}
