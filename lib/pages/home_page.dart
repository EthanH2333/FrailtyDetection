import 'package:StrideWell/pages/login%20&%20singup/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:StrideWell/components/my_button.dart';
import 'package:StrideWell/helper/sp_service.dart';
import 'package:StrideWell/pages/mobility%20test/part1_intro.dart';
import 'package:StrideWell/pages/mobility%20test/part2_intro.dart';
import 'package:StrideWell/pages/plan_page.dart';
import 'package:StrideWell/pages/waiting_page.dart';

import 'login & singup/intro_screen/general/survey.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SP_Service sp_service = SP_Service();
  //logout button
  void logout() {
    setState(() {
      FirebaseAuth.instance.signOut();
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  // Current logged in user
  User? user = FirebaseAuth.instance.currentUser;

  // Future to get user's detail
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetail() async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    double height = deviceSize.height;
    double width = deviceSize.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [IconButton(onPressed: logout, icon: Icon(Icons.logout))],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetail(),
          builder: (context, snapshot) {
            // loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // error
            else if (snapshot.hasError) {
              return Center(child: Text("Error"));
            }

            // data
            else if (snapshot.hasData == false) {
              return Center(child: Text("No data"));
            }

            // extract data
            Map<String, dynamic>? userData = snapshot.data!.data();
            //print("information: $userData");

            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Aligns everything to the left
                    children: [
                      Align(
                        alignment: Alignment
                            .topLeft, // Aligns the text to the top left
                        child: RichText(
                          text: TextSpan(
                            text: 'Welcome back ', // Regular text
                            style: TextStyle(
                              fontSize: 24, // Size of the welcome text
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary, // Color of the regular text
                            ),
                            children: [
                              TextSpan(
                                text: userData!["username"], // The username
                                style: TextStyle(
                                  fontSize: 24, // Same size for the username
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary, // Different color for the username
                                  fontWeight: FontWeight.bold, // Bold username
                                ),
                              ),
                              TextSpan(
                                text:
                                    '!', // Exclamation mark after the username
                                style: TextStyle(
                                  fontSize: 24,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // Add some spacing after the text
                      GestureDetector(
                        onTap: userData!["progress"] > 0
                            ? null
                            : () async {
                                await sp_service.savePointer(0);
                                await sp_service.saveAnsList(
                                    ['-1', '-1', '-1', '-1', '-1', '-1', '-1']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectOne(),
                                  ),
                                );
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: userData["progress"] > 0
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: userData["progress"] > 0
                                ? Icon(Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary)
                                : Text(
                                    'PRISMA-7',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Part1_intro(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: userData["progress"] > 1
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: userData["progress"] > 1
                                ? Icon(Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary)
                                : Text(
                                    'Part 1 - Mobility',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Part2_intro(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: userData["progress"] > 2
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: userData["progress"] > 2
                                ? Icon(Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary)
                                : Text(
                                    'Part 2 - Mobility',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WaitingPage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: userData["progress"] == 3
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: userData["progress"] == 3
                                ? Text(
                                    'Get Your Personal Plan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  )
                                : Icon(Icons.check,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlanPage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: userData["progress"] == 4
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: userData["progress"] == 4
                                ? Text(
                                    'See Your Personal Plan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  )
                                : Icon(Icons.not_interested_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            /* return SafeArea(
              child: Column(
                children: [
                  Text('Welcome back ${userData!["username"]}!'),
                  
                  
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectOne(), // Navigates to the RegisterPage
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'PRISMA-7',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ); */
          }),
    );
  }
}
