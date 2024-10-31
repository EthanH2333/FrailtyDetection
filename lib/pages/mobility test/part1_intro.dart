import 'package:flutter/material.dart';
import 'package:StrideWell/pages/mobility%20test/gaitSpeedTest.dart';
import '../../helper/speak_function.dart';

class Part1_intro extends StatefulWidget {
  const Part1_intro({super.key});

  @override
  State<Part1_intro> createState() => _Part1_introState();
}

class _Part1_introState extends State<Part1_intro> {
  final SpeechService speechService = SpeechService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gait Speed Test (4-metre)'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Dynamically calculate padding and font size based on screen height
            double paddingVertical =
                constraints.maxHeight * 0.01; // Adjust padding dynamically
            double fontSize =
                constraints.maxHeight * 0.02; // Adjust font size dynamically

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildInstructionCard(
                            "1. Instruct the patient to walk at their normal pace. Patients may use an assistive device, if needed.",
                            fontSize,
                            paddingVertical),
                        _buildInstructionCard(
                            "2. Ask the patient to walk down a hallway through a 1-metre zone for acceleration, a central 4-metre 'testing' zone, and a 1-metre zone for deceleration (the patient should not start to slow down before the 4-metre mark).",
                            fontSize,
                            paddingVertical),
                        _buildInstructionCard(
                            "3. Start the timer with the first footfall after the 0-metre line.",
                            fontSize,
                            paddingVertical),
                        _buildInstructionCard(
                            "4. Stop the timer with the first footfall after the 4-metre line.",
                            fontSize,
                            paddingVertical),
                      ],
                    ),
                  ),
                  // Button at the bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GaitSpeedTest(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: Size(constraints.maxWidth * 0.9,
                            50), // Dynamic button size
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: Text(
                        "Let's Test It",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize:
                                fontSize * 1.2), // Dynamic font size for button
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper function to build instruction card with a speech icon, dynamically adjusting padding and font size
  Widget _buildInstructionCard(
      String instruction, double fontSize, double paddingVertical) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingVertical),
      child: Card(
        color: Theme.of(context)
            .colorScheme
            .secondary, // Use secondary theme color for the card background
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  instruction,
                  style: TextStyle(
                    fontSize: fontSize,
                  ), // Adjust text size dynamically
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                //color: Theme.of(context).colorScheme.onPrimary, // Change icon color for contrast
                onPressed: () {
                  speechService.speak(
                      instruction); // Call the speech service to read out the instruction
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
