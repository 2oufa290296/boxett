import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:boxet/GiftPage.dart';
import 'package:boxet/CustomDialog.dart';
import 'package:boxet/classes/ChatPageImages.dart';
import 'package:boxet/classes/OpinionsEntity.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ChatPage extends StatefulWidget {
  final String uid, profImg;
  final void Function() backHome;

  ChatPage({Key key, this.uid, this.profImg, this.backHome}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> chatKey = GlobalKey<ScaffoldState>();
  StreamController<List<DocumentSnapshot>> streamController =
      StreamController<List<DocumentSnapshot>>();
  List<DocumentSnapshot> chatMessages = [];
  bool requesting = false;
  bool finished = false;
  FirebaseFirestore db = FirebaseFirestore.instance;
  ScrollController scrollController;
  double width, height;
  double bottom = 0;
  int yourMessages = 0;
  int pageMessages = 0;
  Stream stream;
  SharedPreferences sharedPref;
  List<String> recentIdListRev = [];
  bool internetError = false;
  int count = 0;
  int limit = 10;
  List<OpinionsEntity> recentList = [];
  bool noPrevGifts = false;
  bool showGifts = false;
  bool loadingGifts = false;
  bool loadingMore = false;
  ScrollController recentController;
  Map<String, String> selectedMap = {};
  StreamSubscription<QuerySnapshot> streamSubscription;
  GlobalKey<CustomDialogState> chatCustomKey = GlobalKey();

  void onChangeData(List<DocumentChange> documentChanges) {
    var isChange = false;
    documentChanges.forEach((messageChange) {
      if (messageChange.type == DocumentChangeType.removed) {
        chatMessages.removeWhere((message) {
          return messageChange.doc.id == message.id;
        });
        isChange = true;
      } else {
        if (messageChange.type == DocumentChangeType.modified) {
          int indexWhere = chatMessages.indexWhere((message) {
            return messageChange.doc.id == message.id;
          });

          if (indexWhere >= 0) {
            chatMessages[indexWhere] = messageChange.doc;
          }
          isChange = true;
        } else if (messageChange.type == DocumentChangeType.added) {
          if (!chatMessages.contains(messageChange.doc) &&
              chatMessages.isNotEmpty) {
            Timestamp newTime = messageChange.doc.data()['time'];
            Timestamp lastTime = chatMessages[0].data()['time'];
            if (newTime.compareTo(lastTime) >= 0) {
              chatMessages.insert(0, messageChange.doc);
              isChange = true;
            }
          }
        }
      }
    });

    if (isChange) {
      streamController.add(chatMessages);
    }
  }

  _getRecentIdList() async {
    sharedPref = await SharedPreferences.getInstance();
    List<String> aaa = sharedPref.getStringList('recentlyviewed');

    if (aaa != null) {
      recentIdListRev = aaa.reversed.toList();
    } else {
      recentIdListRev = [];
    }
  }

  giftOnTap() {
    if (showGifts) {
      selectedMap.clear();
      setState(() {
        showGifts = false;
      });
    } else if (loadingGifts) {
      setState(() {
        loadingGifts = false;
      });
    } else if (internetError) {
      setState(() {
        internetError = false;
      });
    } else {
      setState(() {
        loadingGifts = true;
      });

      if (recentList.isEmpty) {
        _getRecentList();
      } else {
        Future.delayed(Duration(milliseconds: 1000), () {
          _getRecentList();
        });
      }
    }
  }

  _getRecentList() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      while (count < recentIdListRev.length && count < limit) {
        await FirebaseFirestore.instance
            .collection('Gifts')
            .doc(recentIdListRev[count])
            .get()
            .then((value) {
          if (value.data() != null && value.data().isNotEmpty) {
            recentList.add(new OpinionsEntity(
              value.data()['img'],
              value.id,
            ));

            count++;
          } else {
            recentIdListRev.removeAt(count);
            sharedPref.setStringList(
                'recentlyviewed', recentIdListRev.reversed.toList());
          }
        });
      }

      if (recentList.isEmpty) {
        setState(() {
          loadingGifts = false;
          noPrevGifts = true;
        });
      } else {
        setState(() {
          loadingGifts = false;
          showGifts = true;
          internetError = false;
          noPrevGifts = false;
        });
      }
    } else {
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          loadingGifts = false;
          internetError = true;
        });
      });
    }
  }

  _getMoreRecentList() async {
    setState(() {
      loadingMore = true;
      limit += 10;
    });
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      while (count < recentIdListRev.length && count < limit) {
        await FirebaseFirestore.instance
            .collection('Gifts')
            .doc(recentIdListRev[count])
            .get()
            .then((value) {
          if (value.data() != null && value.data().isNotEmpty) {
            recentList.add(new OpinionsEntity(
              value.data()['img'],
              value.id,
            ));

            count++;
          } else {
            recentIdListRev.removeAt(count);
            sharedPref.setStringList(
                'recentlyviewed', recentIdListRev.reversed.toList());
          }
        });
      }

      if (count < recentIdListRev.length) {
        setState(() {
          loadingMore = true;
        });
      } else {
        setState(() {
          loadingMore = false;
        });
      }
    }
  }

  void requestNextMessages() async {
    if (!requesting && !finished) {
      QuerySnapshot querySnapshot;
      requesting = true;
      if (chatMessages.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('AppChat')
            .orderBy('time', descending: true)
            .limit(15)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('AppChat')
            .orderBy('time', descending: true)
            .startAfterDocument(chatMessages[chatMessages.length - 1])
            .limit(15)
            .get();
      }

      if (querySnapshot != null) {
        int oldSize = chatMessages.length;
        chatMessages.addAll(querySnapshot.docs);
        int newSize = chatMessages.length;
        if (oldSize != newSize) {
          streamController.add(chatMessages);
        } else {
          setState(() {
            finished = true;
          });
        }
      }
      
      requesting = false;
    }
  }

  @override
  void initState() {
    streamSubscription = FirebaseFirestore.instance
        .collection('AppChat')
        .snapshots()
        .listen((data) => onChangeData(data.docChanges));

    requestNextMessages();

    recentController = new ScrollController();
    _getRecentIdList();
    scrollController = new ScrollController();

    recentController.addListener(() {
      if (recentController.position.extentAfter == 0) {
        if (count < recentIdListRev.length) _getMoreRecentList();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    scrollController.dispose();
    recentController.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    bottom = WidgetsBinding.instance.window.viewInsets.bottom;

    return Scaffold(
      key: chatKey,
      appBar: PreferredSize(
          child: Container(
              height: 50,
              
              child: Container(
                  child: Row(
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        widget.backHome();
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 20, right: 5),
                          child: Icon(Icons.arrow_back_ios,
                              color: Colors.white70, size: 25))),
                  Container(
                    width: width - 100,
                    alignment: Alignment.center,
                    child: Text('Opinions',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: "Lobster",
                            letterSpacing: 2)),
                  ),
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => CustomDialog(
                                key: chatCustomKey,
                                title: Text('Opinions Activity',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 22,
                                        fontFamily: "Lobster",
                                        letterSpacing: 2)),
                                content: Center(
                                    child: Text(
                                        'In this activity you can chat with other users and take their opinion on choosing the most suitable gifts',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 18))),
                                iconData: MdiIcons.informationVariant));
                      },
                      child: Container(
                          width: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white70, width: 2)),
                          child: Icon(MdiIcons.informationVariant,
                              color: Colors.white70, size: 25)))
                ],
              )),
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
                      Color.fromRGBO(18,42,76,1)
                    ],
                  ))),
          preferredSize: Size(width, 50)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollNotif) {
                if (scrollNotif.metrics.maxScrollExtent ==
                    scrollNotif.metrics.pixels) {
                  requestNextMessages();
                }

                return true;
              },
              child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: streamController.stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<DocumentSnapshot>> snap) {
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    } else if (snap.connectionState ==
                        ConnectionState.waiting) {
                      return SingleChildScrollView(child: loadingWidget());
                    } else if (snap.data != null) {
                      return ListView.builder(
                          padding: EdgeInsets.only(bottom: 5),
                          shrinkWrap: true,
                          reverse: true,
                          controller: scrollController,
                          itemCount: snap.data.length,
                          itemBuilder: (context, index) {
                            DateTime now = DateTime.now();

                            if ((snap.data[index].data()['message'] != null &&
                                    snap.data[index].data()['message'] != "") ||
                                (snap.data[index].data()['attachments'] !=
                                        null &&
                                    snap.data[index]
                                            .data()['attachments']
                                            .toString() !=
                                        '{}')) {
                              Timestamp timeStamp =
                                  snap.data[index].data()["time"];
                              String day = "";
                              String time = "";
                              var formatter = new DateFormat('EEEE');

                              Map<String, dynamic> attachmentsMap =
                                  snap.data[index].data()['attachments'];

                              List<ChatPageImages> chatImages = [];
                              if (attachmentsMap != null &&
                                  attachmentsMap.isNotEmpty) {
                                chatImages = attachmentsMap.entries
                                    .map((entry) =>
                                        ChatPageImages(entry.key, entry.value))
                                    .toList();
                              }
                              var formatter2 = new DateFormat('HH:mm a');
                              time = formatter2.format(timeStamp.toDate());
                              if (now
                                      .difference(timeStamp.toDate())
                                      .inMinutes ==
                                  0) {
                                time = 'Just now';
                              } else if (now
                                      .difference(timeStamp.toDate())
                                      .inHours ==
                                  0) {
                                time = now
                                        .difference(timeStamp.toDate())
                                        .inMinutes
                                        .toString() +
                                    " mins ago";
                              } else if (now
                                          .difference(timeStamp.toDate())
                                          .inDays ==
                                      0 &&
                                  now.day == timeStamp.toDate().day) {
                                time = formatter2.format(timeStamp.toDate());
                              } else if (now
                                          .difference(timeStamp.toDate())
                                          .inDays ==
                                      1 ||
                                  (now.difference(timeStamp.toDate()).inDays ==
                                          0 &&
                                      now.day != timeStamp.toDate().day)) {
                                day = "Yesterday ";
                                time = formatter2.format(timeStamp.toDate());
                              } else if (now
                                      .difference(timeStamp.toDate())
                                      .inDays <
                                  7) {
                                day = formatter.format(timeStamp.toDate());

                                time = formatter2.format(timeStamp.toDate());
                              } else {
                                var formatter = new DateFormat('dd/MM');

                                day = formatter.format(timeStamp.toDate()) +
                                    ' at';

                                time = formatter2.format(timeStamp.toDate());
                              }

                              if (snap.data[index].data()['uid'] ==
                                  widget.uid) {
                                    if (snap.data[index].data()['message'] !=
                                        null &&
                                    snap.data[index].data()['message'] != "") {
                                  return yourText(
                                      index, snap, day, time, chatImages);
                                } else {
                                  return yourImages(
                                      index, snap, day, time, chatImages);
                                }
                                
                              } else if(snap.data[index].data()['uid']== null ||snap.data[index].data()['uid']=="" ){
                               
                                return 
                                Container(margin:EdgeInsets.only(top:10),child:Row(crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 10),
                                                        Expanded(
                                                          child: Divider(thickness: 0.5,
                                                            color: Colors.grey,
                                                            height: 10,
                                                          ),
                                                        ), SizedBox(width: 10),
                                    Container(alignment:Alignment.center,child:Text(snap.data[index].data()['message'],style:TextStyle(color: Colors.white54, fontSize: 14))),
                                  SizedBox(width: 10),
                                                        Expanded(
                                                          child: Divider(thickness: 0.5,
                                                            color: Colors.grey,
                                                            height: 10,
                                                          ),
                                                        ), SizedBox(width: 10),
                                  ],
                                ));
                              }
                              else {
                                if (snap.data[index].data()['message'] !=
                                        null &&
                                    snap.data[index].data()['message'] != "") {
                                  return othersText(
                                      index, snap, day, time, chatImages);
                                } else {
                                  return othersImages(
                                      index, snap, day, time, chatImages);
                                }
                              }
                            } else {
                              return Container(height: 0, width: 0);
                            }
                          });
                    } else {
                      return Center(child: Text('No Previous Chat'));
                    }
                  }),
            ),
          ),
          // Container(
          //   color: Colors.transparent,
          //   margin: EdgeInsets.only(top: 5),
          //   padding: EdgeInsets.only(top: 3),
          //   child: Row(
          //     children: <Widget>[
          //       Container(
          //         margin: EdgeInsets.only(
          //           left: 5,
          //         ),
          //         height: 45,
          //         width: width - 60,
          //         decoration: BoxDecoration(
          //           color: Color(0xFF282828),
          //           borderRadius: BorderRadius.circular(30),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.grey.withOpacity(0.8),
          //               spreadRadius: 3,
          //               blurRadius: 4,
          //               offset: Offset(0, 0),
          //             ),
          //           ],
          //         ),
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: <Widget>[
          //             Expanded(
          //               child: Container(
          //                   padding: EdgeInsets.only(left: 20),
          //                   child: TextField(
          //                     cursorColor: Colors.white70,
          //                     style:
          //                         TextStyle(color: Colors.white, fontSize: 18),
          //                     controller: inputController,
          //                     decoration: InputDecoration.collapsed(
          //                         hintText: 'Type Your Message',
          //                         hintStyle: TextStyle(
          //                             color: Colors.white70, fontSize: 18)),
          //                   )),
          //             ),
          //             Container(
          //                 width: 45,
          //                 height: 45,
          //                 margin: EdgeInsets.only(right: 10),
          //                 child: InkWell(
          //                     onTap: () {
          //                       if (showGifts) {
          //                         setState(() {
          //                           showGifts = false;
          //                         });
          //                       } else if (loadingGifts) {
          //                         setState(() {
          //                           loadingGifts = false;
          //                         });
          //                       } else {
          //                         setState(() {
          //                           loadingGifts = true;
          //                         });
          //                         _getRecentList();
          //                       }
          //                     },
          //                     child: Icon(
          //                       MdiIcons.gift,
          //                       color: Colors.white70,
          //                     ))),
          //           ],
          //         ),
          //       ),
          //       Container(
          //           margin: EdgeInsets.only(right: 5, left: 5),
          //           width: 45,
          //           height: 45,
          //           padding:
          //               EdgeInsets.only(left: 7, right: 3, top: 5, bottom: 5),
          //           decoration: BoxDecoration(
          //               color: Color(0xFF282828),
          //               shape: BoxShape.circle,
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.grey.withOpacity(0.8),
          //                   spreadRadius: 3,
          //                   blurRadius: 4,
          //                   offset: Offset(0, 0),
          //                 ),
          //               ]),
          //           child: InkWell(
          //               onTap: () {
          //                 _sendMessages(inputController.text);
          //               },
          //               child: Icon(
          //                 Icons.send,
          //                 color: Colors.white70,
          //               ))),
          //     ],
          //   ),
          // ),
          AnimatedContainer(
              height: showGifts || loadingGifts || internetError ? 0 : 50,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 500)),
          AnimatedContainer(
            color: Color(0xFF202020),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(top: 10),
            duration: Duration(milliseconds: 500),
            height: showGifts || loadingGifts || internetError
                ? (height * 0.2) + 65
                : 0,
            width: width,
            child: loadingGifts
                ? Container(
                    margin: EdgeInsets.only(bottom: 55),
                    width: width,
                    child: Center(
                        child: Container(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              valueColor: AlwaysStoppedAnimation(
                                  Colors.grey.withOpacity(0.8)),
                            ))))
                : showGifts
                    ? Container(
                        child: ListView.builder(
                            controller: recentController,
                            scrollDirection: Axis.horizontal,
                            itemCount: recentList.length,
                            itemBuilder: (context, index) {
                              return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: selectedMap.containsKey(
                                                    recentList[index].giftId)
                                                ? Color(0xFF151515)
                                                : Colors.transparent,
                                            border: Border.all(
                                                color: selectedMap.containsKey(
                                                        recentList[index]
                                                            .giftId)
                                                    ? Colors.white70
                                                    : Colors.transparent,
                                                width: 2)),
                                        child:
                                            displayCardItem(recentList[index])),
                                    Container(
                                        margin: EdgeInsets.only(
                                            right: loadingMore ? 5 : 0),
                                        height:
                                            index == recentList.length - 1 &&
                                                    loadingMore
                                                ? 15
                                                : 0,
                                        width: index == recentList.length - 1 &&
                                                loadingMore
                                            ? 15
                                            : 0,
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white70),
                                            strokeWidth: 1))
                                  ]);
                            }),
                        padding: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                        width: width,
                      )
                    : internetError
                        ? Container(
                            margin: EdgeInsets.only(bottom: 55),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      child: Text(
                                    'No Internet Connection',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 18),
                                  )),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        padding:
                                            EdgeInsets.only(left: 5, right: 5),
                                        height: 30,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            gradient: LinearGradient(
                                              colors: [
                                                                                                     Color.fromRGBO(18, 42, 76, 1),
                                      Color(0xFF669999),
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
                                                loadingGifts = true;
                                              });
                                              Future.delayed(
                                                  Duration(
                                                    milliseconds: 1000,
                                                  ),
                                                  _getRecentList);
                                            },
                                            child: Center(
                                                child: Text(
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
                                ]))
                        : Container(height: 0, width: 0),
          ),
        ],
      ),
    );
  }

  Widget displayCardItem(OpinionsEntity content) {
    return Card(
      shadowColor: Colors.transparent,
      margin: EdgeInsets.all(0),
      color: Color(0xFF151515),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () {
          
        },
        onTap: () {
          if (selectedMap.containsKey(content.giftId)) {
            setState(() {
              selectedMap.remove(content.giftId);
            });
          } else {
            if (selectedMap.length > 2) {
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //     backgroundColor: Color(0xFF151515),
              //     content: Container(
              //         height: 20,
              //         child: Center(
              //             child: Text('Cannot select more than 3 gifts')))));
            } else {
              setState(() {
                selectedMap[content.giftId] = content.img;
              });
            }
          }
          // if (content.giftId != null && content.giftId.isNotEmpty) {
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => new GiftPage(content.giftId)));
          // }
        },
        child: Container(
          width: width / 2,
          height: height * 0.2,
          child: CachedNetworkImage(
            imageUrl: content.img,
            fit: BoxFit.cover,
            height: height * 0.2,
            width: width / 2,
            progressIndicatorBuilder: (context, url, progress) {
              return Shimmer.fromColors(
                enabled: true,
                child: Container(
                    height: height * 0.2,
                    width: width / 2,
                    color: Color(0xFF282828)),
                baseColor: Color(0xFF282828),
                highlightColor: Color(0xFF383838),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget chatImagesWidget(ChatPageImages pageImgs, double size) {
    return Card(
      shadowColor: Colors.transparent,
      margin: EdgeInsets.all(0),
      color: Color(0xFF151515),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new GiftPage(pageImgs.giftId)));
        },
        child: Container(
          width: size,
          height: size / 2,
          child: CachedNetworkImage(
            imageUrl: pageImgs.giftImg,
            fit: BoxFit.cover,
            height: size / 2,
            width: size,
            progressIndicatorBuilder: (context, url, progress) {
              return Shimmer.fromColors(
                enabled: true,
                child: Container(
                    height: size / 2, width: size, color: Color(0xFF282828)),
                baseColor: Color(0xFF282828),
                highlightColor: Color(0xFF383838),
              );
            },
          ),
        ),
      ),
    );
  }

  sendMessages(String text) async {
    Timestamp timeStamp = Timestamp.fromDate(DateTime.now());

    if (selectedMap.isEmpty && text.isEmpty) {
    } else {
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        showGifts = false;

        loadingGifts = false;
        internetError = false;
      });
      await db.collection('AppChat').add({
        'profileimg': widget.profImg,
        'message': text,
        'time': timeStamp,
        'uid': widget.uid,
        'attachments': selectedMap
      }).then((value) {
        selectedMap.clear();
      });
    }
  }

  Widget yourImages(int index, AsyncSnapshot<List<DocumentSnapshot>> snap,
      String day, String time, List<ChatPageImages> chatImages) {
    return Container(
        margin: EdgeInsets.only(
          top: 10,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              index == chatMessages.length - 1 &&
                      chatMessages.isNotEmpty &&
                      !finished
                  ? Center(
                      child: Container(
                          margin: EdgeInsets.only(
                            bottom: 5,
                            top: 5,
                          ),
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation(Colors.white70),
                          )),
                    )
                  : Container(height: 0, width: 0),
                  Column(children:<Widget>[Container(
            margin: EdgeInsets.only(right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: chatImagesWidget(chatImages[0], width / 2 ),
                ),
                chatImages.length > 1
                    ? Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: chatImagesWidget(chatImages[1], width /2))
                    : Container(height: 0, width: 0),
                chatImages.length > 2
                    ? Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: chatImagesWidget(chatImages[2], width / 2))
                    : Container(height: 0, width: 0),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 10,
                              ),
                              child: Text(day + " " + time,
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),]),
             
            ]));
  }

  Widget othersImages(int index, AsyncSnapshot<List<DocumentSnapshot>> snap,
      String day, String time, List<ChatPageImages> chatImages) {
    return Container(
      
        margin: EdgeInsets.only(
          top: 10,
        ),
        child: Column(
          children: <Widget>[
            index == chatMessages.length - 1 &&
                    chatMessages.isNotEmpty &&
                    !finished
                ? Center(
                    child: Container(
                        margin: EdgeInsets.only(
                          bottom: 5,
                          top: 5,
                        ),
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation(Colors.white70),
                        )),
                  )
                : Container(height: 0, width: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      left: 5, right: 15),
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Card(
                    margin: EdgeInsets.all(0),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.1)),
                    child: snap.data[index].data()['profileimg'] != null &&
                            snap.data[index].data()['profileimg'] != ""
                        ? CachedNetworkImage(
                            imageUrl: snap.data[index].data()['profileimg'],
                            height: (width * 0.1),
                            width: (width * 0.1),
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context, url, progress) {
                              return Shimmer.fromColors(
                                enabled: true,
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromRGBO(55, 57, 56, 1.0)),
                                  height: width * 0.1,
                                  width: width * 0.1,
                                ),
                                baseColor: Color(0xFF282828),
                                highlightColor: Color(0xFF383838),
                              );
                            },
                          )
                        : Container(
                            color: Color.fromRGBO(75, 77, 76, 1.0),
                            child: Image.asset('assets/images/profile.png',
                                height: width * 0.1, width: width * 0.1)),
                  ),
                ),
                CustomPaint(painter: ChatArrow()),
                DecoratedBox(
                  decoration: BoxDecoration(
                      color:Color.fromRGBO(99, 155, 173,1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: IntrinsicWidth(
                      child: Column(
                        children: <Widget>[
                          Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: chatImagesWidget(chatImages[0], width / 2),
                        ),
                        chatImages.length > 1
                            ? Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child:
                                    chatImagesWidget(chatImages[1], width / 2))
                            : Container(height: 0, width: 0),
                        chatImages.length > 2
                            ? Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child:
                                    chatImagesWidget(chatImages[2], width / 2))
                            : Container(height: 0, width: 0),
                  
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                                child: Text(day + " " + time,
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 10))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ],
        ));
  }

  Widget yourText(int index, AsyncSnapshot<List<DocumentSnapshot>> snap,
      String day, String time, List<ChatPageImages> chatImages) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          index == chatMessages.length - 1 &&
                  chatMessages.isNotEmpty &&
                  !finished
              ? Center(
                  child: Container(
                      margin: EdgeInsets.only(
                        bottom: 5,
                        top: 5,
                      ),
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation(Colors.white70),
                      )),
                )
              : Container(height: 0, width: 0),
          Container(
            margin: EdgeInsets.only(right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          chatImages.isNotEmpty &&
                                  snap.data[index].data()['message'] != null &&
                                  snap.data[index].data()['message'] != ""
                              ? Container(
                                  constraints: BoxConstraints(
                                      minWidth: chatImages.length == 1
                                          ? width / 3
                                          : chatImages.length == 2
                                              ? width / 2
                                              : width / 3),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                              right: chatImages.length > 1
                                                  ? 5
                                                  : 0),
                                          child: chatImagesWidget(
                                              chatImages[0],
                                              chatImages.length == 1
                                                  ? width / 2
                                                  : width / 4),
                                        ),
                                        chatImages.length > 1
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    right: chatImages.length > 2
                                                        ? 5
                                                        : 0),
                                                child: chatImagesWidget(
                                                    chatImages[1], width / 4))
                                            : Container(height: 0, width: 0),
                                        chatImages.length > 2
                                            ? Container(
                                                child: chatImagesWidget(
                                                    chatImages[2], width / 4))
                                            : Container(height: 0, width: 0),
                                      ]),
                                )
                              : Container(height: 0, width: 0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: chatImages.length == 1
                                      ? width / 2
                                      : chatImages.length == 2
                                          ? (width / 2) + 5
                                          : (width * 0.75) + 10),
                              padding: EdgeInsets.only(
                                  top: chatImages.isNotEmpty ? 3 : 0,
                                  left: chatImages.isNotEmpty ? 3 : 0),
                              child: Text(snap.data[index].data()['message'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 10,
                              ),
                              child: Text(day + " " + time,
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget othersText(int index, AsyncSnapshot<List<DocumentSnapshot>> snap,
      String day, String time, List<ChatPageImages> chatImages) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          index == chatMessages.length - 1 &&
                  chatMessages.isNotEmpty &&
                  !finished
              ? Center(
                  child: Container(
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation(Colors.white70),
                      )),
                )
              : Container(height: 0, width: 0),
          Container(
            margin: EdgeInsets.only(
              left: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 15),
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Card(
                    margin: EdgeInsets.all(0),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.1)),
                    child: snap.data[index].data()['profileimg'] != null &&
                            snap.data[index].data()['profileimg'] != ""
                        ? CachedNetworkImage(
                            imageUrl: snap.data[index].data()['profileimg'],
                            height: (width * 0.1),
                            width: (width * 0.1),
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context, url, progress) {
                              return Shimmer.fromColors(
                                enabled: true,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(55, 57, 56, 1.0),
                                      shape: BoxShape.circle),
                                  height: width * 0.1,
                                  width: width * 0.1,
                                ),
                                baseColor: Color(0xFF282828),
                                highlightColor: Color(0xFF383838),
                              );
                            },
                          )
                        : Container(
                            color: Color.fromRGBO(75, 77, 76, 1.0),
                            child: Image.asset('assets/images/profile.png',
                                height: width * 0.1, width: width * 0.1)),
                  ),
                ),
                CustomPaint(painter: ChatArrow()),
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(99, 155, 173,1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: IntrinsicWidth(
                      child: Column(
                        children: <Widget>[
                          chatImages.isNotEmpty &&
                                  snap.data[index].data()['message'] != null &&
                                  snap.data[index].data()['message'] != ""
                              ? Container(
                                  constraints: BoxConstraints(
                                      minWidth: chatImages.length == 1
                                          ? width / 3
                                          : chatImages.length == 2
                                              ? width / 2
                                              : width / 3),
                                  child: Column(children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom:
                                              chatImages.length > 1 ? 5 : 0),
                                      child: chatImagesWidget(
                                          chatImages[0], width / 2),
                                    ),
                                    chatImages.length > 1
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                bottom: chatImages.length > 2
                                                    ? 5
                                                    : 0),
                                            child: chatImagesWidget(
                                                chatImages[1], width / 2))
                                        : Container(height: 0, width: 0),
                                    chatImages.length > 2
                                        ? Container(
                                            child: chatImagesWidget(
                                                chatImages[2], width / 2))
                                        : Container(height: 0, width: 0),
                                  ]),
                                )
                              : Container(height: 0, width: 0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin:EdgeInsets.only(top:chatImages.isNotEmpty?3:0, left:chatImages.isNotEmpty?3:0),
                              constraints: BoxConstraints(
                                  maxWidth: chatImages.isNotEmpty
                                      ? width / 2
                                      :  (width * 0.75) ),
                              child: Text(snap.data[index].data()['message'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(margin:EdgeInsets.only(left:10),
                                child: Text(day + " " + time,
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 10))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingWidget() {
    return Column(children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Shimmer.fromColors(
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF333333)),
                  height: width * 0.12,
                  width: width * 0.12,
                ),
                baseColor: Color(0xFF333333),
                highlightColor: Color(0xFF434343),
              )),
          Shimmer.fromColors(
              baseColor: Color(0xFF333333),
              highlightColor: Color(0xFF434343),
              enabled: true,
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Container(
                    width: width / 3,
                    height: 30,
                  ),
                ),
              ))
        ]),
      ),
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Shimmer.fromColors(
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF333333)),
                  height: width * 0.12,
                  width: width * 0.12,
                ),
                baseColor: Color(0xFF333333),
                highlightColor: Color(0xFF434343),
              )),
          Shimmer.fromColors(
              baseColor: Color(0xFF333333),
              highlightColor: Color(0xFF434343),
              enabled: true,
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Container(
                    width: width / 2,
                    height: 50,
                  ),
                ),
              ))
        ]),
      ),
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Shimmer.fromColors(
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF333333)),
                  height: width * 0.12,
                  width: width * 0.12,
                ),
                baseColor: Color(0xFF333333),
                highlightColor: Color(0xFF434343),
              )),
          Shimmer.fromColors(
              baseColor: Color(0xFF333333),
              highlightColor: Color(0xFF434343),
              enabled: true,
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Container(
                    width: width / 4,
                    height: 30,
                  ),
                ),
              ))
        ]),
      ),
      Container(
        width: width,
        alignment: Alignment.centerRight,
        margin: EdgeInsets.only(top: 10, right: 5),
        child: Shimmer.fromColors(
            baseColor: Color(0xFF333333),
            highlightColor: Color(0xFF434343),
            enabled: true,
            child: Container(
              margin: EdgeInsets.only(left: 5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Color(0xFF333333),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Container(
                  width: width / 2,
                  height: 40,
                ),
              ),
            )),
      ),
      Container(
        width: width,
        margin: EdgeInsets.only(top: 10, right: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Shimmer.fromColors(
            enabled: true,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                  height: width / 4,
                  width: width / 4,
                  color: Color(0xFF282828)),
            ),
            baseColor: Color(0xFF282828),
            highlightColor: Color(0xFF383838),
          ),
          Shimmer.fromColors(
            enabled: true,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                  height: width / 4,
                  width: width / 4,
                  color: Color(0xFF282828)),
            ),
            baseColor: Color(0xFF282828),
            highlightColor: Color(0xFF383838),
          )
        ]),
      ),
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Shimmer.fromColors(
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF333333)),
                  height: width * 0.12,
                  width: width * 0.12,
                ),
                baseColor: Color(0xFF333333),
                highlightColor: Color(0xFF434343),
              )),
          Shimmer.fromColors(
              baseColor: Color(0xFF333333),
              highlightColor: Color(0xFF434343),
              enabled: true,
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Container(
                    width: width / 2,
                    height: 50,
                  ),
                ),
              ))
        ]),
      ),
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Shimmer.fromColors(
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF333333)),
                  height: width * 0.12,
                  width: width * 0.12,
                ),
                baseColor: Color(0xFF333333),
                highlightColor: Color(0xFF434343),
              )),
          Shimmer.fromColors(
              baseColor: Color(0xFF333333),
              highlightColor: Color(0xFF434343),
              enabled: true,
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Container(
                    width: width / 4,
                    height: 30,
                  ),
                ),
              ))
        ]),
      ),
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Shimmer.fromColors(
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF333333)),
                  height: width * 0.12,
                  width: width * 0.12,
                ),
                baseColor: Color(0xFF333333),
                highlightColor: Color(0xFF434343),
              )),
          Shimmer.fromColors(
            enabled: true,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                  margin: EdgeInsets.only(left: 5),
                  height: width / 4,
                  width: width / 4,
                  color: Color(0xFF282828)),
            ),
            baseColor: Color(0xFF282828),
            highlightColor: Color(0xFF383838),
          ),
          Shimmer.fromColors(
            enabled: true,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                  height: width / 4,
                  width: width / 4,
                  color: Color(0xFF282828)),
            ),
            baseColor: Color(0xFF282828),
            highlightColor: Color(0xFF383838),
          ),
          Shimmer.fromColors(
            enabled: true,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                  height: width / 4,
                  width: width / 4,
                  color: Color(0xFF282828)),
            ),
            baseColor: Color(0xFF282828),
            highlightColor: Color(0xFF383838),
          )
        ]),
      ),
    ]);
  }
}

class ChatArrow extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color =Color.fromRGBO(99, 155, 173,1);
    var path = Path();
    path.lineTo(0, 15);
    path.lineTo(-10, 18);
    path.lineTo(0, 21);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ChatArrowRight extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color(0xFF333333);
    var path = Path();
    path.lineTo(0, 3);
    path.lineTo(10, 0);
    path.lineTo(0, -3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
