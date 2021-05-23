import 'package:boxet/LoginState.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigningOut extends StatefulWidget {
  SigningOut({Key key}) : super(key: key);

  @override
  SigningOutState createState() => SigningOutState();
}

class SigningOutState extends State<SigningOut> with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _controllerr;
  Animation animation, animationSuccess;
  SharedPreferences sharedPref;
  bool signingOut = false;
  double width;

  String uid;

  @override
  void dispose() {
    _controllerr.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllerr = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    getSharedPref();

    animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    animationSuccess = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllerr, curve: Curves.elasticOut));

    _controller.forward();
  }

  getSharedPref() async {
    sharedPref = await SharedPreferences.getInstance();
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
          padding: EdgeInsets.only(
            top: 55,
            left: 13,
            right: 13,
          ),
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
                Text('Sign Out',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                signingOut
                    ? Container(
                        height: 60,
                        width: 60,
                        child: FlareActor('assets/loading.flr',
                            animation: 'Loading'))
                    : Container(
                        child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            child: Text('Are you sure you want to Sign Out?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    signingOut = true;
                                  });

                                  Future.delayed(Duration(milliseconds: 2000),
                                      () async {
                                    sharedPref.clear();
                                    final auth = Provider.of<LoginState>(
                                        context,
                                        listen: false);
                                    await auth.logout();
                                    signingOut = false;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 15, top: 15),
                                  height: 40,
                                  width: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.green),
                                  child: Text('YES',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 15),
                                  height: 40,
                                  width: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey),
                                  child: Text('NO',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                SizedBox(height: 26)
              ],
            ),
          ),
        ),
        Positioned(
            right: 10,
            top: 65,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close, color: Colors.white54, size: 20))),
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
                              Color.fromRGBO(5, 150, 197, 1),
                              Color.fromRGBO(18, 42, 76, 1)
                            ],
                            center: Alignment.center,
                            radius: 1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(MdiIcons.logout,
                            color: Colors.white70, size: 50)),
                  ),
                )))
      ],
    );
  }
}
