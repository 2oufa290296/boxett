import 'package:boxet/HomePage.dart';
import 'package:boxet/LoginActivity.dart';
import 'package:boxet/LoginState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Redirecting extends StatefulWidget {
  @override
  _RedirectingState createState() => _RedirectingState();
}

class _RedirectingState extends State<Redirecting> {
  @override
  Widget build(BuildContext context) {
      return Consumer<LoginState>(
      builder: (_, auth, __) {
        if (auth.loggedIn) return HomePage();
        return LoginActivity();
      },
    );
  }
}