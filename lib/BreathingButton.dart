import 'package:flutter/material.dart';

class BreathingButton extends StatefulWidget {
  

  final bool shown;

  BreathingButton(this.shown);
  _BreathingButtonState createState() => _BreathingButtonState();
}

class _BreathingButtonState extends State<BreathingButton>
    with TickerProviderStateMixin {
  AnimationController _breathingController;
  AnimationController _angleController;
  double _breathe = 0.0;

  @override
  void initState() {
    super.initState();

    _angleController = new AnimationController(
        duration: Duration(milliseconds: 200), vsync: this);
    // _angleController.addListener(() {
    //   setState(() {
    //     // _angle = _angleController.value * 45 / 360 * 2 * pi;
    //   });
    // });
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
    _angleController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    final double size = 70.0 - 5.0 * _breathe;
    double width=MediaQuery.of(context).size.width;
    return AnimatedPositioned(curve: Curves.easeOut,
      duration: Duration(milliseconds: 300),
      bottom: widget.shown==true?10:-15,
      left: (width/2)-(size/2),
      child: InkWell(
        onTap: _onButtonTap,
        child: Center(
          child: Container(
            width: size,
            height: widget.shown?size:0,
            child: Center(
                      child: Image.asset('assets/images/qqq.png',fit: BoxFit.fitWidth,))
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
        ),
      ),
    );
  }

  _onButtonTap() {
    print('pressed');
    // if (_angleController.status == AnimationStatus.completed) {
    //   _angleController.reverse();
    // } else if (_angleController.status == AnimationStatus.dismissed) {
    //   _angleController.forward();
    // }

    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => new CaptureImage()));
  }
}
