import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:boxet/JumpingDots.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Chat extends StatefulWidget {
  final String uid;

  Chat(this.uid);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  StreamController<List<DocumentSnapshot>> streamController =
      StreamController<List<DocumentSnapshot>>();
  List<DocumentSnapshot> chatList = [];
  bool requesting = false;
  StreamSubscription<QuerySnapshot> streamSubscription;
  bool showProgressBar = false;
  FirebaseFirestore db = FirebaseFirestore.instance;
  ScrollController scrollController;
  double width, height;
  TextEditingController inputController;
  bool typingg = false;
  int yourMessages = 0;
  int pageMessages = 0;
  Stream stream;

  void onChangedData(List<DocumentChange> documentChanges) {
    var isChanged = false;

    documentChanges.forEach((messageChange) {
      if (messageChange.type == DocumentChangeType.removed) {
        chatList.removeWhere((message) {
          return messageChange.doc.id == message.id;
        });
        isChanged = true;
      } else {
        if (messageChange.type == DocumentChangeType.modified) {
          int indexWhere = chatList.indexWhere((message) {
            return messageChange.doc.id == message.id;
          });

          if (indexWhere >= 0) {
            chatList[indexWhere] = messageChange.doc;
          }
          isChanged = true;
        } else if (messageChange.type == DocumentChangeType.added) {
          if (!chatList.contains(messageChange.doc) && chatList.isNotEmpty) {
            Timestamp newTime = messageChange.doc.data()['time'];
            Timestamp lastTime = chatList[0].data()['time'];
            if (newTime.compareTo(lastTime) >= 0) {
              chatList.insert(0, messageChange.doc);
              isChanged = true;
            }
          }
        }
      }
    });
    if (isChanged) {
      streamController.add(chatList);
    }
  }

  void requestNextMessages() async {
    if (!requesting) {
      QuerySnapshot querySnapshot;
      requesting = true;
      if (chatList.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('ContactUs')
            .doc(widget.uid)
            .collection('Messages')
            .orderBy('time', descending: true)
            .limit(20)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('ContactUs')
            .doc(widget.uid)
            .collection('Messages')
            .orderBy('time', descending: true)
            .startAfterDocument(chatList[chatList.length - 1])
            .limit(20)
            .get();
      }

      if (querySnapshot != null) {
        int oldSize = chatList.length;
        chatList.addAll(querySnapshot.docs);
        int newSize = chatList.length;
        if (oldSize != newSize) {
          streamController.add(chatList);
          requesting = false;
        } else if(chatList.isEmpty){
          streamController.add(chatList);
          Future.delayed(Duration(milliseconds: 1000), () {
            setState(() {
              typingg = true;
            });
          });

          Future.delayed(Duration(milliseconds: 2000), () async {
            await FirebaseFirestore.instance
                .collection('ContactUs')
                .doc(widget.uid)
                .collection('Messages')
                .add({
              'time': DateTime.now(),
              'message': 'Welcome to Boxet',
              'you': false,
              'seen': false
            }).then((value) async {
              value.get().then((value) {
                chatList.add(value);
                setState(() {
                  typingg = false;
                  requesting = false;
                });
              });

              Future.delayed(Duration(milliseconds: 1000), () async {
                setState(() {
                  typingg = true;
                });

                Future.delayed(Duration(milliseconds: 2000), () async {
                  await FirebaseFirestore.instance
                      .collection('ContactUs')
                      .doc(widget.uid)
                      .collection('Messages')
                      .add({
                    'time': DateTime.now(),
                    'message': 'How can we help you?',
                    'you': false,
                    'seen': false
                  }).then((value) {
                    setState(() {
                      typingg = false;
                    });
                  });
                });
              });
            });
          });
        }else {
          requesting = false;
        }
      }
    }
  }

  @override
  void initState() {
    inputController = new TextEditingController();
    inputController.addListener(() {
      if (inputController.text.isNotEmpty) {
        typing(true);
      } else {
        typing(false);
      }
    });
    scrollController = new ScrollController();
    streamSubscription = FirebaseFirestore.instance
        .collection('ContactUs')
        .doc(widget.uid)
        .collection('Messages')
        .snapshots()
        .listen((data) => onChangedData(data.docChanges));

    requestNextMessages();

    super.initState();
  }

  @override
  void dispose() {
    inputController.dispose();
    scrollController.dispose();
    streamController.close();
    streamSubscription.cancel();
    super.dispose();
  }

  typing(bool typing) async {
    if (typing) {
      await FirebaseFirestore.instance
          .collection('ContactUs')
          .doc(widget.uid)
          .set({'typingUser': true}, SetOptions(merge: true)).then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      await FirebaseFirestore.instance
          .collection('ContactUs')
          .doc(widget.uid)
          .set({'typingUser': false}, SetOptions(merge: true)).then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  // Stream _queryDB() {
  //   Query query = db
  //       .collection('ContactUs')
  //       .doc(widget.uid)
  //       .collection('Messages')
  //       .orderBy('time');
  //   return stream =
  //       query.snapshots().map((list) => list.docs.map((e) => e.data));
  // }

  seen(String id) async {
    await FirebaseFirestore.instance
        .collection('ContactUs')
        .doc(widget.uid)
        .collection('Messages')
        .doc(id)
        .set({'seen': true}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return SafeArea(
          child: Scaffold(
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
                      child: Text('Contact Us',
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
                    builder:
                        (context, AsyncSnapshot<List<DocumentSnapshot>> snap) {
                      // list = snap.data.toList();

                      print(snap.connectionState);
                      if (snap.hasError) {
                        return Center(
                            child: Text('Error: ${snap.error}',
                                style: TextStyle(color: Colors.white70)));
                      } else if (snap.connectionState ==
                          ConnectionState.waiting) {
                        return SingleChildScrollView(child: loadingWidget());
                      } else if (snap.data != null) {
                        return ListView.builder(
                          padding: EdgeInsets.only(bottom: 10),
                          shrinkWrap: true,
                          reverse: true,
                          controller: scrollController,
                          itemCount: snap.data.length,
                          itemBuilder: (context, index) {
                            DateTime now = DateTime.now();
                            Timestamp timeStamp = snap.data[index].data()["time"];
                            String day = "";
                            String time = "";
                            var formatter = new DateFormat('EEEE');
                            // pageMessages = items
                            //     .where((element) => element['you'] == false)
                            //     .toList()
                            //     .length;
                            // yourMessages = items.length - pageMessages;
                            var formatter2 = new DateFormat('HH:mm a');
                            time = formatter2.format(timeStamp.toDate());
                            if (now.difference(timeStamp.toDate()).inMinutes ==
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
                                0) {
                              time = formatter2.format(timeStamp.toDate());
                            } else if (now
                                    .difference(timeStamp.toDate())
                                    .inDays ==
                                1) {
                              day = "Yesterday";
                            } else if (now.difference(timeStamp.toDate()).inDays <
                                7) {
                              day = formatter.format(timeStamp.toDate());

                              time = formatter2.format(timeStamp.toDate());
                            } else {
                              var formatter = new DateFormat('dd/MM');

                              day = formatter.format(timeStamp.toDate()) + ' at';

                              time = formatter2.format(timeStamp.toDate());
                            }

                            if (!snap.data[index].data()['you']) {
                              if (snap.data[index].data()['seen'] == false) {
                                seen(snap.data[index].id);
                              }

                              return Column(
                                children: <Widget>[
                                  index == chatList.length - 1 &&
                                          chatList.isNotEmpty &&
                                          requesting
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
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white70),
                                              )),
                                        )
                                      : Container(height: 0, width: 0),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 10,
                                      left: 13,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        CustomPaint(painter: ChatArrow()),
                                        Container(
                                          constraints: BoxConstraints(maxWidth:width*0.7),
                                          decoration: BoxDecoration(
                                              color: Color.fromRGBO(99, 155, 173,1),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10))),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0,
                                                top: 5.0,
                                                bottom: 3.0,
                                                right: 8.0),
                                            child: IntrinsicWidth(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5),
                                                      child: Text(
                                                          snap.data[index]
                                                              .data()['message'],
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16)),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      margin:
                                                          EdgeInsets.only(top: 3),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: <Widget>[
                                                          Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                      bottom: 2),
                                                              child: Text(
                                                                  day +
                                                                      " " +
                                                                      time,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white70,
                                                                      fontSize:
                                                                          10))),
                                                        ],
                                                      ),
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
                              );
                            } else {
                              return Column(
                                children: <Widget>[
                                  index == chatList.length - 1 &&
                                          chatList.isNotEmpty &&
                                          requesting
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
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white70),
                                              )),
                                        )
                                      : Container(height: 0, width: 0),
                                  Container(
                                    margin: EdgeInsets.only(top: 10, right: 13),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Container(constraints: BoxConstraints(maxWidth:width*0.7),
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF333333),
                                                  borderRadius: BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10),
                                                      topLeft:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0,
                                                    top: 5.0,
                                                    right: 8,
                                                    bottom: 3.0),
                                                child: IntrinsicWidth(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Align(
                                                        alignment:
                                                            Alignment.centerLeft,
                                                        child: Container(
                                                          child: Text(
                                                              snap.data[index]
                                                                      .data()[
                                                                  'message'],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16)),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.centerRight,
                                                        child: Container(
                                                          margin: EdgeInsets.only(
                                                              left: 10, top: 3),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize.min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: <Widget>[
                                                              Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              3,
                                                                          bottom:
                                                                              2),
                                                                  child: Text(
                                                                      day +
                                                                          " " +
                                                                          time,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white70,
                                                                          fontSize:
                                                                              10))),
                                                              Container(
                                                                  height: 15,
                                                                  width: 20,
                                                                  child: Stack(
                                                                    children: <
                                                                        Widget>[
                                                                      Positioned(
                                                                        left: 0,
                                                                        top: 0,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              15,
                                                                          height:
                                                                              15,
                                                                          child:
                                                                              Icon(
                                                                            Icons
                                                                                .check,
                                                                            size:
                                                                                15,
                                                                            color: snap.data[index].data()['seen']
                                                                                ? Colors.blue[300]
                                                                                : Colors.white70,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        left: 7,
                                                                        top: 0,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              15,
                                                                          height:
                                                                              15,
                                                                          child:
                                                                              Icon(
                                                                            Icons
                                                                                .check,
                                                                            size:
                                                                                15,
                                                                            color: snap.data[index].data()['seen']
                                                                                ? Colors.blue[300]
                                                                                : Color(0xFF333333),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            CustomPaint(painter: ChatArrowRight())
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        );
                      } else {
                        return Center(
                            child: Container(
                                width: 50,
                                height: 50,
                                child: FlareActor(
                                  'assets/loading.flr',
                                  animation: 'Loading',
                                )));
                      }
                    }),
              ),
            ),
            typingg
                ? Container(
                    margin: EdgeInsets.only(left: 10, bottom: 5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Text('typing',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16)),
                        SizedBox(width: 2, height: 5),
                        JumpingDots(),
                      ],
                    ))
                : Container(height: 0, width: 0),
            StreamBuilder(
                stream: db.collection('ContactUs').doc(widget.uid).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.data() != null &&
                        snapshot.data.data()['typing'] == true) {
                      return Container(
                          margin: EdgeInsets.only(left: 10, bottom: 5),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Text('typing',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16)),
                              SizedBox(width: 2, height: 5),
                              JumpingDots(),
                            ],
                          ));
                    } else {
                      return Container(height: 0, width: 0);
                    }
                  } else {
                    return Container(height: 0, width: 0);
                  }
                }),
            Container(
              height: Platform.isIOS?60:50,
              width: width,
              padding:EdgeInsets.only(bottom:Platform.isIOS?10:0),
              color: Color(0xFF232323),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      width: width * 0.9 - 10,
                      padding: EdgeInsets.only(left: 20),
                      child: TextField(
                        cursorColor: Colors.white70,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        controller: inputController,
                        decoration: InputDecoration.collapsed(
                            hintText: 'Type Your Message',
                            hintStyle:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      )),
                  Container(
                      width: width * 0.1,
                      height: width * 0.1,
                      margin: EdgeInsets.only(right: 10),
                      child: InkWell(
                          onTap: () {
                            if (inputController.text != null &&
                                inputController.text.isNotEmpty)
                              _sendMessages(inputController.text);
                          },
                          child: Icon(
                            Icons.send,
                            color: Color.fromRGBO(3, 99, 130,1),
                          )))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _read() async {
  //   await db
  //       .collection('Users')
  //       .doc('abaka1231')
  //       .collection('Messages')
  //       .doc(widget.pageId)
  //       .set({'unread': 0}, SetOptions(merge: true));
  // }

  // _seen() async {
  //   await db
  //       .collection('Pages')
  //       .document(widget.pageId)
  //       .collection('Messages')
  //       .document('abaka1231')
  //       .setData({'notseen': 0}, merge: true);
  // }

  _sendMessages(String text) async {
    Timestamp timeStamp = Timestamp.fromDate(DateTime.now());
    // var formatter2 = new DateFormat('HH:mm a');
    // String time = formatter2.format(timeStamp.toDate());

    inputController.clear();

    await db
        .collection('ContactUs')
        .doc(widget.uid)
        .collection('Messages')
        .add({'message': text, 'time': timeStamp, 'you': true, 'seen': false});
    scrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    await db.collection('ContactUs').doc(widget.uid).set({
      'lastmessage': text,
      'time': timeStamp,
      'unread': 0,
    }, SetOptions(merge: true)).then((value) {
      // getMessages();
    });

    // await db
    //     .collection('Pages')
    //     .document(widget.pageId)
    //     .collection('Messages')
    //     .document('abaka1231')
    //     .collection('messages')
    //     .add({
    //   'message': text,
    //   'time': timeStamp,
    //   'you': true,
    // }).then((onValue) {
    //   db
    //       .collection('Pages')
    //       .document(widget.pageId)
    //       .collection('Messages')
    //       .document('abaka1231')
    //       .setData({'unread': FieldValue.increment(1)}, merge: true);

    // });
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
                  width: width * 0.6,
                  height: 30,
                ),
              ),
            )),
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
                  width: width * 0.4,
                  height: 50,
                ),
              ),
            )),
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
                  width: width * 0.6,
                  height: 30,
                ),
              ),
            )),
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
                    width: width * 0.4,
                    height: 40,
                  ),
                ),
              )),
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
                  width: width * 0.5,
                  height: 50,
                ),
              ),
            )),
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
                    width: width * 0.4,
                    height: 40,
                  ),
                ),
              )),
        ]),
      ),
    ]);
  }
}

class ChatArrow extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color.fromRGBO(99, 155, 173,1);
    var path = Path();
    path.lineTo(-10, 0);
    path.lineTo(0, -10);
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
    path.lineTo(10, 0);
    path.lineTo(0, -10);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
