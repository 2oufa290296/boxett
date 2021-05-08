import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssistantActivity extends StatefulWidget {
  @override
  _AssistantActivityState createState() => _AssistantActivityState();
}

class _AssistantActivityState extends State<AssistantActivity>
    with SingleTickerProviderStateMixin {
  double width, height;
  int age = 20;
  int startPrice = 100;
  int endPrice = 300;
  bool male = true;
  bool occasionError = false;
  bool relationError = false;
  bool sending = false;
  bool favoritesError = false;
  TextEditingController occasionController;
  TextEditingController favoritesController;
  TextEditingController relationController;

  FocusNode favoritesNode = FocusNode();
  FocusNode occasionNode = FocusNode();

  GlobalKey<ScaffoldState> assistantKey = GlobalKey<ScaffoldState>();
  AnimationController _controller;
  String uid = "";
  SharedPreferences sharedPref;

  @override
  void initState() {
    
    occasionController = TextEditingController();
    favoritesController = TextEditingController();
    relationController = TextEditingController();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _loadPref();
    super.initState();
  }

  @override
  void dispose() {
    
    occasionController.dispose();
    favoritesController.dispose();
    relationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  _loadPref() async {
    sharedPref = await SharedPreferences.getInstance();
    uid = sharedPref.getString('uid');
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Scaffold(
        key: assistantKey,
        appBar: PreferredSize(
            child: Container(
                height: 50,
                margin: EdgeInsets.only(top: 30),
                child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Icon(Icons.arrow_back_ios, color: Colors.white)),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text('Assistant',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: "Lobster",
                              letterSpacing: 2)))
                ]),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 3,
                        blurRadius: 4,
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(18,42,76,1),
                        Color.fromRGBO(5,150,197,1),
                        Color.fromRGBO(18,42,76,1)
                      ],
                    ))),
            preferredSize: Size(width, 50)),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                  height: (width / 2),
                  width: (width / 2),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    color: male ? Color(0xFF484848) : Color(0xFF232323),
                    child: InkWell(
                      onTap: () {
                        if (!male) {
                          setState(() {
                            male = true;
                          });
                        }
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(MdiIcons.genderMale,
                                size: 70, color: Colors.white),
                            SizedBox(height: 10),
                            Text('Male',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                    fontFamily: "Lobster",
                                    letterSpacing: 2))
                          ]),
                    ),
                  )),
              Container(
                  height: (width / 2),
                  width: (width / 2),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    color: male ? Color(0xFF232323) : Color(0xFF484848),
                    child: InkWell(
                      onTap: () {
                        if (male) {
                          setState(() {
                            male = false;
                          });
                        }
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(MdiIcons.genderFemale,
                                size: 70, color: Colors.white),
                            SizedBox(height: 10),
                            Text('Female',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                    fontFamily: "Lobster",
                                    letterSpacing: 2))
                          ]),
                    ),
                  ))
            ]),
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 5, right: 10, top: 10, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Age',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontFamily: "Lobster",
                                letterSpacing: 2)),
                        Text(age.toString(),
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70))
                      ],
                    ),
                  ),
                  Card(
                    color: Color(0xFF232323),
                    child: Slider(
                        min: 1,
                        max: 100,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                        value: age.toDouble(),
                        onChanged: (val) {
                          setState(() {
                            age = val.toInt();
                          });
                        }),
                  )
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 5, right: 10, top: 10, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Price',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontFamily: "Lobster",
                                letterSpacing: 2)),
                        Text(
                            startPrice.toString() +
                                ' - ' +
                                endPrice.toString() +
                                ' LE',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ))
                      ],
                    ),
                  ),
                  Card(
                    color: Color(0xFF232323),
                    child: RangeSlider(
                        values: RangeValues(
                            startPrice.toDouble(), endPrice.toDouble()),
                        min: 10.0,
                        max: 3000.0,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                        onChanged: (val) {
                          setState(() {
                            startPrice = val.start.toInt();
                            endPrice = val.end.toInt();
                          });
                        }),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 4, right: 4, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 10, bottom: 4),
                    child: Text('Relationship',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontFamily: "Lobster",
                            letterSpacing: 2)),
                  ),
                  Card(
                    margin: EdgeInsets.all(0),
                    color: Color(0xFF232323),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 5),
                      child: TextField(
                        onChanged: (a) {
                          setState(() {
                            if (relationError) {
                              relationError = false;
                            }
                          });
                        },
                        controller: relationController,
                        autofocus: false,
                        cursorColor: Colors.white54,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(occasionNode);
                        },
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38)),
                            errorText: relationError
                                ? 'Relationship cannot be empty'
                                : null,
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red)),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red)),
                            errorStyle: TextStyle(color: Colors.red),
                            isDense: true,
                            hintText: 'Brother, Sister, Fiancee, etc..',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 4, right: 4, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 10, bottom: 4),
                    child: Text('Occasion',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontFamily: "Lobster",
                            letterSpacing: 2)),
                  ),
                  Card(
                    margin: EdgeInsets.all(0),
                    color: Color(0xFF232323),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 5),
                      child: TextField(
                        focusNode: occasionNode,
                        onChanged: (a) {
                          setState(() {
                            if (occasionError) {
                              occasionError = false;
                            }
                          });
                        },
                        controller: occasionController,
                        autofocus: false,
                        cursorColor: Colors.white54,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(favoritesNode);
                        },
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38)),
                            errorText: occasionError
                                ? 'Occasion cannot be empty'
                                : null,
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red)),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red)),
                            errorStyle: TextStyle(color:Colors.red),
                            isDense: true,
                            hintText: 'Birthday, Graduation, etc..',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 4, right: 4, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 10, bottom: 4),
                    child: Text('Favorites',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontFamily: "Lobster",
                            letterSpacing: 2)),
                  ),
                  Card(
                    margin: EdgeInsets.all(0),
                    color: Color(0xFF232323),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 5),
                      child: TextField(
                        focusNode: favoritesNode,
                        controller: favoritesController,
                        autofocus: false,
                        cursorColor: Colors.white54,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                            isDense: true,
                            hintText: 'Hobbies, Colors, etc..',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  clipBehavior: Clip.antiAlias,
                  width: width * 0.4,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(18,42,76,1),
                          Color.fromRGBO(5,150,197,1),
                          Color.fromRGBO(18,42,76,1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (occasionController.text.isEmpty) {
                          occasionError = true;
                        } else {
                          occasionError = false;
                        }

                        if (relationController.text.isEmpty) {
                          relationError = true;
                        } else {
                          relationError = false;
                        }

                        if (occasionController.text.isNotEmpty &&
                            relationController.text.isNotEmpty) {
                          setState(() {
                            sending = true;
                          });
                          await FirebaseFirestore.instance
                              .collection('AssistantRequests')
                              .doc(uid).collection('requests').doc(DateTime.now().toString())
                              .set({
                            'gender': male ? 'male' : 'female',
                            'age': age,
                            'price': 'from: ' +
                                startPrice.toString() +
                                ' to: ' +
                                endPrice.toString(),
                            'relationship': relationController.text,
                            'occasion': occasionController.text,
                            'favorites': favoritesController.text
                          }, SetOptions(merge: true));
                          
                          Navigator.pushReplacementNamed(
                              context, '/assistantdone');
                        }
                        setState(() {
                          sending = false;
                        });
                      },
                      child: Center(
                          child: sending
                              ? Container(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                    strokeWidth: 1,
                                  ))
                              : Text('Submit',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1))),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ]),
        ));
  }
}
