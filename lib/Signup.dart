import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:boxet/CustomOtp.dart';
import 'package:boxet/main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;
  String firstname;
  String lastname;
  String phone;
  String password;
  String passwordconf;
  String username;
  String verificationId;
  bool firstError = false;
  bool lastError = false;
  bool userError = false;
  bool passwordError = false;
  bool phoneError = false;
  bool showprogress = false;
  bool passwordConfError = false;
  bool male = true;
  File _image;
  final picker = ImagePicker();
  UploadTask uploadTask;
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  String imageLink = "";
  FocusNode lastFocus = FocusNode();
  FocusNode userFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  String gender = "";
  String userToken = "";

  @override
  void initState() {
    super.initState();
    getUserToken();
    // animationController =
    //     new AnimationController(duration: Duration(seconds: 2), vsync: this);
    // animation = Tween(begin: -2.0, end: 0.0).animate(CurvedAnimation(
    //     parent: animationController, curve: Curves.fastOutSlowIn));

    // animationController.forward();
  }

  getUserToken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      userToken = value.toString();
    });
  }

  // Future smsCodeFn(BuildContext context) {
  //   // signinManual(String smscode) {
  //   //   final AuthCredential credential = PhoneAuthProvider.credential(
  //   //     verificationId: verificationId,
  //   //     smsCode: smscode,
  //   //   );

  //   //   // FirebaseAuth.instance.signInWithCredential(credential).then((user) {
  //   //   //   Navigator.pushNamed(context, 'Login');
  //   //   // }).catchError((e) {});
  //   // }

  //   // return showDialog(

  //   //   context: context,
  //   //   builder: (BuildContext context) => CustomDialog(
  //   //         title: "Code Verification",
  //   //         description:
  //   //             "Please Verify Your Code",
  //   //         buttonText: "Verify",
  //   //       ),
  //   // );
  // }

  void saveUser(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
    prefs.setString('provider', 'phone');
    prefs.setString('username', firstname.trim() + " " + lastname.trim());
    prefs.setString('imgURL', imageLink);
    prefs.setString('gender', gender);
    prefs.setString('userToken', userToken);

    await FirebaseFirestore.instance
        .collection('UsersAuth')
        .doc(uid)
        .set({'username': username, 'password': password, 'Mobile': phone});

    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'username': firstname.trim() + " " + lastname.trim(),
      'imgURL': imageLink,
      'provider': 'phone',
      'Password': password,
      'gender': gender,
      'userToken': userToken
    });

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => new MyHomePage()));
  }

  Future<bool> checkUser() async {
    bool exists;
    await FirebaseFirestore.instance
        .collection('UsersAuth')
        .where('username', isEqualTo: username)
        .get()
        .then((data) {
      if (data.docs.isNotEmpty) {
        exists = true;
      } else {
        exists = false;
      }
    });

    return exists;
  }

  Future<bool> checkPhone() async {
    bool exists;
    await FirebaseFirestore.instance
        .collection('UsersAuth')
        .where('Mobile', isEqualTo: phone)
        .get()
        .then((data) {
      if (data.docs.isNotEmpty) {
        exists = true;
      } else {
        exists = false;
      }
    });

    return exists;
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout =
        (String verificationID) {
      verificationId = verificationID;
    };

    final PhoneCodeSent smsCodeSent =
        (String verificationSmsId, int forceCodeSent) {
      verificationId = verificationSmsId;

      setState(() {
        showprogress = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Otp(
                  verificationId: verificationId,
                  phone: phone,
                  forceToken: forceCodeSent,
                  userName: username,
                  password: password,
                  imageLink: imageLink,
                  displayName: firstname.trim() + " " + lastname.trim(),
                  gender: gender)));
    };

    final PhoneVerificationCompleted verificationSuccess =
        (PhoneAuthCredential phoneCred) async {
      UserCredential userCred = await _fAuth.signInWithCredential(phoneCred);
      saveUser(userCred.user.uid);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException ex) {
      setState(() {
        showprogress = false;
        phoneError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Color(0xFF232323),
          content:
              Text('Invalid mobile number', style: TextStyle(fontSize: 16))));
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+2' + phone,
        codeAutoRetrievalTimeout: autoRetrievalTimeout,
        codeSent: smsCodeSent,
        timeout: const Duration(milliseconds: 10000),
        verificationCompleted: verificationSuccess,
        verificationFailed: verificationFailed);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        maxWidth: MediaQuery.of(context).size.width);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {}
    });
  }

  Future _uploadImage(File imageFile) async {
    var now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmss');
    String imgName = formatter.format(now);
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("UsersImages")
        .child(imgName + ".jpg");
    uploadTask = ref.putFile(imageFile);

    uploadTask.snapshotEvents.listen((event) async {
      if (event.state == TaskState.success) {
        imageLink = await (await uploadTask.whenComplete(() => null))
            .ref
            .getDownloadURL();
        verifyPhone();
      } else if (event.state == TaskState.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color(0xFF232323),
            content: Text('Uploading image failed, please try again',
                style: TextStyle(fontSize: 16))));
        setState(() {
          showprogress = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(leading: null,automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          actions: [InkWell(onTap:(){Navigator.of(context).pop();},child: Container(margin:EdgeInsets.all(25),child: Icon(Icons.close_rounded, color: Colors.white70)))],
        ),
        body: GestureDetector(onTap:(){if(FocusScope.of(context).hasFocus){FocusScope.of(context).unfocus();}},
                  child: Container(
            height: height,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10, width: width),
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(1),
                      height: 120,
                      width: 120,
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Card(
                              margin: EdgeInsets.all(0),
                              color: Color(0xff232323),
                              shape: CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                  onTap: getImage,
                                  child: _image != null
                                      ? Image.file(_image, fit: BoxFit.cover)
                                      : Image.asset(
                                          male
                                              ? 'assets/images/profile.png'
                                              : 'assets/images/profilef.png',
                                        )),
                            ),
                          ),
                          Positioned(
                              left: 0,
                              top: 0,
                              child: _image == null
                                  ? InkWell(
                                      onTap: getImage,
                                      child: Icon(
                                        Icons.add_a_photo,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    )
                                  : Container(height: 0, width: 0))
                        ],
                      )),
                  _image == null
                      ? Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  if (!male) {
                                    setState(() {
                                      male = true;
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                      width: male ? 10.0 : 8.0,
                                      height: male ? 10.0 : 8.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: male
                                            ? Colors.white70
                                            : Color(0xff383838),
                                      )),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (male) {
                                    setState(() {
                                      male = false;
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: !male ? 10.0 : 8.0,
                                    height: !male ? 10.0 : 8.0,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: !male
                                            ? Colors.white70
                                            : Color(0xff383838)),
                                  ),
                                ),
                              )
                            ],
                          ))
                      : Container(height: 0, width: 0),
                  Container(
                      margin: EdgeInsets.only(top: 35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Card(
                              margin: EdgeInsets.only(
                                right: 4,
                              ),
                              elevation: 5,
                              child: Container(
                                  width: width * 0.35,
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  alignment: Alignment.center,
                                  child: TextField(
                                    onChanged: (text) {
                                      setState(() {
                                        firstname = text;
                                      });
                                    },
                                    textCapitalization: TextCapitalization.words,
                                    textAlignVertical: TextAlignVertical.center,
                                    onSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(lastFocus);
                                    },
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        focusedBorder: InputBorder.none,
                                        hintText: 'Firstname',
                                        hintStyle: TextStyle(
                                            color: Colors.white54, fontSize: 18)),
                                  )),
                              color: Color(0xff232323),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(
                                  color: firstError ? Colors.red : Colors.white,
                                  width: 0.5,
                                ),
                              )),
                          Card(
                              margin: EdgeInsets.only(
                                left: 4,
                              ),
                              elevation: 5,
                              child: Container(
                                  width: width * 0.35,
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  alignment: Alignment.center,
                                  child: TextField(
                                    focusNode: lastFocus,
                                    onChanged: (text) {
                                      setState(() {
                                        lastname = text;
                                      });
                                    },
                                    textAlignVertical: TextAlignVertical.center,
                                    textCapitalization: TextCapitalization.words,
                                    onSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(userFocus);
                                    },
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        focusedBorder: InputBorder.none,
                                        hintText: 'Lastname',
                                        hintStyle: TextStyle(
                                            color: Colors.white54, fontSize: 18)),
                                  )),
                              color: Color(0xff232323),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(
                                  color: lastError ? Colors.red : Colors.white,
                                  width: 0.5,
                                ),
                              )),
                        ],
                      )),
                  Card(
                      margin: EdgeInsets.only(
                        top: 15,
                      ),
                      elevation: 5,
                      child: Container(
                          width: (width * 0.7) + 8,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          child: TextField(
                            focusNode: userFocus,
                            onChanged: (text) {
                              setState(() {
                                username = text;
                              });
                            },
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            onSubmitted: (_) {
                              FocusScope.of(context).requestFocus(passwordFocus);
                            },
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                                isDense: true,
                                focusedBorder: InputBorder.none,
                                hintText: 'Username',
                                hintStyle: TextStyle(
                                    color: Colors.white54, fontSize: 18)),
                          )),
                      color: Color(0xff232323),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                          color: userError ? Colors.red : Colors.white,
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
                          padding: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          child: TextField(
                            focusNode: passwordFocus,
                            onChanged: (text) {
                              setState(() {
                                password = text;
                              });
                            },
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            obscureText: true,
                            onSubmitted: (_) {
                              FocusScope.of(context).requestFocus(confirmFocus);
                            },
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                                isDense: true,
                                focusedBorder: InputBorder.none,
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                    color: Colors.white54, fontSize: 18)),
                          )),
                      color: Color(0xff232323),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                          color: passwordError ? Colors.red : Colors.white,
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
                          padding: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          child: TextField(
                            focusNode: confirmFocus,
                            onChanged: (text) {
                              setState(() {
                                passwordconf = text;
                              });
                            },
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            obscureText: true,
                            onSubmitted: (_) {
                              FocusScope.of(context).requestFocus(phoneFocus);
                            },
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                                isDense: true,
                                focusedBorder: InputBorder.none,
                                hintText: 'Confirm password',
                                hintStyle: TextStyle(
                                    color: Colors.white54, fontSize: 18)),
                          )),
                      color: Color(0xff232323),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                          color: passwordConfError ? Colors.red : Colors.white,
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
                          padding: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          child: TextField(
                            focusNode: phoneFocus,
                            onChanged: (text) {
                              setState(() {
                                phone = text;
                              });
                            },
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            cursorColor: Colors.white,
                            keyboardType: Platform.isIOS
                                ? TextInputType.text
                                : TextInputType.phone,
                            onSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                            },
                            decoration: InputDecoration(
                                isDense: true,
                                focusedBorder: InputBorder.none,
                                hintText: 'Mobile Number',
                                hintStyle: TextStyle(
                                    color: Colors.white54, fontSize: 18)),
                          )),
                      color: Color(0xff232323),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                          color: phoneError ? Colors.red : Colors.white,
                          width: 0.5,
                        ),
                      )),
                  Card(
                    color: Colors.transparent,
                    elevation: 8,
                    margin: EdgeInsets.only(top: 20),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: (width * 0.7) + 8,
                      height: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(18, 42, 76, 1),
                          Color.fromRGBO(5, 150, 197, 1),
                          Color.fromRGBO(18, 42, 76, 1)
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
                          onTap: () async {
                            setState(() {
                              firstError = false;
                              lastError = false;
                              userError = false;
                              passwordError = false;
                              phoneError = false;
                              showprogress = false;
                              passwordConfError = false;
                            });
                            if (username != null &&
                                username.isNotEmpty &&
                                firstname != null &&
                                firstname.isNotEmpty &&
                                lastname != null &&
                                lastname.isNotEmpty &&
                                phone != null &&
                                phone.isNotEmpty &&
                                password != null &&
                                password.isNotEmpty &&
                                passwordconf != null &&
                                passwordconf.isNotEmpty &&
                                password == passwordconf) {
                              setState(() {
                                firstError = false;
                                lastError = false;
                                userError = false;
                                phoneError = false;
                                passwordError = false;
                                passwordConfError = false;
                                showprogress = true;
                              });

                              bool exists = await checkUser();
                              if (exists) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor: Color(0xFF232323),
                                        content: Text('Username already exists',
                                            style: TextStyle(fontSize: 16))));
                                setState(() {
                                  showprogress = false;
                                  userError = true;
                                });
                              } else {
                                bool phoneExists = await checkPhone();
                                if (phoneExists) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      backgroundColor: Color(0xFF232323),
                                      content: Text(
                                          'Cant use the same mobile number with more than one account',
                                          style: TextStyle(fontSize: 16))));
                                  setState(() {
                                    showprogress = false;
                                    phoneError = true;
                                  });
                                } else {
                                  if (_image != null) {
                                    _uploadImage(_image);
                                  } else {
                                    setState(() {
                                      if (male) {
                                        gender = 'male';
                                      } else {
                                        gender = 'female';
                                      }
                                    });
                                    verifyPhone();
                                  }
                                }
                              }
                            } else {
                              if (phone == null || phone.isEmpty) {
                                setState(() {
                                  phoneError = true;
                                });
                              }

                              if (username == null || username.isEmpty) {
                                setState(() {
                                  userError = true;
                                });
                              }

                              if (password == null || password.isEmpty) {
                                setState(() {
                                  passwordError = true;
                                });
                              }

                              if (passwordconf == null || passwordconf.isEmpty) {
                                setState(() {
                                  passwordConfError = true;
                                });
                              }

                              if (password != passwordconf) {
                                setState(() {
                                  passwordError = true;
                                  passwordConfError = true;
                                });
                              }

                              if (firstname == null || firstname.isEmpty) {
                                setState(() {
                                  firstError = true;
                                });
                              }

                              if (lastname == null || lastname.isEmpty) {
                                setState(() {
                                  lastError = true;
                                });
                              }

                              if (password != passwordconf) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor: Color(0xFF232323),
                                        content: Text('Passwords dont match',
                                            style: TextStyle(fontSize: 16))));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor: Color(0xFF232323),
                                        content: Text(
                                            'Please fill the empty fields',
                                            style: TextStyle(fontSize: 16))));
                              }
                            }
                          },
                          child: showprogress == true
                              ? Center(
                                  child: Container(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      )),
                                )
                              : Center(
                                  child: Text('SIGN UP',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
