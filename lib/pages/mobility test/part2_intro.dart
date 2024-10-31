import 'package:flutter/material.dart';
import 'package:frailtyapp/helper/speak_function.dart';
import 'package:frailtyapp/pages/mobility%20test/TUGTest.dart';

class Part2_intro extends StatefulWidget {
  const Part2_intro({super.key});

  @override
  State<Part2_intro> createState() => _Part2_introState();
}

class _Part2_introState extends State<Part2_intro> {
  final SpeechService speechService = SpeechService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timed Up and Go (TUG) Test'),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          double paddingVertical = constraints.maxHeight * 0.01;
          double fontSize = constraints.maxHeight * 0.02;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInstructionCard(
                    "1. Sit back in a chair and point to a line 3 metres away on the floor."),
                _buildInstructionCard("2. Start the timer when I say 'Go'."),
                _buildInstructionCard(
                    "3. Walk to the line, turn, and come back."),
                _buildInstructionCard(
                    "4. Sit back in the chair, and I'll stop the timer."),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: Size(
                        constraints.maxWidth * 0.9, 50), // Dynamic button size
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TUGTest()),
                    );
                  },
                  child: Text(
                    "Let's Test It",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize:
                            fontSize * 1.2), // Dynamic font size for button
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInstructionCard(String instruction) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                instruction,
                style: TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () {
                speechService.speak(instruction);
              },
            ),
          ],
        ),
      ),
    );
  }
}
