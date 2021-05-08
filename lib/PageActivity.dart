
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:boxet/GiftPage.dart';
import 'package:boxet/MapsPage.dart';
import 'package:boxet/classes/PagePrev.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class PageActivity extends StatefulWidget {
  final String pageId;
  final String prevPage;

  PageActivity(this.pageId, this.prevPage);

  @override
  _PageActivityState createState() => _PageActivityState();
}

class _PageActivityState extends State<PageActivity> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String pageName = "";
  String pageImg = "";
  String coverImg = "";
  String pageInfo = "";
  num pageRate = 0;
  bool showProgress = true;
  List<PagePrev> prevGifts = [];
  double height, width;
  // PageController pageController = PageController(viewportFraction: 0.8);
  int currentPage = 0;
  String location = "";
  bool noPrevGifts = false;
  bool internetError = false;
  bool retrying = false;
  bool giftshopNotAvailable = false;
  GeoPoint mapLoc;

  @override
  void initState() {
    _getPageData();
    // pageController.addListener(() {
    //   int next = pageController.page.round();
    //   if (currentPage != next) {
    //     setState(() {
    //       currentPage = next;
    //     });
    //   }
    // });
    super.initState();
  }

  _getPageData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      
      await db.collection('pages').doc(widget.pageId).get().then((value) {
        if (value.exists) {
          pageName = value.data()['pagename'];
          pageImg = value.data()['pageimg'];
          coverImg = value.data()['coverimg'];
          pageInfo = value.data()['pageinfo'];
          pageRate = value.data()['pagerate'];
          location = value.data()['location'];
          mapLoc=value.data()['maploc'];
          _getPrevGifts();
        } else {
          setState(() {
            giftshopNotAvailable = true;
            internetError = false;
            showProgress = false;
            retrying = false;
          });
        }
      }, onError: (error) {
        print(error);
      });
    } else {
      setState(() {
        retrying = false;
        internetError = true;
        showProgress = false;
      });
    }
  }

  _getPrevGifts() async {
    await db
        .collection('pages')
        .doc(widget.pageId)
        .collection('prevgifts')
        .get()
        .then((value) {
      if (value.docs != null && value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          prevGifts.add(new PagePrev(element.data()['giftid'],
              element.data()['giftimg'], element.data()['rate']));
        });

        setState(() {
          showProgress = false;
          retrying = false;
          internetError = false;
        });
      } else {
        setState(() {
          showProgress = false;
          retrying = false;
          internetError = false;
          noPrevGifts = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: showProgress
            ? Center(child:  Container(
                    width: 50,
                    height: 50,
                    child: FlareActor(
                      'assets/loading.flr',
                      animation: 'Loading',
                    )))
            : internetError
                ? Container(
                    height: height,
                    width: width,
                    child: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                       
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
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromRGBO(18,42,76,1),
                                      Color.fromRGBO(5,150,197,1),
                                      Color.fromRGBO(18,42,76,1)
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
                                  _getPageData();
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
                        ),
                      ],
                    ),
                    
                    
                    
                  )
                : giftshopNotAvailable
                    ? Center(
                        child: Text(
                        'Giftshop Not Available Right Now',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ))
                    : Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                  clipBehavior: Clip.antiAlias,
                                  height: height * 0.35,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(0.3 * width),
                                  )),
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                          height: height * 0.35,
                                          width: width,
                                          child: CachedNetworkImage(
                                            imageUrl: coverImg,
                                            fit: BoxFit.cover,
                                            progressIndicatorBuilder:
                                                (context, url, progress) {
                                              return Shimmer.fromColors(
                                                enabled: true,
                                                child: Container(
                                                    height: height * 0.35,
                                                    width: width,
                                                    color: Color(0xFF282828)),
                                                baseColor: Color(0xFF282828),
                                                highlightColor:
                                                    Color(0xFF383838),
                                              );
                                            },
                                          )),
                                    ],
                                  )),
                              Expanded(
                                  child: SingleChildScrollView(
                                      child: Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 15, top: 10, bottom: 5),
                                    child: Text(
                                      pageName,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontFamily: 'lobster',
                                          letterSpacing: 1),
                                    ),
                                  ),
                                  Container(
                                    width: width,
                                    margin: EdgeInsets.only(top: 15),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                  child: Icon(
                                                    Icons.info_outline,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      bottom: 3, left: 5)),
                                              Container(width:width-30,
                                                margin: EdgeInsets.only(
                                                    left: 5, bottom: 3),
                                                child: Text(
                                                  pageInfo,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                          location!=null && location!=""?Row(
                                            children: <Widget>[
                                              Container(
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      bottom: 3, left: 5)),
                                              Container(
                                                width:width-30,
                                                margin: EdgeInsets.only(
                                                  left: 5,
                                                ),
                                                child: Text(
                                                  location,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ):Container(),
                                        ]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    child: Row(children: <Widget>[
                                      Expanded(
                                          child: Container(
                                        child: new Divider(
                                          color: Colors.grey,
                                          height: 10,
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 10.0, right: 5.0),
                                      )),
                                      new Text('Products',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      Expanded(
                                          child: Container(
                                        child: new Divider(
                                          color: Colors.grey,
                                          height: 10,
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 5.0, right: 10.0),
                                      )),
                                    ]),
                                  ),
                                  noPrevGifts
                                      ? Container(
                                          alignment: Alignment.center,
                                          height: height / 3,
                                          width: width,
                                          child: Text(
                                            'No Previous Gifts',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 18,),
                                          ))
                                      : Container(
                                        
                                          height: height / 4,
                                          margin: EdgeInsets.only(
                                            left: 5,
                                            top: (height*0.04),
                                          ),
                                          child: ListView.builder(
                                              itemCount: prevGifts.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, i) {
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                new GiftPage(
                                                                    prevGifts[i]
                                                                        .giftId)));
                                                  },
                                                  child: Card(
                                                      color: Color(0xFF151515),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child: CachedNetworkImage(
                                                        imageUrl: prevGifts[i]
                                                            .giftImg,
                                                        fit: BoxFit.cover,
                                                        height: height / 4,
                                                        width: width - 20,
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                progress) {
                                                          return Shimmer
                                                              .fromColors(
                                                            enabled: true,
                                                            child: Container(
                                                                height:
                                                                    height / 4,
                                                                width:
                                                                    width - 20,
                                                                color: Color(
                                                                    0xFF282828)),
                                                            baseColor: Color(
                                                                0xFF282828),
                                                            highlightColor:
                                                                Color(
                                                                    0xFF383838),
                                                          );
                                                        },
                                                      )),
                                                );
                                              }),
                                        ),
                                ],
                              ))
                                  //     PageView.builder(
                                  //   scrollDirection: Axis.horizontal,
                                  //   controller: pageController,
                                  //   itemCount: prevGifts.length,
                                  //   itemBuilder: (context, index) {
                                  //     bool active = index == currentPage;
                                  //     return _buildGiftPage(prevGifts[index], active);
                                  //   },
                                  // )
                                  )
                            ],
                          ),
                          Positioned(
                              top: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10))),
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, right: 20),
                                child: Row(children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Icon(Icons.arrow_back_ios,
                                            color: Colors.white)),
                                  ),
                                  Container(
                                      child: Text('Profile',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontFamily: "Lobster")))
                                ]),
                              )),
                          Positioned(
                            top: height * 0.27,
                            left: 0.05 * width,
                            child: Row(children: <Widget>[
                              Card(
                                  color: Color.fromRGBO(55, 57, 56, 1.0),
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  clipBehavior: Clip.antiAlias,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: pageImg,
                                    height: 0.22 * width,
                                    width: 0.22 * width,
                                    progressIndicatorBuilder:
                                        (context, url, progress) {
                                      return Shimmer.fromColors(
                                        enabled: true,
                                        child: Container(
                                            height: 0.22 * width,
                                            width: 0.22 * width,
                                            color: Color(0xFF282828)),
                                        baseColor: Color(0xFF282828),
                                        highlightColor: Color(0xFF383838),
                                      );
                                    },
                                  )),
                              pageRate!=null&& pageRate != 0 
                                  ? Container(
                                      padding: EdgeInsets.only(
                                          left: 4, right: 4, top: 4, bottom: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3))),
                                      child: SmoothStarRating(
                                        allowHalfRating: true,
                                        starCount: 5,
                                        rating: pageRate is double
                                            ? pageRate
                                            : pageRate.toDouble(),
                                        size: 0.05 * width,
                                        spacing: 3,
                                        isReadOnly: true,
                                         defaultIconData:
                                                                Icons.star,
                                                            borderColor: Color(
                                                                0xFF484848),
                                        color: Colors.yellow[700],
                                      ),
                                    )
                                  : Container(height: 0, width: 0),
                            ]),
                          ),
                          widget.prevPage == 'product'&& mapLoc!=null
                              ? Positioned(
                                  right: 0.1 * width,
                                  top: height * 0.30,
                                  child: Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                           Color.fromRGBO(18, 42, 76, 1),
                                      Color.fromRGBO(5, 150, 197, 1),
                                      Color.fromRGBO(18, 42, 76, 1),
                                          ],
                                        )),
                                    child: InkWell(
                                      onTap: () {
                                        print(widget.pageId);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MapsPage(
                                                      pageId: widget.pageId,
                                                      pageName:pageName,
                                                      pageAddress:location,
                                                      pageImg:pageImg,
                                                      mapLoc:mapLoc
                                                    )));
                                      },

                                      child: Icon(Icons.location_on,
                                          color: Colors.white),
                                      // Icon(Icons.chat_bubble),
                                    ),
                                  ),
                                )
                              : Container(height: 0, width: 0)
                        ],
                      ));
  }
}
