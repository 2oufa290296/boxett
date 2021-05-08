import 'package:flutter/material.dart';

class BreathingButton2 extends StatefulWidget {
  final String categImg;
  BreathingButton2(this.categImg);

  @override
  _BreathingButtonState2 createState() => _BreathingButtonState2();
}

class _BreathingButtonState2 extends State<BreathingButton2>
    with TickerProviderStateMixin {
  AnimationController _breathingController;
  double _breathe = 0.0;
  

  @override
  void initState() {
    super.initState();

    
    _breathingController = new AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _breathingController.forward();
      }
    });

    _breathingController.addListener(() {
      setState(() {
        _breathe = _breathingController.value;
      });
    });

    _breathingController.forward();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.categImg == 'assets/images/kids.png'
        ? (50.0 - 5.0 * _breathe)
        : widget.categImg == 'assets/images/mom.png'
            ? (60.0 - 5.0 * _breathe)
            :widget.categImg == 'assets/images/male.png'
            ? (60.0 - 5.0 * _breathe)
            :widget.categImg == 'assets/images/female.png'
            ? (60.0 - 5.0 * _breathe)
            :widget.categImg == 'assets/images/heart.png'
            ? (60.0 - 5.0 * _breathe)
            : (70.0 - 5.0 * _breathe);
    
    return Center(
      child: Container(
        margin: EdgeInsets.only(left:widget.categImg == 'assets/images/kids.png'?5:0),
          color: Colors.transparent,
          width: size,
          height: size,
          child: Center(
              child: Image.asset(
            widget.categImg != "" && widget.categImg != null
                  ? widget.categImg
                  : 'assets/images/qqq.png',
            fit: BoxFit.fitWidth,
          ))
          // Transform.rotate(
          //   angle: 45 / 360 * pi * 2,
          //   child: Container(
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(size / 3),
          //         gradient: LinearGradient(
          //             begin: Alignment.centerLeft,
          //             end: Alignment.centerRight,
          //             colors: [Colors.transparent, Colors.transparent])),
          //     child: Transform.rotate(
          //         angle: 315 / 360 * pi * 2,
          //         child: Center(
          //           child: Image.asset('assets/images/qqq.png',fit: BoxFit.fitWidth,)
          //           // Icon(
          //           //   Icons.clear,
          //           //   size: widget.shown?size - 20:0,
          //           //   color: Colors.grey[300],
          //           // ),
          //         )),
          //   ),
          // ),
          ),
    );
  }

  
}
