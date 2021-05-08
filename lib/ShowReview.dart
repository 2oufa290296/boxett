import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ShowReview extends StatefulWidget {
  final String orderId, giftImg, giftId, review;
  final double onTime, goodPackaging, materialQuality, worthPrice;

  ShowReview(this.orderId, this.giftImg, this.giftId, this.onTime,
      this.goodPackaging, this.materialQuality, this.worthPrice, this.review);

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<ShowReview> {
  final showReviewKey = GlobalKey<ScaffoldState>();
  double width, height;
  TextEditingController reviewController;
  bool first = false;
  bool second = false;
  bool third = false;
  bool forth = false;
  bool editable = false;
  bool closeIcon = false;
  bool textChanged = false;
  bool changed1 = false;
  bool changed2 = false;
  bool changed3 = false;
  bool changed4 = false;
  String textString = "";
  double onTim, goodPackagin, materialQualit, worthPric;

  @override
  void initState() {
    reviewController = TextEditingController();
    reviewController.addListener(() {
      setState(() {
        if (reviewController.text != widget.review) {
          textChanged = true;
        } else {
          textChanged = false;
        }
      });
    });
    super.initState();
    onTim = widget.onTime;
    goodPackagin = widget.goodPackaging;
    materialQualit = widget.materialQuality;
    worthPric = widget.worthPrice;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: showReviewKey,
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
                      child: Text('Your Review',
                          style: TextStyle(color: Colors.white, fontSize: 20,fontFamily:"Lobster",letterSpacing:1))),
                  Expanded(child: Container()),
                  // !editable
                  //     ? InkWell(
                  //         onTap: () {
                  //           setState(() {
                  //             if (widget.review != "") {
                  //               reviewController.text = widget.review;
                  //             }
                  //             closeIcon = true;
                  //             editable = true;
                  //           });
                  //         },
                  //         child: Container(
                  //             margin: EdgeInsets.only(right: 10),
                  //             padding: EdgeInsets.all(5),
                  //             child: Icon(Icons.edit, color: Colors.white)))
                  //     : closeIcon
                  //         ? InkWell(
                  //             onTap: () {
                  //               setState(() {
                  //                 print(onTim.toString());
                  //                 editable = false;
                  //                 onTim = widget.onTime;
                  //                 goodPackagin = widget.goodPackaging;
                  //                 materialQualit = widget.materialQuality;
                  //                 worthPric = widget.worthPrice;
                  //                 reviewController.text = widget.review;
                  //                 print(onTim.toString());
                  //               });
                  //             },
                  //             child: Container(
                  //                 margin: EdgeInsets.only(right: 10),
                  //                 padding: EdgeInsets.all(5),
                  //                 child:
                  //                     Icon(Icons.close, color: Colors.white)))
                  //         : Container(height: 0, width: 0)
                ]),
                decoration: BoxDecoration(
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
            child: Column(
          children: <Widget>[
            Card(
              color: Color(0xFF151515),
              elevation: 5,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/giftPage',
                      arguments: widget.giftId);
                },
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
                            editable
                                ? Container(
                                    key: UniqueKey(),
                                    child: SmoothStarRating(
                                      size: 25,
                                      starCount: 5,
                                      spacing: 3,
                                      isReadOnly: editable ? false : true,
                                      color: Colors.yellow[700],
                                      defaultIconData: Icons.star,
                                      halfFilledIconData: Icons.star_half,
                                      borderColor: Color(0xFF484848),
                                      filledIconData: Icons.star,
                                      rating: onTim,
                                      onRated: editable
                                          ? (rate) {
                                              setState(() {
                                                if (rate != widget.onTime) {
                                                  changed1 = true;
                                                } else {
                                                  changed1 = false;
                                                }

                                                onTim = rate;
                                                if (first) {
                                                  first = false;
                                                }
                                              });
                                            }
                                          : (rate) {},
                                    ))
                                : Container(
                                    key: UniqueKey(),
                                    child: SmoothStarRating(
                                      size: 20,
                                      starCount: 5,
                                      spacing: 3,
                                      isReadOnly: true,
                                      color: Colors.yellow[700],
                                      defaultIconData: Icons.star,
                                      halfFilledIconData: Icons.star_half,
                                      borderColor: Color(0xFF484848),
                                      filledIconData: Icons.star,
                                      rating: widget.onTime,
                                    ),
                                  )
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
                          margin: EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text('Gift Wrapping',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              editable
                                  ? Container(
                                      key: UniqueKey(),
                                      child: SmoothStarRating(
                                        size: 25,
                                        starCount: 5,
                                        spacing: 3,
                                        isReadOnly: editable ? false : true,
                                        color: Colors.yellow[700],
                                        defaultIconData: Icons.star,
                                        halfFilledIconData: Icons.star_half,
                                        borderColor: Color(0xFF484848),
                                        filledIconData: Icons.star,
                                        rating: goodPackagin,
                                        onRated: editable
                                            ? (rate) {
                                                setState(() {
                                                  if (rate !=
                                                      widget.goodPackaging) {
                                                    changed2 = true;
                                                  } else {
                                                    changed2 = false;
                                                  }

                                                  goodPackagin = rate;
                                                  if (second) {
                                                    second = false;
                                                  }
                                                });
                                              }
                                            : (rate) {},
                                      ))
                                  : Container(
                                      key: UniqueKey(),
                                      child: SmoothStarRating(
                                        size: 20,
                                        starCount: 5,
                                        spacing: 3,
                                        isReadOnly: true,
                                        color: Colors.yellow[700],
                                        defaultIconData: Icons.star,
                                        halfFilledIconData: Icons.star_half,
                                        borderColor: Color(0xFF484848),
                                        filledIconData: Icons.star,
                                        rating: goodPackagin,
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
                          margin: EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text('Material Quality',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              editable
                                  ? Container(
                                      key: UniqueKey(),
                                      child: SmoothStarRating(
                                        size: 25,
                                        starCount: 5,
                                        spacing: 3,
                                        isReadOnly: editable ? false : true,
                                        color: Colors.yellow[700],
                                        defaultIconData: Icons.star,
                                        halfFilledIconData: Icons.star_half,
                                        borderColor: Color(0xFF484848),
                                        filledIconData: Icons.star,
                                        rating: materialQualit,
                                        onRated: editable
                                            ? (rate) {
                                                setState(() {
                                                  if (rate !=
                                                      widget.materialQuality) {
                                                    changed3 = true;
                                                  } else {
                                                    changed3 = false;
                                                  }

                                                  materialQualit = rate;
                                                  if (third) {
                                                    third = false;
                                                  }
                                                });
                                              }
                                            : (rate) {},
                                      ))
                                  : Container(
                                      key: UniqueKey(),
                                      child: SmoothStarRating(
                                        size: 20,
                                        starCount: 5,
                                        spacing: 3,
                                        isReadOnly: true,
                                        color: Colors.yellow[700],
                                        defaultIconData: Icons.star,
                                        halfFilledIconData: Icons.star_half,
                                        borderColor: Color(0xFF484848),
                                        filledIconData: Icons.star,
                                        rating: materialQualit,
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
                          margin: EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text('Worth its price',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              editable
                                  ? Container(
                                      key: UniqueKey(),
                                      child: SmoothStarRating(
                                        size: 25,
                                        starCount: 5,
                                        spacing: 3,
                                        isReadOnly: editable ? false : true,
                                        defaultIconData: Icons.star,
                                        halfFilledIconData: Icons.star_half,
                                        borderColor: Color(0xFF484848),
                                        filledIconData: Icons.star,
                                        rating: worthPric,
                                        color: Colors.yellow[700],
                                        onRated: editable
                                            ? (rate) {
                                                setState(() {
                                                  if (rate !=
                                                      widget.worthPrice) {
                                                    changed4 = true;
                                                  } else {
                                                    changed4 = false;
                                                  }

                                                  worthPric = rate;
                                                  if (forth) {
                                                    forth = false;
                                                  }
                                                });
                                              }
                                            : (rate) {},
                                      ))
                                  : Container(
                                      key: UniqueKey(),
                                      child: SmoothStarRating(
                                        size: 20,
                                        starCount: 5,
                                        spacing: 3,
                                        isReadOnly: true,
                                        defaultIconData: Icons.star,
                                        halfFilledIconData: Icons.star_half,
                                        borderColor: Color(0xFF484848),
                                        filledIconData: Icons.star,
                                        rating: worthPric,
                                        color: Colors.yellow[700],
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
            widget.review == ""?Container(height:0,width:0):Card(
                color: Color(0xFF232323),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                              child: Text(
                                  editable && widget.review == ""
                                      ? 'Leave a Review '
                                      : 'Your Review ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                          editable
                              ? Container(
                                  child: Text('(optional)',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 18)))
                              : Container(height: 0, width: 0)
                        ],
                      ),
                      editable && widget.review == ""
                          ? Container(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: TextField(textAlign: TextAlign.start,
                                  cursorColor: Colors.white70,
                                  autofocus: false,
                                  controller: reviewController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Type Your Review Here',
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white70)),
                                    hintStyle: TextStyle(color: Colors.white70),
                                  )))
                          : editable
                              ? Container(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: TextField(
                                      cursorColor: Colors.white70,
                                      textDirection: widget.review.contains(
                                              new RegExp(r'[\u0600-\u06FF]'))
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      autofocus: false,
                                      controller: reviewController,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                      decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white70)),
                                        hintStyle:
                                            TextStyle(color: Colors.white70),
                                      )))
                              : Container(
                                  width: width,
                                  padding: EdgeInsets.only(
                                      top: 14, left: 5, right: 5, bottom: 10),
                                  child: Text(widget.review,
                                      textAlign: widget.review.contains(
                                              new RegExp(r'[\u0600-\u06FF]'))
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: TextStyle(
                                          height: 1.1,
                                          fontSize: 18,
                                          color: Colors.white)))
                    ],
                  ),
                ))
          ],
        )),
        // bottomNavigationBar: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     Container(
        //       margin: EdgeInsets.only(
        //         bottom: 20,
        //       ),
        //       width: width * 0.4,
        //       height: 40,
        //       clipBehavior: Clip.antiAlias,
        //       decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(10),
        //           gradient: LinearGradient(
        //             colors: [
        //               Color(0xFF3E0000),
        //               Color(0xFFCE203C),
        //               Color(0xFF3E0000),
        //             ],
        //             begin: Alignment.topLeft,
        //             end: Alignment.bottomRight,
        //           )),
        //       child: Material(
        //         color: Colors.transparent,
        //         borderRadius: BorderRadius.circular(10),
        //         clipBehavior: Clip.antiAlias,
        //         child: InkWell(
        //           onTap: editable &&
        //                   (changed1 ||
        //                       changed2 ||
        //                       changed3 ||
        //                       changed4 ||
        //                       (widget.review == "" &&
        //                           reviewController.text.isNotEmpty) ||
        //                       textChanged)
        //               ? () {
        //                   if (onTim != null &&
        //                       onTim != 0 &&
        //                       goodPackagin != null &&
        //                       goodPackagin != 0 &&
        //                       materialQualit != null &&
        //                       materialQualit != 0 &&
        //                       worthPric != null &&
        //                       worthPric != 0) {
        //                     String review;
        //                     if (reviewController.text.isNotEmpty) {
        //                       review = reviewController.text;
        //                     } else {
        //                       review = "";
        //                     }
        //                     double totalRate = (onTim +
        //                             goodPackagin +
        //                             materialQualit +
        //                             worthPric) /
        //                         4;
        //                     _uploadProfileReview(
        //                             widget.orderId,
        //                             widget.giftId,
        //                             onTim,
        //                             goodPackagin,
        //                             materialQualit,
        //                             worthPric,
        //                             totalRate,
        //                             review)
        //                         .then((onValue) {
        //                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //                           shape: RoundedRectangleBorder(
        //                               borderRadius: BorderRadius.circular(15)),
        //                           behavior: SnackBarBehavior.floating,
        //                           content:
        //                               Container(height:15,child: Center(child: Text('Your review has been updated')))));
        //                       Future.delayed(Duration(milliseconds: 1000), () {
        //                         Navigator.pop(context);
        //                       });
        //                     });
        //                   } else if (onTim == null || onTim == 0) {
        //                     setState(() {
        //                       first = true;
        //                     });
        //                   } else if (goodPackagin == null ||
        //                       goodPackagin == 0) {
        //                     setState(() {
        //                       second = true;
        //                     });
        //                   } else if (materialQualit == null ||
        //                       materialQualit == 0) {
        //                     setState(() {
        //                       third = true;
        //                     });
        //                   } else if (worthPric == null || worthPric == 0) {
        //                     setState(() {
        //                       forth = true;
        //                     });
        //                   } else {}
        //                 }
        //               : () {
        //                   Navigator.pop(context);
        //                 },
        //           child: Center(
        //             child: Text(
        //                 editable &&
        //                         (changed1 ||
        //                             changed2 ||
        //                             changed3 ||
        //                             changed4 ||
        //                             (widget.review == "" &&
        //                                 reviewController.text.isNotEmpty) ||
        //                             textChanged)
        //                     ? 'Submit'
        //                     : 'Back',
        //                 style: TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 18,
        //                     fontWeight: FontWeight.bold)),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // )
        );
  }

  // Future _uploadProfileReview(
  //     String orderId,
  //     String giftId,
  //     double onTime,
  //     double goodPackaging,
  //     double materialQuality,
  //     double worthPrice,
  //     double totalRate,
  //     String review) async {
  //   await FirebaseFirestore.instance
  //       .collection('Gifts')
  //       .doc(giftId)
  //       .collection('reviews')
  //       .doc(orderId)
  //       .set({
  //     "ontime": onTime,
  //     "goodpackaging": goodPackaging,
  //     "materialquality": materialQuality,
  //     "worthprice": worthPrice,
  //     "totalrate": totalRate,
  //     "review": textChanged ? review : widget.review
  //   }, SetOptions(merge: true));
  // }
}
