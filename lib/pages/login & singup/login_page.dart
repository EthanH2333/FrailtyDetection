import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frailtyapp/components/my_button.dart';
import 'package:frailtyapp/components/my_textfield.dart';
import 'package:frailtyapp/helper/helper_function.dart';
import 'package:frailtyapp/pages/home_page.dart';
import 'package:frailtyapp/pages/login%20&%20singup/register_page.dart';

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
      displayMessage(e.message!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // logo
            Icon(
              Icons.health_and_safety_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),

            // app name
            Text(
              "Frailty App",
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
    );
  }
}
