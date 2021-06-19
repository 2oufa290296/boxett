import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:boxet/GiftPage.dart';
import 'package:boxet/PageActivity.dart';
import 'package:boxet/classes/Gifts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'classes/PriceDecoration.dart';

class FavPage extends StatefulWidget {
  FavPage();
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  SharedPreferences sharedPreferences;
  List<String> favIdList = [];
  List<Gifts> favList = [];
  String userId = '';
  bool showLoading = true;
  bool empty = false;
  double height, width;
  bool internetError = false;
  bool retrying = false;

  @override
  void initState() {
    super.initState();
    _getFavIdList();
  }

  _refresh() async {
    if (mounted) {
      setState(() {
        if (favList != null) {
          favList.clear();
        }
        if (favIdList != null) {
          favIdList.clear();
        }
        setState(() {
          showLoading = true;
        });
        _getFavIdList();
      });
    }
  }

  // Future _getUserId() async {
  //   sharedPreferences = await SharedPreferences.getInstance();
  //   userId = sharedPreferences.getString('userid');

  //   if (userId != '' && userId != null) {
  //     _getFavList();
  //   } else {
  //     _getFavIdList();
  //   }
  // }

  Future _getFavIdList() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      sharedPreferences = await SharedPreferences.getInstance();
      favIdList = sharedPreferences.getStringList('favorite');
      if(favIdList!=null){
List revList = favIdList.reversed.toList();
print(favIdList);
      if (favIdList != null && favIdList.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Gifts')
            .where(FieldPath.documentId, whereIn: revList)
            .get()
            .then((results) async {
          if (results.docs.isNotEmpty) {
            favList.length = favIdList.length;
            results.docs.forEach((v) {
              print(revList.indexOf(v.id));
              favList[revList.indexOf(v.id)] = new Gifts(
                  v.data()['img'],
                  v.data()['name'],
                  v.data()['price'],
                  v.data()['page'],
                  v.id,
                  v.data()['pageid'],v.data()['discount']);
            });

            if (mounted) {
              setState(() {
                showLoading = false;
                internetError = false;
                retrying = false;
              });
            }
          } else {
            setState(() {
              internetError = true;
              showLoading = false;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            empty = true;
            showLoading = false;
          });
        }
      }
      }else{
        if (mounted) {
          setState(() {
            empty = true;
            showLoading = false;
          });
        }
      }
      
    } else {
      setState(() {
        setState(() {
          internetError = true;
          showLoading = false;
          retrying = false;
        });
      });
    }
  }

  // Future _getFavList() async {
  //   await Firestore.instance
  //       .collection('Users')
  //       .document(userId)
  //       .collection('favorites')
  //       .orderBy('date', descending: true)
  //       .getDocuments()
  //       .then((results) {
  //     if (results != null && results.documents.isNotEmpty) {
  //       results.documents.forEach((v) {
  //         favList.add(new Gifts(v['img'], v['name'], v['price'], v['page'],
  //             FieldPath.documentId.toString(), v['pageid']));
  //       });
  //       if (mounted) {
  //         setState(() {
  //           empty = false;
  //           showLoading = false;
  //         });
  //       }
  //     } else {
  //       if (mounted) {
  //         setState(() {
  //           empty = true;
  //           showLoading = false;
  //         });
  //       }
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          child: Container(
              height: 50,
             
              child: Container(
                
                
                alignment: Alignment.center,
                child: Text('Favorites',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "Lobster",
                        letterSpacing: 2)),
              ),
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
      body: empty
          ? Container(
            height: height-150,
            width:width,alignment:Alignment.center,
              child: Text(
          'Your Favorite List is Empty',
          style: TextStyle(color: Colors.white70, fontSize: 18,),
            ))
          : internetError
              ? Container(
                  height: height-160,
                  width: width,
                  child: Column(
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
                              margin: EdgeInsets.only(top: 20),
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
                                _getFavIdList();
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
                  
                  
                  
                )
              :  showLoading
                      ? Container(height:height-150,
                 
                  child: Center(child:  Container(
                    width: 50,
                    height: 50,
                    child: FlareActor(
                      'assets/loading.flr',
                      animation: 'Loading',
                    ))))
                      :Container(height:height-30, margin: EdgeInsets.only(left: 3, right: 3, ),child: AnimationLimiter(
                          child: ListView.builder(padding: EdgeInsets.only(top:5,bottom:50),
                              itemCount: favList.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 100.0,
                                      child: FadeInAnimation(
                                        child: displayCardItem(favList[index]),
                                      ),
                                    ));
                              }),
                        )),
    );
  }

  Widget displayCardItem(Gifts content) {
    return Card(
      color: Color.fromRGBO(65, 67, 66, 1.0),
      margin: EdgeInsets.only(bottom: 5, right: 2, left: 2),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new GiftPage(content.id)))
              .then((retVal) {
            if (retVal != null && retVal == true) {
              _refresh();
            }
          });
        },
        child: Container(
          width: width,
          height:200,
          
          foregroundDecoration: content.discount!=null && content.discount.isNotEmpty?PriceDecoration(
            badgeColor: Color.fromRGBO(5, 150, 197, 1),
            badgeSize: 60,
            textSpan: TextSpan(
              children: <TextSpan>[
                
                TextSpan(
                  text: content.discount,
                  style: TextStyle(
                      color: Colors.white, fontFamily: "Lobster", fontSize: 18),
                )
              ],
            ),
          ):null,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: content.image,
                fit: BoxFit.cover,
                height: 200,
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
              Positioned(
                  left: 5,
                  top: 5,
                  child: Card(
                    color: Colors.black38,
                    shape: CircleBorder(),
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new PageActivity(
                                    content.pageId, 'product')));
                      },
                      child: Card(
                          margin: EdgeInsets.all(0),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width / 15)),
                          color: Color.fromRGBO(65, 67, 66, 1.0),
                          child: CachedNetworkImage(
                            imageUrl: content.page,
                            height: height / 15,
                            width: height / 15,
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
                          )),
                    ),
                  )),
              Positioned(
                              bottom: 15,right:0,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.6),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        bottomLeft: Radius.circular(5))),
                                padding: EdgeInsets.only(
                                    top: 3, bottom: 3, right: 20,left:20),
                                child: Container(
                                    child: Row(
                                      children: [
                                        Text(content.price.toString(),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontFamily: "Lobster")),Text(' LE',style:TextStyle(fontSize:18,color:Colors.white,fontWeight:FontWeight.bold))
                                      ],
                                    )),
                              )),
            ],
          ),
        ),
      ),
    );
  }
}
