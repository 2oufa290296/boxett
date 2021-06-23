import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TestDropdown extends StatefulWidget {
  final Function changeIcon;

  TestDropdown({Key key, @required this.changeIcon}) : super(key: key);

  @override
  TestDropdownState createState() => TestDropdownState();
}

class TestDropdownState extends State<TestDropdown>
    with TickerProviderStateMixin {
  bool opened = false;
  bool openedd = false;
  AnimationController rotatingController;
  Animation<double> _rotatingAnimation;
  Color firstItem = Colors.transparent;
  Color secondItem = Colors.transparent;
  Color thirdItem = Colors.transparent;
  Color forthItem = Colors.transparent;
  Color fifthItem = Colors.transparent;
  double width, height;
  IconData mainIcon = Icons.restaurant_menu;
  Key menuIconKey;
  bool clicked = false;
  // List<Color> colorsList = [Colors.transparent, Colors.transparent];
  Color backgroundColor = Colors.transparent;
  bool shadow = false;

  void openMenu() {
    shadow = true;
    Future.delayed(Duration(milliseconds: 300), () {
      rotatingController.forward();
      
      
    });

    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        if (!openedd) openedd = true;
      });
    });
    setState(() {
      if (!opened) opened = true;
      if (firstItem != Colors.white70) {
        firstItem = Colors.white70;
        secondItem = Colors.white70;
        thirdItem = Colors.white70;
        backgroundColor = Color(0xFF282828);
      }
    });
  }

  void closeMenu() {
    shadow = false;
    rotatingController.reverse();
    
    setState(() {
      if (openedd) openedd = false;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        if (opened) opened = false;
      });
    });

    Future.delayed(Duration(milliseconds: 700), () {
      setState(() {
        if (firstItem != Colors.transparent) {
          firstItem = Colors.transparent;
          secondItem = Colors.transparent;
          thirdItem = Colors.transparent;

          backgroundColor = Colors.transparent;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    rotatingController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
        lowerBound: 0,
        upperBound: 1);
    _rotatingAnimation = CurvedAnimation(
        parent: rotatingController, curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    rotatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        // Container(width:width,height:height,color:Colors.black38),
        shadow
            ? GestureDetector(
                onTap: () {}, child: Container(color: Colors.black38))
            : Container(height: 0, width: 0),
        AnimatedPositioned(
          duration: Duration(milliseconds: 400),
          left: width - 70,
          top: opened ? 100 : 60,
          child: _buildIcon(
              Icon(
                MdiIcons.gift,
                color: firstItem,
              ),
              backgroundColor,
              70,
              'Gifts'),
        ),

        AnimatedPositioned(
          duration: Duration(milliseconds: 450),
          left: width - 70,
          top: opened ? 150 : 60,
          child: _buildIcon(
              Icon(
                Icons.calendar_today,
                color: secondItem,
              ),
              backgroundColor,
              70,
              'Occasion'),
        ),

        AnimatedPositioned(
          duration: Duration(milliseconds: 500),
          left: width - 70,
          top: opened ? 200 : 60,
          child: _buildIcon(
              Icon(
                Icons.store_mall_directory,
                color: thirdItem,
              ),
              backgroundColor,
              70,
              'GiftShop'),
        ),
      ],
    );
  }

  Widget _buildIcon(Icon icon, Color color, double textWidth, String text) {
    return Row(
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              top: 10,
              right: 40,
              child: AnimatedContainer(
                  decoration: BoxDecoration(
                      color: backgroundColor,
                      // gradient: LinearGradient(
                      //     begin: Alignment.centerRight,
                      //     end: Alignment.centerLeft,
                      //     colors: colorsList),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15))),
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease,
                  width: openedd ? textWidth + 15 : 0,
                  height: 20,
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.only(top: 2, right: 3, left: 10),
                    child: Text(text,
                        style: TextStyle(
                            color:
                                openedd ? Colors.white70 : Colors.transparent)),
                  )),
            ),
            Positioned(
              child: AnimatedSwitcher(
                duration: Duration(
                  milliseconds: 500,
                ),
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                ) {
                  return RotationTransition(
                    child: child,
                    turns: ReverseAnimation(_rotatingAnimation),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: backgroundColor
                        // gradient: LinearGradient(
                        //     begin: Alignment.centerLeft,
                        //     end: Alignment.centerRight,
                        //     colors: colorsList),
                        ),
                    child: Center(
                      child: InkWell(
                          key: UniqueKey(),
                          onTap: () {
                            if (!clicked) {
                              shadow = false;
                              rotatingController.reverse();
                              
                              setState(() {
                                if (openedd) openedd = false;
                              });

                              Future.delayed(Duration(milliseconds: 400), () {
                                widget.changeIcon(icon.icon);
                              });
                              Future.delayed(Duration(milliseconds: 500), () {
                                setState(() {
                                  if (opened) opened = false;
                                });
                              });

                              Future.delayed(Duration(milliseconds: 700), () {
                                setState(() {
                                  if (firstItem != Colors.transparent) {
                                    firstItem = Colors.transparent;
                                    secondItem = Colors.transparent;
                                    thirdItem = Colors.transparent;

                                    backgroundColor = Colors.transparent;
                                  }
                                });
                              });
                            }
                          },
                          child: icon),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
