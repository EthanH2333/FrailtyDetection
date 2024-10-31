import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frailtyapp/helper/sp_service.dart';
import 'package:frailtyapp/helper/speak_function.dart';
import 'package:frailtyapp/pages/home_page.dart';

class SelectOne extends StatefulWidget {
  const SelectOne({super.key});

  @override
  State<SelectOne> createState() => _SelectOneState();
}

class _SelectOneState extends State<SelectOne> {
  SP_Service sp_service = SP_Service();
  int point = -1;
  int selectedOption = -1; // -1 means no option is selected
  List<String> answer = [];

  // Question List
  List<String> questionList = [
    'Are you older than 85 years old?',
    'Are you male?',
    'In general, do you have any health problems that require you to limit your activities?',
    'Do you need someone to help you on a regular basis?',
    'In general, do you have any health problems that require you to stay at home?',
    'If you need help, can you count on someone close to you?',
    'Do you regularly use a stick, walker or wheelchair to move about?',
  ];

  // The options for each question
  List<String> options = [
    "True",
    "False",
  ]; // Only True or False

  SpeechService speechService = SpeechService();

  void _initFun() async {
    int tempPoint = await sp_service.getPointer();
    List<String> tempAnswer = await sp_service.getAnsList();
    int pointer = int.parse(tempAnswer[tempPoint]);

    setState(() {
      point = tempPoint;
      answer = tempAnswer;
      selectedOption = pointer;
    });
  }

  void saveAnswer() {
    print("The answer is $selectedOption");
    setState(() {
      answer[point] = selectedOption.toString();
      sp_service.saveAnsList(answer);
    });
  }

  void getRisk() async {
    // Get the answer list
    List<String> finalAns = await sp_service.getAnsList();

    // Sum the list and get the score
    int score = finalAns.map((e) => int.parse(e)).reduce((a, b) => a + b);

    // Determine risk level
    bool haveRisk = score < 5;

    // Prepare the question and answer list
    List<Map<String, String>> qaList = [];

    for (int i = 0; i < questionList.length; i++) {
      String question = questionList[i];
      String answerIndex = finalAns[i];
      String answerText = options[int.parse(answerIndex)];
      qaList.add({
        'question': question,
        'answer': answerText,
      });
    }

    // Get current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Save the score and risk level to Firebase Firestore
      await FirebaseFirestore.instance.collection('Users').doc(user.email).set(
          {
            'GeneralRiskScore': score,
            'HaveGeneralRisk': haveRisk,
            'PRISMA-7': qaList,
            'progress': 1, // Update the process to 1
          },
          SetOptions(
              merge:
                  true)); // Use merge: true to update the existing document without overwriting all fields

      print("Risk assessment saved to Firebase");
    } else {
      print("No user is currently signed in");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initFun();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSize = screenWidth * 0.05;
    double titleSize = screenWidth * 0.08; // Dynamic text size for options
    double buttonTextSize = screenWidth * 0.05; // Dynamic text size for buttons
    double sidePadding = screenWidth * 0.2; // 20% of screen width for padding
    double imageWidth = screenWidth * 0.6; // 80% of screen width
    double imageHeight = screenHeight * 0.3; // 20% of screen height

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('PRISMA-7'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                /* width: imageWidth,
              height: imageHeight,
              child: Image.asset(
                'assets/your_image.jpg',
                fit: BoxFit
                    .cover, // This can be adjusted as per your requirement
              ), */
                ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      questionList[point],
                      style: TextStyle(
                          fontSize: titleSize, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis, // Prevent overflow
                    ),
                  ),
                  SizedBox(width: 10), // Add some space between text and icon
                  IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      size: screenHeight * 0.05,
                    ), // Use any icon you want
                    onPressed: () {
                      speechService.speak(questionList[point]);
                      speechService.speak("Please select True or False:");
                    },
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap:
                  true, // To limit the ListView to the size of its content
              itemCount: options.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width *
                      0.75, // 75% of screen width
                  child: Card(
                    color: selectedOption == index
                        ? (index == 0 ? Colors.green : Colors.yellow[400])
                        : Theme.of(context)
                            .colorScheme
                            .background, // Green for True, Red for False
                    child: ListTile(
                      title: Text(
                        options[index],
                        style: TextStyle(fontSize: textSize),
                      ),
                      leading: Radio<int>(
                        value: index,
                        groupValue: selectedOption,
                        onChanged: (int? value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                      ),
                      onTap: () {
                        speechService.speak(options[index]);
                        setState(() {
                          selectedOption = index;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 30),
            Padding(
              padding: EdgeInsets.only(
                left: sidePadding,
                right: sidePadding,
                top: 10.0,
                bottom: screenHeight * 0.05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: point == 0
                        ? null
                        : () {
                            speechService.speak('Back');
                            saveAnswer();
                            sp_service.savePointer(point - 1);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectOne()),
                            );
                          },
                    child: Text(
                      'Back',
                      style: TextStyle(fontSize: buttonTextSize),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedOption == -1
                        ? null
                        : () {
                            saveAnswer();
                            print(point);
                            if (point > 5) {
                              speechService.speak('Finish');
                              getRisk();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                              );
                            } else {
                              speechService.speak('Next');
                              sp_service.savePointer(point + 1);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectOne()),
                              );
                            }
                          }, // Disable if no selection
                    child: point > 5
                        ? Text('Finish',
                            style: TextStyle(fontSize: buttonTextSize))
                        : Text(
                            'Next',
                            style: TextStyle(fontSize: buttonTextSize),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
