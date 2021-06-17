import 'package:boxet/LoginActivity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:boxet/OrderPage.dart';
import 'package:boxet/classes/Descriptions.dart';
import 'package:boxet/classes/SimilarGifts.dart';
import 'package:boxet/classes/ReviewsClass.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:boxet/my_flutter_app_icons.dart' as custicons;
import 'package:video_player/video_player.dart';



import 'PageActivity.dart';

class GiftPage extends StatefulWidget {
  final String id;
  
  GiftPage(this.id);

  @override
  _GiftPageState createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage> {
  final _auth = FirebaseAuth.instance;
  bool _progressBarVisible = true;
  String videoLink = "";
  List<CachedNetworkImage> imgProv = [];
  List<Descriptions> detailsList = [];
  String name = "";
  int price = 0;
  String pagename = "";
  String pageimg = "";
  String shopPackagingImg="";
  String shopPackagingFree="";
 int shopPackaging=0;
  String pageId = "";
  List description = [];
  num deliveryTime = 0;
  int delivery = 0;
  int boxetPackaging = 0;
  double pagerate = 0.0;
  String mainImg = "";
  int pagerates = 0;
  String pageInfo = "";
  List<SimilarGifts> similarList = [];
  Map<dynamic, dynamic> details;
  Map<dynamic, dynamic> reviewsMap;
  AnimationController likeController;
  Animation likeAnimation;
  SharedPreferences sharedPreferences;
  List<String> favoriteList = [];
  List<String> recentList = [];
  List selection=[];
  List<ReviewsClass> reviewsList = [];
  String userId = "";
  bool internetError = false;
  bool retrying = false;
  bool errorLoading = false;
  num refId;
  double giftRate;
  VideoPlayerController videoContr;
  bool wide=false;

  @override
  void initState() {
    _getSharedPref();
    _loadGiftData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (videoContr != null) videoContr.dispose();
  }

  Future _saveToFavDB(String giftId, String date, String img, String page,
      String pagId, int price) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('favorites')
        .doc(giftId)
        .set({
      "date": date,
    });
  }

  Future _deleteFromFavDB(String giftId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('favorites')
        .doc(giftId)
        .delete();
  }

  Future _getSharedPref() async {
    sharedPreferences =
        await SharedPreferences.getInstance().then((value) => value);
    userId = sharedPreferences.getString('uid');

    favoriteList = sharedPreferences.getStringList('favorite');
    if (favoriteList == null) {
      favoriteList = [];
    }
    recentList = sharedPreferences.getStringList('recentlyviewed');
    if (recentList == null) {
      recentList = [];
    }
    if (!recentList.contains(widget.id)) {
      recentList.add(widget.id);
      sharedPreferences.setStringList('recentlyviewed', recentList);
    } else {
      recentList.remove(widget.id);
      recentList.add(widget.id);
      sharedPreferences.setStringList('recentlyviewed', recentList);
    }

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('recentlyViewed')
        .doc(widget.id)
        .set({
      "date": DateTime.now().toString(),
    });

    // if (userId != null && userId != "") {
    //   await Firestore.instance
    //       .collection('Users')
    //       .document(userId)
    //       .collection('favorites')
    //       .getDocuments()
    //       .then((value) {
    //     if (value.documents != null && value.documents.isNotEmpty) {
    //       value.documents.forEach((element) {
    //         favoriteList.add(element['giftid']);
    //       });
    //     }
    //   });
    // }
  }

  Future _saveToFavorites(String giftId) async {
    setState(() {
      favoriteList.add(giftId);
    });
    sharedPreferences.setStringList('favorite', favoriteList);

    if (_auth.currentUser!=null &&userId != null && userId.isNotEmpty) {
      _saveToFavDB(widget.id, DateTime.now().toString(), mainImg, pageimg,
          pageId, price);
    }
  }

  Future _removeFromFavorites(String id) async {
    setState(() {
      favoriteList.remove(id);
    });
    sharedPreferences.setStringList('favorite', favoriteList);

    if (_auth.currentUser!=null && userId != null && userId.isNotEmpty) {
      _deleteFromFavDB(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
          body: _progressBarVisible == true
              ? new Center(
                  child: Container(
                      width: 50,
                      height: 50,
                      child: FlareActor(
                        'assets/loading.flr',
                        animation: 'Loading',
                      )),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: 1,
                      child: SingleChildScrollView(
                        child: internetError
                            ? Container(
                                alignment: Alignment.center,
                                height: height,
                                width: width,
                                child: Container(
                                  width: width,
                                  height: height / 2,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Icon(
                                          MdiIcons.accessPointNetworkOff,
                                          color: Colors.white70,
                                          size: 40,
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(top: 15),
                                          child: Text(
                                            'No Internet Connection',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 18,
                                               ),
                                          )),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(top: 25),
                                            width: width / 3,
                                            height: 30,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
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
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    retrying = true;
                                                  });
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 500),
                                                      () async {
                                                    _loadGiftData();
                                                  });
                                                },
                                                child: Center(
                                                    child: retrying
                                                        ? Container(
                                                            height: 15,
                                                            width: 15,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation(
                                                                      Colors
                                                                          .white),
                                                              strokeWidth: 1,
                                                            ),
                                                          )
                                                        : Text(
                                                            'RETRY',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16),
                                                          )),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : errorLoading
                                ? Container(height:height,width:width,
                                  child: Stack(alignment: Alignment.center,
                                    children: [
                                      Positioned(top:0,left:0,child: Container(
            height: 50,
            width:width,
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
                  child: Text('Gift Page',
                      style: TextStyle(color: Colors.white, fontSize: 20,fontFamily:"Lobster",letterSpacing:2)))
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
                ))),),
                                      Text(
                                        'Gift is not available',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                )
                                : Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          width: width,
                                          margin: EdgeInsets.only(
                                            bottom: 20,
                                          ),
                                          child: videoLink != null
                                              ? Stack(
                                                  children: [
                                                    Container( 
                                                           height:
                                                                    height /
                                                                        2,
                                                                width: width,
                                                          child: Center(
                                                            child:  videoContr != null &&
                                                            videoContr.value
                                                                .initialized
                                                        ?AspectRatio(
                                                                aspectRatio:
                                                                    videoContr
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    videoContr)):  Shimmer.fromColors(
                                                            enabled: true,
                                                            child: Container(
                                                                height:
                                                                    height /
                                                                        2,
                                                                width: width,
                                                                color: Color(
                                                                    0xFF282828)),
                                                            baseColor: Color(
                                                                0xFF282828),
                                                            highlightColor:
                                                                Color(
                                                                    0xFF383838),
                                                          )
                                                          ),
                                                        )
                                                        ,
                                                    Positioned.fill(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (videoContr
                                                                    .value
                                                                    .isPlaying) {
                                                                  setState(
                                                                      () {
                                                                    videoContr
                                                                        .pause();
                                                                  });
                                                                } else {
                                                                  setState(
                                                                      () {
                                                                    videoContr
                                                                        .play();
                                                                  });
                                                                }
                                                        },
                                                      ),
                                                    ),
                                                    
                                                    Positioned(
                                                        top: 10,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .black26,
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          10))),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10,
                                                                  right: 20),
                                                          child: Row(
                                                              children: <
                                                                  Widget>[
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              5),
                                                                      child: Icon(
                                                                          Icons
                                                                              .arrow_back_ios,
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                                Container(
                                                                    child: Text(
                                                                        'Gift',
                                                                        style: TextStyle(
                                                                            fontSize: 18,
                                                                            color: Colors.white,
                                                                            letterSpacing: 2,
                                                                            fontFamily: "Lobster")))
                                                              ]),
                                                        )),
                                                  ],
                                                )
                                              : Stack(
                                                  children: [
                                                    imgProv.isNotEmpty
                                                        ? Container(
                                                            width: width,height: wide?0.75*width:1.33*width,
                                                            color:  Color(0xFF181818),
                                                            child: Carousel(
                                                              
                                                              images: imgProv,
                                                              animationCurve:
                                                                  Curves
                                                                      .fastOutSlowIn,
                                                              autoplay: false,
                                                              dotSize: 4,
                                                              indicatorBgPadding:
                                                                  6.0,
                                                              dotBgColor:
                                                                  Colors
                                                                      .black54,
                                                            ),
                                                          )
                                                        : Shimmer.fromColors(
                                                            enabled: true,
                                                            child: Container(
                                                                height:
                                                                    wide?0.75*width:1.33*width,
                                                                width: width,
                                                                color: Color(
                                                                    0xFF282828)),
                                                            baseColor: Color(
                                                                0xFF282828),
                                                            highlightColor:
                                                                Color(
                                                                    0xFF383838),
                                                          ),
                                                    Positioned(
                                                        top: 10,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .black26,
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          10))),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10,
                                                                  right: 20),
                                                          child: Row(
                                                              children: <
                                                                  Widget>[
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              5),
                                                                      child: Icon(
                                                                          Icons
                                                                              .arrow_back_ios,
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                                Container(
                                                                    child: Text(
                                                                        'Gift',
                                                                        style: TextStyle(
                                                                            fontSize: 18,
                                                                            color: Colors.white,
                                                                            letterSpacing: 2,
                                                                            fontFamily: "Lobster")))
                                                              ]),
                                                        )),
                                                  ],
                                                )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Container(
                                              margin:
                                                  EdgeInsets.only(left: 10),
                                              child: Label(
                                                triangleHeight: 17,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(4),
                                                      gradient:
                                                          LinearGradient(
                                                        colors: [
                                                          Color.fromRGBO(
                                                              18, 42, 76, 1),
                                                          Color.fromRGBO(
                                                              5, 150, 197, 1),
                                                          Color.fromRGBO(
                                                              18, 42, 76, 1),
                                                        ],
                                                        begin: Alignment
                                                            .topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors
                                                                .black38,
                                                            offset:
                                                                Offset(5, 0))
                                                      ]),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 25,
                                                            top: 5,
                                                            bottom: 5),
                                                    child: Row(
                                                      children: [
                                                        Text(price.toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    'Lobster')),
                                                        Text(' LE',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )),
                                          Container(
                                            margin:
                                                EdgeInsets.only(right: 20),
                                            child: InkWell(
                                                splashColor:
                                                    Colors.transparent,
                                                onTap: () {
                                                  
                                                  if (favoriteList
                                                      .contains(widget.id)) {
                                                    _removeFromFavorites(
                                                        widget.id);
                                                  } else {
                                                    _saveToFavorites(
                                                        widget.id);
                                                  }
                                                },
                                                child: AnimatedSwitcher(
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  transitionBuilder:
                                                      (Widget child,
                                                          Animation<double>
                                                              animation) {
                                                    if (child.key ==
                                                        Key(widget.id)) {
                                                      return ScaleTransition(
                                                        child: child,
                                                        scale: animation,
                                                      );
                                                    } else if (child.key ==
                                                        Key(widget.id +
                                                            'un')) {
                                                      return ScaleTransition(
                                                        child: child,
                                                        scale: animation,
                                                      );
                                                    } else {
                                                      return child;
                                                    }
                                                  },
                                                  child: favoriteList
                                                          .contains(widget.id)
                                                      ? Container(
                                                          key: Key(widget.id +
                                                              'un'),
                                                          // key: UniqueKey(),
                                                          child: Icon(
                                                              custicons
                                                                  .MyFlutterApp
                                                                  .heart__1_,
                                                              size: 22,
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      : Container(
                                                          key: Key(widget.id),
                                                          // key: UniqueKey(),

                                                          child: Icon(
                                                            custicons
                                                                .MyFlutterApp
                                                                .likee,
                                                            size: 22,
                                                            color: Colors
                                                                .grey[300],
                                                          ),
                                                        ),
                                                )

                                                //  favoriteList.contains(widget.id)
                                                //     ? Icon(
                                                //         Icons.favorite,
                                                //         color: Colors.red,
                                                //       )
                                                //     : Icon(
                                                //         Icons.favorite_border,
                                                //         color:Colors.grey
                                                //       )
                                                ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: 15,
                                              top: 10,
                                            ),
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontFamily: "Lobster",
                                                  letterSpacing: 2),
                                            ),
                                          ),
                                          description!=null && description.isNotEmpty?Container(
                                            margin: EdgeInsets.only(
                                                left: 15, top: 5, bottom: 10),
                                            child: ListView.builder(physics: NeverScrollableScrollPhysics(),shrinkWrap: true,itemCount:description.length,itemBuilder: (context,index){return Text(
                                              description[index],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            );},)
                                            
                                            
                                            
                                          ):Container(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: Row(children: <Widget>[
                                              Expanded(
                                                  child: Container(
                                                child: new Divider(
                                                  color: Colors.grey,
                                                  height: 10,
                                                ),
                                                margin: EdgeInsets.only(
                                                    left: 10.0, right: 10.0),
                                              )),
                                              new Text('Details',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              Expanded(
                                                  child: Container(
                                                child: new Divider(
                                                  color: Colors.grey,
                                                  height: 10,
                                                ),
                                                margin: EdgeInsets.only(
                                                    left: 10.0, right: 10.0),
                                              )),
                                            ]),
                                          ),
                                          Column(
                                              children: detailsList
                                                  .map<Widget>((f) => Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Container(
                                                              width: (width /
                                                                      2) -
                                                                  30,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          20),
                                                              child: Text(
                                                                f.title,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          Text(" :",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16,
                                                                  color: Colors
                                                                      .white)),
                                                          Expanded(
                                                            child: Container(
                                                                width: (width /
                                                                        2) -
                                                                    30,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            20),
                                                                child: Text(
                                                                    f.content,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines:
                                                                        5,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color:
                                                                            Colors.white))),
                                                          )
                                                        ],
                                                      ))
                                                  .toList()),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: Row(children: <Widget>[
                                              Expanded(
                                                  child: Container(
                                                child: new Divider(
                                                  color: Colors.grey,
                                                  height: 10,
                                                ),
                                                margin: EdgeInsets.only(
                                                    left: 10.0, right: 10.0),
                                              )),
                                              new Text('Gift Shop',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              Expanded(
                                                  child: Container(
                                                child: new Divider(
                                                  color: Colors.grey,
                                                  height: 10,
                                                ),
                                                margin: EdgeInsets.only(
                                                    left: 10.0, right: 10.0),
                                              )),
                                            ]),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20),
                                                  child:
                                                      pageimg != null &&
                                                              pageimg != ""
                                                          ? Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          0.5),
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .white),
                                                              child: Card(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            0),
                                                                clipBehavior:
                                                                    Clip.antiAlias,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                child:
                                                                    InkWell(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => new PageActivity(pageId, 'product')));
                                                                  },
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl:
                                                                        pageimg,
                                                                    height:
                                                                        40,
                                                                    width: 40,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    progressIndicatorBuilder:
                                                                        (context,
                                                                            url,
                                                                            progress) {
                                                                      return Shimmer
                                                                          .fromColors(
                                                                        enabled:
                                                                            true,
                                                                        child: Container(
                                                                            height: 40,
                                                                            width: 40,
                                                                            color: Color(0xFF282828)),
                                                                        baseColor:
                                                                            Color(0xFF282828),
                                                                        highlightColor:
                                                                            Color(0xFF383838),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 0,
                                                              width: 0)),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(pagename,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 10),
                                                    child: pagerate != 0.0
                                                        ? SmoothStarRating(
                                                            allowHalfRating:
                                                                true,
                                                            starCount: 5,
                                                            rating: pagerate,
                                                            size: 10,
                                                            isReadOnly: true,
                                                            defaultIconData:
                                                                Icons.star,
                                                            borderColor: Color(
                                                                0xFF484848),
                                                            color: Colors
                                                                .yellow[700],
                                                          )
                                                        : Container(
                                                            height: 0,
                                                            width: 0),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          reviewsList.isEmpty ||
                                                  reviewsList == null
                                              ? Container(height: 0, width: 0)
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10),
                                                  child:
                                                      Row(children: <Widget>[
                                                    Expanded(
                                                        child: Container(
                                                      child: new Divider(
                                                        color: Colors.grey,
                                                        height: 10,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                    )),
                                                    new Text('Reviews',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            color: Colors
                                                                .white)),
                                                    Expanded(
                                                        child: Container(
                                                      child: new Divider(
                                                        color: Colors.grey,
                                                        height: 10,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                    )),
                                                  ]),
                                                ),
                                          reviewsList == null ||
                                                  reviewsList.isEmpty
                                              ? Container(height: 0, width: 0)
                                              : reviewsList.length == 1
                                                  ? Container(
                                                      width: width - 20,
                                                      margin: EdgeInsets.only(
                                                          bottom: 10,
                                                          left: 10),
                                                      child: Card(
                                                        margin:
                                                            EdgeInsets.all(0),
                                                        color:
                                                            Color(0xff232323),
                                                        child: Container(
                                                          width: width,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <
                                                                Widget>[
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: <
                                                                    Widget>[
                                                                  reviewsList[0].profilepic != null &&
                                                                          reviewsList[0]
                                                                              .profilepic
                                                                              .isNotEmpty
                                                                      ? Container(
                                                                          padding:
                                                                              EdgeInsets.all(0.5),
                                                                          decoration:
                                                                              BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                          child:
                                                                              Card(
                                                                            margin: EdgeInsets.all(0),
                                                                            clipBehavior: Clip.antiAlias,
                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                                                            child: CachedNetworkImage(
                                                                              imageUrl: reviewsList[0].profilepic,
                                                                              height: 44,
                                                                              width: 44,
                                                                              fit: BoxFit.cover,
                                                                              progressIndicatorBuilder: (context, url, progress) {
                                                                                return Shimmer.fromColors(
                                                                                  enabled: true,
                                                                                  child: Container(height: 44, width: 44, color: Color.fromRGBO(55, 57, 56, 1.0)),
                                                                                  baseColor: Color(0xFF282828),
                                                                                  highlightColor: Color(0xFF383838),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          height:
                                                                              0,
                                                                          width:
                                                                              0),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment.start,
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                            margin: EdgeInsets.only(left: 10),
                                                                            child: Text(reviewsList[0].name, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                                                                        Container(
                                                                            margin: EdgeInsets.only(left: 10),
                                                                            child: SmoothStarRating(
                                                                              allowHalfRating: true,
                                                                              color: Colors.yellow[700],
                                                                              defaultIconData: Icons.star,
                                                                              borderColor: Color(0xFF484848),
                                                                              isReadOnly: true,
                                                                              size: 15,
                                                                              rating: reviewsList[0].rate,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              reviewsList[0].review !=
                                                                          null &&
                                                                      reviewsList[0]
                                                                          .review
                                                                          .isNotEmpty
                                                                  ? Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              10),
                                                                      child: Text(
                                                                          reviewsList[0]
                                                                              .review,
                                                                          style:
                                                                              TextStyle(color: Colors.white, fontSize: 16)))
                                                                  : Container()
                                                            ],
                                                          ),
                                                        ),
                                                      ))
                                                  : Container(
                                                      height: height / 3,
                                                      width: width - 20,
                                                      margin: EdgeInsets.only(
                                                          bottom: 10,
                                                          left: 10,
                                                          top: 10),
                                                      child: ListView.builder(
                                                          itemCount:
                                                              reviewsList
                                                                  .length,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 0),
                                                          itemBuilder:
                                                              (context, i) {
                                                            return Card(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          4,
                                                                      top: 4),
                                                              color: Color(
                                                                  0xff232323),
                                                              child:
                                                                  Container(
                                                                width: width,
                                                                padding: EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 10,
                                                                    bottom:
                                                                        10),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize.max,
                                                                      children: <
                                                                          Widget>[
                                                                        reviewsList[i].profilepic != null && reviewsList[i].profilepic.isNotEmpty
                                                                            ? Container(
                                                                                padding: EdgeInsets.all(0.5),
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                                                child: Card(
                                                                                  margin: EdgeInsets.all(0),
                                                                                  clipBehavior: Clip.antiAlias,
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                                                                  child: CachedNetworkImage(
                                                                                    imageUrl: reviewsList[i].profilepic,
                                                                                    height: 44,
                                                                                    width: 44,
                                                                                    fit: BoxFit.cover,
                                                                                    progressIndicatorBuilder: (context, url, progress) {
                                                                                      return Shimmer.fromColors(
                                                                                        enabled: true,
                                                                                        child: Container(height: 44, width: 44, color: Color.fromRGBO(55, 57, 56, 1.0)),
                                                                                        baseColor: Color(0xFF282828),
                                                                                        highlightColor: Color(0xFF383838),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Container(height: 0, width: 0),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Container(margin: EdgeInsets.only(left: 10), child: Text(reviewsList[i].name, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                                                                              Container(
                                                                                  margin: EdgeInsets.only(left: 10),
                                                                                  child: SmoothStarRating(
                                                                                    allowHalfRating: true,
                                                                                    color: Colors.yellow[700],
                                                                                    defaultIconData: Icons.star,
                                                                                    borderColor: Color(0xFF484848),
                                                                                    isReadOnly: true,
                                                                                    size: 15,
                                                                                    rating: reviewsList[i].rate,
                                                                                  )),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    reviewsList[i].review != null && reviewsList[i].review.isNotEmpty
                                                                        ? Container(
                                                                            margin: EdgeInsets.only(top: 10, left: 10),
                                                                            child: Text(reviewsList[i].review, style: TextStyle(color: Colors.white, fontSize: 16)))
                                                                        : Container()
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })),
                                          similarList.isEmpty ||
                                                  similarList == null
                                              ? Container(height: 0, width: 0)
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10),
                                                  child:
                                                      Row(children: <Widget>[
                                                    Expanded(
                                                        child: Container(
                                                      child: new Divider(
                                                        color: Colors.grey,
                                                        height: 10,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                    )),
                                                    new Text('Similar Gifts',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            color: Colors
                                                                .white)),
                                                    Expanded(
                                                        child: Container(
                                                      child: new Divider(
                                                        color: Colors.grey,
                                                        height: 10,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                    )),
                                                  ]),
                                                ),
                                          similarList.isEmpty
                                              ? Container(height: 0, width: 0)
                                              : Container(
                                                  height: height / 4,
                                                  margin: EdgeInsets.only(
                                                      left: 5, top: 10),
                                                  child: ListView.builder(
                                                      itemCount:
                                                          similarList.length,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, i) {
                                                        return Stack(
                                                          children: <Widget>[
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            new GiftPage(similarList[i].giftid)));
                                                              },
                                                              child: Card(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          55,
                                                                          57,
                                                                          56,
                                                                          1.0),
                                                                  clipBehavior:
                                                                      Clip
                                                                          .antiAlias,
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl:
                                                                        similarList[i]
                                                                            .giftimg,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height:
                                                                        height /
                                                                            4,
                                                                    width:
                                                                        width -
                                                                            20,
                                                                    progressIndicatorBuilder:
                                                                        (context,
                                                                            url,
                                                                            progress) {
                                                                      return Shimmer
                                                                          .fromColors(
                                                                        enabled:
                                                                            true,
                                                                        child: Container(
                                                                            height: height / 4,
                                                                            width: width - 20,
                                                                            color: Color(0xFF282828)),
                                                                        baseColor:
                                                                            Color(0xFF282828),
                                                                        highlightColor:
                                                                            Color(0xFF383838),
                                                                      );
                                                                    },
                                                                  )),
                                                            ),
                                                            Positioned(
                                                                bottom: 15,
                                                                right: 0,
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Color.fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.6),
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(5),
                                                                          bottomLeft: Radius.circular(5))),
                                                                  padding: EdgeInsets.only(
                                                                      top: 3,
                                                                      bottom:
                                                                          3,
                                                                      right:
                                                                          20,
                                                                      left:
                                                                          20),
                                                                  child: Container(
                                                                      child: Row(
                                                                    children: [
                                                                      Text(
                                                                          similarList[i]
                                                                              .price
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              fontSize: 18,
                                                                              color: Colors.white,
                                                                              fontFamily: "Lobster")),
                                                                      Text(
                                                                          ' LE',
                                                                          style: TextStyle(
                                                                              fontSize: 18,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold))
                                                                    ],
                                                                  )),
                                                                )),
                                                          ],
                                                        );
                                                      }),
                                                ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 20, bottom: 20),
                                                  width: width * 0.4,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(10),
                                                      gradient:
                                                          LinearGradient(
                                                        colors: [
                                                          Color.fromRGBO(
                                                              18, 42, 76, 1),
                                                          Color.fromRGBO(
                                                              5, 150, 197, 1),
                                                          Color.fromRGBO(
                                                              18, 42, 76, 1),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      )),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(10),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if(_auth.currentUser !=null){
                                                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Color(0xFF232323),
              content: Container(
                height: 20,
                width: width,
                alignment: Alignment.center,
                child:
                    Text(_auth.currentUser.displayName, style: TextStyle(fontSize: 16)),
              )));
                                                           Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => new OrderPage(
                                                                    widget.id,
                                                                    mainImg,
                                                                    name,
                                                                    price,
                                                                    deliveryTime,
                                                                    delivery,
                                                                    boxetPackaging,
                                                                    shopPackaging,
                                                                    pageimg,
                                                                    pageId,
                                                                    pagename,
                                                                    giftRate,
                                                                    reviewsList
                                                                        .length,shopPackagingFree,shopPackagingImg,selection)));
                                                  
                                                        }else {
                                                           Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => new LoginActivity('order',widget.id)));
                                                  
                                                        }
                                                            },
                                                      child: Center(
                                                          child: Text(
                                                              'Order Now',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  letterSpacing:
                                                                      1))),
                                                    ),
                                                  ),
                                                )
                                              ]),
                                        ],
                                      )
                                    ],
                                  ),
                      ),
                    ),
                  ],
                )),
    );
  }

  Future _loadGiftData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      await FirebaseFirestore.instance
          .collection('Gifts')
          .doc(widget.id)
          .get()
          .then((results) async {
        if (results.exists) {
          num giftRateNum = 0;
          if(results.data()['wide']!=null && results.data()['wide']==true){

            setState((){
              wide=true;
            });
          }
          name = results.data()['name'];
          mainImg = results.data()['img'];
          description = results.data()['description'];
          shopPackaging=results.data()['shoppackaging'];
          boxetPackaging=results.data()['boxetpackaging'];
          details = results.data()['details'];
          price = results.data()['price'];
          pageId = results.data()['pageid'];
          refId = results.data()['id'];
          selection=results.data()['selection'];
          giftRateNum = results.data()['rate'];
          if (giftRateNum != null && giftRateNum != 0) {
            giftRate =
                giftRateNum is double ? giftRateNum : giftRateNum.toDouble();
          }

          if(selection==null){
            selection=[];
          }
          if(shopPackaging==null){
            shopPackaging=0;
          }
          if(boxetPackaging==null){
            boxetPackaging=0;
          }
          pageimg = results.data()['page'];
          pagename = results.data()['pagename'];
          deliveryTime = results.data()['deliverytime'];
          delivery = results.data()['delivery'];
          

          videoLink = results.data()['video'];

          details.forEach((k, v) {
            detailsList.add(new Descriptions(k, v));
          });

          setState(() {
            if (retrying) retrying = false;
            if (_progressBarVisible) _progressBarVisible = false;
          });

          await results.reference
              .collection('reviews')
              .orderBy('date', descending: true)
              .get()
              .then((onValue) {
            if (onValue.docs.isNotEmpty) {
              onValue.docs.forEach((v) {
                num abc = v.data()['totalrate'];
                if (abc != null) {
                  reviewsList.add(new ReviewsClass(
                      v.data()['name'],
                      v.data()['profilepic'],
                      v.data()['review'],
                      abc is double ? abc : abc.toDouble()));
                }
              });
              setState(() {});
            }
          });
          if (videoLink != null && videoLink.isNotEmpty) {
            videoContr = VideoPlayerController.network(
              videoLink,
            );
            videoContr.setLooping(true);
            videoContr.setVolume(0.0);
            await videoContr.initialize().then((_) {
              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

              videoContr.play();
              if (mounted) {
                setState(() {});
              }
            });
          } else {
            List images = results.data()['images'];
            images.forEach((value) {
              imgProv.add(
                CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: value,
                  progressIndicatorBuilder: (context, url, progress) {
                    return Shimmer.fromColors(
                      enabled: true,
                      child: Container(color: Color(0xFF282828)),
                      baseColor: Color(0xFF282828),
                      highlightColor: Color(0xFF383838),
                    );
                  },
                ),
              );
            });
            if (mounted) {
              setState(() {});
            }
          }

          if (pageId != null && pageId != "") {
            await FirebaseFirestore.instance
                .collection('pages')
                .doc(pageId)
                .get()
                .then((results) async {
              if (results.exists) {
                num aa = results.data()['pagerate'];
                if(aa!=null){
                  if (aa is int) {
                  pagerate = aa.toDouble();
                } else {
                  pagerate = aa;
                }
                }
                

                pageInfo = results.data()['pageinfo'];
                await FirebaseFirestore.instance
                    .collection('Gifts')
                    .where('id', isEqualTo: refId)
                    .get()
                    .then((onValue) {
                  if (onValue.docs.isNotEmpty) {
                    onValue.docs.forEach((v) {
                      if (v.id != widget.id)
                        similarList.add(new SimilarGifts(
                            v.id, v.data()['img'], v.data()['price']));
                    });
                  }
                });

                setState(() {
                  if (_progressBarVisible) _progressBarVisible = false;
                });
              } else {}
            }, onError: (error) {
              print(error);
            });
          }
        } else {
          setState(() {
            errorLoading = true;
            if (_progressBarVisible) _progressBarVisible = false;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          if (retrying) retrying = false;
          internetError = true;
          if (_progressBarVisible) _progressBarVisible = false;
        });
      }
    }
  }
}
