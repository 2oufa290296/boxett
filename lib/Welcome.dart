import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  String error = "";

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      redirecting();
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      print(e);
    }
  }

  double width, height;
  // handleUser() async {
  //   Future.delayed(Duration(seconds: 2), () {
  //     auth.authStateChanges().listen((user) {
  //       if (user != null) {
  //         print('user');
  //         Navigator.pushNamed(context, '/homePage');
  //       } else {
  //         print('null');
  //         Navigator.pushNamed(context, '/login');
  //       }
  //     });
  //   });
  // }

  redirecting() async {
    await Future.delayed(Duration(milliseconds: 1000));
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String userToken = sharedPref.getString('userToken');
    String uid = sharedPref.getString('uid');
    FirebaseMessaging messaging = FirebaseMessaging.instance;

// use the returned token to send messages to users from your custom server
    String token = await messaging.getToken(
      vapidKey: "BGpdLRs......",
    );
    if (userToken != null && token != userToken) {
      sharedPref.setString('userToken', token);
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .set({'userToken': token}, SetOptions(merge: true));
      }
      print('----Tokenchanged');
    } else {
      print(token);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {});
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification.title}');
      }
    });

    if (Platform.isIOS) {
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    // FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    //   if (userToken != null && newToken != userToken) {
    //     sharedPref.setString('userToken', newToken);
    //     if (uid != null) {
    //       await FirebaseFirestore.instance
    //           .collection('Users')
    //           .doc(uid)
    //           .set({'userToken': userToken}, SetOptions(merge: true));
    //     }
    //     print('----Tokenchanged');
    //   } else {
    //     print(newToken);
    //   }
    // });

    Navigator.pushNamed(context, '/redirect');
  }

  @override
  void initState() {
    initializeFlutterFire();

    super.initState();

    // handleUser();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Center(
            child: Shimmer.fromColors(
      baseColor: Color.fromRGBO(18, 42, 76, 1),
      highlightColor: Color.fromRGBO(5, 150, 197, 1),
      enabled: true,
      child: Text('Boxet',
          style: TextStyle(
            fontSize: 36,
            fontFamily: "Lobster",
          )),
    )));
  }
}
