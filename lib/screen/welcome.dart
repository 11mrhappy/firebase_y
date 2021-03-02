import 'package:firebase_y/screen/register_page.dart';
import 'package:firebase_y/screen/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';

import './screen/register_page.dart';
import './screen/signin_page.dart';

class WelcomePage extends StatelessWidget {
  static const String id = 'welcome_screen';
  final String title = 'Welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: SignInButtonBuilder(
              icon: Icons.person_add,
              backgroundColor: Colors.indigo,
              text: 'Registration',
              onPressed: () => Navigator.pushNamed(context, RegisterPage.id),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
          Container(
            child: SignInButtonBuilder(
              icon: Icons.verified_user,
              backgroundColor: Colors.orange,
              text: 'Sign In',
              onPressed: () => Navigator.pushNamed(context, SignInPage.id),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}
