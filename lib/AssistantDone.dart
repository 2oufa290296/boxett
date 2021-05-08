import 'package:flutter/material.dart';

class AssistantDone extends StatefulWidget {
  @override
  _AssistantDoneState createState() => _AssistantDoneState();
}

class _AssistantDoneState extends State<AssistantDone>
    with SingleTickerProviderStateMixin {
  double width, height;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
        Future.delayed(Duration(milliseconds:200),(){_controller.forward();});
  }

  @override
  void dispose() {
   
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
             
              width: width,
              child: Column(
                children: <Widget>[
                  Center(
                      child: ScaleTransition(alignment: Alignment.center,
                    scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                        curve: Curves.elasticOut, parent: _controller)),
                    child: Container(
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50,
                        )),
                  )),
                  Center(
                    child: Text('Thank you!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: "Lobster",
                          letterSpacing: 3,
                        )),
                  ),
                  SizedBox(height: 20),
                  Container(width:width*0.9,alignment:Alignment.center,
                    child: Text(
                      'We have received your request',textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(width:width*0.9,alignment: Alignment.center,
                    child: Text(
                      'We will send you a list of the most suitable gifts for you in few hours.',textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                bottom: 30,
              ),
              
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                    Color.fromRGBO(18,42,76,1),
                          Color.fromRGBO(5,150,197,1),
                          Color.fromRGBO(18,42,76,1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding:EdgeInsets.only(left:10,right:10),
                    child: Center(
                      child: Text('Return To Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
