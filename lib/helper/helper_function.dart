import 'package:flutter/material.dart';

// display message to user
void displayMessage(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ));
}
