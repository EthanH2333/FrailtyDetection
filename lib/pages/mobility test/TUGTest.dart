import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frailtyapp/helper/speak_function.dart';
import 'package:frailtyapp/pages/home_page.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart'; // For accelerometer
import 'dart:math';

class TUGTest extends StatefulWidget {
  const TUGTest({super.key});

  @override
  State<TUGTest> createState() => _TUGTestState();
}

class _TUGTestState extends State<TUGTest> {
  final SpeechService speechService = SpeechService();
  Timer? _timer;
  int seconds = 0;
  double totalTime = 0.0; // Store total time
  DateTime? startTime;
  bool testInProgress = false;
  bool isCountingDown = false;
  bool testCompleted = false;
  bool hasTurnedAround = false;
  int testAttempt = 1;

  // Variables for test results
  double firstTestTime = 0.0;
  double secondTestTime = 0.0;

  // Real sensor data
  StreamSubscription? accelerometerSubscription;
  double distanceWalked = 0.0; // Estimated distance walked
  double velocityX = 0.0, velocityY = 0.0, velocityZ = 0.0;
  double previousTimestamp = 0.0;

  // Function to save the testing result to the server
  void saveResult() async {
    int score = 0;
    String risk = "Low";

    if (firstTestTime > 10) {
      score += 1;
    }
    if (secondTestTime > 10) {
      score += 1;
    }

    if (score == 1) {
      risk = "Medium";
    } else if (score == 2) {
      risk = "High";
    }

    // Get current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Save the score and risk level to Firebase Firestore
      await FirebaseFirestore.instance.collection('Users').doc(user.email).set(
          {
            'TUG Test Risk': risk,
            'First TUG Test time': firstTestTime,
            'Second TUG Test time': secondTestTime,
            'progress': 3, // Update the process to 1
          },
          SetOptions(
              merge:
                  true)); // Use merge: true to update the existing document without overwriting all fields

      print("Risk assessment saved to Firebase");
    } else {
      print("No user is currently signed in");
    }
  }

  void startCountdown() async {
    setState(() {
      isCountingDown = true;
    });

    // Ask the user to put the phone into their pocket
    speechService.speak(
        "Please put your phone into your pocket. Test will start after count down.");

    // 5 second delay before countdown
    await Future.delayed(Duration(seconds: 5));

    // Countdown from 5 to 1
    for (int i = 5; i > 0; i--) {
      speechService.speak("$i");
      await Future.delayed(Duration(seconds: 1));
    }

    // Start the test
    await Future.delayed(Duration(microseconds: 300));
    speechService.speak(
        "Test start now. Please stand up from the chair and walk until you hear the next instruction.");
    startTest();
  }

  void startTest() {
    setState(() {
      isCountingDown = false;
      testInProgress = true;
      startTime = DateTime.now();
      distanceWalked = 0.0; // Reset the walked distance
      seconds = 0;
    });

    // Listen to accelerometer data to track distance
    accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

      if (previousTimestamp == 0.0) {
        previousTimestamp = currentTime;
        return; // Skip the first event as we don't have a previous timestamp to calculate delta time
      }

      double deltaTime = currentTime - previousTimestamp;
      previousTimestamp = currentTime;

      // Calculate the change in velocity for each axis
      velocityX += event.x * deltaTime;
      velocityY += event.y * deltaTime;
      velocityZ += event.z * deltaTime;

      // Approximate the total distance walked
      double totalVelocity = sqrt(velocityX * velocityX +
          velocityY * velocityY +
          velocityZ * velocityZ);
      double deltaDistance = totalVelocity * deltaTime;
      distanceWalked += deltaDistance;

      updateTestProgress(event);
    });
  }

  void updateTestProgress(AccelerometerEvent event) {
    // Check if the user has walked 3 meters to turn around
    if (distanceWalked >= 3.0 && !hasTurnedAround) {
      hasTurnedAround = true;
      speechService.speak("Now, turn around and walk back to your seat.");
      // Reset distanceWalked to track the return distance
      distanceWalked = 0.0;
    }

    // After the user has walked back 3 meters (return trip), detect sitting down
    if (hasTurnedAround && distanceWalked >= 3.0 && testInProgress) {
      // Monitor z-axis to detect sitting down (large downward spike followed by stabilization)
      if (detectSittingDown(event)) {
        stopTest();
      }
    }
  }

  // FIXME: Here need to be change and modify
  bool detectSittingDown(AccelerometerEvent event) {
    // Example condition to detect a sharp deceleration followed by stability (sitting down)
    // The threshold values and conditions may need to be adjusted based on device sensitivity and user motion.
    if (event.z > 9.8 && event.z < 11.0) {
      // 9.8 m/s² is gravitational acceleration; small spike around this indicates sitting down
      return true;
    }
    return false;
  }

  void stopTest() {
    _timer?.cancel();
    accelerometerSubscription?.cancel(); // Stop listening to the accelerometer

    DateTime endTime = DateTime.now();
    totalTime = endTime.difference(startTime!).inSeconds.toDouble();

    setState(() {
      hasTurnedAround = false;
      testInProgress = false;
      if (testAttempt == 1) {
        firstTestTime = totalTime;
        testAttempt = 2; // Prepare for the second attempt
      } else {
        secondTestTime = totalTime;
        testCompleted = true;
      }
    });

    speechService.speak(
        "The test ends. Time taken: ${totalTime.toStringAsFixed(2)} seconds.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TUG Test In Progress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            testInProgress
                ? /* Text(
                    "Time: $seconds seconds",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ) */
                const SizedBox()
                : testCompleted
                    ? Column(
                        children: [
                          Center(
                            child: Card(
                              color: Theme.of(context).colorScheme.secondary,
                              elevation: 4.0, // Adjust the shadow effect
                              margin: const EdgeInsets.all(
                                  16.0), // Add margin for spacing around the card
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    16.0), // Padding inside the card
                                child: Column(
                                  children: [
                                    Text(
                                      "Test completed!",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "First Test: ${firstTestTime.toStringAsFixed(2)} seconds",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "Second Test: ${secondTestTime.toStringAsFixed(2)} seconds",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton(
                                      onPressed: () {
                                        saveResult();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => HomePage()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 20),
                                      ),
                                      child: const Text(
                                        'Back to Home',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Card(
                            color: Theme.of(context).colorScheme.secondary,
                            elevation:
                                4.0, // You can adjust the elevation for the shadow effect
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0), // Adjust margin for spacing
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  16.0), // Padding inside the card
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Instructions:',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    onPressed: () {
                                      speechService.speak("Instructions");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            color: Theme.of(context).colorScheme.secondary,
                            elevation: 4.0, // Adjust elevation as needed
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  16.0), // Add padding inside the card
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'To start the test, please click the start test button. After you click the button, please put your phone in your pocket immediately, and the test will start after the countdown.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    onPressed: () {
                                      speechService.speak(
                                          "To start the test, please click the start test button. After you click the button, please put your phone in your pocket immediately, and the test will start after the countdown.");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Test Attempt: $testAttempt',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          testInProgress || isCountingDown
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: () {
                                    if (!testInProgress && !isCountingDown) {
                                      startCountdown();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 20),
                                  ),
                                  child: Text(
                                    testAttempt == 1
                                        ? 'Start Test'
                                        : 'Start Second Try',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                        ],
                      ),
            const SizedBox(height: 32),
            testInProgress
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        stopTest();
                        if (testAttempt == 1) {
                          setState(() {
                            testAttempt = 2;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                      ),
                      child: const Text(
                        'Stop Test',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    accelerometerSubscription?.cancel();
    super.dispose();
  }
}
