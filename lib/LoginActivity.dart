import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:boxet/CustomDialog.dart';
import 'package:boxet/main.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boxet/Signup.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;

class LoginActivity extends StatefulWidget {
  @override
  _LoginActivityState createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  final Future<bool> _isAvailableFuture = apple.TheAppleSignIn.isAvailable();
  String errorMessage;
  double height, width;
  TextEditingController userController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FacebookLogin facebooklogin = FacebookLogin();
  bool showLoginProgress = false;
  SharedPreferences sharedPref;
  bool loadingGoogle = false;
  bool loadingFacebook = false;
  String username, password;
  bool userDoesntExist = false;
  bool wrongPassword = false;
  bool emptyUsername = false;
  bool emptyPassword = false;
  bool checkingUsername = false;
  FocusNode passwordNode = FocusNode();
  FocusNode forgotUserNode = FocusNode();
  FocusNode forgotPhoneNode = FocusNode();
  String userToken = "";
  String forgotUsername = '';
  String forgotPhone = '';
  bool sendingResetCode = false;
  bool wrongForgotUsername = false;
  bool wrongForgotPhone = false;
  String forgotPhoneFromDB = "";
  GlobalKey<CustomDialogState> customKey = GlobalKey();
  String uid = '';
  String forgotErrorText = '';

  Future<bool> checkUser() async {
    bool exists;
    await FirebaseFirestore.instance
        .collection('UsersAuth')
        .where('username', isEqualTo: forgotUsername)
        .get()
        .then((data) {
      if (data.docs.isNotEmpty) {
        forgotPhoneFromDB = data.docs.first.data()['Mobile'];
        uid = data.docs.first.id;
        exists = true;
      } else {
        exists = false;
      }
    });

    return exists;
  }

  usernamePasswordSign(String username, String password) async {
    await FirebaseFirestore.instance
        .collection('UsersAuth')
        .where('username', isEqualTo: username.trim())
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        if (userDoesntExist) {
          userDoesntExist = false;
        }
        if (value.docs[0].data()['password'] == password) {
          if (wrongPassword) {
            wrongPassword = false;
          }

          await FirebaseFirestore.instance
              .collection('Users')
              .doc(value.docs[0].id)
              .get()
              .then((data) async {
            if (data.exists) {
              sharedPref.setString('username', data.data()['username']);
              sharedPref.setString('uid', data.id);
              sharedPref.setString('imgURL', data.data()['imgURL']);
              sharedPref.setString('provider', 'phone');

              sharedPref.setString('userToken', userToken);

              if (data.data()['address'] != null) {
                Map<String, dynamic> addressMap = data.data()['address'];
                if (addressMap['customername'] != null &&
                    addressMap['city'] != null &&
                    addressMap['region'] != null &&
                    addressMap['address'] != null &&
                    addressMap['mobile'] != null) {
                  sharedPref.setString(
                      'customername', addressMap['customername']);
                  sharedPref.setString('city', addressMap['city']);
                  sharedPref.setString('region', addressMap['region']);
                  sharedPref.setString('address', addressMap['address']);
                  sharedPref.setString('mobile', addressMap['mobile']);
                }
              }

              await data.reference
                  .collection('favorites')
                  .orderBy('date', descending: true)
                  .get()
                  .then((value) {
                List<String> favList = [];
                if (value.docs.isNotEmpty) {
                  value.docs.forEach((val) {
                    favList.add(val.id);
                  });
                }
                sharedPref.setStringList('favorite', favList);
              });

              await data.reference
                  .set({'userToken': userToken}, SetOptions(merge: true));

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => new MyHomePage()));
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Color(0xFF232323),
              content: Container(
                height: 20,
                width: width,
                alignment: Alignment.center,
                child:
                    Text('Incorrect password', style: TextStyle(fontSize: 16)),
              )));

          wrongPassword = true;
        }
      } else {
        userDoesntExist = true;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color(0xFF232323),
            content: Container(
              height: 20,
              width: width,
              alignment: Alignment.center,
              child:
                  Text('Username doesnt exist', style: TextStyle(fontSize: 16)),
            )));
      }
    });

    setState(() {
      checkingUsername = false;
    });
  }

  Future<User> _gSignIn() async {
    GoogleSignInAccount account = await _googleSignIn.signIn();
    if (account == null) {
      setState(() {
        loadingGoogle = false;
      });
      return null;
    } else {
      GoogleSignInAuthentication authentication = await account.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: authentication.accessToken,
          idToken: authentication.idToken);

      UserCredential userCred = await _fAuth.signInWithCredential(credential);
      return (userCred.user);
    }
  }

  Future _fbSignin(BuildContext context) async {
    // facebooklogin.loginBehavior=FacebookLoginBehavior.webViewOnly;

    final FacebookLoginResult result =
        await facebooklogin.logIn(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        AuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken.token);
        UserCredential userCred = await _fAuth.signInWithCredential(credential);

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCred.user.uid)
            .set({
          'username': userCred.user.displayName,
          'uid': userCred.user.uid,
          'imgURL': userCred.user.photoURL +
              "?type=large&access_token=" +
              result.accessToken.token,
          'provider': 'facebook',
          'userToken': userToken != null && userToken != "" ? userToken : ""
        }, SetOptions(merge: true));

        sharedPref.setString('username', userCred.user.displayName);
        sharedPref.setString('uid', userCred.user.uid);
        sharedPref.setString(
            'imgURL',
            userCred.user.photoURL +
                "?type=large&access_token=" +
                result.accessToken.token);
        sharedPref.setString('provider', 'facebook');
        sharedPref.setString('userToken', userToken);
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCred.user.uid)
            .get()
            .then((data) async {
          if (data.exists) {
            if (data.data()['address'] != null) {
              Map<String, dynamic> addressMap = data.data()['address'];
              if (addressMap['customername'] != null &&
                  addressMap['city'] != null &&
                  addressMap['region'] != null &&
                  addressMap['address'] != null &&
                  addressMap['mobile'] != null) {
                sharedPref.setString(
                    'customername', addressMap['customername']);
                sharedPref.setString('city', addressMap['city']);
                sharedPref.setString('region', addressMap['region']);
                sharedPref.setString('address', addressMap['address']);
                sharedPref.setString('mobile', addressMap['mobile']);
              }
            }

            await data.reference
                .collection('favorites')
                .orderBy('date', descending: true)
                .get()
                .then((value) {
              List<String> favList = [];
              if (value.docs.isNotEmpty) {
                value.docs.forEach((val) {
                  favList.add(val.id);
                });
              }
              print(value.docs);
              sharedPref.setStringList('favorite', favList);
            });
          }

          Navigator.pushNamed(context, '/homePage');
        });

        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() {
          loadingFacebook = false;
        });
        break;
      case FacebookLoginStatus.error:
        setState(() {
          loadingFacebook = false;
        });

        break;

      default:
        setState(() {
          loadingFacebook = false;
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedPref();
    getUserToken();

    apple.TheAppleSignIn.onCredentialRevoked.listen((_) {
      print("Credentials revoked");
    });
  }

  getUserToken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      userToken = value.toString();
    });
  }

  getSharedPref() async {
    sharedPref = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: <Widget>[
          Positioned(
              top: 0,
              left: 0,
              height: height * 0.3,
              width: width,
              child: Card(
                color: Color(0xFF232323),
                elevation: 8,
                margin: EdgeInsets.all(0),
                child: Image.asset(
                  'assets/images/giftDel.jpg',
                  fit: BoxFit.cover,
                ),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(width / 2),
                        bottomRight: Radius.circular(width / 2))),
              )),
          Positioned(
              top: 0,
              left: 0,
              height: height * 0.3,
              width: width,
              child: Card(
                margin: EdgeInsets.all(0),
                color: Colors.black38,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(width / 2),
                        bottomRight: Radius.circular(width / 2))),
              )),
          // Positioned(
          //       top: height * 0.1,
          //       width: width,
          //       child: Center(
          //           child: Image.asset(
          //         'assets/images/spark.png',
          //         width: width / 2,
          //         height: 60,
          //         fit: BoxFit.fill,
          //         color: Colors.white54,
          //       ))),
          Positioned(
              top: height * 0.1,
              width: width,
              child: Center(
                child: Text('Boxet',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: "Lobster",
                      color: Colors.white70,
                    )),
              )),
          Positioned(
              top: (height * 0.3) - 50,
              left: (width / 2) - 50,
              height: 100,
              width: 100,
              child: Image.asset(
                'assets/images/zzz.png',
                alignment: Alignment.center,
                fit: BoxFit.contain,
              )),
          Positioned(
              top: height * 0.4,
              left: width * 0.2,
              child: Column(children: <Widget>[
                Card(
                    margin: EdgeInsets.all(0),
                    elevation: 5,
                    child: Container(
                        width: width * 0.6,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        alignment: Alignment.center,
                        child: TextField(
                          onChanged: (text) {
                            username = text;
                          },
                          cursorColor: Colors.white54,
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(passwordNode);
                          },
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          decoration: InputDecoration(
                              isDense: true,
                              focusedBorder: InputBorder.none,
                              hintText: 'Username',
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 18)),
                        )),
                    color: Color(0xFF232323),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: emptyUsername || userDoesntExist
                            ? Colors.red
                            : Colors.white54,
                        width: 0.5,
                      ),
                    )),
                // Container(
                //     margin: EdgeInsets.only(top: 2, bottom: 2),
                //     width: width * 0.6,
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //         emptyUsername
                //             ? ' Please enter your username'
                //             : userDoesntExist ? ' Username doesnt exist' : '',
                //         style: TextStyle(color: Colors.red))),
                Card(
                    margin: EdgeInsets.only(top: 10),
                    elevation: 5,
                    child: Container(
                        width: width * 0.6,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        alignment: Alignment.center,
                        child: TextField(
                          obscureText: true,
                          focusNode: passwordNode,
                          cursorColor: Colors.white54,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          onSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          onChanged: (text) {
                            password = text;
                          },
                          decoration: InputDecoration(
                              isDense: true,
                              focusedBorder: InputBorder.none,
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 18)),
                        )),
                    color: Color(0xFF232323),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: emptyPassword || wrongPassword
                            ? Colors.red
                            : Colors.white54,
                        width: 0.5,
                      ),
                    )),
                // Container(
                //     margin: EdgeInsets.only(top: 2, bottom: 2),
                //     width: width * 0.6,
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //         emptyPassword
                //             ? ' Please enter your password'
                //             : wrongPassword ? ' Incorrect password' : '',
                //         style: TextStyle(color: Colors.red))),

                Container(
                  width: width * 0.6,
                  margin: EdgeInsets.only(
                    top: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          forgotUsername = '';
                          forgotPhone = '';
                          wrongForgotUsername = false;
                          wrongForgotPhone = false;
                          forgotErrorText = '';
                          sendingResetCode = false;
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) =>
                                  StatefulBuilder(builder: (context, setState) {
                                    return CustomDialog(
                                      key: customKey,
                                      title: Text('Forgot Password?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 22,
                                          )),
                                      content: Column(children: <Widget>[
                                        Card(
                                            margin: EdgeInsets.only(
                                              top: 15,
                                            ),
                                            elevation: 5,
                                            child: Container(
                                                width: (width * 0.7) + 8,
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                alignment: Alignment.center,
                                                child: TextField(
                                                  focusNode: forgotUserNode,
                                                  onChanged: (text) {
                                                    if (wrongForgotUsername) {
                                                      if (!wrongForgotPhone) {
                                                        forgotErrorText = '';
                                                      }
                                                      wrongForgotUsername =
                                                          false;
                                                    }
                                                    setState(() {
                                                      forgotUsername = text;
                                                    });
                                                  },
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                  onSubmitted: (_) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            forgotPhoneNode);
                                                  },
                                                  cursorColor: Colors.white54,
                                                  decoration: InputDecoration(
                                                      isDense: true,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      hintText: 'Username',
                                                      hintStyle: TextStyle(
                                                          color: Colors.white54,
                                                          fontSize: 18)),
                                                )),
                                            color: Color(0xff232323),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              side: BorderSide(
                                                color: wrongForgotUsername
                                                    ? Colors.red
                                                    : Colors.white,
                                                width: 0.5,
                                              ),
                                            )),
                                        Card(
                                            margin: EdgeInsets.only(
                                              top: 15,
                                            ),
                                            elevation: 5,
                                            child: Container(
                                                width: (width * 0.7) + 8,
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                alignment: Alignment.center,
                                                child: TextField(
                                                  keyboardType: Platform.isIOS
                                                      ? TextInputType.text
                                                      : TextInputType.phone,
                                                  focusNode: forgotPhoneNode,
                                                  onChanged: (text) {
                                                    setState(() {
                                                      if (wrongForgotPhone) {
                                                        if (!wrongForgotUsername) {
                                                          forgotErrorText = '';
                                                        }
                                                        wrongForgotPhone =
                                                            false;
                                                      }
                                                      forgotPhone = text;
                                                    });
                                                  },
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                  onSubmitted: (_) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  cursorColor: Colors.white54,
                                                  decoration: InputDecoration(
                                                      isDense: true,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      hintText: 'Mobile Number',
                                                      hintStyle: TextStyle(
                                                          color: Colors.white54,
                                                          fontSize: 18)),
                                                )),
                                            color: Color(0xff232323),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              side: BorderSide(
                                                color: wrongForgotPhone
                                                    ? Colors.red
                                                    : Colors.white,
                                                width: 0.5,
                                              ),
                                            )),
                                        Container(
                                            height:
                                                forgotErrorText == '' ? 0 : 20,
                                            width: (width * 0.7) + 8,
                                            margin: EdgeInsets.only(
                                                top: forgotErrorText == ''
                                                    ? 0
                                                    : 10),
                                            child: Text(forgotErrorText,
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16))),
                                        Card(
                                          color: Colors.transparent,
                                          elevation: 8,
                                          margin: EdgeInsets.only(
                                              top: forgotErrorText != ''
                                                  ? 10
                                                  : 20),
                                          clipBehavior: Clip.antiAlias,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Container(
                                            width: (width * 0.7) + 8,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                              colors: [
                                                Color.fromRGBO(18, 42, 76, 1),
                                                Color.fromRGBO(5, 150, 197, 1),
                                                Color.fromRGBO(18, 42, 76, 1),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )),
                                            child: Material(
                                              color: Colors.transparent,
                                              clipBehavior: Clip.antiAlias,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: InkWell(
                                                onTap: () async {
                                                  wrongForgotUsername = false;
                                                  wrongForgotPhone = false;
                                                  forgotErrorText = '';
                                                  setState(() {
                                                    sendingResetCode = true;
                                                  });

                                                  if (forgotUsername != null &&
                                                      forgotUsername
                                                          .isNotEmpty &&
                                                      forgotPhone != null &&
                                                      forgotPhone.isNotEmpty) {
                                                    bool exists =
                                                        await checkUser();
                                                    if (exists) {
                                                      if (forgotPhoneFromDB !=
                                                              null &&
                                                          forgotPhoneFromDB
                                                              .isNotEmpty) {
                                                        if (forgotPhone ==
                                                            forgotPhoneFromDB) {
                                                          customKey.currentState
                                                              .verifyPhone(
                                                                  forgotPhone,
                                                                  forgotUsername,
                                                                  uid);
                                                        } else {
                                                          setState(() {
                                                            forgotErrorText =
                                                                'Incorrect mobile number';
                                                            wrongForgotPhone =
                                                                true;
                                                            sendingResetCode =
                                                                false;
                                                          });
                                                        }
                                                      } else {
                                                        setState(() {
                                                          wrongForgotPhone =
                                                              true;
                                                          sendingResetCode =
                                                              false;
                                                          forgotErrorText =
                                                              'Incorrect mobile number';
                                                        });
                                                      }
                                                    } else {
                                                      setState(() {
                                                        sendingResetCode =
                                                            false;
                                                        forgotErrorText =
                                                            'Username doesnt exist';
                                                        wrongForgotUsername =
                                                            true;
                                                      });
                                                    }
                                                  } else {
                                                    forgotErrorText = '';

                                                    if (forgotUsername ==
                                                            null ||
                                                        forgotUsername
                                                            .isEmpty) {
                                                      wrongForgotUsername =
                                                          true;
                                                      forgotErrorText =
                                                          'Please enter your username';
                                                    }

                                                    if (forgotPhone == null ||
                                                        forgotPhone.isEmpty) {
                                                      wrongForgotPhone = true;
                                                      if (forgotErrorText ==
                                                          'Please enter your username') {
                                                        forgotErrorText =
                                                            'Please enter the missing data';
                                                      } else {
                                                        forgotErrorText =
                                                            'Please enter your mobile number';
                                                      }
                                                    }

                                                    setState(() {
                                                      sendingResetCode = false;
                                                    });
                                                  }
                                                },
                                                child: sendingResetCode == true
                                                    ? Center(
                                                        child: Container(
                                                            width: 15,
                                                            height: 15,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  new AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                              strokeWidth: 2,
                                                            )),
                                                      )
                                                    : Center(
                                                        child: Text('Send Code',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    1))),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                      iconData: MdiIcons.emoticonConfused,
                                    );
                                  }));
                        },
                        child: Container(
                            child: Text('Forgot Password?',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white))),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  width: width * 0.6,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(18, 42, 76, 1),
                          Color.fromRGBO(5, 150, 197, 1),
                          Color.fromRGBO(18, 42, 76, 1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
                  child: Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          checkingUsername = true;
                          emptyPassword = false;
                          emptyUsername = false;
                        });
                        if (username != null &&
                            password != null &&
                            username.trim().isNotEmpty &&
                            password.trim().isNotEmpty) {
                          usernamePasswordSign(username, password);
                        } else if ((password == null || password.isEmpty) &&
                            (username == null || username.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Color(0xFF232323),
                              content: Container(
                                height: 20,
                                width: width,
                                alignment: Alignment.center,
                                child: Text(
                                    'Please enter your username & password',
                                    style: TextStyle(fontSize: 16)),
                              )));
                          setState(() {
                            emptyUsername = true;
                            emptyPassword = true;
                            checkingUsername = false;
                          });
                        } else {
                          if (password == null || password.isEmpty) {
                            emptyPassword = true;
                          } else {
                            emptyPassword = false;
                          }
                          if (username == null || username.isEmpty) {
                            emptyUsername = true;
                          } else {
                            emptyUsername = false;
                          }

                          setState(() {
                            checkingUsername = false;
                          });

                          if (emptyPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Color(0xFF232323),
                                content: Container(
                                  height: 20,
                                  width: width,
                                  alignment: Alignment.center,
                                  child: Text(' Please enter your password',
                                      style: TextStyle(fontSize: 16)),
                                )));
                          } else if (emptyUsername) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Color(0xFF232323),
                                content: Container(
                                  height: 20,
                                  width: width,
                                  alignment: Alignment.center,
                                  child: Text(' Please enter your username',
                                      style: TextStyle(fontSize: 16)),
                                )));
                          }
                        }
                      },
                      child: checkingUsername == true
                          ? Center(
                              child: Container(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                    strokeWidth: 1,
                                  )),
                            )
                          : Center(
                              child: Text('LOGIN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1))),
                    ),
                  ),
                ),
                // Card(
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(50)),
                //     margin: EdgeInsets.only(top: 20),
                //     elevation: 5,
                //     color: Colors.tealAccent[700],
                //     child: Container(
                //         alignment: Alignment.center,
                //         width: width * 0.6,
                //         padding: EdgeInsets.only(
                //           top: 10,
                //           bottom: 10,
                //         ),
                //         child: Text('LOGIN',
                //             style: TextStyle(
                //               fontWeight: FontWeight.bold,
                //               color: Colors.white,
                //               fontSize: 18,
                //             )))),
              ])),
          Positioned(
              width: width,
              bottom: 10,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(top: 5, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                child: Text('Dont have account?',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white))),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => new Signup()));
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text('SIGN UP',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[400]))),
                            )
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 0),
                        height: 20,
                        width: width * 0.6,
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                          )),
                          Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Text('OR',
                                  style: TextStyle(color: Colors.white70))),
                          Expanded(
                              child: Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                          ))
                        ])),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(right: 5, bottom: 0),
                              child: new ElevatedButton(
                                style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(10),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blueAccent),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    )),
                                child: Container(
                                    width: 30,
                                    height: 30,
                                    child: loadingFacebook
                                        ? Center(
                                            child: Container(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.white),
                                                  strokeWidth: 1,
                                                )))
                                        : Image.asset(
                                            'assets/images/facebook.png')),
                                onPressed: () {
                                  setState(() {
                                    loadingFacebook = true;
                                  });
                                  _fbSignin(context);
                                },
                              )),
                          Container(
                              margin: EdgeInsets.only(left: 5, bottom: 0),
                              child: new ElevatedButton(
                                style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double>(10),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.redAccent),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    )),
                                child: Container(
                                    padding: EdgeInsets.all(5),
                                    width: 30,
                                    height: 30,
                                    child: loadingGoogle
                                        ? Center(
                                            child: Container(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.white),
                                                  strokeWidth: 1,
                                                )))
                                        : new Image.asset(
                                            'assets/images/googleicon.png')),
                                onPressed: () {
                                  setState(() {
                                    loadingGoogle = true;
                                  });
                                  _gSignIn().then((User user) async {
                                    if (user != null) {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(user.uid)
                                          .set({
                                        'username': user.displayName,
                                        'uid': user.uid,
                                        'imgURL': user.photoURL,
                                        'provider': 'google',
                                        'userToken':
                                            userToken != null && userToken != ""
                                                ? userToken
                                                : ""
                                      }, SetOptions(merge: true)).then(
                                              (value) async {
                                        sharedPref.setString(
                                            'username', user.displayName);
                                        sharedPref.setString('uid', user.uid);
                                        sharedPref.setString(
                                            'imgURL', user.photoURL);
                                        sharedPref.setString(
                                            'provider', 'google');
                                        sharedPref.setString(
                                            'userToken', userToken);

                                        await FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(user.uid)
                                            .get()
                                            .then((data) async {
                                          if (data.exists) {
                                            sharedPref.setString('username',
                                                data.data()['username']);
                                            sharedPref.setString(
                                                'uid', data.id);
                                            sharedPref.setString('imgURL',
                                                data.data()['imgURL']);
                                            sharedPref.setString(
                                                'provider', 'phone');

                                            if (data.data()['address'] !=
                                                null) {
                                              Map<String, dynamic> addressMap =
                                                  data.data()['address'];
                                              if (addressMap['customername'] !=
                                                      null &&
                                                  addressMap['city'] != null &&
                                                  addressMap['region'] !=
                                                      null &&
                                                  addressMap['address'] !=
                                                      null &&
                                                  addressMap['mobile'] !=
                                                      null) {
                                                sharedPref.setString(
                                                    'customername',
                                                    addressMap['customername']);
                                                sharedPref.setString(
                                                    'city', addressMap['city']);
                                                sharedPref.setString('region',
                                                    addressMap['region']);
                                                sharedPref.setString('address',
                                                    addressMap['address']);
                                                sharedPref.setString('mobile',
                                                    addressMap['mobile']);
                                              }
                                            }

                                            await data.reference
                                                .collection('favorites')
                                                .orderBy('date',
                                                    descending: true)
                                                .get()
                                                .then((value) {
                                              List<String> favList = [];
                                              if (value.docs.isNotEmpty) {
                                                value.docs.forEach((val) {
                                                  favList.add(val.id);
                                                });
                                              }
                                              sharedPref.setStringList(
                                                  'favorite', favList);
                                            });
                                          }
                                        });

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    new MyHomePage()));
                                      });
                                    }
                                  });
                                },
                              ))
                        ],
                      ),
                    ),
                    Platform.isIOS
                        ? SizedBox(
                            width: 280,
                            child: FutureBuilder<bool>(
                              future: _isAvailableFuture,
                              builder: (context, isAvailableSnapshot) {
                                return isAvailableSnapshot.data
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                            apple.AppleSignInButton(
                                              onPressed: logIn,
                                              style: apple.ButtonStyle.black,
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ])
                                    : Text(
                                        'Sign in With Apple not available. Must be run on iOS 13+');
                              },
                            ))
                        : Container()

                    // Container(child: SignInWithAppleButton(
                    //     onPressed: ()
                    // async {
                    //       final appleIdCredential =
                    //           await SignInWithApple.getAppleIDCredential(
                    //         scopes: [
                    //           AppleIDAuthorizationScopes.email,
                    //           AppleIDAuthorizationScopes.fullName,
                    //         ],

                    //       );
                    //       appleIdCredential.state  == state

                    //       final oAuthProvider=OAuthProvider('apple.com');
                    //       final credential=oAuthProvider.credential(idToken:appleIdCredential.identityToken,accessToken:appleIdCredential.authorizationCode);
                    //       await FirebaseAuth.instance.signInWithCredential(credential);

                    //       if (appleIdCredential!=null) {
                    //         await FirebaseFirestore.instance
                    //             .collection('Users')
                    //             .doc(appleIdCredential.userIdentifier)
                    //             .set({
                    //           'username': appleIdCredential.givenName,
                    //           'uid': appleIdCredential.userIdentifier,
                    //           'provider': 'appleid',
                    //           'userToken': appleIdCredential.userIdentifier
                    //         }, SetOptions(merge: true)).then((value) async {
                    //           sharedPref.setString(
                    //               'username', appleIdCredential.givenName);
                    //           sharedPref.setString(
                    //               'uid', appleIdCredential.userIdentifier);

                    //           sharedPref.setString('provider', 'appleid');
                    //           sharedPref.setString(
                    //               'userToken', appleIdCredential.userIdentifier);

                    //           await FirebaseFirestore.instance
                    //               .collection('Users')
                    //               .doc(appleIdCredential.userIdentifier)
                    //               .get()
                    //               .then((data) async {
                    //             if (data.exists) {
                    //               sharedPref.setString(
                    //                   'username', data.data()['username']);
                    //               sharedPref.setString('uid', data.id);
                    //               sharedPref.setString(
                    //                   'imgURL', data.data()['imgURL']);
                    //               sharedPref.setString(
                    //                   'provider', 'appleid');

                    //               if (data.data()['address'] != null) {
                    //                 Map<String, dynamic> addressMap =
                    //                     data.data()['address'];
                    //                 if (addressMap['customername'] !=
                    //                         null &&
                    //                     addressMap['city'] != null &&
                    //                     addressMap['region'] != null &&
                    //                     addressMap['address'] != null &&
                    //                     addressMap['mobile'] != null) {
                    //                   sharedPref.setString('customername',
                    //                       addressMap['customername']);
                    //                   sharedPref.setString(
                    //                       'city', addressMap['city']);
                    //                   sharedPref.setString(
                    //                       'region', addressMap['region']);
                    //                   sharedPref.setString(
                    //                       'address', addressMap['address']);
                    //                   sharedPref.setString(
                    //                       'mobile', addressMap['mobile']);
                    //                 }
                    //               }

                    //               await data.reference
                    //                   .collection('favorites')
                    //                   .orderBy('date', descending: true)
                    //                   .get()
                    //                   .then((value) {
                    //                 List<String> favList = [];
                    //                 if (value.docs.isNotEmpty) {
                    //                   value.docs.forEach((val) {
                    //                     favList.add(val.id);
                    //                   });
                    //                 }
                    //                 sharedPref.setStringList(
                    //                     'favorite', favList);
                    //               });
                    //             }
                    //           });

                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                   builder: (context) =>
                    //                       new MyHomePage()));
                    //         });
                    //       }

                    //       // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                    //       // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                    //     },
                    //   ))
                    // : Container()
                  ]))
        ]),
      ),
    ));
  }

  void logIn() async {
    final apple.AuthorizationResult result =
        await apple.TheAppleSignIn.performRequests([
      apple.AppleIdRequest(requestedScopes: [
        apple.Scope.email,
        apple.Scope.fullName,
      ])
    ]);

    switch (result.status) {
      case apple.AuthorizationStatus.authorized:
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(result.credential.identityToken),
            accessToken:
                String.fromCharCodes(result.credential.authorizationCode));
        UserCredential cred =
            await FirebaseAuth.instance.signInWithCredential(credential);

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(cred.user.uid)
            .set({
          'username': result.credential.fullName != null
              ? result.credential.fullName.givenName +
                  ' ' +
                  result.credential.fullName.familyName
              : result.credential.email,
          'uid': cred.user.uid,
          'provider': 'appleid',
          'imgURL': '',
          'userToken': userToken != null ? userToken : "",
        }, SetOptions(merge: true)).then((valuue) async {
          sharedPref.setString(
              'username',
              result.credential.fullName != null
                  ? result.credential.fullName.givenName +
                      ' ' +
                      result.credential.fullName.familyName
                  : result.credential.email);
          sharedPref.setString('uid', cred.user.uid);
          sharedPref.setString('imgURL', '');
          sharedPref.setString('provider', 'appleid');
          sharedPref.setString('userToken', userToken != null ? userToken : "");

          DocumentSnapshot snap = await FirebaseFirestore.instance
              .collection('Users')
              .doc(cred.user.uid)
              .get(GetOptions(source: Source.server));

          if (snap.exists) {
            if (snap.data()['address'] != null) {
              Map<String, dynamic> addressMap = snap.data()['address'];
              if (addressMap['customername'] != null &&
                  addressMap['city'] != null &&
                  addressMap['region'] != null &&
                  addressMap['address'] != null &&
                  addressMap['mobile'] != null) {
                sharedPref.setString(
                    'customername', addressMap['customername']);
                sharedPref.setString('city', addressMap['city']);
                sharedPref.setString('region', addressMap['region']);
                sharedPref.setString('address', addressMap['address']);
                sharedPref.setString('mobile', addressMap['mobile']);
              }
            }

            await snap.reference
                .collection('favorites')
                .orderBy('date', descending: true)
                .get()
                .then((val) {
              List<String> favList = [];
              if (val.docs.isNotEmpty) {
                val.docs.forEach((val) {
                  favList.add(val.id);
                });
              }
              sharedPref.setStringList('favorite', favList);
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Color(0xFF232323),
              content: Container(
                width: width,
                alignment: Alignment.center,
                child: Text(
                    'Welcome New User ' +
                        result.credential.fullName.givenName +
                        ' ' +
                        result.credential.fullName.familyName,
                    style: TextStyle(fontSize: 16)),
              )));

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => new MyHomePage()));
        });

        // Store user ID

        break;

      case apple.AuthorizationStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color(0xFF232323),
            content: Container(
              height: 20,
              width: width,
              alignment: Alignment.center,
              child: Text('Sign In failed, please try again',
                  style: TextStyle(fontSize: 16)),
            )));
        break;

      case apple.AuthorizationStatus.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color(0xFF232323),
            content: Container(
              height: 20,
              width: width,
              alignment: Alignment.center,
              child: Text('Sign in canceled, please Sign in to continue',
                  style: TextStyle(fontSize: 16)),
            )));
        break;
    }
  }
}
