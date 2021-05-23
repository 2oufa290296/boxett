import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginState with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  Future<void> logout() async {
    await _auth.signOut();
    _loggedIn = false;
    notifyListeners();
  }

  Future<void> loginUser(AuthCredential credential) async {
    await _auth.signInWithCredential(credential);
    _loggedIn = true;
    notifyListeners();
  }

  Future<User> getCurrentUser() async {
    return  _auth.currentUser;
  }
}