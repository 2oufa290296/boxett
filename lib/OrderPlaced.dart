import 'package:flutter/material.dart';

class OrderPlaced extends StatefulWidget {
  @override
  _OrderPlacedState createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced>
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
              height: height * 0.4,
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
                  Container(height: 15),
                  Center(
                    child: Text(
                      'Your order has been placed!',
                      style: TextStyle(
                        color: Colors.white,
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
                bottom: 20,
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
                    Navigator.pushReplacementNamed(
                      context,
                      '/homePage',
                    );
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0,right:8.0),
                      child: Text('Return Home',
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
