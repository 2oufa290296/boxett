import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:boxet/GiftPage.dart';
import 'package:boxet/PageActivity.dart';
import 'package:boxet/TestDropdown.dart';
import 'package:boxet/classes/SearchGifts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'classes/PriceDecoration.dart';

class SearchActivity extends StatefulWidget {
  @override
  _SearchActivityState createState() => _SearchActivityState();
}

class _SearchActivityState extends State<SearchActivity>
    with TickerProviderStateMixin {
  double width, height;
  bool menuOpened = false;
  IconData menuIcon = MdiIcons.gift;
  GlobalKey<TestDropdownState> menuKey = GlobalKey();
  bool showLoading = true;
  bool internetError = false;
  bool noPrevGifts = false;
  List<SearchGifts> searchList = [];
  List<SearchGifts> recentList = [];
  ScrollController mainListController;
  String searchText = "";
  Timestamp lastDate;
  bool retrying = false;
  bool showMore = true;
  bool noMatches = false;
  Timer searchOnStoppedTyping;
  AnimationController blinkController;
  Animation<double> blinkAnimation;
  Animation<Offset> dropAnimation;
  bool filterOpened = false;
  String filter = "";
  String uid = "";
  SharedPreferences sharedPref;
  int count = 0;
  int limit = 3;
  List<String> recentIdListRev = [];
  AnimationController dropController;
  List<SearchGifts> sortedList = [];
  String searchValue = '';
  FlareActor refreshFlare;
  bool clicked = false;
  Timer resetTimer;

  _onChangeHandler(value) {
    if (searchValue != value) {
      setState(() {
        showLoading = true;
        searchValue = value;
      });

      const duration = Duration(
          milliseconds:
              800); // set the duration that you want call search() after that.
      if (searchOnStoppedTyping != null) {
        setState(() {
          searchOnStoppedTyping.cancel();
        }); // clear timer
      }
      setState(() {
        searchOnStoppedTyping = new Timer(duration, () => search(value));
      });
    }
  }

  search(value) {
    if (value.trim().isEmpty) {
      print('empty');
      searchText = "";

      noMatches = false;

      if (recentList.isEmpty) {
        noPrevGifts = true;
      } else {
        noPrevGifts = false;
      }
      setState(() {
        showLoading = false;
      });
    } else {
      searchText = value;
      print(value);
      print('------');
      print(menuIcon == MdiIcons.gift);
      noPrevGifts = false;
      internetError = false;
      noMatches = false;
      searchList.clear();

      _loadData(value.trim());
    }
  }

  _getUid() async {
    sharedPref = await SharedPreferences.getInstance();
    uid = sharedPref.getString('uid');
    List<String> aaa = sharedPref.getStringList('recentlyviewed');

    if (aaa != null) {
      recentIdListRev = aaa.reversed.toList();
    } else {
      recentIdListRev = [];
    }

    // recentIdList10 = recentIdList.take(3).toList();
  }

  @override
  void initState() {
    super.initState();
    blinkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    blinkAnimation = Tween(begin: 1.0, end: 0.0).animate(blinkController);
    blinkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        blinkController.reverse();
      }
    });
    refreshFlare = FlareActor(
      'assets/loading.flr',
      animation: 'Loading',
    );
    dropController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    dropAnimation = Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0))
        .animate(dropController);
    dropController.addListener(() {});

    mainListController = new ScrollController();
    mainListController.addListener(() {
      if (mainListController.position.extentAfter == 0) {
        if (recentIdListRev.length >= count) {
          limit += 3;
          _loadMoreData(searchText);
        } else {
          if (showMore) {
            setState(() {
              showMore = false;
            });
          }
        }
      }
    });

    dropController.forward();
    _getUid();
    _loadData(searchText);
  }

  @override
  void dispose() {
    blinkController.dispose();
    mainListController.dispose();
    dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: <Widget>[
        showLoading
            ? Center(
                child: Container(width: 50, height: 50, child: refreshFlare))
            : internetError
                ? Positioned(
                    height: height,
                    width: width,
                    top: 0,
                    left: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                    Future.delayed(Duration(milliseconds: 1000),
                                        () async {
                                      _loadData(searchText);
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
                : noPrevGifts || noMatches
                    ? Center(
                        child: Text(
                          noMatches
                              ? 'No matched gifts'
                              : 'You havent viewed any gifts',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      )
                    : Positioned(
                        top: 100,
                        left: 0,
                        child: Container(
                          height: height - 90,
                          width: width,
                          child: Container(
                              margin: EdgeInsets.only(left: 3, right: 3),
                              child: AnimationLimiter(
                                child: ListView.builder(
                                    controller: mainListController,
                                    padding: EdgeInsets.all(0),
                                    itemCount: searchText.isNotEmpty
                                        ? searchList.length
                                        : recentList.length,
                                    itemBuilder: (context, index) {
                                      if (searchText.isNotEmpty) {
                                        if (index == 0) {
                                          return Column(children: <Widget>[
                                            Container(
                                                margin: EdgeInsets.only(
                                                    top: 40, bottom: 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Container(
                                                      child: Divider(
                                                        color: Colors.grey,
                                                        height: 10,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                    )),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 30,
                                                      child: Text('Results',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white70)),
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      child: Divider(
                                                        color: Colors.grey,
                                                        height: 10,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 10.0,
                                                          right:
                                                              searchText.isEmpty
                                                                  ? 10.0
                                                                  : 0),
                                                    )),
                                                    InkWell(
                                                      onTap: () {
                                                        if (filterOpened) {
                                                          setState(() {
                                                            filterOpened =
                                                                false;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            filterOpened = true;
                                                          });
                                                        }
                                                      },
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Icon(
                                                              Icons.filter_list,
                                                              color:
                                                                  Colors.white,
                                                              size: 20)),
                                                    )
                                                  ],
                                                )),
                                            AnimationConfiguration
                                                .staggeredList(
                                                    position: index,
                                                    duration: const Duration(
                                                        milliseconds: 375),
                                                    child: SlideAnimation(
                                                      verticalOffset: 100.0,
                                                      child: FadeInAnimation(
                                                        child: displayCardItem(
                                                            searchList[index]),
                                                      ),
                                                    ))
                                          ]);
                                        } else {
                                          return AnimationConfiguration
                                              .staggeredList(
                                                  position: index,
                                                  duration: const Duration(
                                                      milliseconds: 375),
                                                  child: SlideAnimation(
                                                    verticalOffset: 100.0,
                                                    child: FadeInAnimation(
                                                      child: displayCardItem(
                                                          searchList[index]),
                                                    ),
                                                  ));
                                        }
                                      } else {
                                        if (index == 0) {
                                          return Column(
                                            children: <Widget>[
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      top: 40, bottom: 10),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Expanded(
                                                          child: Container(
                                                        child: Divider(
                                                          color: Colors.grey,
                                                          height: 10,
                                                        ),
                                                        margin: EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 10.0),
                                                      )),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 30,
                                                        child: Text(
                                                            'Recently Viewed',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white70)),
                                                      ),
                                                      Expanded(
                                                          child: Container(
                                                        child: Divider(
                                                          color: Colors.grey,
                                                          height: 10,
                                                        ),
                                                        margin: EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 10.0),
                                                      )),
                                                    ],
                                                  )),
                                              AnimationConfiguration
                                                  .staggeredList(
                                                      position: index,
                                                      duration: const Duration(
                                                          milliseconds: 375),
                                                      child: SlideAnimation(
                                                        verticalOffset: 100.0,
                                                        child: FadeInAnimation(
                                                          child: index ==
                                                                  recentList
                                                                          .length -
                                                                      1
                                                              ? Column(
                                                                  children: <
                                                                      Widget>[
                                                                    displayCardItem(
                                                                        recentList[
                                                                            index]),
                                                                    Container(
                                                                      height:
                                                                          showMore?15:20,
                                                                      width: showMore?15:width,
                                                                      child: showMore
                                                                          ? Center(
                                                                              child: CircularProgressIndicator(
                                                                                valueColor: AlwaysStoppedAnimation(
                                                                                  Colors.white70,
                                                                                ),
                                                                                strokeWidth: 1,
                                                                              ),
                                                                            )
                                                                          : Row(children:<Widget>[
                                                SizedBox(width:10),
                                                Expanded(child:Divider(color: Colors.grey,height: 10,),),
                                                Container(margin:EdgeInsets.only(left:10,right:10),child: Text('No More Gifts Available',style:TextStyle(color:Colors.white70))),
                                                Expanded(child:Divider(color: Colors.grey,height: 10,)),
                                                  SizedBox(width:10),]),

                                                                      margin:  EdgeInsets.only(
                                                                              bottom: 20,
                                                                              top: 5)
                                                                          
                                                                    )
                                                                  ],
                                                                )
                                                              : displayCardItem(
                                                                  recentList[
                                                                      index]),
                                                        ),
                                                      ))
                                            ],
                                          );
                                        } else {
                                          return AnimationConfiguration
                                              .staggeredList(
                                                  position: index,
                                                  duration: const Duration(
                                                      milliseconds: 375),
                                                  child: SlideAnimation(
                                                    verticalOffset: 100.0,
                                                    child: FadeInAnimation(
                                                      child: index ==
                                                              recentList
                                                                      .length -
                                                                  1
                                                          ? Column(
                                                              children: <
                                                                  Widget>[
                                                                displayCardItem(
                                                                    recentList[
                                                                        index]),
                                                                Container(
                                                                  height: showMore?15:20,
                                                                  width: showMore?15:width,
                                                                  child: showMore
                                                                      ? Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation(
                                                                              Colors.white70,
                                                                            ),
                                                                            strokeWidth:
                                                                                1,
                                                                          ),
                                                                        )
                                                                      :  Row(children:<Widget>[
                                                SizedBox(width:10),
                                                Expanded(child:Divider(color: Colors.grey,height: 10,),),
                                                Container(margin:EdgeInsets.only(left:10,right:10),child: Text('No More Gifts Available',style:TextStyle(color:Colors.white70))),
                                                Expanded(child:Divider(color: Colors.grey,height: 10,)),
                                                  SizedBox(width:10),]),

                                                                  margin:  EdgeInsets.only(
                                                                          bottom:
                                                                              20,
                                                                          top:
                                                                              5)
                                                                      
                                                                )
                                                              ],
                                                            )
                                                          : displayCardItem(
                                                              recentList[
                                                                  index]),
                                                    ),
                                                  ));
                                        }
                                      }
                                    }),
                              )),
                        )),
        Positioned(
          left: 0,
          top: 30,
          child: SlideTransition(
            position: dropAnimation,
            child: Container(
              height: 100,
              width: width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 1,
                    )
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(18, 42, 76, 1),
                      Color.fromRGBO(5, 150, 197, 1),
                      Color.fromRGBO(18, 42, 76, 1)
                    ],
                  )),
            ),
          ),
        ),
        Positioned(
            top: 180,
            right: 10,
            child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: filterOpened ? 120 : 0,
                height: filterOpened ? 130 : 0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFF282828),
                    boxShadow: [
                      BoxShadow(
                        color: filterOpened
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.transparent,
                        // changes position of shadow
                      )
                    ]),
                child: Column(
                  children: <Widget>[
                    AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        height: filterOpened ? 30 : 0,
                        child: InkWell(
                            onTap: () {
                              filter = 'lowestprice';
                              filterOpened = false;
                              if (searchList.isNotEmpty) {
                                sortedList = searchList.toList();
                              }
                              searchList.clear();
                              setState(() {
                                showLoading = true;
                              });
                              Future.delayed(Duration(milliseconds: 500), () {
                                sortedList
                                    .sort((a, b) => a.price.compareTo(b.price));
                                searchList = sortedList;

                                setState(() {
                                  showLoading = false;
                                });
                              });
                            },
                            child: Text('Lowest Price',
                                style: TextStyle(
                                    color: filter == 'lowestprice'
                                        ? Colors.white
                                        : Colors.white54)))),
                    Expanded(
                        child: Divider(
                      color: Colors.grey,
                      height: 3,
                    )),
                    AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        height: filterOpened ? 30 : 0,
                        child: InkWell(
                            onTap: () {
                              filter = 'highestprice';
                              filterOpened = false;
                              if (searchList.isNotEmpty) {
                                sortedList = searchList.toList();
                              }
                              searchList.clear();
                              setState(() {
                                showLoading = true;
                              });
                              Future.delayed(Duration(milliseconds: 500), () {
                                sortedList
                                    .sort((a, b) => b.price.compareTo(a.price));
                                searchList = sortedList;

                                setState(() {
                                  showLoading = false;
                                });
                              });
                            },
                            child: Text('Highest Price',
                                style: TextStyle(
                                    color: filter == 'highestprice'
                                        ? Colors.white
                                        : Colors.white54)))),
                    Expanded(
                        child: Divider(
                      color: Colors.grey,
                      height: 3,
                    )),
                    AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        height: filterOpened ? 30 : 0,
                        child: InkWell(
                            onTap: () {
                              filter = 'mostrecently';
                              filterOpened = false;
                              if (searchList.isNotEmpty) {
                                sortedList = searchList.toList();
                              }
                              searchList.clear();
                              setState(() {
                                showLoading = true;
                              });
                              Future.delayed(Duration(milliseconds: 500), () {
                                sortedList
                                    .sort((a, b) => a.date.compareTo(b.date));
                                searchList = sortedList;

                                setState(() {
                                  showLoading = false;
                                });
                              });
                            },
                            child: Text('Most Recently',
                                style: TextStyle(
                                    color: filter == 'mostrecently'
                                        ? Colors.white
                                        : Colors.white54)))),
                    Expanded(
                        child: Divider(
                      color: Colors.grey,
                      height: 3,
                    )),
                    AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        height: filterOpened ? 30 : 0,
                        child: InkWell(
                            onTap: () {
                              filter = 'highestrate';
                              filterOpened = false;
                              if (searchList.isNotEmpty) {
                                sortedList = searchList.toList();
                              }
                              searchList.clear();
                              setState(() {
                                showLoading = true;
                              });
                              Future.delayed(Duration(milliseconds: 500), () {
                                sortedList.sort((a, b) {
                                  if (a.rate == null && b.rate == null) {
                                    return 0;
                                  } else if (a.rate == null) {
                                    return 0.compareTo(b.rate);
                                  } else {
                                    return a.rate.compareTo(0);
                                  }
                                });
                                searchList = sortedList;

                                setState(() {
                                  showLoading = false;
                                });
                              });
                            },
                            child: Text('Highest Rate',
                                style: TextStyle(
                                    color: filter == 'highestrate'
                                        ? Colors.white
                                        : Colors.white54)))),
                  ],
                ))),
        Positioned.fill(
            child: TestDropdown(key: menuKey, changeIcon: changeIcon)),
        Positioned(
          left: 30,
          top: 30,
          child: SlideTransition(
            position: dropAnimation,
            child: Container(
                height: 100,
                padding: EdgeInsets.only(bottom: 10),
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: width - 100,
                      height: 40,
                      child: Card(
                        margin: EdgeInsets.all(0),
                        clipBehavior: Clip.antiAlias,
                        color: Color(0xFF282828),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                                color: Colors.white,
                                style: BorderStyle.solid,
                                width: 1)),
                        child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: new Icon(
                                    Icons.search,
                                    size: 30,
                                    color: Colors.white70,
                                  )),
                              Expanded(
                                child: TextField(
                                  cursorColor: Colors.white54,
                                  onChanged: _onChangeHandler,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 10),
                                      focusedBorder: InputBorder.none,
                                      hintText: menuIcon == MdiIcons.gift
                                          ? 'Search Gifts'
                                          : menuIcon == Icons.calendar_today
                                              ? 'Search Occasions'
                                              : menuIcon ==
                                                      Icons.store_mall_directory
                                                  ? 'Search Gift Shops'
                                                  : 'Search',
                                      hintStyle: TextStyle(
                                          color: Colors.white70, fontSize: 20)),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ]),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Card(
                          elevation: 8,
                          clipBehavior: Clip.antiAlias,
                          color: Color(0xFF282828),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                  color: Colors.white,
                                  style: BorderStyle.solid,
                                  width: 1)),
                          child: InkWell(
                            onTap: () {
                              if (resetTimer == null || !resetTimer.isActive) {
                                resetTimer =
                                    Timer(Duration(milliseconds: 1000), () {
                                  if (clicked) clicked = false;
                                  if (menuKey.currentState.clicked)
                                    menuKey.currentState.clicked = false;
                                  resetTimer.cancel();
                                });
                              }
                              if (!clicked) {
                                clicked = true;
                                menuKey.currentState.clicked = true;
                                if (menuOpened) {
                                  menuKey.currentState.closeMenu();
                                  blinkController.forward();

                                  setState(() {
                                    menuOpened = false;
                                    // menuWidget = Container(
                                    //   height: 0,
                                    // );
                                  });
                                } else {
                                  menuKey.currentState.openMenu();
                                  blinkController.forward();

                                  setState(() {
                                    // menuWidget = TestDropdown( key:menuKey,changeIcon:changeIcon);
                                    menuOpened = true;
                                  });
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: AnimatedSwitcher(
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: blinkAnimation,
                                    child: child,
                                  );
                                },
                                duration: Duration(milliseconds: 250),
                                child: menuOpened
                                    ? Container(
                                        width: 30,
                                        height: 30,
                                        child: Icon(Icons.close,
                                            color: Colors.white70, size: 20))
                                    : Container(
                                        height: 30,
                                        width: 30,
                                        child: Icon(menuIcon,
                                            color: Colors.white70, size: 25),
                                      ),
                              ),
                            ),
                          ),
                        ))
                  ],
                )),
          ),
        ),
        Positioned(
            left: (width / 2) - 15,
            top: 35,
            height: 30,
            width: 30,
            child: SlideTransition(
              position: dropAnimation,
              child: InkWell(
                  onTap: () {
                    dropController.reverse();
                    Future.delayed(Duration(milliseconds: 500), () {
                      Navigator.pop(context);
                    });
                  },
                  child: Icon(Icons.keyboard_arrow_up,
                      color: Colors.white70, size: 30)),
            )),
      ]),
    );
  }

  void changeIcon(IconData icondata) {
    blinkController.forward();

    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        menuOpened = false;
        menuIcon = icondata;
      });
      if (searchText.isNotEmpty) {
        search(searchText);
      }
    });
  }

  // Widget displayLoading() {
  //   return Card(
  //     color: Color.fromRGBO(65, 67, 66, 1.0),
  //     margin: EdgeInsets.only(bottom: 5, right: 2, left: 2),
  //     elevation: 5,
  //     clipBehavior: Clip.antiAlias,
  //     child: Container(
  //       padding: EdgeInsets.all(0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           Container(
  //             width: width,
  //             height: height / 3,
  //             child: Stack(
  //               alignment: Alignment.center,
  //               children: <Widget>[
  //                 Positioned(
  //                     top: 0,
  //                     left: 0,
  //                     width: width,
  //                     height: height / 3,
  //                     child: Shimmer.fromColors(
  //                       enabled: true,
  //                       child: Container(),
  //                       baseColor: Color.fromRGBO(65, 67, 66, 1.0),
  //                       highlightColor: Color.fromRGBO(75, 77, 76, 1.0),
  //                     )),
  //                 Positioned(
  //                     left: 5,
  //                     top: 10,
  //                     child: Shimmer.fromColors(
  //                       enabled: true,
  //                       child: Card(
  //                         shape: CircleBorder(),
  //                         elevation: 3,
  //                         child: CircleAvatar(
  //                           radius: width / 15,
  //                         ),
  //                       ),
  //                       baseColor: Color.fromRGBO(65, 67, 66, 1.0),
  //                       highlightColor: Color.fromRGBO(75, 77, 76, 1.0),
  //                     )),
  //                 Positioned(
  //                     right: 5,
  //                     top: 0,
  //                     child: RotatedBox(
  //                         quarterTurns: 1,
  //                         child: Label(
  //                           triangleHeight: 17,
  //                           child: Shimmer.fromColors(
  //                             enabled: true,
  //                             baseColor: Color.fromRGBO(65, 67, 66, 1.0),
  //                             highlightColor: Color.fromRGBO(75, 77, 76, 1.0),
  //                             child: Card(
  //                               color: Colors.red[600],
  //                               child: Padding(
  //                                 padding: const EdgeInsets.only(
  //                                     left: 5, right: 20, top: 3, bottom: 3),
  //                                 child: Text('700 LE',
  //                                     style: TextStyle(color: Colors.white)),
  //                               ),
  //                             ),
  //                           ),
  //                         )))
  //               ],
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget displayCardItem(SearchGifts content) {
    return Card(
      color: Color(0xFF151515),
      margin: EdgeInsets.only(bottom: 5, right: 2, left: 2),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (content.id != null && content.id.isNotEmpty) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new GiftPage(content.id)));
          }
        },
        child: Container(
          width: width,
          height: 200,
          
           foregroundDecoration: content.discount != null &&
                                  content.discount.isNotEmpty
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
                          height: 200,
                          
                         
                          width: width,
                          color: Color(0xFF282828)),
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
                    margin: EdgeInsets.all(0),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width / 15)),
                    color: Color(0xFF282828),
                    child: InkWell(
                      onTap: () {
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
            ],
          ),
        ),
      ),
    );
  }

  Future _loadData(String search) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (search != null && search != "") {
        if (menuIcon == MdiIcons.gift) {
          await FirebaseFirestore.instance
              .collection('Gifts')
              .where('show', isEqualTo: true)
              .where('tag', arrayContains: search)
              .orderBy('tag', descending: true)
              .get()
              .then((results) async {
            if (results.docs.isNotEmpty) {
              results.docs.forEach((v) {
                searchList.add(new SearchGifts(
                    v.data()['img'],
                    v.data()['name'],
                    v.data()['price'],
                    v.data()['page'],
                    v.id,
                    v.data()['pageid'],
                    v.data()['date'],
                    v.data()['rate'],
                    v.data()['discount']));
              });
            } else {
              noMatches = true;
            }
          });
        } else if (menuIcon == Icons.calendar_today) {
          await FirebaseFirestore.instance
              .collection('Gifts')
              .where('show', isEqualTo: true)
              .where('occasion', arrayContains: search)
              .orderBy('occasion', descending: true)
              .get()
              .then((results) async {
            if (results.docs.isNotEmpty) {
              results.docs.forEach((v) {
                searchList.add(new SearchGifts(
                    v.data()['img'],
                    v.data()['name'],
                    v.data()['price'],
                    v.data()['page'],
                    v.id,
                    v.data()['pageid'],
                    v.data()['date'],
                    v.data()['rate'],
                    v.data()['discount']));
              });
            } else {
              noMatches = true;
            }
          });
        } else if (menuIcon == Icons.store_mall_directory) {
          await FirebaseFirestore.instance
              .collection('Gifts')
              .where('show', isEqualTo: true)
              .where('pagename', isEqualTo: search)
              .orderBy('date', descending: true)
              .get()
              .then((results) async {
            if (results.docs.isNotEmpty) {
              results.docs.forEach((v) {
                searchList.add(new SearchGifts(
                    v.data()['img'],
                    v.data()['name'],
                    v.data()['price'],
                    v.data()['page'],
                    v.id,
                    v.data()['pageid'],
                    v.data()['date'],
                    v.data()['rate'],
                    v.data()['discount']));
              });
            } else {
              noMatches = true;
            }
          });
        }
        if (mounted) {
          setState(() {});
        }
      } else {
        while (count < recentIdListRev.length && count < limit) {
          await FirebaseFirestore.instance
              .collection('Gifts')
              .doc(recentIdListRev[count])
              .get()
              .then((value) {
            if (value.data() != null &&
                value.data().isNotEmpty &&
                value.data()['show'] == true) {
              recentList.add(
                new SearchGifts(
                    value.data()['img'],
                    value.data()['name'],
                    value.data()['price'],
                    value.data()['page'],
                    value.id,
                    value.data()['pageid'],
                    value.data()['date'],
                    value.data()['rate'],
                    value.data()['discount']),
              );

              count++;
            } else {
              recentIdListRev.removeAt(count);
              sharedPref.setStringList(
                  'recentlyviewed', recentIdListRev.reversed.toList());
            }
          });
        }

        if (recentList.isEmpty) {
          noPrevGifts = true;
        } else if (count == recentIdListRev.length && showMore) {
          showMore = false;
        }
      }

      if (mounted) {
        setState(() {
          if (internetError) internetError = false;
          showLoading = false;
          retrying = false;
        });
      }
    } else {
      setState(() {
        retrying = false;
        internetError = true;
        showLoading = false;
      });
    }
  }

  Future _loadMoreData(String search) async {
    if (search != null && search != "") {
      // await Firestore.instance
      //     .collection('Gifts')
      //     .where('type', isEqualTo: 'normal')
      //     .where('name', arrayContains: search)
      //     .orderBy('id', descending: true)
      //     .startAfter([lastSearchItem])
      //     .limit(10)
      //     .getDocuments()
      //     .then((results) {
      //       if (results != null) {
      //         if (results.documents != null) {
      //           results.documents.forEach((v) {
      //             searchList.add(new Gifts(v['img'], v['name'], v['price'],
      //                 v['page'], v.documentID, v['pageid']));
      //             lastItem = v['id'];
      //           });
      //         }
      //       }
      //     });

      // setState(() {
      //   showLoading = false;
      // });
    } else {
      // print(recentIdList10);
      // recentIdList10.addAll(recentIdList.skip(3).take(3));
      // print(recentIdList10);
      // await FirebaseFirestore.instance
      //     .collection('Gifts')
      //     .where(FieldPath.documentId, whereIn: recentIdList10)
      //     .get()
      //     .then((results) async {
      //   if (results != null && results.docs.isNotEmpty) {
      //     recentList.length = recentIdList10.length;
      //     results.docs.forEach((v) {
      //       recentList[recentIdList10.indexOf(v.id)] = new SearchGifts(
      //           v.data()['img'],
      //           v.data()['name'],
      //           v.data()['price'],
      //           v.data()['page'],
      //           v.id,
      //           v.data()['pageid'],
      //           v.data()['date'],
      //           v.data()['rate']);

      //       lastDate = v.data()['date'];
      //     });
      //     showMore = true;
      //   } else {
      //     showMore = false;
      //   }

      //   setState(() {
      //     showLoading = false;
      //   });
      // });

      while (count < recentIdListRev.length && count < limit) {
        await FirebaseFirestore.instance
            .collection('Gifts')
            .doc(recentIdListRev[count])
            .get()
            .then((value) {
          if (value.data() != null &&
              value.data().isNotEmpty &&
              value.data()['show'] == true) {
            recentList.add(new SearchGifts(
                value.data()['img'],
                value.data()['name'],
                value.data()['price'],
                value.data()['page'],
                value.id,
                value.data()['pageid'],
                value.data()['date'],
                value.data()['rate'],
                value.data()['discount']));

            count++;
          } else {
            recentIdListRev.removeAt(count);
            sharedPref.setStringList(
                'recentlyviewed', recentIdListRev.reversed.toList());
          }
        });
      }
      if (recentIdListRev.length > count) {
        showMore = true;
      } else {
        showMore = false;
      }

      setState(() {
        showLoading = false;
      });
    }
  }
}
