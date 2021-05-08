import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:boxet/AppLocalizations.dart';
import 'package:boxet/GiftPage.dart';
import 'package:boxet/SearchActivity.dart';
import 'package:boxet/classes/PriceDecoration.dart';
import 'package:shimmer/shimmer.dart';
import 'PageActivity.dart';
import 'classes/Gifts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:boxet/Collections.dart';
import 'classes/HeaderClass.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Gifts> data = [];
  ScrollController mainListController;
  List<HeaderClass> headerId = [];
  List<CachedNetworkImage> headerImages = [];
  double width, height;
  bool showProgressBar = true;
  bool showHeader = false;
  Timestamp lastItem;
  String category = "default";
  bool internetError = false;
  bool retrying = false;
  bool moveHeader = false;
  bool showMore = true;
  bool showing = false;
  bool empty = false;
  bool showCatProgressBar = false;
  bool catOpen = false;

  // openingCat(bool opening) {
  //   catOpen = opening;
  // }

  refresh(String categ) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      category = categ;
      data.clear();
      lastItem = null;
      showCatProgressBar = true;
      setState(() {});
      _loadData(categ);
    } else {
      setState(() {
        retrying = false;
        internetError = true;
        showProgressBar = false;
      });
    }
  }

  @override
  void dispose() {
    mainListController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    mainListController = new ScrollController();
    mainListController.addListener(() {
      if (mainListController.position.extentAfter == 0) {
        _loadMoreData(category);
      }
    });

    _loadheader();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return internetError
        ? Container(
            width: width,
            alignment: Alignment.center,
            height: height - 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  margin: EdgeInsets.only(top: 20),
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
                        Future.delayed(Duration(milliseconds: 500), () async {
                          _loadheader();
                        });
                      },
                      child: Center(
                          child: retrying
                              ? Container(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                    strokeWidth: 1,
                                  ),
                                )
                              : Text(
                                  'RETRY',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                )),
                    ),
                  ),
                ),
              ],
            ),
          )
        : showProgressBar
            ? Center(
                child: Container(
                    width: 50,
                    height: 50,
                    child: FlareActor(
                      'assets/loading.flr',
                      animation: 'Loading',
                    )))
            : CustomScrollView(
                controller: mainListController,
                slivers: <Widget>[
                  SliverAppBar(
                    leading: Container(height: 0, width: 0),
                    expandedHeight: width * 0.6,
                    backgroundColor: Colors.black,
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(60.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => new SearchActivity()));
                          // Navigator.push(
                          //     context,
                          //     PageRouteBuilder(
                          //         fullscreenDialog: true,
                          //         transitionDuration: Duration(milliseconds: 500),
                          //         pageBuilder: (BuildContext context,
                          //             Animation<double> animation,
                          //             Animation<double> secondaryAnim) {
                          //           return SearchActivity();
                          //         },
                          //         transitionsBuilder: (BuildContext context,
                          //             Animation<double> animation,
                          //             Animation<double> secondaryAnim,
                          //             Widget child) {
                          //           return FadeTransition(
                          //               opacity: animation, child: child);
                          //         }));
                        },
                        child: Card(
                          elevation: 8,
                          clipBehavior: Clip.antiAlias,
                          color: Color(0xFF282828),
                          margin: EdgeInsets.only(
                              top: 10, bottom: 10, left: 5, right: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                  color: Color.fromRGBO(3, 111, 146, 1),
                                  style: BorderStyle.solid,
                                  width: 2)),
                          child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(
                                        left: 10, top: 5, bottom: 5),
                                    child: new Icon(
                                      Icons.search,
                                      size: 30,
                                      color: Colors.white70,
                                    )),
                                Expanded(
                                  child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .translate('searchText'),
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 20,
                                        ),
                                      )),
                                )
                              ]),
                        ),
                      ),
                    ),
                    flexibleSpace: new FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,

                      background: Container(
                          height: width * 0.6,
                          padding: EdgeInsets.only(bottom: 30),
                          color: Colors.black,
                          child: Carousel(
                            onImageTap: (index) {
                              // if (!catOpen)
                              if (headerId[index].collection == true) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => new Collections(
                                            headerId[index].id)));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            new GiftPage(headerId[index].id)));
                              }
                            },
                            images: headerImages,
                            autoplay: moveHeader,
                            animationCurve: Curves.fastOutSlowIn,
                            animationDuration: Duration(seconds: 2),
                            autoplayDuration: Duration(seconds: 4),
                            dotSize: 0,
                            dotBgColor: Colors.transparent,
                          )
                          // : Shimmer.fromColors(
                          //     enabled: true,
                          //     child: Container(
                          //         height: height / 3,
                          //         width: width,
                          //         color: Color.fromRGBO(55, 57, 56, 1.0)),
                          //     baseColor: Color.fromRGBO(65, 67, 66, 1.0),
                          //     highlightColor: Color.fromRGBO(75, 77, 76, 1.0),
                          //   ),
                          ),
                      // titlePadding: EdgeInsets.only(left:5.0,right:15.0,bottom: 5.0),
                    ),
                  ),
                  showCatProgressBar
                      ? SliverToBoxAdapter(
                          child: Container(
                            width: width,
                            height: height / 2,
                            child: Center(
                                child: Container(
                                    width: 50,
                                    height: 50,
                                    child: FlareActor(
                                      'assets/loading.flr',
                                      animation: 'Loading',
                                    ))),
                          ),
                        )
                      : empty
                          ? SliverToBoxAdapter(
                              child: Container(
                                width: width,
                                height: height / 2,
                                child: Center(
                                  child: Text(
                                    'No Gifts Available',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: new SliverChildBuilderDelegate(
                                (context, index) => index == data.length - 1
                                    ? Column(
                                        children: <Widget>[
                                          displayCardItem(data[index]),
                                          Container(
                                              height: showMore ? 15 : 20,
                                              width: showMore ? 15 : width,
                                              child: showMore && showing
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                          Colors.white70,
                                                        ),
                                                        strokeWidth: 1,
                                                      ),
                                                    )
                                                  : !showMore
                                                      ? Row(children: <Widget>[
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                            child: Divider(
                                                              color:
                                                                  Colors.grey,
                                                              height: 10,
                                                            ),
                                                          ),
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 10,
                                                                      right:
                                                                          10),
                                                              child: Text(
                                                                  'No More Gifts Available',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white70))),
                                                          Expanded(
                                                              child: Divider(
                                                            color: Colors.grey,
                                                            height: 10,
                                                          )),
                                                          SizedBox(width: 10),
                                                        ])
                                                      : Container(),
                                              margin: EdgeInsets.only(
                                                  bottom: 65, top: 5))
                                        ],
                                      )
                                    : displayCardItem(data[index]),
                                childCount: data.length,
                              ),
                            )
                ],
              );
  }

  Widget displayCardItem(Gifts content) {
    return Card(
      color: Color(0xFF151515),
      margin: EdgeInsets.only(bottom: 5, right: 2, left: 2),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new GiftPage(content.id)));
        },
        child: Container(
          width: width,
          height: 200,
          foregroundDecoration: content.discount != null &&
                  content.discount.isNotEmpty &&
                  content.discount != "0%"
              ? PriceDecoration(
                  badgeColor: Color.fromRGBO(5, 150, 197, 1),
                  badgeSize: 60,
                  textSpan: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: content.discount,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Lobster",
                            fontSize: 18),
                      )
                    ],
                  ),
                )
              : null,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: content.image,
                  fit: BoxFit.cover,
                  width: width,
                  progressIndicatorBuilder: (context, url, progress) {
                    return Shimmer.fromColors(
                      enabled: true,
                      child: Container(
                          height: 200, width: width, color: Color(0xFF282828)),
                      baseColor: Color(0xFF282828),
                      highlightColor: Color(0xFF383838),
                    );
                  },
                ),
              ),
              Positioned(
                  left: 10,
                  top: 10,
                  child: Card(
                    elevation: 3,
                    color: Colors.transparent,
                    margin: EdgeInsets.all(0),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width / 15)),
                    child: InkWell(
                      onTap: () {
                        // if (!catOpen)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new PageActivity(
                                    content.pageId, 'product')));
                      },
                      child: Container(
                        height: height / 15,
                        width: height / 15,
                        constraints:
                            BoxConstraints(minHeight: 50, minWidth: 50),
                        child: CachedNetworkImage(
                          imageUrl: content.page,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) {
                            return Shimmer.fromColors(
                              enabled: true,
                              child: Container(
                                  constraints: BoxConstraints(
                                      minHeight: 50, minWidth: 50),
                                  height: height / 15,
                                  width: height / 15,
                                  color: Color(0xFF282828)),
                              baseColor: Color(0xFF282828),
                              highlightColor: Color(0xFF383838),
                            );
                          },
                        ),
                      ),
                    ),
                  )),

              Positioned(
                  bottom: 15,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            bottomLeft: Radius.circular(5))),
                    padding:
                        EdgeInsets.only(top: 3, bottom: 3, right: 20, left: 20),
                    child: Container(
                        child: Row(
                      children: [
                        Text(content.price.toString(),
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: "Lobster")),
                        Text(' LE',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                      ],
                    )),
                  )),
              // Positioned(
              //     right: 5,
              //     top: 0,
              //     child: RotatedBox(
              //         quarterTurns: 1,
              //         child: Label(
              //           triangleHeight: 17,
              //           child: Container(
              //             margin: EdgeInsets.all(4),
              //             decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(4),
              //                 gradient: LinearGradient(
              //                   colors: [
              //                     Color.fromRGBO(18, 42, 76, 1),
              //                     Color.fromRGBO(5, 150, 197, 1),
              //                     Color.fromRGBO(18, 42, 76, 1),
              //                   ],
              //                   begin: Alignment.topCenter,
              //                   end: Alignment.bottomCenter,
              //                 ),
              //                 boxShadow: [
              //                   BoxShadow(
              //                       color: Colors.black38, offset: Offset(5, 0))
              //                 ]),
              //             child: Padding(
              //               padding: const EdgeInsets.only(
              //                   left: 5, right: 20, top: 3, bottom: 3),
              //               child: Text(content.price.toString() + ' LE',
              //                   style: TextStyle(color: Colors.white)),
              //             ),
              //           ),
              //         )))
            ],
          ),
        ),
      ),
    );
  }

  Future _loadheader() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      await FirebaseFirestore.instance
          .collection('LatestGifts')
          .get()
          .then((results) {
        if (results.docs.isNotEmpty) {
          results.docs.forEach((v) {
            if (v.data()['collection'] != null &&
                v.data()['collection'] == true) {
              headerId.add(new HeaderClass(v.data()['listid'], true));
            } else {
              headerId.add(new HeaderClass(v.data()['giftid'], false));
            }

            headerImages.add(
              CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: v.data()['img'],
                progressIndicatorBuilder: (context, url, progress) {
                  return Shimmer.fromColors(
                    enabled: true,
                    child: Container(
                        height: height / 3,
                        width: width,
                        color: Color(0xFF282828)),
                    baseColor: Color(0xFF282828),
                    highlightColor: Color(0xFF383838),
                  );
                },
              ),
            );
          });

          showHeader = true;
          moveHeader = true;
        } else {
          showHeader = false;
        }
        _loadData("default");
      });
    } else {
      setState(() {
        retrying = false;
        showProgressBar = false;
        internetError = true;
      });
    }
  }

  Future _loadData(String category) async {
    if (category != null && category != "default") {
      await FirebaseFirestore.instance
          .collection('Gifts')
          .where('show', isEqualTo: true)
          .where('category', arrayContains: category)
          .orderBy('date', descending: true)
          .limit(5)
          .get()
          .then((results) async {
        if (results.docs.isNotEmpty) {
          results.docs.forEach((v) {
            data.add(new Gifts(
                v.data()['img'],
                v.data()['name'],
                v.data()['price'],
                v.data()['page'],
                v.id,
                v.data()['pageid'],
                v.data()['discount']));

            lastItem = v.data()['date'];
          });

          if (mounted) {
            if (internetError) internetError = false;
            if (retrying) retrying = false;
            if (empty) empty = false;
            if (results.docs.length < 5) showMore = false;
            if (showing) showing = false;
            if (showCatProgressBar) showCatProgressBar = false;
            if (empty) empty = false;

            setState(() {
              showProgressBar = false;
            });
          }
        } else {
          if (mounted) {
            if (retrying) retrying = false;
            if (internetError) internetError = false;
            if (showCatProgressBar) showCatProgressBar = false;

            setState(() {
              empty = true;
              showProgressBar = false;
            });
          }
        }
      });
    } else {
      await FirebaseFirestore.instance
          .collection('Gifts')
          .where('show', isEqualTo: true)
          .orderBy('date', descending: true)
          .limit(3)
          .get()
          .then((results) {
        if (results.docs.isNotEmpty) {
          results.docs.forEach((v) {
            data.add(new Gifts(
                v.data()['img'],
                v.data()['name'],
                v.data()['price'],
                v.data()['page'],
                v.id,
                v.data()['pageid'],
                v.data()['discount']));
            lastItem = v.data()['date'];
          });
          if (mounted) {
            if (retrying) retrying = false;
            if (internetError) internetError = false;
            if (results.docs.length < 3) showMore = false;
            if (showing) showing = false;
            if (showCatProgressBar) showCatProgressBar = false;
            if (empty) empty = false;
            print('aaaaa');
            setState(() {
              showProgressBar = false;
            });
          }
        } else {
          if (mounted) {
            if (retrying) retrying = false;
            if (internetError) internetError = false;
            if (showCatProgressBar) showCatProgressBar = false;
            setState(() {
              empty = true;
              showProgressBar = false;
            });
          }
        }
      });
    }
  }

  Future _loadMoreData(String category) async {
    setState(() {
      showing = true;
    });
    if (category != null && category != "default") {
      await FirebaseFirestore.instance
          .collection('Gifts')
          .where('show', isEqualTo: true)
          .where(
            'category',
            arrayContains: category,
          )
          .where('date', isLessThan: lastItem)
          .orderBy('date', descending: true)
          .limit(5)
          .get()
          .then((results) {
        if (results.docs.isNotEmpty) {
          results.docs.forEach((v) {
            data.add(new Gifts(
                v.data()['img'],
                v.data()['name'],
                v.data()['price'],
                v.data()['page'],
                v.id,
                v.data()['pageid'],
                v.data()['discount']));
            lastItem = v.data()['date'];
          });
          if (mounted) {
            setState(() {
              showMore = true;
              showing = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              showMore = false;
              showing = false;
            });
          }
        }
      });
    } else {
      await FirebaseFirestore.instance
          .collection('Gifts')
          .where('show', isEqualTo: true)
          .where('date', isLessThan: lastItem)
          .orderBy('date', descending: true)
          .limit(5)
          .get()
          .then((results) {
        if (results.docs.isNotEmpty) {
          results.docs.forEach((v) {
            Gifts aaa = new Gifts(
                v.data()['img'],
                v.data()['name'],
                v.data()['price'],
                v.data()['page'],
                v.id,
                v.data()['pageid'],
                v.data()['discount']);
            if (!data.contains(aaa)) {
              data.add(aaa);
              lastItem = v.data()['date'];
            }
            // data.add(new Gifts(
            //     v.data()['img'],
            //     v.data()['name'],
            //     v.data()['price'],
            //     v.data()['page'],
            //     v.id,
            //     v.data()['pageid'],
            //     v.data()['discount']));
          });

          if (mounted) {
            setState(() {
              showMore = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              showMore = false;
            });
          }
        }
      });
    }
  }
}
