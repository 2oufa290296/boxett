import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class AddReview extends StatefulWidget {
  final String orderId, giftImg, giftId, parameter;

  AddReview(this.orderId, this.giftImg, this.giftId, this.parameter);

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  final addReviewKey = GlobalKey<ScaffoldState>();
  double width, height;
  double onTime, materialQuality, worthPrice, goodPackaging;
  TextEditingController reviewController;
  bool first = false;
  bool second = false;
  bool third = false;
  bool forth = false;
  String displayName;
  String userImg;
  bool uploading = false;
  String uid = "";

  SharedPreferences sharedPref;

  Future _getUserData() async {
    sharedPref = await SharedPreferences.getInstance();
    displayName = sharedPref.getString('username');
    userImg = sharedPref.getString('imgURL');
    uid = sharedPref.getString('uid');
  }

  @override
  void initState() {
    super.initState();
    reviewController = TextEditingController();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _getUserData();
  }

  @override
  void dispose() {
    
    super.dispose();
    reviewController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        key: addReviewKey,
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
                      child: Text('Add Review',
                          style: TextStyle(color: Colors.white, fontSize: 20,fontFamily:"Lobster",letterSpacing:1)))
                ]),
                decoration: BoxDecoration(boxShadow: [
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
                     Color.fromRGBO(18, 42, 76, 1),
                                      Color.fromRGBO(5, 150, 197, 1),
                                      Color.fromRGBO(18, 42, 76, 1),
                  ],
                ))),
            preferredSize: Size(width, 50)),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Card(
              color: Colors.transparent,
              elevation: 5,
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: width,
                height: height / 4,
                child: CachedNetworkImage(
                  imageUrl: widget.giftImg,
                  fit: BoxFit.cover,
                  height: height / 4,
                  width: width,
                  progressIndicatorBuilder: (context, url, progress) {
                    return Shimmer.fromColors(
                      enabled: true,
                      child: Container(
                          height: height / 4,
                          width: width,
                          color: Color(0xFF282828)),
                      baseColor: Color(0xFF282828),
                      highlightColor: Color(0xFF383838),
                    );
                  },
                ),
              ),
            ),
            Card(
                color: Color(0xFF232323),
                child: Container(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: Text('Delivered on time',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18))),
                            Container(
                                child: SmoothStarRating(
                              size: 20,
                              starCount: 5,
                              allowHalfRating: true,
                              spacing: 3,
                              isReadOnly: false,
                              color: Colors.yellow[700],
                              defaultIconData: Icons.star,
                              halfFilledIconData: Icons.star_half,
                             borderColor: Color(0xFF484848),
                                      filledIconData: Icons.star,
                              onRated: (rate) {
                                setState(() {
                                  onTime = rate;
                                  if (first) {
                                    first = false;
                                  }
                                });
                              },
                            ))
                          ],
                        ),
                        first
                            ? Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  'Please rate this item',
                                  style:
                                      TextStyle(color: Colors.redAccent[400]),
                                ),
                              )
                            : Container(height: 0, width: 0),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text('Gift Wrapping',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              Container(
                                  child: SmoothStarRating(
                                size: 20,
                                starCount: 5,
                                spacing: 3,
                                isReadOnly: false,
                                color: Colors.yellow[700],
                                defaultIconData: Icons.star,
                                halfFilledIconData: Icons.star,
                                 borderColor: Color(0xFF484848),
                                   
                                filledIconData: Icons.star,
                                onRated: (rate) {
                                  setState(() {
                                    goodPackaging = rate;
                                    if (second) {
                                      second = false;
                                    }
                                  });
                                },
                              ))
                            ],
                          ),
                        ),
                        second
                            ? Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  'Please rate this item',
                                  style:
                                      TextStyle(color: Colors.redAccent[400]),
                                ),
                              )
                            : Container(height: 0, width: 0),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text('Material Quality',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              Container(
                                  child: SmoothStarRating(
                                size: 20,
                                starCount: 5,
                                spacing: 3,
                                isReadOnly: false,
                                color: Colors.yellow[700],
                                defaultIconData: Icons.star,
                                halfFilledIconData: Icons.star,
                                borderColor: Color(0xFF484848),
                                filledIconData: Icons.star,
                                onRated: (rate) {
                                  setState(() {
                                    materialQuality = rate;
                                    if (third) {
                                      third = false;
                                    }
                                  });
                                },
                              ))
                            ],
                          ),
                        ),
                        third
                            ? Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  'Please rate this item',
                                  style:
                                      TextStyle(color: Colors.redAccent[400]),
                                ),
                              )
                            : Container(height: 0, width: 0),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text('Worth its price',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              Container(
                                  child: SmoothStarRating(
                                size: 20,
                                starCount: 5,
                                spacing: 3,
                                isReadOnly: false,
                                defaultIconData: Icons.star,
                                halfFilledIconData: Icons.star,
                                borderColor: Color(0xFF484848),
                                filledIconData: Icons.star,
                                color: Colors.yellow[700],
                                onRated: (rate) {
                                  setState(() {
                                    worthPrice = rate;
                                    if (forth) {
                                      forth = false;
                                    }
                                  });
                                },
                              ))
                            ],
                          ),
                        ),
                        forth
                            ? Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  'Please rate this item',
                                  style:
                                      TextStyle(color: Colors.redAccent[400]),
                                ),
                              )
                            : Container(height: 0, width: 0),
                      ],
                    ))),
            Card(
                color: Color(0xFF232323),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                              child: Text('Leave a Review ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                          Container(
                              child: Text('(optional)',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 18)))
                        ],
                      ),
                      Container(
                          child: TextField(
                              cursorColor: Colors.white70,
                              autofocus: false,
                              controller: reviewController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                hintText: 'Type Your Review Here',
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white70)),
                                hintStyle: TextStyle(color: Colors.white70),
                              )))
                    ],
                  ),
                ))
          ],
        )),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20, top: 20),
              width: width * 0.4,
              height: 40,
              clipBehavior: Clip.antiAlias,
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
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    if (onTime != null &&
                        onTime != 0 &&
                        goodPackaging != null &&
                        goodPackaging != 0 &&
                        materialQuality != null &&
                        materialQuality != 0 &&
                        worthPrice != null &&
                        worthPrice != 0) {
                      setState(() {
                        uploading = true;
                      });
                      String review;
                      if (reviewController.text.isNotEmpty) {
                        review = reviewController.text;
                      } else {
                        review = "";
                      }
                      double totalRate = (onTime +
                              goodPackaging +
                              materialQuality +
                              worthPrice) /
                          4;
                      _uploadProfileReview(
                              widget.orderId,
                              widget.giftId,
                              widget.giftImg,
                              onTime,
                              goodPackaging,
                              materialQuality,
                              worthPrice,
                              totalRate,
                              review)
                          .then((onValue) {
                        setState(() {
                          uploading = true;
                        });
                        
                            Navigator.pop(context, true);
                        
                      });
                    } else {
                      if (onTime == null || onTime == 0) {
                        setState(() {
                          first = true;
                        });
                      }
                      if (goodPackaging == null || goodPackaging == 0) {
                        setState(() {
                          second = true;
                        });
                      }
                      if (materialQuality == null || materialQuality == 0) {
                        setState(() {
                          third = true;
                        });
                      }
                      if (worthPrice == null || worthPrice == 0) {
                        setState(() {
                          forth = true;
                        });
                      }
                    }
                  },
                  child: Center(
                    child: uploading
                        ? Container(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white),strokeWidth: 1,),
                            height: 15,
                            width: 15)
                        : Text('Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future _uploadProfileReview(
      String orderId,
      String giftId,
      String giftImg,
      double onTime,
      double goodPackaging,
      double materialQuality,
      double worthPrice,
      double totalRate,
      String review) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Reviews')
        .doc(orderId)
        .set({
      "giftid": giftId,
      "giftimg": giftImg,
      "ontime": onTime,
      "goodpackaging": goodPackaging,
      "materialquality": materialQuality,
      "worthprice": worthPrice,
      "totalrate": totalRate,
      "review": review,
      "date": DateTime.now()
    });

    double giftRate;
    int reviewsNo;
    await FirebaseFirestore.instance
        .collection('Gifts')
        .doc(giftId)
        .get()
        .then((value) {
      if (value.exists) {
        reviewsNo = value.data()['reviewsno'];
        if (reviewsNo == null) {
          reviewsNo = 0;
        }

        num abc = value.data()['rate'];
        if (abc != null) {
          if (abc is double) {
            giftRate = abc;
          } else {
            giftRate = abc.toDouble();
          }
        } else {
          giftRate = 0;
        }
      } else {
        giftRate = 0;
      }
    });

    await FirebaseFirestore.instance.collection('Gifts').doc(giftId).set({
      'rate':giftRate==0?totalRate:((giftRate*reviewsNo)+totalRate)/(reviewsNo+1),
      'reviewsno':reviewsNo==0?1:FieldValue.increment(1),
      
    },SetOptions(merge:true));

    await FirebaseFirestore.instance
        .collection('Gifts')
        .doc(giftId)
        .collection('reviews')
        .doc(orderId)
        .set({
      "name": displayName,
      "profilepic": userImg,
      "totalrate": totalRate,
      "ontime": onTime,
      "goodpackaging": goodPackaging,
      "materialquality": materialQuality,
      "worthprice": worthPrice,
      "review": review,
      "date": DateTime.now()
    });

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderId)
        .set({"reviewed": true}, SetOptions(merge: true));
  }
}
