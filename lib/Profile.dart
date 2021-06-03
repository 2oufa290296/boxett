import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:boxet/AssistantActivity.dart';
import 'package:boxet/ProfileOrderState.dart';
import 'package:boxet/RoundedAppBar.dart';
import 'package:boxet/classes/ProfileGifts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';


class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  double height;
  double width;
  List<ProfileGifts> preOrders = [];
  // List<String> bottomlist = new List<String>();
  // List<Icon> bottomlisticon = new List<Icon>();
  String imgUrl = "";
  String username = "";
  String userId = "";
  bool _progressBarActive = false;
  String gender = "";
  String provider = "";
  bool noPrevOrders = false;
  SharedPreferences pref;
  bool showProgress = true;
  bool networkError=false;
  bool retrying=false;
  FlareActor flareActor = FlareActor(
    'assets/loading.flr',
    animation: 'Loading',
  );

  @override
  void initState() {
    getData();

    super.initState();
  }

  Future getData() async {

    if(imgUrl==""){
pref = await SharedPreferences.getInstance();

    imgUrl = pref.getString('imgURL');
    userId = pref.getString('uid');
    username = pref.getString('username');
    gender = pref.getString('gender');
    provider = pref.getString('provider');

  

    if (gender == null) {
      gender = "";
    }
    }
    

     var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get()
        .then((results) async {
      if (results.data().isNotEmpty && results.data()['Orders'] != null) {
        List ordersIds = results.data()['Orders'];
        List ordersIdsRev = ordersIds.reversed.toList();
        await FirebaseFirestore.instance
            .collection('Orders')
            .where(FieldPath.documentId, whereIn: ordersIdsRev)
            .get()
            .then((value) {
          if (value.docs != null && value.docs.isNotEmpty) {
            preOrders.length = value.docs.length;
            value.docs.forEach((element) {
              preOrders[ordersIdsRev.indexOf(element.id)] = new ProfileGifts(
                  element.id,
                  element.data()['GiftImg'],
                  element.data()['GiftName'],
                  element.data()['price'],
                  element.data()['delivery'],
                  element.data()['totalPrice'],
                  element.data()['discount'],
                  element.data()['giftId'],
                  element.data()['customer'],
                  element.data()['address'],
                  element.data()['mobile'],
                  element.data()['state'],
                  element.data()['deliveryTime'],
                  element.data()['special'],
                  element.data()['reviewed']);
            });
          }
        });
      }
    });

    if (mounted) {
      setState(() {
        if (preOrders != null && preOrders.isNotEmpty) {
          noPrevOrders = false;
        } else {
          noPrevOrders = true;
        }
        if(networkError) networkError=false;
        if(retrying) retrying=false;
        showProgress = false;
      });
    }

        }else {
          setState((){
            networkError=true;
            showProgress = false;
            if(retrying)retrying=false;
          });
        }
    
  }

  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldkey,
      body: _progressBarActive == true
          ? Center(
              child: Container(
                  width: 50,
                  height: 50,
                  child: FlareActor(
                    'assets/loading.flr',
                    animation: 'Loading',
                  )),
            )
          : new Stack(
              fit: StackFit.expand,
              children: <Widget>[
                FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.45,
                    child: RoundedAppBar(
                        imgUrl, username, gender, provider, userId)),
                FractionallySizedBox(
                    heightFactor: 0.55,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: <Widget>[
                        Card(
                            elevation: 5,
                            color: Colors.transparent,
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                                width: (0.9 * width) - 8,
                                height: 80,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      child: Image.asset(
                                        'assets/images/inboxassist.jpg',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Positioned.fill(
                                        child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AssistantActivity()));
                                        },
                                        child: Container(
                                            color: Colors.black45,
                                            alignment: Alignment.center,
                                            child: Text('Boxet Assistant',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontFamily: "Lobster",
                                                    letterSpacing: 2))),
                                      ),
                                    )),
                                  ],
                                ))),
                        Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: 0.1 * width, right: 10),
                                  child: Divider(
                                    color: Colors.grey,
                                    height: 10,
                                  ),
                                ),
                              ),
                              Container(
                                  child: Text('Your Orders',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white))),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: 10, right: 0.1 * width),
                                  child: Divider(
                                    color: Colors.grey,
                                    height: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: height/4,
                          width: width,
                          child: showProgress
                              ? Center(
                                  child: Container(
                                      width: 50, height: 50, child: flareActor))
                              :networkError||retrying?
                     Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            
                            child: Text(
                              'No Internet Connection',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                 ),
                            )),
                        Container(
                              margin: EdgeInsets.only(top: 10),
                              width: width / 3,
                              height: 30,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      retrying = true;
                                    });
                                    Future.delayed(Duration(milliseconds: 500),
                                        () async {
                                      getData() ;
                                    });
                                  },
                                  child: Center(
                                      child: retrying
                                          ? Container(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white),
                                                strokeWidth: 1,
                                              ),
                                            )
                                          : Text(
                                              'RETRY',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            )),
                                ),
                              ),
                            ),
                      ],
                    
                  ): !noPrevOrders
                                  ? ListView.builder(
                                      padding:
                                          EdgeInsets.only(left: 0.05 * width),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: preOrders.length,
                                      itemBuilder: (context, index) {
                                        if (index == preOrders.length - 1) {
                                          return Container(
                                              margin: EdgeInsets.only(
                                                  right: 0.05 * width),
                                              child: displayCardItem(
                                                  preOrders[index]));
                                        } else {
                                          return displayCardItem(
                                              preOrders[index]);
                                        }
                                      })
                                  : Container(
                                      
                                      child: Center(
                                          child: Text('No Previous Orders',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 16))),
                                    ),
                        ),
                      ],
                    )

                    //     // Expanded(
                    //     //   child: Align(
                    //     //     alignment: Alignment.bottomCenter,
                    //     //     child: Container(
                    //     //       margin: EdgeInsets.only(bottom: 0.007),
                    //     //       height: height * 0.15,
                    //     //       child: Row(
                    //     //           mainAxisSize: MainAxisSize.max,
                    //     //           children: <Widget>[
                    //     //             Expanded(
                    //     //               child: ListView.builder(
                    //     //                 itemCount: bottomlist.length,
                    //     //                 scrollDirection: Axis.horizontal,
                    //     //                 itemBuilder: (context, index) {
                    //     //                   return Container(
                    //     //                     width: width * 0.9,
                    //     //                     margin: EdgeInsets.only(
                    //     //                         left: 0.05 * width),
                    //     //                     child: Card(
                    //     //                       color: Colors.black,
                    //     //                       child: Row(
                    //     //                         mainAxisAlignment:
                    //     //                             MainAxisAlignment.center,
                    //     //                         children: <Widget>[
                    //     //                           Container(
                    //     //                               margin: EdgeInsets.only(
                    //     //                                   right: 15),
                    //     //                               child:
                    //     //                                   bottomlisticon[index]),
                    //     //                           Column(
                    //     //                             mainAxisAlignment:
                    //     //                                 MainAxisAlignment.center,
                    //     //                             children: <Widget>[
                    //     //                               Text(bottomlist[index],
                    //     //                                   style: TextStyle(
                    //     //                                       color: Colors.white,
                    //     //                                       fontSize: 18))
                    //     //                             ],
                    //     //                           )
                    //     //                         ],
                    //     //                       ),
                    //     //                     ),
                    //     //                   );
                    //     //                 },
                    //     //               ),
                    //     //             )
                    //     //           ]),
                    //     //     ),
                    //     //   ),
                    //     // ),
                    //   ],
                    // ),
                    ),
              ],
            ),
    );
  }

  Widget displayCardItem(ProfileGifts content) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.only(bottom: 5, right: 3, left: 3),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new ProfileOrderState(
                        content.orderId,
                        content.image,
                        content.name,
                        content.price,
                        content.delivery,
                        content.total,
                        content.discount,
                        content.giftid,
                        content.customer,
                        content.address,
                        content.mobile,
                        content.state,
                        content.deliveryTime,
                        content.special,
                      )));
        },
        child: Container(
          width: (width * 0.9) - 8,
          height: height / 4,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: content.image,
                fit: BoxFit.cover,
                height: height / 4,
                width: (width * 0.9) - 8,
                progressIndicatorBuilder: (context, url, progress) {
                  return Shimmer.fromColors(
                    enabled: true,
                    child: Container(
                        height: height / 4,
                        width: (width * 0.9) - 8,
                        color: Color(0xFF282828)),
                    baseColor: Color(0xFF282828),
                    highlightColor: Color(0xFF383838),
                  );
                },
              ),
              content.state != null && content.state != ""
                  ? Positioned(
                      left: 0,
                      top: 10,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                        padding: EdgeInsets.only(
                            top: 5, bottom: 5, right: 10, left: 5),
                        child: Container(
                            child: Text(content.state,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Lobster",
                                  letterSpacing: 2,
                                  color:
                                      content.state.toLowerCase() == "returned"
                                          ? Color(0xFFCE203C)
                                          : content.state.toLowerCase() ==
                                                  "delivered"
                                              ? Colors.green
                                              : content.state.toLowerCase() ==
                                                      "preparing"
                                                  ? Colors.yellow
                                                  : Colors.transparent,
                                ))),
                      ),
                    )
                  : Container(height: 0, width: 0),
            ],
          ),
        ),
      ),
    );
  }
}
