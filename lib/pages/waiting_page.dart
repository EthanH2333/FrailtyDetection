import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frailtyapp/pages/plan_page.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaitingPage extends StatefulWidget {
  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  static const int _totalTime = 90; // Total time in seconds (5 minutes)
  int _remainingTime = _totalTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    checkPlan();
  }

  void updateProgress() async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Save the score and risk level to Firebase Firestore
      await FirebaseFirestore.instance.collection('Users').doc(user.email).set({
        'progress': 4,
      }, SetOptions(merge: true));
    } else {
      print("Unable to update the progress");
    }
  }

  Future<void> checkPlan() async {
    var url = Uri.parse('http://15.222.45.62:5100/getPlan');
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    var data = {"uid": uid};
    String jsonData = json.encode(data);

    try {
      http.Response response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonData,
      );

      if (response.statusCode == 200) {
        updateProgress();
        setState(() {
          _remainingTime = 0;
        });
      } else {
        sendInfo();
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> sendInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();

      Map<String, dynamic>? firebaseData =
          userDoc.data() as Map<String, dynamic>?;

      if (firebaseData != null) {
        firebaseData.remove('email');
        firebaseData.remove('progress');
        firebaseData.remove('username');

        firebaseData['uid'] = uid;
        var data = firebaseData;

        String jsonData = json.encode(data);

        var url = Uri.parse('http://15.222.45.62:5100/plan');

        print("\n $jsonData \n");

        try {
          http.Response response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonData,
          );

          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            print('Response data: $responseData');
          } else {
            print('Server responded with status code ${response.statusCode}');
            print('Response body: ${response.body}');
          }
        } catch (e) {
          print('An error occurred: $e');
        }
      } else {
        print('No data found for the user.');
      }
    } else {
      print('No user is currently signed in.');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_remainingTime == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = _remainingTime / _totalTime;

    return Scaffold(
      appBar: AppBar(title: Text('Your Personal Plan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 200.0,
                  width: 200.0,
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 8.0,
                  ),
                ),
                Text(
                  _formatTime(_remainingTime),
                  style: TextStyle(fontSize: 48.0),
                ),
              ],
            ),
            SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: _remainingTime == 0 ? _onButtonPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _remainingTime == 0
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              child: _remainingTime == 0
                  ? Text(
                      "Your Plan is Ready!",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Text("Processing"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onButtonPressed() {
    updateProgress();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanPage(),
      ),
    );
  }
}
