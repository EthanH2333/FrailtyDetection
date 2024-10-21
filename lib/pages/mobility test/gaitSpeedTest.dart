import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frailtyapp/helper/speak_function.dart';
import 'package:frailtyapp/pages/home_page.dart';
import 'package:sensors_plus/sensors_plus.dart'; // For accessing sensors
import 'dart:async';
import 'dart:math';

class GaitSpeedTest extends StatefulWidget {
  const GaitSpeedTest({super.key});

  @override
  State<GaitSpeedTest> createState() => _GaitSpeedTestState();
}

class _GaitSpeedTestState extends State<GaitSpeedTest> {
  final SpeechService speechService = SpeechService();

  // Variables to track test attempts and progress
  int testAttempt = 1;
  bool testInProgress = false;
  bool isCountingDown = false;
  bool testCompleted = false; // Track if both tests are completed

  // Store time taken and gait speed for both tests
  double firstTestTime = 0.0;
  double firstTestSpeed = 0.0;
  double secondTestTime = 0.0;
  double secondTestSpeed = 0.0;

  // Store start time and distance walked for the current test
  double startTime = 0.0;
  double distanceWalked = 0.0;

  // Variables to simulate phases of the walk
  bool hasReachedTestingZone = false;
  bool hasFinishedTest = false;
  StreamSubscription? accelerometerSubscription;

  // Countdown function that speaks the countdown and starts the test
  Future<void> startCountdown() async {
    speechService.speak(
        "Please put your phone in your pocket immediately, and the test will start after the count down.");
    setState(() {
      isCountingDown = true;
    });
    await Future.delayed(const Duration(seconds: 5));

    // Speak the countdown from 5 to 1
    for (int i = 5; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      speechService.speak("$i");
    }

    // Speak "Start!" after the countdown
    await Future.delayed(const Duration(seconds: 1));
    speechService.speak("Start!");

    startTest(); // Begin the test after the countdown
  }

  // Function to save the testing result to the server
  void saveResult() async {
    int score = 0;
    String risk = "Low";

    if (firstTestSpeed < 0.8 || firstTestTime > 5) {
      score += 1;
    }
    if (secondTestSpeed < 0.8 || secondTestTime > 5) {
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
            'Gait Speed Test Risk': risk,
            'First Gait Test speed': firstTestSpeed,
            'First Gait Test time': firstTestTime,
            'Second Gait Test speed': secondTestSpeed,
            'Second Gait Test time': secondTestTime,
            'progress': 2, // Update the process to 1
          },
          SetOptions(
              merge:
                  true)); // Use merge: true to update the existing document without overwriting all fields

      print("Risk assessment saved to Firebase");
    } else {
      print("No user is currently signed in");
    }
  }

  // Start the test and initialize sensor listening
  void startTest() {
    setState(() {
      isCountingDown = false;
      testInProgress = true;
      startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      distanceWalked = 0.0;
      hasReachedTestingZone = false;
      hasFinishedTest = false;
    });

    speechService
        .speak("Test start, please walk at your normal walking speed.");

    // Variables to store velocity and time
    double velocityX = 0.0;
    double velocityY = 0.0;
    double velocityZ = 0.0;
    double previousTimestamp = 0.0;

// Listen to accelerometer data and calculate distance
    accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

      if (previousTimestamp == 0.0) {
        previousTimestamp = currentTime;
        return; // Skip the first event as we don't have a previous timestamp to calculate delta time
      }

      double deltaTime = currentTime - previousTimestamp;
      previousTimestamp = currentTime;

      // Calculate the change in velocity for each axis (v = u + at)
      velocityX += event.x * deltaTime;
      velocityY += event.y * deltaTime;
      velocityZ += event.z * deltaTime;

      // Approximate the total distance walked (s = v * t)
      double totalVelocity = sqrt(velocityX * velocityX +
          velocityY * velocityY +
          velocityZ * velocityZ);
      double deltaDistance = totalVelocity * deltaTime;

      // Add to the total distance walked
      distanceWalked += deltaDistance;

      // Update progress based on the distance walked
      updateTestProgress();
    });
  }

  // Update the progress of the test based on the distance walked
  void updateTestProgress() {
    if (distanceWalked >= 1.0 && !hasReachedTestingZone) {
      // Reached the 1-metre acceleration zone
      hasReachedTestingZone = true;

      // Start the timer when the user reaches the testing zone (after 1 meter)
      startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

      // Notify the user that they are in the testing zone
      speechService
          .speak("Now keep the speed, you are in your testing zone now.");
    } else if (distanceWalked >= 5.0 && !hasFinishedTest) {
      // Finished the test after walking 4 meters in total (including the 1 meter acceleration zone)
      hasFinishedTest = true;

      // Notify the user that the test is finished
      speechService
          .speak("Now you finished your test, please slow down and rest.");

      // Stop the test and calculate results
      stopTest();
    }
  }

// Stop the test and calculate the time taken and gait speed
  void stopTest() {
    // Get the current time when the test finishes
    double endTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Calculate the total time spent in the 3-meter testing zone (excluding the 1-meter acceleration)
    double totalTime = endTime - startTime;

    // Calculate gait speed (distance covered in the 4-meter testing zone divided by time)
    double gaitSpeed = 4.0 / totalTime;

    // Store results based on which test attempt this is
    if (testAttempt == 1) {
      firstTestTime = totalTime;
      firstTestSpeed = gaitSpeed;
    } else if (testAttempt == 2) {
      secondTestTime = totalTime;
      secondTestSpeed = gaitSpeed;
    }

    // Stop listening to sensor events
    accelerometerSubscription?.cancel();

    setState(() {
      testInProgress = false;
      if (testAttempt == 1) {
        testAttempt = 2;
      } else {
        testCompleted = true;
      }
    });

    // Announce the results of the test
    speechService.speak(
        "Test completed. Time taken: ${totalTime.toStringAsFixed(2)} seconds, speed: ${gaitSpeed.toStringAsFixed(2)} metres per second.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gait Speed Test (4-metre)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            testCompleted
                ? Column(
                    children: [
                      Card(
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
                                'Test Complete!',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'First Test - Time: ${firstTestTime.toStringAsFixed(2)} seconds, Speed: ${firstTestSpeed.toStringAsFixed(2)} m/s',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Second Test - Time: ${secondTestTime.toStringAsFixed(2)} seconds, Speed: ${secondTestSpeed.toStringAsFixed(2)} m/s',
                                style: TextStyle(fontSize: 16),
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
                                      Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 20),
                                ),
                                child: const Text(
                                  'Back to Home Page',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
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
                      const SizedBox(height: 16),
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
                                  'To start the test, please cilck the start test button. After you click the button, please put your phone in your pocket immediately, and the test will start after the count down.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.volume_up),
                                onPressed: () {
                                  speechService.speak(
                                      "'To start the test, please cilck the start test button. After you click the button, please put your phone in your pocket immediately, and the test will start after the count down.");
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
                                backgroundColor: Theme.of(context).primaryColor,
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
                      const SizedBox(height: 16),
                      testInProgress
                          ? ElevatedButton(
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
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 32),
                      testAttempt > 1 && firstTestTime > 0
                          ? Text(
                              'First Test - Time: ${firstTestTime.toStringAsFixed(2)} seconds, Speed: ${firstTestSpeed.toStringAsFixed(2)} m/s',
                              style: TextStyle(fontSize: 16),
                            )
                          : const SizedBox(),
                      testAttempt > 1 && secondTestTime > 0
                          ? Text(
                              'Second Test - Time: ${secondTestTime.toStringAsFixed(2)} seconds, Speed: ${secondTestSpeed.toStringAsFixed(2)} m/s',
                              style: TextStyle(fontSize: 16),
                            )
                          : const SizedBox(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    accelerometerSubscription
        ?.cancel(); // Cancel sensor subscription when widget is disposed
    super.dispose();
  }
}
