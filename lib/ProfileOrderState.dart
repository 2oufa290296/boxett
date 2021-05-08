import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:boxet/AddReview.dart';
import 'package:boxet/ShowReview.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProfileOrderState extends StatefulWidget {
  final String orderId,
      mainImg,
      giftName,
      giftId,
      customer,
      address,
      mobile,
      state,
      special;
  final int giftPrice, delivery, total, discount;
  final Timestamp deliveryTime;
  ProfileOrderState(
    this.orderId,
    this.mainImg,
    this.giftName,
    this.giftPrice,
    this.delivery,
    this.total,
    this.discount,
    this.giftId,
    this.customer,
    this.address,
    this.mobile,
    this.state,
    this.deliveryTime,
    this.special,
  );

  @override
  _ProfileOrderStateState createState() => _ProfileOrderStateState();
}

class _ProfileOrderStateState extends State<ProfileOrderState>
    with SingleTickerProviderStateMixin {
  double width, height;
  String location = "";
  String region = "";
  String city = "";
  String yourReview = "";
  double goodPackaging = 0.0;
  double worthPrice = 0.0;
  double materialQuality = 0.0;
  double onTime = 0.0;
  double yourRate = 0;
  DateTime deliveryTime;
  String deliveryDay = "";
  String deliveryMonthDay = "";
  bool showProgressBar = true;
  bool addPressed = false;
  bool reviewed = false;
  TextEditingController specialController;
  String userImg = "";
  String userName = "";
  String returnedReason = "";
  AnimationController _controller;
  String mainImg, giftName, giftId, customer, address, mobile, state, special;
  int giftPrice, delivery, total, discount;
  Timestamp deliveryT;
  bool emptyPage=false;
  bool addingData=false;
  List<Widget> forgottenList=[];

  _refresh() {
    setState(() {
      
      getOrderData();
    });
  }

  Future getOrderData() async {
    var formatterd = new DateFormat('EEEE');
    var formatterm = new DateFormat('MMMM d');
    var formattermm=new DateFormat('hh:mm a');
    if (deliveryT != null) {
      deliveryTime = deliveryT.toDate();
      deliveryDay = formatterd.format(deliveryTime);
      deliveryMonthDay = formatterm.format(deliveryTime)+' at '+formattermm.format(deliveryTime);
    }

    if (address != null && address.isNotEmpty) {
      List<String> splitted = address.split(",");
      if (splitted != null && splitted.isNotEmpty) {
        location = splitted[0];
        region = splitted[1];
        city = splitted[2];
      }
    }

    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    // String uid = sharedPref.getString('uid');
    userImg = sharedPref.getString('imgURL');
    userName = sharedPref.getString('username');

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderId)
        .get()
        .then((value) {
      if (value.exists) {
        reviewed = value.data()['reviewed'];
        if (mainImg == null || mainImg.isEmpty) {
          mainImg = value.data()['GiftImg'];
          giftName = value.data()['GiftName'];
          giftId = value.data()['giftId'];
          customer = value.data()['customer'];
          address = value.data()['address'];
          mobile = value.data()['mobile'];
          state = value.data()['state'];
          special = value.data()['special'];
          giftPrice = value.data()['price'];
          delivery = value.data()['delivery'];
          total = value.data()['totalPrice'];
          deliveryT = value.data()['deliveryTime'];
          deliveryTime = deliveryT.toDate();
          deliveryDay = formatterd.format(deliveryTime);
          deliveryMonthDay = formatterm.format(deliveryTime)+' at '+formattermm.format(deliveryTime);
           List<String> splitted = address.split(",");
      if (splitted != null && splitted.isNotEmpty) {
        location = splitted[0];
        region = splitted[1];
        city = splitted[2];
      }
        }
      }
    });

    if(mainImg==null || mainImg.isEmpty){
      emptyPage=true;
    }

    if (state.toLowerCase() == "returned") {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.orderId)
          .get()
          .then((results) {
        if (results.exists) {
          returnedReason = results.data()['returnedReason'];
        }
      });
    }

    if (state.toLowerCase() == "preparing") {
    await FirebaseFirestore.instance.collection('ForgottenData').doc(widget.orderId).get().then((value) {
      if(value.exists&&value.data().isNotEmpty){
        if(forgottenList.isNotEmpty)forgottenList.clear();
        value.data().forEach((key, value) { forgottenList.add(Container(child:Text(value,style:TextStyle(fontSize:18,color:Colors.white))));});
      }
    });
    }

    if (reviewed) {
      
      await FirebaseFirestore.instance
          .collection('Gifts')
          .doc(giftId)
          .collection('reviews')
          .doc(widget.orderId)
          .get()
          .then((onValue) {
        if (onValue.exists) {
          print(onValue.data());
          yourReview = onValue.data()['review'];
          num timeNum = onValue.data()['ontime'];
          num materialNum = onValue.data()['materialquality'];
          num packagingNum = onValue.data()['goodpackaging'];
          num priceNum = onValue.data()['worthprice'];

          onTime = timeNum.toDouble();
          materialQuality = materialNum.toDouble();
          goodPackaging = packagingNum.toDouble();
          worthPrice = priceNum.toDouble();
          if (onValue.data()['totalrate'] != null) {
            num abc = onValue.data()['totalrate'];

            if (abc is double) {
              yourRate = abc;
            } else {
              yourRate = abc.toDouble();
            }
          }
        }
      });
    }

    setState(() {
      showProgressBar = false;
    });
  }

  @override
  void dispose() {
    
    super.dispose();
    specialController.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    specialController = TextEditingController();
    mainImg = widget.mainImg;
    giftName = widget.giftName;
    giftId = widget.giftId;
    customer = widget.customer;
    address = widget.address;
    mobile = widget.mobile;
    state = widget.state;
    special = widget.special;
    giftPrice = widget.giftPrice;
    delivery = widget.delivery;
    total = widget.total;
    discount = widget.discount;
    deliveryT = widget.deliveryTime;
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    getOrderData();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
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
                        style: TextStyle(color: Colors.white, fontSize: 20,fontFamily:"Lobster",letterSpacing:1)))
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
                    Color.fromRGBO(18,42,76,1),
                    ],
                  ))),
          preferredSize: Size(width, 50)),
      body: showProgressBar
          ? Center(child:  Container(
                    width: 50,
                    height: 50,
                    child: FlareActor(
                      'assets/loading.flr',
                      animation: 'Loading',
                    )))
          :emptyPage?Center(child:Text('Order doesnt exist anymore',style:TextStyle(color:Colors.white,fontSize:18))) :SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Card(
                    color: Color(0xFF282828),
                    child: Column(
                      children: <Widget>[
                        Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft:Radius.circular(4),topRight:Radius.circular(4),bottomLeft:Radius.circular(0),bottomRight:Radius.circular(0))),
                          color: Color(0xFF151515),
                          margin: EdgeInsets.all(0),
                          
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/giftPage',
                                  arguments: giftId);
                            },
                            child: Container(
                              width: width,
                              height: height / 4,
                              child: CachedNetworkImage(
                                imageUrl: mainImg,
                                fit: BoxFit.cover,
                                height: height / 4,
                                width: width,
                                progressIndicatorBuilder:
                                    (context, url, progress) {
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
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 5),
                                  child: Text(giftName,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontFamily: "Lobster",
                                          letterSpacing: 2))),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 1, bottom: 1),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Text('Subtotal',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                          )),
                                    ),
                                    Container(
                                        child:
                                            Text(giftPrice.toString() + ' LE',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white70,
                                                )))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 1, bottom: 1),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Text('Delivery Fee',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                          )),
                                    ),
                                    Container(
                                        child: Text(delivery.toString() + ' LE',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            )))
                                  ],
                                ),
                              ),
                              discount != null && discount != 0
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, top: 1, bottom: 1),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            child: Text('Discount',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green,
                                                )),
                                          ),
                                          Container(
                                              child: Text(
                                                  '- ' +
                                                      discount.toString() +
                                                      ' LE',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.green,
                                                  )))
                                        ],
                                      ),
                                    )
                                  : Container(height: 0, width: 0),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: <Widget>[
                                  Expanded(
                                      child: Divider(
                                    color: Colors.grey,
                                    height: 10,
                                  ))
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 1, bottom: 15),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Text('Total ',
                                          style: TextStyle(
                                              fontSize: 20,
                                            
                                              color: Colors.white,
                                             )),
                                    ),
                                    Container(
                                        child: Text(total.toString() + ' LE',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                            )))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                      color: Color(0xFF232323),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                              fontWeight: FontWeight.bold))),
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
                                      child: Text(customer,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        child: Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    )),
                                    Container(
                                        width: width * 0.8,
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(location,
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
                      )),
                  special != null && special != ""
                      ? Card(
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
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ],
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        special,
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ]),
                          ))
                      : Container(height: 0, width: 0),
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
                                  Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: RichText(
                                        text: TextSpan(children: <TextSpan>[
                                          new TextSpan(
                                              text: "( ",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          new TextSpan(
                                              text: state,
                                              style: TextStyle(
                                                  color: state.toLowerCase() ==
                                                          "delivered"
                                                      ? Colors.green
                                                      : state.toLowerCase() ==
                                                              "preparing"
                                                          ? Colors.yellow
                                                          : Colors.red,
                                                  fontSize: 18,
                                                  fontFamily: "Lobster",
                                                  letterSpacing: 2)),
                                          new TextSpan(
                                              text: " )",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                      ))
                                ],
                              ),
                              state.toLowerCase() == "delivered"
                                  ? Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(
                                          width: width - 30,
                                          child: RichText(
                                            text: TextSpan(children: <TextSpan>[
                                              new TextSpan(
                                                  text:
                                                      'Your gift was delivered on ',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white)),
                                              new TextSpan(
                                                  text: deliveryDay +
                                                      " " +
                                                      deliveryMonthDay,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                          ),
                                          margin: EdgeInsets.only(top: 10),
                                        ),
                                      ],
                                    )
                                  : state.toLowerCase() == "returned"
                                      ? Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Container(
                                              width: width - 30,
                                              child: RichText(
                                                text: TextSpan(children: <
                                                    TextSpan>[
                                                  new TextSpan(
                                                      text:
                                                          'Your gift was returned on ',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white)),
                                                  new TextSpan(
                                                      text: deliveryDay +
                                                          " " +
                                                          deliveryMonthDay,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ]),
                                              ),
                                              margin: EdgeInsets.only(top: 10),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Container(
                                                width: width - 30,
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                child: Text(
                                                    'Your gift will arrive on ' +
                                                        deliveryDay +
                                                        " " +
                                                        deliveryMonthDay,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white))),
                                          ],
                                        ),
                              state.toLowerCase() == "returned"
                                  ? Container(
                                      margin: EdgeInsets.only(top: 3),
                                      child: Text(returnedReason,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                          )))
                                  : Container(height: 0, width: 0)
                            ]),
                      )),
                      forgottenList.isNotEmpty?Card(color: Color(0xFF232323),
                      child: Container(width:width,
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: [
                             Container(margin:EdgeInsets.only(bottom:5),
                                      child: Text('Additional Details',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))),
                            Container(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:forgottenList)),
                          ],
                        ),
                      )):Container(),
                  state.toLowerCase() == "preparing"
                      ? Card(
                          color: Color(0xFF232323),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Container(
                                          child: Text(
                                              "Forgot to add something? ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white))),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (addPressed) {
                                              addPressed = false;
                                              specialController.clear();
                                            } else {
                                              addPressed = true;
                                            }
                                          });
                                        },
                                        child: Container(
                                            child: Text(
                                                addPressed ? 'Cancel' : 'Add',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: addPressed
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ),
                                    ],
                                  ),
                                  addPressed
                                      ? Container(
                                          child: TextField(
                                              autofocus: false,
                                              cursorColor: Colors.white70,
                                              controller: specialController,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Type your missing data here',
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white)),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .white70)),
                                                hintStyle: TextStyle(
                                                    color: Colors.white70),
                                              )))
                                      : Container(height: 0, width: 0)
                                ]),
                          ))
                      : Container(height: 0, width: 0),
                  state.toLowerCase() == "delivered"
                      ? Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Divider(
                                    color: Colors.grey,
                                    height: 10,
                                  ),
                                ),
                              ),
                              Container(
                                  child: Text('Your Review',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white))),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Divider(
                                    color: Colors.grey,
                                    height: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(height: 0, width: 0),
                  reviewed && state.toLowerCase() == "delivered"
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowReview(
                                        widget.orderId,
                                        mainImg,
                                        giftId,
                                        onTime,
                                        goodPackaging,
                                        materialQuality,
                                        worthPrice,
                                        yourReview)));
                          },
                          child: Card(
                            color: Color(0xFF232323),
                            child: Container(
                              padding: EdgeInsets.only(
                                  right: 10, left: 10, top: 10, bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      userImg != null && userImg.isNotEmpty
                                          ? Container(
                                              padding: EdgeInsets.all(0.5),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white),
                                              child: Card(
                                                margin: EdgeInsets.all(0),
                                                clipBehavior: Clip.antiAlias,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22)),
                                                child: CachedNetworkImage(
                                                  imageUrl: userImg,
                                                  height: 44,
                                                  width: 44,
                                                  fit: BoxFit.cover,
                                                  progressIndicatorBuilder:
                                                      (context, url, progress) {
                                                    return Shimmer.fromColors(
                                                      enabled: true,
                                                      child: Container(
                                                          height: 44,
                                                          width: 44,
                                                          color: Color.fromRGBO(
                                                              55, 57, 56, 1.0)),
                                                      baseColor:
                                                          Color(0xFF282828),
                                                      highlightColor:
                                                          Color(0xFF383838),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : Container(height: 0, width: 0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(userName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 10),
                                                    child: SmoothStarRating(
                                                      allowHalfRating: true,
                                                      color: Colors.yellow[700],
                                                      borderColor:
                                                          Colors.yellow[700],
                                                      isReadOnly: true,
                                                      size: 15,
                                                      rating: yourRate,
                                                    )),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text('( ',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white70))),
                                                Text(
                                                    yourRate.toStringAsFixed(2),
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                Text(' )',
                                                    style: TextStyle(
                                                        color: Colors.white70))
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  yourReview != null && yourReview != ""
                                      ? Container(
                                          width: width,
                                          alignment: yourReview.contains(
                                                  new RegExp(
                                                      r'[\u0600-\u06FF]'))
                                              ? Alignment.topRight
                                              : Alignment.topLeft,
                                          padding: EdgeInsets.only(
                                              left: width * 0.15,
                                              right: 15,
                                              bottom: 0),
                                          child: Text(yourReview,
                                              textAlign: yourReview.contains(
                                                      new RegExp(
                                                          r'[\u0600-\u06FF]'))
                                                  ? TextAlign.end
                                                  : TextAlign.start,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)))
                                      : Container(height: 0, width: 0)
                                ],
                              ),
                            ),
                          ),
                        )
                      : state.toLowerCase() == "delivered"
                          ? Card(
                              color: Color(0xFF232323),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Container(
                                              child: Text(
                                                  "Please rate your gift  ",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white))),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (addPressed) {
                                                  addPressed = false;
                                                } else {
                                                  addPressed = true;
                                                }
                                              });
                                            },
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddReview(
                                                                widget.orderId,
                                                                mainImg,
                                                                giftId,
                                                                'add'))).then(
                                                    (onValue) {
                                                  if (onValue) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(
                                                            backgroundColor:
                                                                Color(
                                                                    0xFF232323),
                                                            content: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                    height: 15,
                                                                    child: Text(
                                                                        'Your review has been added')),
                                                                ScaleTransition(
                                                                    scale: Tween(
                                                                            begin:
                                                                                0.0,
                                                                            end:
                                                                                1.0)
                                                                        .animate(CurvedAnimation(
                                                                            parent:
                                                                                _controller,
                                                                            curve: Curves
                                                                                .elasticOut)),
                                                                    child: Container(
                                                                        width:
                                                                            30,
                                                                        height:
                                                                            30,
                                                                        decoration: BoxDecoration(
                                                                            shape: BoxShape
                                                                                .circle,
                                                                            color: Colors
                                                                                .green),
                                                                        child: Icon(
                                                                            Icons
                                                                                .done,
                                                                            color:
                                                                                Colors.white)))
                                                              ],
                                                            )));
                                                    _controller.forward();

                                                    _refresh();
                                                  }
                                                });
                                              },
                                              child: Container(
                                                  child: Text('Add Review',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.yellow,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ))
                          : Container(height: 0, width: 0),
                  state.toLowerCase() == "preparing" &&
                                          specialController.text.isNotEmpty
                                      ?Row(
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
                              Color.fromRGBO(18,42,76,1),
                    Color.fromRGBO(5,150,197,1),
                    Color.fromRGBO(18,42,76,1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap:  () async {
                                      setState((){addingData=true;});
                                        await FirebaseFirestore.instance
                                            .collection('ForgottenData')
                                            .doc(widget.orderId)
                                            .set({
                                          DateTime.now().toString():
                                              specialController.text,
                                        }, SetOptions(merge: true)).then(
                                                (onValue) {
                                                  setState((){addingData=false;});
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor:
                                                      Color(0xFF232323),
                                                  content: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                          height: 15,
                                                          child: Text(
                                                              'Your additional data has been added')),
                                                      ScaleTransition(
                                                          scale: Tween(
                                                                  begin: 0.0,
                                                                  end: 1.0)
                                                              .animate(CurvedAnimation(
                                                                  parent:
                                                                      _controller,
                                                                  curve: Curves
                                                                      .elasticOut)),
                                                          child: Container(
                                                              width: 30,
                                                              height: 30,
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .green),
                                                              child: Icon(
                                                                  Icons.done,
                                                                  color: Colors
                                                                      .white)))
                                                    ],
                                                  )));
                                          _controller.forward();
                                          specialController.clear();
                                          setState((){addPressed = false;});
                                          
                                              
                                         _refresh();
                                        });
                                      }
                                    ,
                            child: Center(
                              child: addingData?Container(height:15,width:15,child: CircularProgressIndicator(strokeWidth: 1,valueColor: AlwaysStoppedAnimation(Colors.white),)):Text(
                                 'Submit'
                                      ,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ):Container(height:50)
                ],
              ),
            ),
    );
  }

}
