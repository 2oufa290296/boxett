import 'package:boxet/SigningOut.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:boxet/AddAddress.dart';
import 'package:boxet/Chat.dart';
import 'package:boxet/CustomDialog.dart';
import 'package:boxet/NotificationActivity.dart';
import 'package:boxet/ProfileReviews.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

GlobalKey<CustomDialogState> profileCustomKey = GlobalKey();

class RoundedAppBar extends StatefulWidget {
  final String imgUrl;
  final String username;
  final String gender;
  final String provider;
  final String uid;

  RoundedAppBar(
      this.imgUrl, this.username, this.gender, this.provider, this.uid);
  @override
  _RoundedAppBarState createState() => _RoundedAppBarState();
}

class _RoundedAppBarState extends State<RoundedAppBar> {
  double height;
  double widthh;

  SharedPreferences sharedPref;
  bool firsttime = true;
  bool signingOut = false;

  @override
  void initState() {
    super.initState();
    getSharedPref();
  }

  getSharedPref() async {
    sharedPref = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    widthh = MediaQuery.of(context).size.width;

    return new SizedBox.fromSize(
      size: preferedsize,
      child: new LayoutBuilder(builder: (context, constraint) {
        final width = constraint.maxWidth * 4;

        return new ClipRect(
          child: Stack(
            children: <Widget>[
              Container(
                child: new OverflowBox(
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  child: new SizedBox(
                    width: width,
                    height: width,
                    child: new Padding(
                      padding: EdgeInsets.only(
                          bottom: width / 2 - preferedsize.height / 5),
                      child: new DecoratedBox(
                        decoration: new BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Color.fromRGBO(5, 150, 197, 1),
                                Color.fromRGBO(18, 42, 76, 1),
                              ],
                              center: Alignment.center,
                              radius: 0.8,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              new BoxShadow(
                                  color: Colors.black54, blurRadius: 10.0)
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 50,
                  right: 20,
                  child: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>SigningOut(
                                key: profileCustomKey));
                      },
                      child: Icon(MdiIcons.logout,
                          color: Colors.white, size: 25))),
              Positioned(
                  left: widthh * 0.05,
                  top: height * 0.12,
                  child: Row(children: <Widget>[
                    Card(
                        color: Colors.white,
                        shape: CircleBorder(
                            side: BorderSide(color: Colors.white, width: 1)),
                        elevation: 4,
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xFF282828)),
                          height: height * 0.08,
                          width: height * 0.08,
                          child: widget.provider == "phone" &&
                                  widget.gender != null &&
                                  widget.gender != ""
                              ? CircleAvatar(
                                  radius: (height * 0.08) / 2,
                                  backgroundColor: Color(0xFF282828),
                                  backgroundImage: widget.gender == 'male'
                                      ? AssetImage('assets/images/profile.png')
                                      : AssetImage(
                                          'assets/images/profilef.png'),
                                )
                              : widget.imgUrl == "" || widget.imgUrl == null
                                  ? Shimmer.fromColors(
                                      enabled: true,
                                      child: Container(
                                        color: Color(0xFF282828),
                                      ),
                                      baseColor: Color(0xFF282828),
                                      highlightColor:
                                          Color.fromRGBO(75, 77, 76, 1.0),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: widget.imgUrl,
                                      height: (height * 0.08),
                                      width: (height * 0.08),
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
                                          baseColor: Color(0xFF282828),
                                          highlightColor: Color(0xFF383838),
                                        );
                                      },
                                    ),
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(widget.username,
                          style: TextStyle(
                              color: Colors.grey[50],
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    )
                  ])),
              Positioned(
                left: widthh * 0.05,
                top: height * 0.23,
                child: Container(
                    width: widthh * 0.90,
                    child: Card(
                        color: Color(0xFF232323),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                constraints: BoxConstraints(minHeight: 65),
                                width: widthh * (0.2),
                                height: height * 0.09,
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      clipBehavior: Clip.antiAlias,
                                      shape: CircleBorder(),
                                      elevation: 3,
                                      color: Color.fromRGBO(3, 99, 130, 1),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      new Chat(widget.uid)));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(7),
                                          child: Icon(Icons.chat_bubble,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        'Contact Us',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                        overflow: TextOverflow.clip,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(minHeight: 65),
                                width: widthh * (0.2),
                                height: height * 0.09,
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      shape: CircleBorder(),
                                      clipBehavior: Clip.antiAlias,
                                      elevation: 3,
                                      color: Color.fromRGBO(3, 99, 130, 1),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      new ProfileReviews()));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(7),
                                          child: Icon(Icons.star,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        'Reviews',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(minHeight: 65),
                                width: widthh * (0.2),
                                height: height * 0.09,
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      shape: CircleBorder(),
                                      elevation: 3,
                                      clipBehavior: Clip.antiAlias,
                                      color: Color.fromRGBO(3, 99, 130, 1),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      new AddAddress()));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(7),
                                          child: Icon(Icons.home,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        'Address',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(minHeight: 65),
                                width: widthh * (0.2),
                                height: height * 0.09,
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                        clipBehavior: Clip.antiAlias,
                                        shape: CircleBorder(),
                                        elevation: 3,
                                        color: Color.fromRGBO(3, 99, 130, 1),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        new NotificationActivity()));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(7),
                                            child: Icon(Icons.notifications,
                                                color: Colors.white),
                                          ),
                                        )),
                                    Container(
                                      child: Text(
                                        'Notifications',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                        overflow: TextOverflow.clip,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))),
              ),
            ],
          ),
        );
      }),
    );
  }

  Size get preferedsize => Size.fromHeight(height * 0.45);
}
