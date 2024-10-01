import 'package:flutter/material.dart';
import 'package:frailtyapp/pages/login%20&%20singup/intro_screen/intro_page_1.dart';
import 'package:frailtyapp/pages/login%20&%20singup/intro_screen/intro_page_2.dart';
import 'package:frailtyapp/pages/login%20&%20singup/intro_screen/intro_page_3.dart';
import 'package:frailtyapp/pages/login%20&%20singup/login_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller to keep track of the current page
  PageController _controller = PageController();

  // Keep track if we are in the last page
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    final device_size = MediaQuery.of(context).size;
    double height = device_size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),

          Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(bottom: height * 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Skip button
                  GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(2);
                    },
                    child: Text(
                      "Skip",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),

                  // dot indicators
                  SmoothPageIndicator(controller: _controller, count: 3),

                  // Next button or get started button
                  onLastPage
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return LoginPage();
                              },
                            ));
                          },
                          child: Text(
                            "Done",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _controller.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          },
                          child: Text(
                            "Next",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                ],
              ))
        ],
      ),
    );
  }
}
