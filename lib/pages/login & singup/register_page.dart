import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:StrideWell/components/my_button.dart';
import 'package:StrideWell/components/my_textfield.dart';
import 'package:StrideWell/helper/helper_function.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:StrideWell/pages/home_page.dart';
import 'package:StrideWell/pages/login%20&%20singup/login_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  // Text controller
  TextEditingController userController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController comfirmPassController = TextEditingController();

  bool isPasswordVisible = false;
  bool isAutoLogin = false;
  bool isConsent = false;
  bool isFormValid = false;

  String passwordError = '';
  String confirmPasswordError = '';
  String phoneNumberError = '';

  // register method
  void register() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    // make sure passwords match
    if (passwordController.text != comfirmPassController.text) {
      //pop loading circle
      Navigator.pop(context);

      //show error message
      displayMessage('Passwords do not match', context);
    } else if (isConsent == false) {
      //pop loading circle
      Navigator.pop(context);

      //show error message
      displayMessage('Please accept the terms and conditions', context);
    } else {
      // create user
      try {
        var res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        print("------------- Result from register --------");
        print(res);

        // create user document and add to firestore
        createUserDocument(res);

        if (context.mounted) Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        //pop loading circle
        Navigator.pop(context);

        //show error message
        displayMessage(e.message!, context);
      }
    }
  }

  // create user document and collect them to firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': userController.text,
        'progress': 0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ClipOval(
                child: Image.asset(
                  'lib/image/icon.png',
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                ),
              ),

              //const SizedBox(height: 25),

              // app name
              Text(
                "Stride Well",
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 50),
              const SizedBox(height: 50),

              // username textfeld
              TextFormField(
                controller: userController,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.primary,
                  prefixIcon: Icon(Icons.person),
                  labelText: "User Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // email textfeld
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.primary,
                  prefixIcon: Icon(Icons.email),
                  labelText: "Email",
                  hintText: "XXX@XXX.XXX",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // password textfeld
              TextFormField(
                controller: passwordController,
                obscureText: isPasswordVisible ? false : true,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: "Password",
                    //hintText: "password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility))),
              ),
              const SizedBox(height: 10),

              // confirm password textfeld
              TextFormField(
                controller: comfirmPassController,
                obscureText: isPasswordVisible ? false : true,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: "Confirm Password",
                    //hintText: "password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility))),
              ),
              const SizedBox(height: 15),

              // consent
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                            value: isConsent,
                            onChanged: (value) {
                              setState(() {
                                isConsent = !isConsent;
                              });
                            }),
                        Text(
                          "Agree to the ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "User agreement",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // sign in button
              MyButton(text: 'Register', onTap: register),
              const SizedBox(height: 25),

              // Already have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LoginPage(), // Navigates to the RegisterPage
                        ),
                      );
                    },
                    child: Text(
                      "Login Here",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
