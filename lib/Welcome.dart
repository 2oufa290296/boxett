import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  FirebaseAuth auth = FirebaseAuth.instance;
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
    await Future.delayed(Duration(milliseconds: 2000));
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String userToken = sharedPref.getString('userToken');
    String uid = sharedPref.getString('uid');
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (userToken != null && newToken != userToken) {
        sharedPref.setString('userToken', newToken);
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(uid)
              .set({'userToken': userToken}, SetOptions(merge: true));
        }
        print('----Tokenchanged');
      } else {
        print(newToken);
      }
    });
    
     Navigator.pushNamed(context, '/redirect');
  }

  @override
  void initState() {
    super.initState();
    redirecting();
    // handleUser();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(body:
    Center(child: Shimmer.fromColors( baseColor: Color.fromRGBO(18, 42, 76, 1),
            highlightColor: Color.fromRGBO(5, 150, 197, 1),
            enabled: true,
                                  child: Text('Boxet',style:TextStyle(fontSize:36,fontFamily:"Lobster",)),
                ))
   )
    ;
  }
}
