import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:boxet/ChatPage.dart';
import 'package:boxet/JumpingDots.dart';
import 'package:boxet/classes/nav_button.dart';
import 'package:boxet/classes/nav_custom_painter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:meta/meta.dart';
import 'package:boxet/MenuItems.dart';

import 'MenuItems.dart';

class CustomNavBar extends StatefulWidget {
  final void Function(String category) reloadMain;
  // final void Function(bool openingCat) openingCat;
  final List<Widget> items;
  final int index;
  final Color color;
  final Color buttonBackgroundColor;
  final Color backgroundColor;
  final ValueChanged<int> onTap;
  final Curve animationCurve;
  final Duration animationDuration;
  final double height;
  final GlobalKey<ChatPageState> chatKey;

  CustomNavBar(
      {Key key,
      @required this.items,
      this.index,
      this.color = Colors.white,
      this.buttonBackgroundColor,
      this.backgroundColor = Colors.blueAccent,
      this.onTap,
      this.animationCurve = Curves.easeOut,
      this.animationDuration = const Duration(milliseconds: 600),
      this.height = 75.0,
      this.reloadMain,
      // this.openingCat,
      this.chatKey})
      : assert(items != null),
        assert(items.length >= 1),
        assert(0 <= index && index < items.length),
        assert(0 <= height && height <= 75.0),
        super(key: key);

  @override
  CustomNavBarState createState() => CustomNavBarState();
}

class CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  int indexxx = 2;
  double _startingPos;
  int _endingIndex = 0;
  double _pos;
  double _buttonHide = 0;
  Widget _icon;
  AnimationController _animationController;
  int _length;
  OverlayEntry entry;
  OverlayState overlayState;
  String categImg = 'default';
  bool opened = false;
  FlareControls flareContr;
  bool flareState = false;
  FlareActor flareAc;
  TextEditingController inputController;
  bool showw = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _icon = widget.items[widget.index];
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;

    flareContr = FlareControls();
    flareContr.isActive.addListener(() {
      flareState = flareContr.isActive.value;
      // widget.openingCat(flareContr.isActive.value);
    });
    overlayState = Overlay.of(context);
    inputController = new TextEditingController();
    entry = OverlayEntry(
        builder: (context) =>
            new MenuItems(entry, categImg, updateNavBar: (String selectedCat) {
              if (!flareState) {
                flareContr.play('fly');

                if (categImg != selectedCat) {
                  setState(() {
                    categImg = selectedCat;
                    widget.reloadMain(selectedCat);
                  });
                }
              }
            }, updateNavBarDelayed: (String selectedCat) {
              if (!flareState) {
                flareContr.play('fly');

                Future.delayed(Duration(milliseconds: 1400), () {
                  setState(() {
                    categImg = selectedCat;
                    widget.reloadMain(selectedCat);
                  });
                });
              }
            }));
    flareAc = FlareActor(
      'assets/zzz.flr',
      animation: 'Breathing',
      alignment: Alignment.center,
      fit: BoxFit.contain,
      controller: flareContr,
    );
    // flareContr.play(
    //   'Breathing',
    // );

    _animationController = AnimationController(vsync: this, value: _pos);
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex];
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index != 4 && showw == true) {
      setState(() {
        showw = false;
      });
    }

    if (widget.index == 2 && _pos != 0.4) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
      Future.delayed(Duration(milliseconds: 200), () {
        indexxx = 2;
      });
    }

    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    inputController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      color: widget.backgroundColor,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            bottom: 0 - (75.0 - widget.height),
            child: CustomPaint(
              painter: NavCustomPainter(_pos, _length, widget.color,
                  Directionality.of(context), size.width),
              child: Container(
                height: 75.0,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: indexxx == 4 ? size.width / _length : 0,
            bottom: showw && indexxx == 4 ? 0 : 0 - (75.0 - widget.height),
            child: showw && indexxx == 4
                ? SizedBox(
                    height: 60.0,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.only(
                                left: 10,
                              ),
                              child: TextField(
                                cursorColor: Colors.white70,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                                controller: inputController,
                                decoration: InputDecoration.collapsed(

                                    // focusedBorder: UnderlineInputBorder(borderSide:BorderSide(color:Colors.white70)),

                                    // enabledBorder: UnderlineInputBorder(
                                    //     borderSide:
                                    //         BorderSide(color: Colors.white70)),
                                    hintText: 'Type Your Message',
                                    hintStyle: TextStyle(
                                        color: Colors.white70, fontSize: 18)),
                              )),
                        ),
                        Container(
                            width: 45,
                            height: 45,
                            margin: EdgeInsets.only(
                              right: 10,
                            ),
                            child: InkWell(
                                onTap: () {
                                  widget.chatKey.currentState.giftOnTap();
                                },
                                child: Icon(
                                  MdiIcons.gift,
                                  color: Colors.white,
                                ))),
                      ],
                    ))
                : indexxx == 4
                    ? SizedBox(
                        height: 100.0, child: Center(child: JumpingDots()))
                    : SizedBox(
                        height: 100.0,
                        child: Row(
                            children: widget.items.map((item) {
                          return NavButton(
                            onTap: _buttonTap,
                            position: _pos,
                            length: _length,
                            index: widget.items.indexOf(item),
                            child: item,
                          );
                        }).toList())),
          ),
          Positioned.fill(
              bottom: -40 - (75.0 - widget.height),
              left: Directionality.of(context) == TextDirection.rtl
                  ? null
                  : _pos * size.width,
              right: Directionality.of(context) == TextDirection.rtl
                  ? _pos * size.width
                  : null,
              child: Container(
                width: size.width / _length,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      indexxx == 2
                          ? -(1 - _buttonHide) * 45
                          : indexxx == 4
                              ? -(1 - _buttonHide) * 35
                              : -(1 - _buttonHide) * 40,
                    ),
                    child: indexxx == 2
                        ? InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              // blinkController.forward();

                              if (!flareState) {
                                flareContr.play('fly');
                                Future.delayed(Duration(milliseconds: 400), () {
                                  overlayState.insert(entry);
                                });
                              }

                              // if (opened && !flareState) {
                              //   flareContr.play('CloseCover');
                              //   opened = false;
                              // } else if (!flareState) {
                              //   flareContr.play('OpenCover');
                              //   opened = true;
                              //   Future.delayed(Duration(milliseconds: 400), () {
                              //     overlayState.insert(entry);
                              //   });
                              // }
                            },
                            child: flareAc)
                        : indexxx == 4
                            ? Material(
                                color: widget.buttonBackgroundColor ??
                                    Color.fromRGBO(3, 99, 130, 1),
                                type: MaterialType.circle,
                                child: InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      widget.chatKey.currentState
                                          .sendMessages(inputController.text);
                                      inputController.clear();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0,
                                          right: 8.0,
                                          top: 8.0,
                                          bottom: 8.0),
                                      child:
                                          Icon(Icons.send, color: Colors.white),
                                    )),
                              )
                            : Material(
                                color: widget.buttonBackgroundColor ??
                                    Color.fromRGBO(3, 99, 130, 1),
                                type: MaterialType.circle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _icon,
                                ),
                              ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (widget.onTap != null) {
      widget.onTap(index);
    }
    categImg = 'default';
    indexxx = index;
    if (indexxx == 4) {
      if (inputController != null) {
        inputController.clear();
      }
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          showw = true;
        });
      });
    } else {
      setState(() {
        showw = false;
      });
    }

    final newPosition = index / _length;
    if (_auth.currentUser != null) {
      setState(() {
        _startingPos = _pos;
        _endingIndex = index;
        _animationController.animateTo(newPosition,
            duration: widget.animationDuration, curve: widget.animationCurve);
      });
    }
  }
}
