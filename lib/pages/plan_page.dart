import 'dart:convert';
import 'package:StrideWell/helper/helper_function.dart';
import 'package:StrideWell/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  double textSize = 10.0;
  Map<String, dynamic>? plan;

  @override
  void initState() {
    super.initState();
    getPlan();
  }

  Future<void> getPlan() async {
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
        final responseBody = jsonDecode(response.body);

        // Check if 'plan' is a Map or String
        if (responseBody['plan'] is String) {
          // Parse the plan string into sections based on headings
          setState(() {
            plan = _parsePlanString(responseBody['plan']);
          });
        } else {
          // Directly assign if it's already a structured map
          setState(() {
            plan = responseBody['plan'];
          });
        }
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      print('An error occurred: $e');
      _showErrorDialog();
    }
  }

  // Helper function to parse plain text plan into a structured map
  Map<String, dynamic> _parsePlanString(String planText) {
    Map<String, dynamic> parsedPlan = {};

    // Split based on double newline and "Sources used" section
    List<String> sections = planText.split("\n\n");
    String? currentKey;

    for (String section in sections) {
      // Detect sections using keywords
      if (section.startsWith("Patient Summary:")) {
        currentKey = "Patient Summary";
        parsedPlan[currentKey] = section;
      } else if (section.startsWith("Frailty Status:")) {
        currentKey = "Frailty Status";
        parsedPlan[currentKey] = section;
      } else if (section.startsWith("Care Recommendations:")) {
        currentKey = "Care Recommendations";
        parsedPlan[currentKey] = section;
      } else if (section.startsWith("Safety Considerations:")) {
        currentKey = "Safety Considerations";
        parsedPlan[currentKey] = section;
      } else if (section.startsWith("Monitoring and Evaluation:")) {
        currentKey = "Monitoring and Evaluation";
        parsedPlan[currentKey] = section;
      } else if (section.startsWith("Resources and Support Services:")) {
        currentKey = "Resources and Support Services";
        parsedPlan[currentKey] = section;
      } else if (section.startsWith("Additional Assessments:")) {
        currentKey = "Additional Assessments";
        parsedPlan[currentKey] = section;
      } else if (section.startsWith("Sources used:")) {
        currentKey = "Sources used";
        parsedPlan[currentKey] = section;
      } else if (currentKey != null) {
        // Append any additional lines to the last section
        parsedPlan[currentKey] += "\n\n" + section;
      }
    }
    return parsedPlan;
  }

  bool _isValidUrl(String line) {
    final urlPattern = r"^\d+\.\s?(http|https):\/\/[^\s]+$";
    bool isVal = RegExp(urlPattern).hasMatch(line);
    return isVal;
  }

  String extractUrl(String line) {
    // Regular expression to match and remove the leading number and dot (e.g., "1. ", "2. ")
    final urlPattern = RegExp(r'^\d+\.\s*');

    // Replace the matching pattern with an empty string, leaving only the URL
    String url = line.replaceFirst(urlPattern, '');

    return url;
  }

  void _launchURL(String url) async {
    String cleanURL = extractUrl(url);
    if (await canLaunch(cleanURL)) {
      await launch(cleanURL);
    } else {
      displayMessage(
          'Something wrong with the resources, please try again later.',
          context);
      print('Could not launch $cleanURL');
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(
            'An error occurred. Please try re-login and wait for another 5 minutes.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper function to make each link clickable
  Widget _buildClickableLinks(String content) {
    print('object: $content');
    List<String> lines = content.split("\n");
    print("lines: $lines");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (_isValidUrl(line)) {
          return GestureDetector(
            onTap: () => _launchURL(line),
            child: Text(
              line,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          );
        }
        return Text(line, style: TextStyle(fontSize: textSize));
      }).toList(),
    );
  }

  Widget _buildPlanSection(String title, String content) {
    print("Title is : $title");
    // Remove the repeated title from content if it starts with the title
    if (content.startsWith("$title:")) {
      content = content.replaceFirst("$title:\n", "");
    }

    if (title == "Sources used") {
      // Render clickable links for the "Sources used" section
      return Card(
        color: Theme.of(context).colorScheme.secondary,
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: textSize + 3, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildClickableLinks(content),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Theme.of(context).colorScheme.secondary,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: textSize + 3, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(content, style: TextStyle(fontSize: textSize)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonTextSize = screenWidth * 0.02;
    setState(() {
      textSize = buttonTextSize;
    });
    return Scaffold(
      appBar: AppBar(title: Text('Care Plan')),
      body: plan == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (plan?['Patient Summary'] != null)
                  _buildPlanSection(
                      'Patient Summary', plan!['Patient Summary']),
                if (plan?['Frailty Status'] != null)
                  _buildPlanSection('Frailty Status', plan!['Frailty Status']),
                if (plan?['Care Recommendations'] != null)
                  _buildPlanSection(
                      'Care Recommendations', plan!['Care Recommendations']),
                if (plan?['Safety Considerations'] != null)
                  _buildPlanSection(
                      'Safety Considerations', plan!['Safety Considerations']),
                if (plan?['Monitoring and Evaluation'] != null)
                  _buildPlanSection('Monitoring and Evaluation',
                      plan!['Monitoring and Evaluation']),
                if (plan?['Resources and Support Services'] != null)
                  _buildPlanSection('Resources and Support Services',
                      plan!['Resources and Support Services']),
                if (plan?['Additional Assessments'] != null)
                  _buildPlanSection('Additional Assessments',
                      plan!['Additional Assessments']),
                if (plan?['Sources used'] != null)
                  _buildPlanSection('Sources used', plan!['Sources used']),
              ],
            ),
    );
  }
}
