import 'package:flutter/material.dart';

class LinearProgressAnimated extends StatefulWidget {
  final int progressDuration;

  LinearProgressAnimated({Key key,this.progressDuration}) : super (key:key);

  @override
  LinearProgressAnimatedState createState() => LinearProgressAnimatedState();
}

class LinearProgressAnimatedState extends State<LinearProgressAnimated>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(seconds: widget.progressDuration), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController)
      ..addListener(() {
        setState(() {
        });
      });
    animationController.forward();  
  }

  pause() {
    animationController.stop();
  }

  resume(){
    animationController.forward();
  }

  replay(){
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(height: 3,
            child: LinearProgressIndicator(
      value: animation.value,
      valueColor: AlwaysStoppedAnimation<Color>(
        Colors.white,
      ),
      backgroundColor: Colors.white54,
    )));
  }
}
