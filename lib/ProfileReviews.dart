import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:boxet/ShowReview.dart';
import 'package:boxet/classes/EditReviews.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProfileReviews extends StatefulWidget {
  @override
  _ProfileReviewsState createState() => _ProfileReviewsState();
}

class _ProfileReviewsState extends State<ProfileReviews> {
  String userId;
  SharedPreferences sharedPref;
  bool showProgressBar = true;
  List<EditReviews> reviewsList = [];
  double height, width;
  bool emptyRev=false;

  Future getReviews() async {
    sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('uid');
    
    if (userId != null && userId != "") {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Reviews')
          .get()
          .then((onValue) {
        if (onValue.docs.isNotEmpty) {
          onValue.docs.forEach((v) {
            num abc = v.data()['totalrate'];
            num onTimee = v.data()['ontime'];
            num gdPack = v.data()['goodpackaging'];
            num materialQuality = v.data()['materialquality'];
            num worthPrice = v.data()['worthprice'];
            reviewsList.add(new EditReviews(
                v.data()['giftid'],
                v.data()['giftimg'],
                v.data()['review'],
                abc is double ? abc : abc.toDouble(),
                onTimee != null && onTimee is double
                    ? onTimee
                    : onTimee == null ? 0 : onTimee.toDouble(),
                gdPack != null && gdPack is double
                    ? gdPack
                    : gdPack == null ? 0 : gdPack.toDouble(),
                materialQuality != null && materialQuality is double
                    ? materialQuality
                    : materialQuality == null ? 0 : materialQuality.toDouble(),
                worthPrice != null && worthPrice is double
                    ? worthPrice
                    : worthPrice == null ? 0 : worthPrice.toDouble(),
                v.id));
          });
        }else {
          setState((){
            emptyRev=true;
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
    getReviews();
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
                      child: Text('Your Reviews',
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
        body: showProgressBar
            ? Center(child:  Container(
                      width: 50,
                      height: 50,
                      child: FlareActor(
                        'assets/loading.flr',
                        animation: 'Loading',
                      ))):
            emptyRev?Container(alignment:Alignment.center,height:height-100,
                    child: Text("You haven't reviewed any gift yet",textAlign: TextAlign.center,style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                     ),),
                  ): Container(
                child: ListView.builder(
                    itemCount: reviewsList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation:5,
                        margin: EdgeInsets.only(
                            top: 5, right: 0.01 * width, left: 0.01 * width),
                        color: Color(0xFF181818),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new ShowReview(
                                        reviewsList[index].orderId,
                                        reviewsList[index].profilepic,
                                        reviewsList[index].giftId,
                                        reviewsList[index].onTime,
                                        reviewsList[index].goodPackaging,
                                        reviewsList[index].materialQuality,
                                        reviewsList[index].worthPrice,
                                        reviewsList[index].review)));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                top: 5, bottom: 5, left: 5, right: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Card(color:Colors.transparent,
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    width: width * 0.2,
                                    height: width * 0.2,
                                    child: CachedNetworkImage(
                                      imageUrl: reviewsList[index].profilepic,
                                      fit: BoxFit.cover,
                                      height: width * 0.2,
                                      width: width * 0.2,
                                      progressIndicatorBuilder:
                                          (context, url, progress) {
                                        return Shimmer.fromColors(
                                          enabled: true,
                                          child: Container(
                                              height: width * 0.2,
                                              width: width * 0.2,
                                              color: Color(0xFF282828)),
                                          baseColor: Color(0xFF282828),
                                          highlightColor: Color(0xFF383838),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(left: 5, top: 5),
                                        child: Row(
                                          
                                          children: <Widget>[
                                            Container(
                                              child: SmoothStarRating(
                                                allowHalfRating: true,
                                                starCount: 5,
                                                rating: reviewsList[index].rate,
                                                size: 18,
                                                spacing: 2,
                                                isReadOnly: true,
                                                defaultIconData: Icons.star,
                                                borderColor: Color(0xFF484848),
                                                color: Colors.yellow[700],
                                              ),
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(left: 5),
                                                child: Text('( ',
                                                    style: TextStyle(
                                                        color: Colors.white70))),
                                            Text(
                                                reviewsList[index]
                                                    .rate
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            Text(' )',
                                                style: TextStyle(
                                                    color: Colors.white70))
                                          ],
                                        ),
                                      ),
                                      Container(
                                          width: 0.75 * width,
                                          padding: EdgeInsets.only(
                                              left: 10,
                                              top: 5,
                                              right: 10,
                                              bottom: 5),
                                          child: Text(reviewsList[index].review,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
      ),
    );
  }
}
