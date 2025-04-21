import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        checkUserLoginStatus();
      }
    });
  }

  void checkUserLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final newMediaQuery = mediaQuery.copyWith(
      textScaler: TextScaler.linear(mediaQuery.textScaleFactor.clamp(0.8, 1.0)),
    );

    return MediaQuery(
      data: newMediaQuery,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3D0087),
                Color(0xFFB45DE7),
                Color(0xFFDC9FFF),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 150.h,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'rodi',
                            style: GoogleFonts.kenia(
                              fontSize: 64.sp,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: 'genius',
                            style: GoogleFonts.kenia(
                              fontSize: 64.sp,
                              color: Color(0xFFF6D360),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'AI Task Manager',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jockeyOne(
                      fontSize: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Welcome to Prodigenius!',
                style: GoogleFonts.jockeyOne(fontSize: 32, color: Colors.white),
              ),
              SizedBox(height: 20),
              Image.asset('assets/robot.png', height: 100),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFA16DE0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Prioritize tasks, meet deadlines, and achieve more with AI-powered scheduling!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jockeyOne(
                        fontSize: 24,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Start Managing your Tasks Now!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jockeyOne(
                      fontSize: 32.sp,
                      color: Color(0xFFBB62FF),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB45DE7),
                      Color(0xFFDC9FFF),
                    ],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      Navigator.pushNamed(context, '/signup');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.jockeyOne(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
