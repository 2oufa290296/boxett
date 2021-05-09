import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:boxet/AssistantView.dart';
import 'package:boxet/GiftPage.dart';
import 'package:boxet/ProfileOrderState.dart';
import 'package:boxet/classes/NotificationsClass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class NotificationActivity extends StatefulWidget {
  @override
  _NotificationActivityState createState() => _NotificationActivityState();
}

class _NotificationActivityState extends State<NotificationActivity> {
  String userId;
  SharedPreferences sharedPref;
  bool showProgressBar = true;
  List<NotificationsClass> notificationList = [];
  double height, width;
  DateTime now = DateTime.now();
  bool emptyNot=false;

  Future getNotifications() async {
    sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('uid');

    if (userId != null && userId != "") {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Notifications')
          .get()
          .then((onValue) {
        if (onValue.docs.isNotEmpty) {
          onValue.docs.forEach((v) {
            String time = "";

            if (v.data()['time'] != null) {
              Timestamp timeStamp = v.data()['time'];
              if (now.difference(timeStamp.toDate()).inMinutes == 0) {
                time = 'Just now';
              } else if (now.difference(timeStamp.toDate()).inHours == 0) {
                time = now.difference(timeStamp.toDate()).inMinutes.toString() +
                    " mins ago";
              } else if (now.difference(timeStamp.toDate()).inDays == 0) {
                if (now.difference(timeStamp.toDate()).inHours == 1) {
                  time = "an hour ago";
                } else {
                  time = now.difference(timeStamp.toDate()).inHours.toString() +
                      " hours ago";
                }
              } else if (now.difference(timeStamp.toDate()).inDays == 1) {
                var formatterd = new DateFormat('hh:mm a');

                time = "Yesterday at " + formatterd.format(timeStamp.toDate());
              } else if (now.difference(timeStamp.toDate()).inDays < 7) {
                var formatter = new DateFormat('EEEE');
                var formatterd = new DateFormat('hh:mm a');

                time = formatter.format(timeStamp.toDate()) +
                    " at " +
                    formatterd.format(timeStamp.toDate());
              } else {
                var formatter = new DateFormat('MMMM d ');
                var formatterd = new DateFormat('hh:mm a');
                time = formatter.format(timeStamp.toDate()) +
                    "at " +
                    formatterd.format(timeStamp.toDate());
              }
            }

            if (v.data()['id'] != null &&
                
                v.data()['text'] != null &&
                v.data()['type'] != null && time.isNotEmpty)
                {
                  notificationList.add(new NotificationsClass(
                  v.data()['id'],
                  v.data()['profileimg'] != null?v.data()['profileimg']:'',
                  v.data()['name']!=null?v.data()['name']:'',
                  v.data()['text'],
                  v.data()['type'],
                  time));
                }
              
          });
        }else {
          setState((){
            emptyNot=true;
          });
        }
      });
    }

    setState(() {
      showProgressBar = false;
    });
  }

  @override
  void initState() {
    

    getNotifications();
    super.initState();
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
                        child: Text('Notifications',
                            style: TextStyle(color: Colors.white, fontSize: 20,fontFamily:"Lobster",letterSpacing:1)))
                  ]),
                  decoration: BoxDecoration(
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
          body: Container(
              child: showProgressBar
                  ? Center(child:  Container(
                      width: 50,
                      height: 50,
                      child: FlareActor(
                        'assets/loading.flr',
                        animation: 'Loading',
                      )))
                  :emptyNot?Container(alignment:Alignment.center,height:height-100,
                    child: Text("You haven't got any notification yet",textAlign: TextAlign.center,style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      ),),
                  ): ListView.builder(
                      itemCount: notificationList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 8,
                          margin: EdgeInsets.only(top: 5, right: 4, left: 4),
                          color: Color(0xff232323),
                          child: InkWell(
                            onTap: () {
                              if (notificationList[index].notType == "gift") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => new GiftPage(
                                            notificationList[index].notId)));
                              } else if (notificationList[index].notType ==
                                  "order") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            new ProfileOrderState(
                                                notificationList[index].notId,
                                                '',
                                                '',
                                                0,
                                                0,
                                                0,
                                                0,
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                null,
                                                '')));
                              } else if (notificationList[index].notType ==
                                  "list") {
                                    Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => new AssistantView(
                                            notificationList[index].notId)));
                                  }
                            },
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 10,
                                            right: 10),
                                        padding: EdgeInsets.all(0.5),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white),
                                        child: Card(
                                          margin: EdgeInsets.all(0),
                                          clipBehavior: Clip.antiAlias,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  0.8 * width)),
                                          child: notificationList[index].notPP == ""?Image.asset('assets/images/qqq.png',height: 0.15 * width,
                                            width: 0.15 * width,
                                            fit: BoxFit.cover,):CachedNetworkImage(
                                            imageUrl:
                                                notificationList[index].notPP,
                                            height: 0.15 * width,
                                            width: 0.15 * width,
                                            fit: BoxFit.cover,
                                            progressIndicatorBuilder:
                                                (context, url, progress) {
                                              return Shimmer.fromColors(
                                                enabled: true,
                                                child: Container(
                                                    height: 0.15 * width,
                                                    width: 0.15 * width,
                                                    color: Color.fromRGBO(
                                                        55, 57, 56, 1.0)),
                                                baseColor: Color(0xFF282828),
                                                highlightColor: Color(0xFF383838),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                              width: 0.7 * width,
                                              child: RichText(
                                                  text: new TextSpan(children: <
                                                      TextSpan>[
                                                new TextSpan(
                                                    text: notificationList[index]
                                                                .notName ==
                                                            ""
                                                        ? ""
                                                        : notificationList[index]
                                                                .notName +
                                                            " ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.white)),
                                                new TextSpan(
                                                    text: notificationList[index]
                                                        .notText,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white))
                                              ]))),
                                          Container(
                                              margin: EdgeInsets.only(top: 3),
                                              child: Text(
                                                notificationList[index].notDate,
                                                style:
                                                    TextStyle(color: Colors.grey),
                                              ))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ))),
    );
  }
}
