import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:boxet/AddAddress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'classes/VoucherEntity.dart';

class OrderPage extends StatefulWidget {
  final String id,
      mainImg,
      giftName,
      pageImg,
      pageId,
      giftShop,
      shopPackagingFree,
      shopPackagingImg;
  final List selection;
  final num deliveryTime;
  final int price, delivery, boxetPackaging, shopPackaging, reviews;
  final double rate;

  OrderPage(
      this.id,
      this.mainImg,
      this.giftName,
      this.price,
      this.deliveryTime,
      this.delivery,
      this.boxetPackaging,
      this.shopPackaging,
      this.pageImg,
      this.pageId,
      this.giftShop,
      this.rate,
      this.reviews,
      this.shopPackagingFree,
      this.shopPackagingImg,
      this.selection);
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SharedPreferences sharedPref;
  int priceInt = 0;
  int normalPackaging = 0;
  int total = 0;
  double width, height;
  TextEditingController specialController;
  TextEditingController voucherController;
  List<VoucherEntity> vouchersList = [];
  bool delNow = true;
  String uid;
  String customerName = "";
  String region = "";
  String address = "";
  String mobile = "";
  String city = "";
  DateTime deliveryTimeLast;
  int delivery = 0;
  CupertinoDatePicker picker;
  CupertinoDatePicker pickerTime;
  bool addressMissed = false;
  String selected="";
  int discount = 0;
  int correctVoucher = 2;
  bool uploading = false;
  bool loading = true;

  @override
  void initState() {
    _loadPref();
    specialController = TextEditingController();
    voucherController = TextEditingController();
    if(widget.selection!=null && widget.selection.isNotEmpty){
selected=widget.selection[0];
    }

    super.initState();
    
  }

  _refresh() async {
    setState(() {
      _loadPref();
    });

    
  }

  _loadPref() async {
    deliveryTimeLast = DateTime.now().add(Duration(days: widget.deliveryTime));
    
    if (widget.delivery == null) {
      delivery = 20;
    } else {
      delivery = widget.delivery;
    }

    if (widget.shopPackagingFree != null && widget.shopPackagingFree != "") {
      normalPackaging = 0;
    } else if (widget.shopPackagingImg != null &&
        widget.shopPackagingImg != "") {
      normalPackaging = 1;
    } else {
      normalPackaging = 2;
    }

    sharedPref = await SharedPreferences.getInstance();
    setState(() {
      uid = sharedPref.getString('uid');
      customerName = sharedPref.getString('customername') ?? '';
      city = sharedPref.getString('city') ?? '';
      region = sharedPref.getString('region') ?? '';
      address = sharedPref.getString('address') ?? '';
      mobile = sharedPref.getString('mobile') ?? '';
    });

    pickerTime = CupertinoDatePicker(
        backgroundColor: Color(0xFF232323),
        mode: CupertinoDatePickerMode.time,
        onDateTimeChanged: (dateTime) {
          deliveryTimeLast = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              (DateTime.now().day + widget.deliveryTime),
              dateTime.hour,
              dateTime.minute);
        });

    picker = CupertinoDatePicker(
        backgroundColor: Color(0xFF232323),
        minimumDate: DateTime.now().add(Duration(
            days: widget.deliveryTime,
            hours: 24 - DateTime.now().hour,
            minutes: 60 - DateTime.now().minute)),
        initialDateTime: DateTime.now().add(Duration(
            days: widget.deliveryTime,
            hours: 24 - DateTime.now().hour,
            minutes: 60 - DateTime.now().minute)),
        onDateTimeChanged: (dateTime) {
          deliveryTimeLast = dateTime;
        });

    await FirebaseFirestore.instance.collection('Vouchers').get().then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          vouchersList.add(new VoucherEntity(
              element.data()['voucher'], element.data()['discount']));
        });
      }
    }, onError: (error) {
      print(error);
    });

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    if (correctVoucher == 1) {
      if (normalPackaging == 0) {
        total = widget.price + delivery - discount;
      } else if (normalPackaging == 1) {
        total = widget.price + delivery + widget.shopPackaging - discount;
      } else {
        total = widget.price + delivery + widget.boxetPackaging - discount;
      }
    } else {
      if (normalPackaging == 0) {
        total = widget.price + delivery;
      } else if (normalPackaging == 1) {
        total = widget.price + delivery + widget.shopPackaging;
      } else {
        total = widget.price + delivery + widget.boxetPackaging;
      }
    }
    return Scaffold(
      key: _scaffoldKey,
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
                    child: Text('Order Details',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: "Lobster",
                            letterSpacing: 1)))
              ]),
              decoration: BoxDecoration(
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
      body: loading
          ? Center(
              child: Container(
                  width: 50,
                  height: 50,
                  child: FlareActor(
                    'assets/loading.flr',
                    animation: 'Loading',
                  )))
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Card(
                    color: Color(0xFF232323),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Card(
                            color: Colors.transparent,
                            margin: EdgeInsets.only(
                                left: 10, top: 10, bottom: 10, right: 10),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: widget.mainImg,
                              fit: BoxFit.fill,
                              height: 100,
                              width: 100,
                              progressIndicatorBuilder:
                                  (context, url, progress) {
                                return Shimmer.fromColors(
                                  enabled: true,
                                  child: Container(
                                      height: 100,
                                      width: 100,
                                      color: Color(0xFF282828)),
                                  baseColor: Color(0xFF282828),
                                  highlightColor: Color(0xFF383838),
                                );
                              },
                            )),
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(bottom: 15),
                                    child: Column(
                                      children: <Widget>[
                                        Text(widget.giftName,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Lobster",
                                                letterSpacing: 2)),
                                        widget.rate != null && widget.rate != 0
                                            ? Container(
                                                margin: EdgeInsets.only(top: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      child: SmoothStarRating(
                                                        allowHalfRating: true,
                                                        color:
                                                            Colors.yellow[700],
                                                        defaultIconData:
                                                            Icons.star,
                                                        borderColor:
                                                            Color(0xFF484848),
                                                        isReadOnly: true,
                                                        size: 18,
                                                        rating: widget.rate,
                                                      ),
                                                    ),
                                                    widget.reviews != null &&
                                                            widget.reviews != 0
                                                        ? Text(
                                                            ' (' +
                                                                widget.reviews
                                                                    .toString() +
                                                                ')',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white))
                                                        : Container(
                                                            height: 0, width: 0)
                                                  ],
                                                ))
                                            : Container(height: 0, width: 0),
                                      ],
                                    )),
                                Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            child: Text('Seller',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Container(
                                              child: Text(widget.giftShop,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  )))
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            child: Text('Price',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Container(
                                              child: Text(
                                                  widget.price.toString() +
                                                      ' LE',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  )))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Row(
                                //   mainAxisSize: MainAxisSize.max,
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: <Widget>[
                                //     Container(
                                //       child: Text('Total ',
                                //           style: TextStyle(
                                //             fontSize: 16,
                                //             color: Colors.white,
                                //           )),
                                //     ),
                                //     Container(
                                //         child: Text(total.toString() + ' LE',
                                //             style: TextStyle(
                                //               fontSize: 16,
                                //               color: Colors.white,
                                //             )))
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  widget.selection!=null && widget.selection.isNotEmpty?Card(
                      color: Color(0xFF232323),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  child: Text('Select Gift',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold))),
                              Container(
                                  margin: EdgeInsets.only(top: 10),
                                  
                                  height: 100,
                                  child: ListView.builder(scrollDirection: Axis.horizontal,
                                      itemCount: widget.selection.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(onTap:(){
                                          setState((){selected=widget.selection[index];});
                                        },
                                                                                  child: Container(foregroundDecoration:selected==widget.selection[index] ?BoxDecoration(border: Border.all(color:Colors.white,width:2),borderRadius:BorderRadius.circular(4)):null,
                                            width:100,
                                            height: 100,
                                            child: Card(clipBehavior: Clip.antiAlias,margin:EdgeInsets.all(1),
                                              child: CachedNetworkImage(
                                                      imageUrl:
                                                          widget.selection[index],
                                                      fit: BoxFit.cover),
                                            ),
                                          ),
                                        );
                                      }))
                            ]),
                      )):Container(),
                  (widget.shopPackagingFree == null ||
                              widget.shopPackagingFree == "") &&
                          (widget.shopPackagingImg == null ||
                              widget.shopPackagingImg == "") &&
                          (widget.boxetPackaging == null ||
                              widget.boxetPackaging == 0)
                      ? Container()
                      : Card(
                          color: Color(0xFF232323),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      child: Text('Wrapping',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    height: 25,
                                    child: ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: <Widget>[
                                        widget.shopPackagingFree != null &&
                                                widget.shopPackagingFree != ""
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (normalPackaging != 0) {
                                                      normalPackaging = 0;
                                                    }
                                                  });
                                                },
                                                child: normalPackaging == 0
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color.fromRGBO(
                                                              5, 150, 197, 1),
                                                        ),
                                                      )
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        child: Container(
                                                            width: 18,
                                                            height: 18),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                          border: Border.all(
                                                              width: 1,
                                                              color: Colors
                                                                  .white70),
                                                        )),
                                              )
                                            : Container(),
                                        widget.shopPackagingFree != null &&
                                                widget.shopPackagingFree != ""
                                            ? Container(
                                                alignment: Alignment.center,
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                child: Text('Normal Wrapping',
                                                    style: TextStyle(
                                                        color:
                                                            normalPackaging == 0
                                                                ? Colors.white
                                                                : Colors
                                                                    .white70,
                                                        fontSize: 14)))
                                            : Container(),
                                        widget.shopPackagingImg != null &&
                                                widget.shopPackagingImg != ""
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (normalPackaging != 1) {
                                                      normalPackaging = 1;
                                                    }
                                                  });
                                                },
                                                child: normalPackaging == 1
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10),
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color.fromRGBO(
                                                              5, 150, 197, 1),
                                                        ),
                                                      )
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        margin: EdgeInsets.only(
                                                            left: 10),
                                                        child: Container(
                                                            width: 18,
                                                            height: 18),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                          border: Border.all(
                                                              width: 1,
                                                              color: Colors
                                                                  .white70),
                                                        )),
                                              )
                                            : Container(),
                                        widget.shopPackagingImg != null &&
                                                widget.shopPackagingImg != ""
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Text('Shop Wrapping',
                                                    style: TextStyle(
                                                        color:
                                                            normalPackaging == 1
                                                                ? Colors.white70
                                                                : Colors
                                                                    .white)),
                                                margin:
                                                    EdgeInsets.only(left: 5))
                                            : Container(),
                                        widget.boxetPackaging != null &&
                                                widget.boxetPackaging != 0
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (normalPackaging != 2) {
                                                      normalPackaging = 2;
                                                    }
                                                  });
                                                },
                                                child: normalPackaging == 2
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10),
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color.fromRGBO(
                                                              5, 150, 197, 1),
                                                        ),
                                                      )
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        margin: EdgeInsets.only(
                                                            left: 10),
                                                        child: Container(
                                                            width: 18,
                                                            height: 18),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                          border: Border.all(
                                                              width: 1,
                                                              color: Colors
                                                                  .white70),
                                                        )),
                                              )
                                            : Container(),
                                        widget.boxetPackaging != null &&
                                                widget.boxetPackaging != 0
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Text('Boxet Wrapping',
                                                    style: TextStyle(
                                                        color:
                                                            normalPackaging == 2
                                                                ? Colors.white70
                                                                : Colors
                                                                    .white)),
                                                margin:
                                                    EdgeInsets.only(left: 5))
                                            : Container()
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.attach_money,
                                            color: Colors.white,
                                          ),
                                          Container(
                                              child: Text(
                                                  normalPackaging == 0
                                                      ? 'Free'
                                                      : normalPackaging == 1
                                                          ? widget.shopPackaging
                                                                  .toString() +
                                                              ' LE'
                                                          : widget.boxetPackaging
                                                                  .toString() +
                                                              ' LE',
                                                  style: TextStyle(
                                                    color: normalPackaging == 0
                                                        ? Colors.green
                                                        : Colors.white,
                                                    fontSize: 16,
                                                  )))
                                        ],
                                      )),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Card(
                                        color: Color(0xFF232323),
                                        clipBehavior: Clip.antiAlias,
                                        child: normalPackaging == 0
                                            ? Image.network(
                                                widget.shopPackagingFree,
                                                fit: BoxFit.cover,
                                                width: width - 20,
                                                height: height / 4,
                                              )
                                            : normalPackaging == 1
                                                ? Image.network(
                                                    widget.shopPackagingImg,
                                                    fit: BoxFit.cover,
                                                    width: width - 20,
                                                    height: height / 4,
                                                  )
                                                : Image.asset(
                                                    'assets/images/qqq.png',
                                                    fit: BoxFit.contain,
                                                    width: width - 20,
                                                    height: height / 4,
                                                  )),
                                  )
                                ]),
                          )),
                  Card(
                    color: Color(0xFF232323),
                    child: address != ""
                        ? Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                          margin: EdgeInsets.only(left: 0),
                                          child: Text('Delivery Details',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          new AddAddress()))
                                              .then((val) => _refresh());
                                        },
                                        child: Container(
                                            child: Text(
                                          'Change',
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  5, 150, 197, 1),
                                              fontSize: 16,
                                              
                                              fontWeight: FontWeight.bold,
                                              ),
                                        )),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                          child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      )),
                                      Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(customerName,
                                              style: TextStyle(
                                                color: Colors.white,
                                              )))
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                          child: Icon(
                                        Icons.home,
                                        color: Colors.white,
                                        size: 20,
                                      )),
                                      Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(
                                              region != "" && region != null
                                                  ? region + ', ' + city
                                                  : "",
                                              style: TextStyle(
                                                color: Colors.white,
                                              )))
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            child: Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 20,
                                        )),
                                        Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text(address,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )))
                                      ]),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Icon(
                                          Icons.phone_android,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(mobile,
                                              style: TextStyle(
                                                color: Colors.white,
                                              )))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(
                            decoration: addressMissed
                                ? BoxDecoration(
                                    color: Color(0xFF232323),
                                    boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.8),
                                          spreadRadius: 3,
                                          blurRadius: 4,
                                          offset: Offset(0,
                                              0), // changes position of shadow
                                        ),
                                      ])
                                : null,
                            padding: EdgeInsets.all(10),
                            child: Column(children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.only(left: 0),
                                        child: Text('Delivery Details',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold))),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        new AddAddress()))
                                            .then((val) => _refresh());
                                      },
                                      child: Container(
                                          child: Text(
                                        'Add Address',
                                        style: TextStyle(
                                            color:
                                                Colors.green,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                           ),
                                      )),
                                    )
                                  ],
                                ),
                              ),
                            ])),
                  ),
                  Card(
                      color: Color(0xFF232323),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  child: Text('Discount Voucher',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold))),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        width: 0.6 * width,
                                        child: TextField(
                                            autofocus: false,
                                            controller: voucherController,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                            cursorColor: Colors.white70,
                                            decoration: InputDecoration(
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: correctVoucher ==
                                                                  1
                                                              ? Colors.green
                                                              : correctVoucher ==
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .transparent)),
                                              errorBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: correctVoucher == 1
                                                          ? Colors.green
                                                          : correctVoucher == 0
                                                              ? Colors.red
                                                              : Colors
                                                                  .transparent)),
                                              errorStyle: TextStyle(
                                                  color: correctVoucher == 1
                                                      ? Colors.green
                                                      : correctVoucher == 0
                                                          ? Colors.red
                                                          : Colors.transparent),
                                              errorText: voucherController
                                                          .text.isNotEmpty &&
                                                      correctVoucher == 1
                                                  ? discount.toString() +
                                                      ' LE Discount Applied'
                                                  : voucherController.text
                                                              .isNotEmpty &&
                                                          correctVoucher == 0
                                                      ? 'Incorrect Voucher'
                                                      : null,
                                              isDense: true,
                                              hintText: 'Voucher Code',
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.white70)),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.white70)),
                                              hintStyle: TextStyle(
                                                  color: Colors.white70),
                                            ))),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          correctVoucher = 2;
                                          discount = 0;
                                        });
                                        if (voucherController.text.isNotEmpty) {
                                          vouchersList.forEach((element) {
                                            if (element.voucher ==
                                                voucherController.text) {
                                              discount = element.discount;
                                            }
                                          });

                                          if (discount != null &&
                                              discount != 0) {
                                            setState(() {
                                              correctVoucher = 1;
                                            });

                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () {
                                              FocusScope.of(context).unfocus();
                                            });
                                          } else {
                                            correctVoucher = 0;
                                          }
                                        }
                                      },
                                      child: Card(
                                          margin: EdgeInsets.only(left: 10),
                                          color: Color(0xFF232323),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('REDEEM',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            side: BorderSide(
                                                color: Colors.white, width: 1),
                                          )),
                                    )
                                  ],
                                ),
                              )
                            ]),
                      )),
                  Card(
                      color: Color(0xFF232323),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                          child: Text('Subtotal',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 16))),
                                      Container(
                                          child: Text(
                                              widget.price.toString() + ' LE',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 16)))
                                    ]),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                          child: Text('Delivery',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 16))),
                                      Container(
                                          child: Text(
                                              delivery.toString() + ' LE',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 16)))
                                    ]),
                              ),
                              normalPackaging == 1 && widget.shopPackaging != 0
                                  ? Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                child: Text('Shop Wrapping',
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16))),
                                            Container(
                                                child: Text(
                                                    widget.shopPackaging
                                                            .toString() +
                                                        ' LE',
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16)))
                                          ]),
                                    )
                                  : normalPackaging == 2 &&
                                          widget.boxetPackaging != 0
                                      ? Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                    child: Text(
                                                        'Boxet Wrapping',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 16))),
                                                Container(
                                                    child: Text(
                                                        widget.boxetPackaging
                                                                .toString() +
                                                            ' LE',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 16)))
                                              ]),
                                        )
                                      : Container(height: 0, width: 0),
                              correctVoucher == 1
                                  ? Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                child: Text('Discount',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 16))),
                                            Container(
                                                child: Text(
                                                    '- ' +
                                                        discount.toString() +
                                                        ' LE',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 16)))
                                          ]),
                                    )
                                  : Container(height: 0, width: 0),
                              Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(children: <Widget>[
                                    Expanded(
                                        child: Divider(
                                      color: Colors.grey,
                                      height: 10,
                                    ))
                                  ])),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                          child: Text('Total',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                 
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18))),
                                      Container(
                                          child: Text(total.toString() + ' LE',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                              ),
                            ]),
                      )),
                  Card(
                      color: Color(0xFF232323),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                      child: Text('Special Requests ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))),
                                  Container(
                                      child: Text('(optional)',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 18)))
                                ],
                              ),
                              Container(
                                  child: TextField(
                                      autofocus: false,
                                      cursorColor: Colors.white70,
                                      controller: specialController,
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Type Your Request Here',
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white70)),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white70)),
                                        hintStyle:
                                            TextStyle(color: Colors.white70),
                                      )))
                            ]),
                      )),
                  Card(
                      color: Color(0xFF232323),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                      child: Text('Delivery Time',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Row(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (delNow == false) {
                                            delNow = true;
                                            deliveryTimeLast = DateTime.now()
                                                .add(Duration(
                                                    days: widget.deliveryTime));
                                          }
                                        });
                                      },
                                      child: delNow
                                          ? Container(
                                              padding: EdgeInsets.all(2),
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color.fromRGBO(
                                                      5, 150, 197, 1)),
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(2),
                                              child: Container(
                                                  width: 18, height: 18),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.white70),
                                              )),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: widget.deliveryTime == 1
                                            ? Text('Tomorrow',
                                                style: TextStyle(
                                                    color: delNow
                                                        ? Colors.white
                                                        : Colors.white70,
                                                    fontSize: 14))
                                            : widget.deliveryTime == 2
                                                ? Text('After Tomorrow',
                                                    style: TextStyle(
                                                        color: delNow
                                                            ? Colors.white
                                                            : Colors.white70,
                                                        fontSize: 14))
                                                : Text(
                                                    'After ' +
                                                        widget.deliveryTime
                                                            .toString() +
                                                        ' Days',
                                                    style: TextStyle(
                                                        color: delNow
                                                            ? Colors.white
                                                            : Colors.white70,
                                                        fontSize: 14))),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (delNow == true) {
                                            delNow = false;
                                          }
                                        });
                                      },
                                      child: delNow
                                          ? Container(
                                              padding: EdgeInsets.all(2),
                                              margin: EdgeInsets.only(left: 10),
                                              child: Container(
                                                  width: 18, height: 18),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.white70),
                                              ))
                                          : Container(
                                              margin: EdgeInsets.only(left: 10),
                                              padding: EdgeInsets.all(2),
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromRGBO(
                                                    5, 150, 197, 1),
                                              ),
                                            ),
                                    ),
                                    Container(
                                        child: Text('Later',
                                            style: TextStyle(
                                                color: delNow
                                                    ? Colors.white70
                                                    : Colors.white)),
                                        margin: EdgeInsets.only(left: 5))
                                  ],
                                ),
                              ),
                              delNow && pickerTime != null
                                  ? Container(
                                      margin: EdgeInsets.only(top: 10),
                                      height: 100,
                                      child: CupertinoTheme(
                                        key: UniqueKey(),
                                        data: CupertinoThemeData(
                                            textTheme: CupertinoTextThemeData(
                                                dateTimePickerTextStyle:
                                                    TextStyle(
                                                        color: Colors.white))),
                                        child: pickerTime,
                                      ),
                                    )
                                  : delNow
                                      ? Container(height: 0, width: 0)
                                      : Container(
                                          margin: EdgeInsets.only(top: 10),
                                          height: 100,
                                          child: CupertinoTheme(
                                            key: UniqueKey(),
                                            data: CupertinoThemeData(
                                                textTheme:
                                                    CupertinoTextThemeData(
                                                        dateTimePickerTextStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .white))),
                                            child: picker,
                                          ),
                                        ),
                            ]),
                      )),
                  Row(
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
                              String special;

                              if (specialController.text.isNotEmpty) {
                                special = specialController.text;
                              } else {
                                special = "";
                              }

                              if (address.isNotEmpty) {
                                setState(() {
                                  uploading = true;
                                });
                                _uploadOrder(
                                        widget.id,
                                        total,
                                        delivery,
                                        normalPackaging == 0
                                            ? 0
                                            : normalPackaging == 1
                                                ? widget.shopPackaging
                                                : widget.boxetPackaging,
                                        correctVoucher == 1 ? discount : 0,
                                        customerName,
                                        city,
                                        region,
                                        address,
                                        mobile,
                                        special,
                                        deliveryTimeLast,selected)
                                    .then((onValue) {
                                  Navigator.pushNamed(context, '/orderPlaced');
                                });
                              } else {
                                setState(() {
                                  addressMissed = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    new SnackBar(
                                        content: new Text(
                                            'Please add your address')));
                              }
                            },
                            child: Center(
                              child: uploading
                                  ? Container(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                        strokeWidth: 1,
                                      ),
                                    )
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
                  )
                ],
              ),
            ),
    );
  }

  Future _uploadOrder(
      String giftId,
      int total,
      int delivery,
      int packaging,
      int discount,
      String customer,
      String city,
      String region,
      String address,
      String mobile,
      String special,
      DateTime del,String selected) async {
    String orderId;
    await FirebaseFirestore.instance.collection('Orders').add({
      "giftId": giftId,
      "GiftName": widget.giftName,
      "GiftImg": widget.mainImg,
      "totalPrice": total,
      "price": widget.price,
      "delivery": delivery,
      "packaging": packaging,
      "discount": discount,
      "customer": customer,
      "address": address + ', ' + region + ', ' + city,
      "mobile": mobile,
      "special": special,
      "deliveryTime": del,
      "OrderTime": DateTime.now(),
      "state": "Preparing",
      "reviewed": false,
      "selected":selected!=null && selected!=""?selected:""
    }).then((onValue) {
      orderId = onValue.id;
    });

    List unionList = [orderId];

    await FirebaseFirestore.instance.collection('Users').doc(uid).set(
        {'Orders': FieldValue.arrayUnion(unionList)}, SetOptions(merge: true));

    setState(() {
      uploading = false;
    });

    //     collection('Orders')
    //     .doc(orderId)
    //     .set({
    //   "OrderTime": DateTime.now(),
    //   "GiftId": giftId,
    //   "GiftName": widget.giftName,
    //   "GiftImg": widget.mainImg,
    //   "price": widget.price,
    //   "totalPrice": total,
    //   "pageimg": widget.pageImg,
    //   "pageid": widget.pageId,
    //   "state": "Waiting For Approval",
    //   "reviewed": false
    // });
  }
}
