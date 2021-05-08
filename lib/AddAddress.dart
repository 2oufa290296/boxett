import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAddress extends StatefulWidget {
  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  TextEditingController cityController;
  TextEditingController customerController;
  TextEditingController regionController;
  TextEditingController addressController;
  TextEditingController mobileController;
  bool customerError = false;
  bool cityError = false;
  bool regionError = false;
  bool addressError = false;
  bool mobileError = false;
  SharedPreferences sharedPref;
  String uid = "";
  String customerName = "";
  String city = "";
  String region = "";
  String address = "";
  String mobile = "";
  bool showProgressBar = true;
  bool changed = false;
  double width, height;
  FocusNode cityNode = FocusNode();
  FocusNode regionNode = FocusNode();
  FocusNode addressNode = FocusNode();
  FocusNode mobileNode = FocusNode();

  @override
  void initState() {
    cityController = new TextEditingController();
    customerController = new TextEditingController();
    regionController = new TextEditingController();
    addressController = new TextEditingController();
    mobileController = new TextEditingController();
    _loadPref();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    customerController.dispose();
    mobileController.dispose();
    addressController.dispose();
    regionController.dispose();
    cityController.dispose();
  }

  _loadPref() async {
    sharedPref = await SharedPreferences.getInstance();
    uid = sharedPref.getString('uid');
    customerName = sharedPref.getString('customername');
    city = sharedPref.getString('city');
    region = sharedPref.getString('region');
    address = sharedPref.getString('address');
    mobile = sharedPref.getString('mobile');

    setState(() {
      customerController.text = customerName;
      cityController.text = city;
      regionController.text = region;
      addressController.text = address;
      mobileController.text = mobile;
      showProgressBar = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: <Widget>[
        Positioned(
          top: 80,
          left: 0,
          height: height - 80,
          width: width,
          child: showProgressBar
              ? Center(child:  Container(
                    width: 50,
                    height: 50,
                    child: FlareActor(
                      'assets/loading.flr',
                      animation: 'Loading',
                    )))
              : Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Card(
                    margin:
                        EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 10),
                    color: Color(0xFF232323),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: TextField(
                        onChanged: (a) {
                          setState(() {
                            if (customerError) {
                              customerError = false;
                            }
                            changed = true;
                          });
                        },
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(cityNode);
                        },
                        controller: customerController,
                        autofocus: false,
                        cursorColor: Colors.white54,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.person,
                              color: Colors.white70,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38)),
                            labelText: 'Customer',
                            errorText: customerError
                                ? 'Customer cannot be empty'
                                : null,
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorStyle: TextStyle(color: Colors.red[600]),
                            labelStyle: TextStyle(color: Colors.white70),
                            isDense: true,
                            hintText: 'Enter Your Name',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Color(0xFF232323),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: TextField(
                        focusNode: cityNode,
                        onChanged: (a) {
                          setState(() {
                            if (cityError) {
                              cityError = false;
                            }
                            changed = true;
                          });
                        },
                        controller: cityController,
                        autofocus: false,
                        cursorColor: Colors.white54,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(regionNode);
                        },
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.location_city,
                              color: Colors.white70,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38)),
                            errorText:
                                cityError ? 'City cannot be empty' : null,
                            labelText: 'City',
                            labelStyle: TextStyle(color: Colors.white70),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color:Colors.red[600])),
                            errorStyle: TextStyle(color: Colors.red[600]),
                            isDense: true,
                            hintText: 'Alexandria, Cairo, etc..',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Color(0xFF232323),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: TextField(
                        focusNode: regionNode,
                        onChanged: (a) {
                          setState(() {
                            if (regionError) {
                              regionError = false;
                            }
                            changed = true;
                          });
                        },
                        controller: regionController,
                        autofocus: false,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(addressNode);
                        },
                        cursorColor: Colors.white54,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.home,
                              color: Colors.white70,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38)),
                            labelText: 'Region',
                            labelStyle: TextStyle(color: Colors.white70),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorStyle: TextStyle(color: Colors.red[600]),
                            errorText:
                                regionError ? 'Region cannot be empty' : null,
                            isDense: true,
                            hintText: 'Smouha, Roushdy, etc..',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Color(0xFF232323),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: TextField(
                        focusNode: addressNode,
                        onChanged: (a) {
                          setState(() {
                            if (addressError) {
                              addressError = false;
                            }
                            changed = true;
                          });
                        },
                        controller: addressController,
                        autofocus: false,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(mobileNode);
                        },
                        cursorColor: Colors.white54,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.location_on,
                              color: Colors.white70,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white38)),
                            labelText: 'Address',
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorStyle: TextStyle(color: Colors.red[600]),
                            errorText:
                                addressError ? 'Address cannot be empty' : null,
                            labelStyle: TextStyle(color: Colors.white70),
                            isDense: true,
                            hintText: 'Enter Your Address',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Color(0xFF282828),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: TextField(
                        focusNode: mobileNode,
                        onChanged: (a) {
                          setState(() {
                            if (mobileError) {
                              mobileError = false;
                            }
                            changed = true;
                          });
                        },
                        controller: mobileController,
                        autofocus: false,
                        cursorColor: Colors.white54,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        keyboardType: Platform.isIOS?TextInputType.text:TextInputType.phone,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.phone_android,
                              color: Colors.white70,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white38),
                            ),
                            labelText: 'Mobile',
                            labelStyle: TextStyle(color: Colors.white70),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red[600])),
                            errorStyle: TextStyle(color: Colors.red[600]),
                            errorText:
                                mobileError ? 'Mobile cannot be empty' : null,
                            isDense: true,
                            hintText: 'Enter Your Mobile Number',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      changed ? Container(
                        margin: EdgeInsets.only(bottom: 20),
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
                              if (changed) {
                                if (customerController.text.isEmpty) {
                                  customerError = true;
                                } else {
                                  customerError = false;
                                }

                                if (cityController.text.isEmpty) {
                                  cityError = true;
                                } else {
                                  cityError = false;
                                }

                                if (regionController.text.isEmpty) {
                                  regionError = true;
                                } else {
                                  regionError = false;
                                }

                                if (addressController.text.isEmpty) {
                                  addressError = true;
                                } else {
                                  addressError = false;
                                }

                                if (mobileController.text.isEmpty) {
                                  mobileError = true;
                                } else {
                                  mobileError = false;
                                }

                                if (customerController.text.isNotEmpty &&
                                    cityController.text.isNotEmpty &&
                                    regionController.text.isNotEmpty &&
                                    addressController.text.isNotEmpty &&
                                    mobileController.text.isNotEmpty) {
                                  sharedPref.setString(
                                      'customername', customerController.text);
                                  sharedPref.setString(
                                      'city', cityController.text);
                                  sharedPref.setString(
                                      'region', regionController.text);
                                  sharedPref.setString(
                                      'address', addressController.text);
                                  sharedPref.setString(
                                      'mobile', mobileController.text);
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(uid)
                                      .set({
                                    'address': {
                                      'customername': customerController.text,
                                      'city': cityController.text,
                                      'region': regionController.text,
                                      'address': addressController.text,
                                      'mobile': mobileController.text
                                    }
                                  }, SetOptions(merge: true));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      backgroundColor: Color(0xFF232323),
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            height: 20,
                                            child: Text(
                                                'Address added successfully',
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                          ScaleTransition(
                                              scale: Tween(begin: 0.0, end: 1.0)
                                                  .animate(CurvedAnimation(
                                                      parent: _controller,
                                                      curve:
                                                          Curves.elasticOut)),
                                              child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.green),
                                                  child: Icon(Icons.done,
                                                      color: Colors.white)))
                                        ],
                                      )));
                                      _controller.forward();
                                  Future.delayed(Duration(milliseconds: 1000),
                                      () {
                                    Navigator.pop(context, true);
                                  });
                                }
                                setState(() {});
                              } else {
                                Navigator.pop(context, true);
                              }
                            },
                            child: Center(
                                child: Text('Save',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1))),
                          ),
                        ),
                      ):Container(),
                    ],
                  ),
                ]),
        ),
        Positioned(
          top: 30,
          left: 0,
          child: Container(
            height: 50,
            width: width,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 1,
                  )
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(18,42,76,1),
                    Color.fromRGBO(5,150,197,1),
                    Color.fromRGBO(18,42,76,1)
                  ],
                )),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Icon(Icons.arrow_back_ios, color: Colors.white)),
                ),
                Container(
                    margin: EdgeInsets.only(left: 25),
                    child: Text('Delivery Address',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: "Lobster",
                                    letterSpacing: 2)))
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
