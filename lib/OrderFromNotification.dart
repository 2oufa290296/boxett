import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:boxet/AddReview.dart';
import 'package:boxet/ShowReview.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class OrderFromNotification extends StatefulWidget {
  final String orderId;

  OrderFromNotification(this.orderId);

  @override
  _OrderFromNotificationState createState() => _OrderFromNotificationState();
}

class _OrderFromNotificationState extends State<OrderFromNotification> {
  double width, height;
  String totalPrice = "";
  String address = "";
  String customerName = "";
  String region = "";
  String city = "";
  String location = "";
  String mobile = "";
  String specialRequest = "";
  String subTotal = "";
  String yourReview = "";
  String giftName = "";
  String giftImg = "";
  String state = "";
  String giftId = "";
  double goodPackaging = 0.0;
  double worthPrice = 0.0;
  double materialQuality = 0.0;
  double onTime = 0.0;
  double yourRate;
  DateTime deliveryTime;
  String deliveryDay = "";
  String deliveryMonthDay = "";
  int deliveryFee;
  bool showProgressBar = true;
  bool addPressed = false;
  bool reviewed = false;
  bool specialChanged = false;
  TextEditingController specialController;

  _refresh() {
    setState(() {
      showProgressBar = true;
      getOrderData();
    });
  }

  Future getOrderData() async {
    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderId)
        .get()
        .then((onValue) {
      if (onValue.exists) {
        totalPrice = onValue.data()['totalPrice'];
        subTotal = onValue.data()['price'];
        giftName = onValue.data()['GiftName'];
        giftImg = onValue.data()['GiftImg'];
        giftId = onValue.data()['giftId'];
        state = onValue.data()['state'];
        reviewed=onValue.data()['reviewed'];
        address = onValue.data()['address'];
        customerName = onValue.data()['customer'];
        mobile = onValue.data()['mobile'];
        specialRequest = onValue.data()['special'];
        Timestamp timestamp = onValue.data()['deliveryTime'];
        deliveryTime = timestamp.toDate();
        var formatterd = new DateFormat('EEEE');
        var formatterm = new DateFormat('MMMM d');
        deliveryDay = formatterd.format(deliveryTime);
        deliveryMonthDay = formatterm.format(deliveryTime);

        deliveryFee = int.parse(totalPrice) - int.parse(subTotal);
        List<String> splitted = address.split(",");
        if (splitted != null && splitted.isNotEmpty) {
          location = splitted[0];
          region = splitted[1];
          city = splitted[2];
        }
      }
    });
    if (reviewed) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc('abaka1231')
          .collection('Reviews')
          .doc(widget.orderId)
          .get()
          .then((onValue) {
        if (onValue.exists) {
          yourReview = onValue.data()['review'];
          num timeNum = onValue.data()['ontime'];
          num materialNum = onValue.data()['materialquality'];
          num packagingNum = onValue.data()['goodPackaging'];
          num priceNum = onValue.data()['worthprice'];

          onTime = timeNum.toDouble();
          materialQuality = materialNum.toDouble();
          goodPackaging = packagingNum.toDouble();
          worthPrice = priceNum.toDouble();
          num abc = onValue.data()['totalrate'];

          if (abc is double) {
            yourRate = abc;
          } else {
            yourRate = abc.toDouble();
          }
        }
      });
    }

    setState(() {
      showProgressBar = false;
    });
  }

  @override
  void initState() {
    specialController = TextEditingController();

    getOrderData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    print(giftName);

    return Scaffold(
        appBar: new AppBar(
          title: Text('Your Order'),
          backgroundColor: Color.fromRGBO(45, 47, 46, 1.0),
        ),
        body: showProgressBar
            ? Center(child:  Container(
                    width: 50,
                    height: 50,
                    child: FlareActor(
                      'assets/loading.flr',
                      animation: 'Loading',
                    )))
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Card(
                      color: Color.fromRGBO(75, 77, 76, 1.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Card(
                            margin: EdgeInsets.only(
                                left: 10, top: 10, bottom: 10, right: 10),
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                giftImg,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                            width: width - 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(bottom: 15),
                                    child: Text(giftName,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                                Row(
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
                                        child: Text(subTotal + ' LE',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            )))
                                  ],
                                ),
                                Row(
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
                                        child:
                                            Text(deliveryFee.toString() + ' LE',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white70,
                                                )))
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Text('Total ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          )),
                                    ),
                                    Container(
                                        child: Text(totalPrice + ' LE',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            )))
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Card(
                        color: Color.fromRGBO(75, 77, 76, 1.0),
                        child: Container(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          child: Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 20,
                                      )),
                                      Container(
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
                    specialRequest != "" && specialRequest != null
                        ? Card(
                            color: Color.fromRGBO(75, 77, 76, 1.0),
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
                                          specialRequest,
                                          style: TextStyle(color: Colors.white),
                                        ))
                                  ]),
                            ))
                        : Container(height: 0, width: 0),
                    Card(
                        color: Color.fromRGBO(75, 77, 76, 1.0),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        child: Text('Delivery Time',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold))),
                                    state == "delivered"
                                        ? Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: RichText(
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                                new TextSpan(
                                                    text: "( ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                new TextSpan(
                                                    text: 'Delivered',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                new TextSpan(
                                                    text: " )",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ))
                                        : state == "preparing"
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                child: RichText(
                                                  text: TextSpan(children: <
                                                      TextSpan>[
                                                    new TextSpan(
                                                        text: "( ",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    new TextSpan(
                                                        text: 'Preparing',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.orange,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    new TextSpan(
                                                        text: " )",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ]),
                                                ))
                                            : state == "returned"
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: RichText(
                                                      text: TextSpan(children: <
                                                          TextSpan>[
                                                        new TextSpan(
                                                            text: "( ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: 'Returned',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: " )",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ]),
                                                    ))
                                                : Container(height: 0, width: 0)
                                  ],
                                ),
                                state == "waiting for approval"
                                    ? Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text('Waiting for approval',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.yellow)))
                                    : state == "returned"
                                        ? Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Container(
                                                width: width -30,
                                                child: RichText(
                                                  text: TextSpan(
                                                      children: <TextSpan>[
                                                        new TextSpan(
                                                            text:
                                                                'Your gift was returned on ',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white)),
                                                        new TextSpan(
                                                            text: deliveryDay +
                                                                " " +
                                                                deliveryMonthDay,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ]),
                                                ),
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child: Text(
                                                      state == "delivered"
                                                          ? 'Your gift arrived on '
                                                          : 'Your gift will arrive on ',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.white))),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child: Text(
                                                      deliveryDay +
                                                          " " +
                                                          deliveryMonthDay,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ],
                                          )
                              ]),
                        )),
                    state == "preparing" || state == "waiting for approval"
                        ? Card(
                            color: Color.fromRGBO(75, 77, 76, 1.0),
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
                                                specialChanged = false;
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
                                                onChanged: (v) {
                                                  specialChanged = true;
                                                },
                                                controller: specialController,
                                                style: TextStyle(
                                                    color: Colors.white),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Type your missing data here',
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
                    state == "delivered"
                        ? Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: 0.1 * width, right: 5),
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
                                    margin: EdgeInsets.only(
                                        left: 5, right: 0.1 * width),
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
                    reviewed && state == "delivered"
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ShowReview(
                                              widget.orderId,
                                              giftImg,
                                              giftId,
                                              onTime,
                                              goodPackaging,
                                              materialQuality,
                                              worthPrice,
                                              yourReview)))
                                  .then((onValue) => _refresh());
                            },
                            child: Card(
                              color: Color.fromRGBO(75, 77, 76, 1.0),
                              child: Container(
                                padding: EdgeInsets.only(
                                    right: 10, left: 10, top: 10, bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                            child: Row(
                                          children: <Widget>[
                                            CircleAvatar(
                                              radius: width / 17,
                                              backgroundImage:
                                                  NetworkImage(giftImg),
                                            ),
                                            Container(
                                                width: width * 0.42,
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text('Your Name',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ],
                                        )),
                                        Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: SmoothStarRating(
                                              allowHalfRating: true,
                                              color: Colors.yellow[700],
                                              borderColor: Colors.yellow[700],
                                              isReadOnly: true,
                                              size: width / 20,
                                              rating: yourRate,
                                            )),
                                      ],
                                    ),
                                    yourReview != null && yourReview != ""
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                top: 10, left: 15),
                                            child: Text(yourReview,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16)))
                                        : Container(height: 0, width: 0)
                                  ],
                                ),
                              ),
                            ),
                          )
                        : state == "delivered"
                            ? Card(
                                color: Color.fromRGBO(75, 77, 76, 1.0),
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
                                                    "Please rate your gift ",
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
                                                                  widget
                                                                      .orderId,
                                                                  giftImg,
                                                                  giftId,
                                                                  'add')));
                                                },
                                                child: Container(
                                                    child: Text('Add Review',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.yellow,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                ))
                            : Container(height: 0, width: 0)
                  ],
                ),
              ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: InkWell(
                onTap: state == "delivered" ||
                        (state == "preparing" &&
                            specialController.text.isEmpty) ||
                        (state == "waiting for approval" &&
                            specialController.text.isEmpty)
                    ? () {
                        Navigator.pop(context);
                      }
                    : (state == "preparing" &&
                                specialController.text.isNotEmpty) ||
                            (state == "waiting for approval" &&
                                specialController.text.isNotEmpty)
                        ? () async {
                            await FirebaseFirestore.instance
                                .collection('ForgottenData')
                                .doc(widget.orderId)
                                .set({
                              "data": specialController.text,
                              "time": DateTime.now()
                            }).then((onValue) {
                              Navigator.pop(context);
                            });
                          }
                        : () {Navigator.pop(context);},
                child: Card(
                  color: Colors.pink,
                  elevation: 8,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                        state == "preparing" &&
                                specialController.text.isNotEmpty
                            ? 'Submit'
                            : state == "waiting for approval" && specialChanged
                                ? 'Submit'
                                : state == "delivered"
                                    ? 'Back'
                                    : state == "preparing" && !specialChanged
                                        ? 'Back'
                                        : state == "waiting for approval" &&
                                                !specialChanged
                                            ? 'Back'
                                            : 'Back',
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
}
