import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:boxet/apple_sign_in_available.dart';
import 'package:boxet/auth_service.dart';
import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithApple(scopes: [Scope.email, Scope.fullName]);
      
      
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 2000),
          backgroundColor: Color(0xFF232323),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 100,
                child: Text('uid: ${user.uid}', style: TextStyle(fontSize: 16)),
              ),
            ],
          )));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 2000),
          backgroundColor: Color(0xFF232323),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 100,
                child: Text(e, style: TextStyle(fontSize: 16)),
              ),
            ],
          )));
    }
  }
  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (appleSignInAvailable.isAvailable)
              AppleSignInButton(
                style: ButtonStyle.black,
                type: ButtonType.signIn,
                onPressed: () => _signInWithApple(context),
              ),
          ],
        ),
      ),
    );
  }
}


