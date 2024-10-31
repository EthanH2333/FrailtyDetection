import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:StrideWell/components/my_button.dart';
import 'package:StrideWell/components/my_textfield.dart';
import 'package:StrideWell/helper/helper_function.dart';
import 'package:StrideWell/pages/home_page.dart';
import 'package:StrideWell/pages/login%20&%20singup/register_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controller
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isAutoLogin = false;

  // login method
  void login() async {
    // showing loading cirecle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    //try to sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      // pop loading circle
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
      displayMessage(
          'Email or password is incorrect, please try again.', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width or height and adjust size accordingly
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // logo

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

              // forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  )
                ],
              ),
              const SizedBox(height: 25),

              // sign in button
              MyButton(text: 'Login', onTap: login),
              const SizedBox(height: 25),

              // don't have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RegisterPage(), // Navigates to the RegisterPage
                        ),
                      );
                    },
                    child: Text(
                      "Register Here",
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
