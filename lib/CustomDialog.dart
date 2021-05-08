import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';


class CustomDialog extends StatefulWidget {
  final Text title;
  final Widget content;
  final IconData iconData;

  CustomDialog({Key key, this.title, this.content, this.iconData})
      : super(key: key);

  @override
  CustomDialogState createState() => CustomDialogState();
}

class CustomDialogState extends State<CustomDialog>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _controllerr;
  Animation animation,animationSuccess;
  String verificationId;
  bool refreshDialog = false;
  bool resetPassword = false;
  double width;
  String password='';
  String confirmPassword='';
  bool passwordError = false;
  bool confirmPasswordError = false;
  bool savingNewPassword = false;
  bool newPasswordsError=false;
  String uid;
  bool passwordUpdated = false;
  bool verified = false;
  bool showCode = false;
  bool wrongSMSCode = false;
  String firstDigit = '';
  String secondDigit = '';
  String thirdDigit = '';
  String forthDigit = '';
  String fifthDigit = '';
  String sixthDigit = '';
  FocusNode firstFocus = FocusNode();
  FocusNode secondFocus = FocusNode();
  FocusNode thirdFocus = FocusNode();
  FocusNode forthFocus = FocusNode();
  FocusNode fifthFocus = FocusNode();
  FocusNode sixthFocus = FocusNode();
  FocusNode newPasswordNode = FocusNode();
  FocusNode confirmNewPasswordNode = FocusNode();
  bool submittingCode = false;
  bool passwordsNotMatching = false;
  bool emptyCode=false;
  TextEditingController firstDigitController,
      secondDigitController,
      thirdDigitController,
      forthDigitController,
      fifthDigitController,
      sixthDigitController;

  Future<void> verifyPhone(
      String forgotPhone, String forgotUsername, String uidd) async {
    uid = uidd;

    // setState(() {
    //   refreshDialog = true;
    // });

    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout =
        (String verificationID) {
      verificationId = verificationID;
    };

    final PhoneCodeSent smsCodeSent =
        (String verificationSmsId, int forceCodeSent) {
      verificationId = verificationSmsId;
      if (!verified) {
        setState(() {
          // refreshDialog = false;
          showCode = true;
        });
      }
    };

    final PhoneVerificationCompleted verificationSuccess =
        (PhoneAuthCredential phoneCred) async {
      setState(() {
        print('verif success');
        if (showCode) showCode = false;
        verified = true;
        // refreshDialog = false;
        resetPassword = true;
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException ex) {
      print(ex);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+2' + forgotPhone,
        codeAutoRetrievalTimeout: autoRetrievalTimeout,
        codeSent: smsCodeSent,
        timeout: const Duration(milliseconds: 20000),
        verificationCompleted: verificationSuccess,
        verificationFailed: verificationFailed);
  }

  signinManual(String smscode) async {
    print(smscode);
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smscode,
    );

    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((userCred) {
      if (userCred.user != null) {
        resetPassword = true;
        if (showCode) showCode = false;
        verified = true;
      } else {
        wrongSMSCode = true;
      }

      setState(() {
        submittingCode = false;
      });
    }).catchError((e) {
      setState(() {
        wrongSMSCode = true;
        submittingCode = false;
      });
    });
  }

  @override
  void dispose() {

    _controllerr.dispose();
    _controller.dispose();
    firstDigitController.dispose();
    secondDigitController.dispose();
    thirdDigitController.dispose();
    forthDigitController.dispose();
    fifthDigitController.dispose();
    sixthDigitController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllerr = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    firstDigitController = TextEditingController();
    secondDigitController = TextEditingController();
    thirdDigitController = TextEditingController();
    forthDigitController = TextEditingController();
    fifthDigitController = TextEditingController();
    sixthDigitController = TextEditingController();

    animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

         animationSuccess = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllerr, curve: Curves.elasticOut));

    firstDigitController.addListener(() {
       if(wrongSMSCode){
        setState((){wrongSMSCode=false;});
      }
      if(emptyCode){
       setState((){emptyCode=false;});
      }
      if (firstDigit != firstDigitController.text) {
        if (firstDigitController.text.isNotEmpty&& secondDigitController.text.isEmpty) {
          
          FocusScope.of(context).requestFocus(secondFocus);
        }
        firstDigit = firstDigitController.text;
      }
    });

    secondDigitController.addListener(() {
       if(wrongSMSCode){
        setState((){wrongSMSCode=false;});
      }
      if(emptyCode){
       setState((){emptyCode=false;});
      }
      if (secondDigit != secondDigitController.text) {
        if (secondDigitController.text.isNotEmpty&& thirdDigitController.text.isEmpty) {
          
          FocusScope.of(context).requestFocus(thirdFocus);
        } else {
          // FocusScope.of(context).requestFocus(firstFocus);
        }
        secondDigit = secondDigitController.text;
      }
    });

    thirdDigitController.addListener(() {
       if(wrongSMSCode){
        setState((){wrongSMSCode=false;});
      }
      if(emptyCode){
       setState((){emptyCode=false;});
      }
      if (thirdDigit != thirdDigitController.text) {
        if (thirdDigitController.text.isNotEmpty&& forthDigitController.text.isEmpty) {
          
          FocusScope.of(context).requestFocus(forthFocus);
        } else {
          // FocusScope.of(context).requestFocus(secondFocus);
        }
        thirdDigit = thirdDigitController.text;
      }
    });
    forthDigitController.addListener(() {
       if(wrongSMSCode){
         setState((){wrongSMSCode=false;});
        
      }
      if(emptyCode){
       setState((){emptyCode=false;});
      }
      if (forthDigit != forthDigitController.text) {
        if (forthDigitController.text.isNotEmpty&& fifthDigitController.text.isEmpty) {
          
          FocusScope.of(context).requestFocus(fifthFocus);
        } else {
          // FocusScope.of(context).requestFocus(thirdFocus);
        }
        forthDigit = forthDigitController.text;
      }
    });
    fifthDigitController.addListener(() {
       if(wrongSMSCode){
        setState((){wrongSMSCode=false;});
      }
      if(emptyCode){
       setState((){emptyCode=false;});
      }
      if (fifthDigit != fifthDigitController.text) {
        if (fifthDigitController.text.isNotEmpty&& sixthDigitController.text.isEmpty) {
          
          FocusScope.of(context).requestFocus(sixthFocus);
        } else {
          // FocusScope.of(context).requestFocus(forthFocus);
        }
        fifthDigit = fifthDigitController.text;
      }
    });
    sixthDigitController.addListener(() {
      if(wrongSMSCode){
       setState((){wrongSMSCode=false;});
      }
      if(emptyCode){
       setState((){emptyCode=false;});
      }
      if (sixthDigit != sixthDigitController.text) {
        if (sixthDigitController.text.isNotEmpty) {
        } else {
          // FocusScope.of(context).requestFocus(fifthFocus);
        }
        sixthDigit = sixthDigitController.text;
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
   
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context));
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[

        
        Container(
            width: width - 50,
            padding: EdgeInsets.only(top: 55, left: 13, right: 13,),
            margin: EdgeInsets.only(top: 55),
            decoration: BoxDecoration(
                color: Color(0xFF181818),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0))
                ]),
            
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    passwordUpdated?Text('Success',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 22,
                            )):
                    showCode
                        ? Text('SMS Code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 22,
                            ))
                        : widget.title,

                    refreshDialog
                        ? Container(
                            height: 120,
                            child: Center(
                                child: Container(
                                    height: 60,
                                    width: 60,
                                    child: FlareActor('assets/loading.flr',
                                        animation: 'Loading'))))
                        : showCode
                            ? Container(
                                width: (width * 0.7) + 8,
                                child: Column(
                                  children: [
                                    Container(
                                      width: (width * 0.7) + 8,
                                      margin: EdgeInsets.only(
                                        top: 15,
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Card(
                                                child: Container(
                                                  width: (width * 0.7) / 8,
                                                  height: (width * 0.7) / 6,
                                                  child: TextField(keyboardType: TextInputType.phone,
                                                    onTap: () {
                                                      firstDigitController
                                                          .clear();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              firstFocus);
                                                    },
                                                    textAlign: TextAlign.center,
                                                    maxLength: 1,
                                                    
                                                    focusNode: firstFocus,
                                                    controller:
                                                        firstDigitController,
                                                    textAlignVertical:
                                                        TextAlignVertical.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: wrongSMSCode
                                                            ? Colors.red
                                                            : Colors.white),
                                                    // onSubmitted: (_) {
                                                    //   FocusScope.of(context).requestFocus(passwordFocus);
                                                    // },
                                                    cursorColor: Colors.white,
                                                    decoration: InputDecoration(
                                                        counterText: '',
                                                        isDense: true,enabledBorder: InputBorder.none,
                                                        
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: Colors.white54,
                                                            fontSize: 18)),
                                                  ),
                                                ),
                                                color: Color(0xff232323),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  side: BorderSide(
                                                    color: wrongSMSCode||emptyCode
                                                        ? Colors.red
                                                        : Colors.white,
                                                    width: 0.5,
                                                  ),
                                                )),
                                            Card(
                                                child: Container(
                                                  width: (width * 0.7) / 8,
                                                  height: (width * 0.7) / 6,
                                                  child: TextField(keyboardType: TextInputType.phone,
                                                    onTap: () {
                                                      secondDigitController
                                                          .clear();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              secondFocus);
                                                    },
                                                    textAlign: TextAlign.center,
                                                    maxLength: 1,
                                                    
                                                    focusNode: secondFocus,
                                                    controller:
                                                        secondDigitController,
                                                    textAlignVertical:
                                                        TextAlignVertical.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: wrongSMSCode
                                                            ? Colors.red
                                                            : Colors.white),
                                                    // onSubmitted: (_) {
                                                    //   FocusScope.of(context).requestFocus(passwordFocus);
                                                    // },
                                                    cursorColor: Colors.white,
                                                    decoration: InputDecoration(
                                                        counterText: '',
                                                        isDense: true,
                                                        enabledBorder:InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: Colors.white54,
                                                            fontSize: 18)),
                                                  ),
                                                ),
                                                color: Color(0xff232323),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  side: BorderSide(
                                                    color: wrongSMSCode||emptyCode
                                                        ? Colors.red
                                                        : Colors.white,
                                                    width: 0.5,
                                                  ),
                                                )),
                                            Card(
                                                child: Container(
                                                  width: (width * 0.7) / 8,
                                                  height: (width * 0.7) / 6,
                                                  child: TextField(keyboardType: TextInputType.phone,
                                                    onTap: () {
                                                      thirdDigitController
                                                          .clear();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              thirdFocus);
                                                    },
                                                    textAlign: TextAlign.center,
                                                    maxLength: 1,
                                                   
                                                    focusNode: thirdFocus,
                                                    controller:
                                                        thirdDigitController,
                                                    textAlignVertical:
                                                        TextAlignVertical.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: wrongSMSCode
                                                            ? Colors.red
                                                            : Colors.white),
                                                    // onSubmitted: (_) {
                                                    //   FocusScope.of(context).requestFocus(passwordFocus);
                                                    // },
                                                    cursorColor: Colors.white,
                                                    decoration: InputDecoration(
                                                        counterText: '',
                                                        enabledBorder:InputBorder.none,
                                                        isDense: true,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: Colors.white54,
                                                            fontSize: 18)),
                                                  ),
                                                ),
                                                color: Color(0xff232323),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  side: BorderSide(
                                                    color: wrongSMSCode||emptyCode
                                                        ? Colors.red
                                                        : Colors.white,
                                                    width: 0.5,
                                                  ),
                                                )),
                                            Card(
                                                child: Container(
                                                  width: (width * 0.7) / 8,
                                                  height: (width * 0.7) / 6,
                                                  child: TextField(keyboardType: TextInputType.phone,
                                                    onTap: () {
                                                      forthDigitController
                                                          .clear();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              forthFocus);
                                                    },
                                                    textAlign: TextAlign.center,
                                                    maxLength: 1,
                                                    
                                                    focusNode: forthFocus,
                                                    controller:
                                                        forthDigitController,
                                                    textAlignVertical:
                                                        TextAlignVertical.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: wrongSMSCode
                                                            ? Colors.red
                                                            : Colors.white),
                                                    // onSubmitted: (_) {
                                                    //   FocusScope.of(context).requestFocus(passwordFocus);
                                                    // },
                                                    cursorColor: Colors.white,
                                                    decoration: InputDecoration(
                                                        counterText: '',
                                                       enabledBorder:InputBorder.none,
                                                        isDense: true,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: Colors.white54,
                                                            fontSize: 18)),
                                                  ),
                                                ),
                                                color: Color(0xff232323),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  side: BorderSide(
                                                    color: wrongSMSCode||emptyCode
                                                        ? Colors.red
                                                        : Colors.white,
                                                    width: 0.5,
                                                  ),
                                                )),
                                            Card(
                                                child: Container(
                                                  width: (width * 0.7) / 8,
                                                  height: (width * 0.7) / 6,
                                                  child: TextField(keyboardType: TextInputType.phone,
                                                    textAlign: TextAlign.center,
                                                    maxLength: 1,
                                                   
                                                    focusNode: fifthFocus,
                                                    onTap: () {
                                                      fifthDigitController
                                                          .clear();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              fifthFocus);
                                                    },
                                                    controller:
                                                        fifthDigitController,
                                                    textAlignVertical:
                                                        TextAlignVertical.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: wrongSMSCode
                                                            ? Colors.red
                                                            : Colors.white),
                                                    // onSubmitted: (_) {
                                                    //   FocusScope.of(context).requestFocus(passwordFocus);
                                                    // },
                                                    cursorColor: Colors.white,
                                                    decoration: InputDecoration(
                                                        counterText: '',
                                                       enabledBorder:InputBorder.none,
                                                        isDense: true,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: Colors.white54,
                                                            fontSize: 18)),
                                                  ),
                                                ),
                                                color: Color(0xff232323),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  side: BorderSide(
                                                    color: wrongSMSCode||emptyCode
                                                        ? Colors.red
                                                        : Colors.white,
                                                    width: 0.5,
                                                  ),
                                                )),
                                            Card(
                                                child: Container(
                                                  width: (width * 0.7) / 8,
                                                  height: (width * 0.7) / 6,
                                                  child: TextField(keyboardType: TextInputType.phone,
                                                    textAlign: TextAlign.center,
                                                    focusNode: sixthFocus,
                                                    maxLength: 1,
                                                    
                                                    onTap: () {
                                                      sixthDigitController
                                                          .clear();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              sixthFocus);
                                                    },
                                                    controller:
                                                        sixthDigitController,
                                                    textAlignVertical:
                                                        TextAlignVertical.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: wrongSMSCode
                                                            ? Colors.red
                                                            : Colors.white),
                                                    cursorColor: Colors.white,
                                                    decoration: InputDecoration(
                                                        counterText: '',
                                                        enabledBorder:InputBorder.none,
                                                        isDense: true,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: Colors.white54,
                                                            fontSize: 18)),
                                                  ),
                                                ),
                                                color: Color(0xff232323),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  side: BorderSide(
                                                    color: wrongSMSCode||emptyCode
                                                        ? Colors.red
                                                        : Colors.white,
                                                    width: 0.5,
                                                  ),
                                                )),
                                          ]),
                                    ),
                                    emptyCode?Container(
                                            height: 20,
                                            width: (width * 0.7) + 8,
                                            margin: EdgeInsets.only(top: 10,left:5),
                                            child: Text('Please enter the code',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16)))
                                        :wrongSMSCode
                                        ? Container(
                                            height: 20,
                                            width: (width * 0.7) + 8,
                                            margin: EdgeInsets.only(top: 10,left:5),
                                            child: Text('Incorrect Code',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16)))
                                        : Container(height: 0, width: 0),
                                    Card(
                                      color: Colors.transparent,
                                      elevation: 8,
                                      margin: EdgeInsets.only(top: wrongSMSCode?10:20),
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
                                            Color.fromRGBO(18,42,76,1),
                                            Color.fromRGBO(5,150,197,1),
                                            Color.fromRGBO(18,42,76,1)
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
                                              setState(() {
                                                submittingCode = true;
                                              });

                                              if (firstDigit.isNotEmpty &&
                                                  secondDigit.isNotEmpty &&
                                                  thirdDigit.isNotEmpty &&
                                                  forthDigit.isNotEmpty &&
                                                  fifthDigit.isNotEmpty &&
                                                  sixthDigit.isNotEmpty) {
                                                signinManual(firstDigit +
                                                    secondDigit +
                                                    thirdDigit +
                                                    forthDigit +
                                                    fifthDigit +
                                                    sixthDigit);
                                              } else {
                                                setState(() {
                                                  submittingCode = false;
                                                  emptyCode=true;
                                                });
                                              }
                                            },
                                            child: submittingCode == true
                                                ? Center(
                                                    child: Container(
                                                        width: 15,
                                                        height: 15,
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                          strokeWidth: 2,
                                                        )),
                                                  )
                                                : Center(
                                                    child: Text('Submit',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 1))),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : resetPassword
                                ? Column(children: <Widget>[
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
                                              focusNode: newPasswordNode,
                                              obscureText: true,
                                              onChanged: (text) {
                                                setState(() {
                                                  if(newPasswordsError) newPasswordsError=false;
                                                  if(passwordError) passwordError=false;
                                                  password = text;
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
                                                        confirmNewPasswordNode);
                                              },
                                              cursorColor: Colors.white,
                                              decoration: InputDecoration(
                                                  isDense: true,
                                                  focusedBorder: InputBorder.none,
                                                  hintText: 'New Password',
                                                  hintStyle: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 18)),
                                            )),
                                        color: Color(0xff232323),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          side: BorderSide(
                                            color: passwordError
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
                                              obscureText: true,
                                              focusNode: confirmNewPasswordNode,
                                              onChanged: (text) {
                                                setState(() {
                                                  if(newPasswordsError) newPasswordsError=false;
                                                  if(confirmPasswordError)confirmPasswordError=false;
                                                  confirmPassword = text;
                                                });
                                              },
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                              onSubmitted: (_) {
                                                FocusScope.of(context).unfocus();
                                              },
                                              cursorColor: Colors.white,
                                              decoration: InputDecoration(
                                                  isDense: true,
                                                  focusedBorder: InputBorder.none,
                                                  hintText:
                                                      'Confirm New Password',
                                                  hintStyle: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 18)),
                                            )),
                                        color: Color(0xff232323),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          side: BorderSide(
                                            color: confirmPasswordError
                                                ? Colors.red
                                                : Colors.white,
                                            width: 0.5,
                                          ),
                                        )),
                                        newPasswordsError?Container(height: 20,
                                            width: (width * 0.7) + 8,
                                            margin: EdgeInsets.only(top: 10,left:5),
                                            child: Text('Passwords dont match',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16))):Container(height:0,width:0),
                                    Card(
                                      color: Colors.transparent,
                                      elevation: 8,
                                      margin: EdgeInsets.only(top: newPasswordsError?10:20),
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
                                            Color.fromRGBO(18,42,76,1),
                                            Color.fromRGBO(5,150,197,1),
                                            Color.fromRGBO(18,42,76,1)
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
                                              passwordError = false;
                                              confirmPasswordError = false;

                                              if (password != null &&
                                                  password.isNotEmpty &&
                                                  confirmPassword != null &&
                                                  confirmPassword.isNotEmpty &&
                                                  password == confirmPassword) {
                                                setState(() {
                                                  savingNewPassword = true;
                                                });
                                                await FirebaseFirestore.instance
                                                    .collection('UsersAuth')
                                                    .doc(uid)
                                                    .set({'password': password},
                                                        SetOptions(merge: true));
                                                setState(() {
                                                  savingNewPassword = false;
                                                  resetPassword = false;
                                                  passwordUpdated = true;
                                                });
                                                _controllerr.forward();
                                                Future.delayed(
                                                    Duration(milliseconds: 1000),
                                                    () {
                                                  Navigator.pop(context);
                                                });
                                              } else {
                                                savingNewPassword = false;

                                                if (password == null ||
                                                    password.isEmpty) {
                                                  passwordError = true;
                                                }

                                                if (confirmPassword == null ||
                                                    confirmPassword.isEmpty) {
                                                  confirmPasswordError = true;
                                                }

                                                if (password != confirmPassword) {
                                                  passwordError = true;
                                                  newPasswordsError=true;
                                                  confirmPasswordError = true;
                                                  passwordsNotMatching = true;
                                                }

                                                setState(() {});
                                              }
                                            },
                                            child: savingNewPassword == true
                                                ? Center(
                                                    child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                          strokeWidth: 2,
                                                        )),
                                                  )
                                                : Center(
                                                    child: Text('SUBMIT',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 1))),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ])
                                : passwordUpdated
                                    ? ScaleTransition(
                                        scale: animationSuccess,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,border: Border.all(color:Colors.white,width: 1),
                                                color: Colors.green),
                                            child: Icon(Icons.done_sharp,size: 30,
                                                color: Colors.white)))
                                    : Container(
                                        margin: EdgeInsets.only(top: 15),
                                        child: widget.content),
                    // Align(
                    //     alignment: Alignment.bottomCenter,
                    //     child: InkWell(
                    //         onTap: () {
                    //           Navigator.pop(context);
                    //         },
                    //         child: Container(child: Text('Got it'))))
                    SizedBox(height:26)
                  ],
                ),
              ),
            ),
            Positioned(right:10,top:65,child:GestureDetector(onTap:(){Navigator.pop(context);},child:Icon(Icons.close,color:Colors.white54,size:20))),
        Positioned(
            top: 0,
            left: 13,
            right: 13,
            child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF181818),
                  shape: BoxShape.circle,
                ),
                width: 110,
                height: 110,
                child: Align(
                  alignment: Alignment.center,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                        parent: _controller, curve: Curves.elasticOut)),
                    child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Color.fromRGBO(5,150,197,1),
                              Color.fromRGBO(18,42,76,1)
                            ],
                            center: Alignment.center,
                            radius: 1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.iconData,
                            color: Colors.white70, size: 50)),
                  ),
                )))
      ],
    );
  }
}
