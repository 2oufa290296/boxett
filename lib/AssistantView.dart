import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:boxet/classes/AssistantClass.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'GiftPage.dart';

class AssistantView extends StatefulWidget {
  final listId;

  AssistantView(this.listId);

  @override
  _AssistantViewState createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  List<AssistantClass> imagesList = [];
  double width, height;
  Map<dynamic, dynamic> giftsMap;
  bool showProgressBar = true;
  bool internetError = false;
  List<_GiftsList> giftsList = [];
  double scrollOffsetY = 0.0;
  double topFirst = 30.0;
  double topSecond;

  

  Future _loadData() async {
    await FirebaseFirestore.instance
        .collection('AssistanceList')
        .doc(widget.listId)
        .get()
        .then((results) async {
      if (results.exists) {
        giftsMap = results.data()['gifts'];
        giftsMap.forEach((k, v) {
          imagesList.add(AssistantClass(v, k));
        });

       

        if (mounted) {
          setState(() {
            showProgressBar = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            internetError = true;
            showProgressBar = false;
          });
        }
      }
    });
  }

  

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    topSecond = height / 4;

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
                      child: Text('Boxet Assistant',
                          style: TextStyle(color: Colors.white, fontSize: 20,fontFamily:"Lobster",letterSpacing:1)))
                ]),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                   Color.fromRGBO(18,42,76,1),
                    Color.fromRGBO(5,150,197,1),
                    Color.fromRGBO(18,42,76,1),
                  ],
                ))),
            preferredSize: Size(width, 50)),
        body: Container(height:height-30, margin: EdgeInsets.only(left: 3, right: 3, ),child: AnimationLimiter(
                          child: ListView.builder(padding: EdgeInsets.only(top:3,bottom:10),
                              itemCount: imagesList.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 100.0,
                                      child: FadeInAnimation(
                                        child: displayCardItem(imagesList[index]),
                                      ),
                                    ));
                              }),
                        )),
      ),
    );
  }

   Widget displayCardItem(AssistantClass content) {
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
                      builder: (context) => new GiftPage(content.giftId)))
              ;
        },
        child: Container(
          width: width,
          height: height / 4,
          constraints: BoxConstraints(minHeight: 170),
          
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: content.img,
                fit: BoxFit.cover,
                height: height / 4,
                width: width,
                progressIndicatorBuilder: (context, url, progress) {
                  return Shimmer.fromColors(
                    enabled: true,
                    child: Container(
                        height: height / 4,
                        width: width,
                          color: Color(0xFF282828)),
                    baseColor: Color(0xFF282828),
                    highlightColor: Color(0xFF383838),
                  );
                },
              ),
              
              
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftsList {
  final String img, id;

  _GiftsList(this.img, this.id);
}
