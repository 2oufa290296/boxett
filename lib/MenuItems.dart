import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MenuItems extends StatefulWidget {
  final OverlayEntry entry;
  final String categImg;
  final void Function(String selectedCateg) updateNavBar;
  final void Function(String selectedCateg) updateNavBarDelayed;

  MenuItems(this.entry, this.categImg, {this.updateNavBar,this.updateNavBarDelayed});

  @override
  _MenuItemsState createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems> with TickerProviderStateMixin {
  List<Widget> children = [];
  Alignment alignment = Alignment.bottomCenter;
  Color ringColor = Colors.black87;
  double ringDiameter;
  double ringWidth = 100;
  double fabSize = 56;
  double fabElevation = 8;
  Color fabColor;
  Color fabOpenColor = Colors.black54;
  Color fabCloseColor = Colors.transparent;
  Icon fabOpenIcon;
  Icon fabCloseIcon = Icon(Icons.close, size: 25);
  EdgeInsets fabMargin = EdgeInsets.all(16.0);
  Duration animationDuration = const Duration(milliseconds: 800);
  Curve animationCurve = Curves.easeInOutCirc;
  DisplayChange onDisplayChange;

  
  double width, height;
  bool animH = false;

  AnimationController _animationController;
 
 
  SharedPreferences sharedPref;
  String selectedCategory = "default";

  bool _isOpen = false;
  bool _isAnimating = false;
  bool firstItem = false;
  bool secondItem = false;
  bool thirdItem = false;
  bool forthItem = false;
  bool fifthItem = false;
  bool sixthItem = false;
  bool seventhItem = false;

  

  @override
  void initState() {
    super.initState();

    animH = true;
    children = [
      InkWell(
          onTap: () {
            if (selectedCategory != 'candies') {
              selectedCategory = 'candies';
              _hideItemsDelay();
            } else {
              _hideItems();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(5),
            child:Image.asset('assets/images/candies.png', height: 40, width: 40),
           
          )),
      InkWell(
          onTap: () {
            if (selectedCategory != 'handmade') {
              selectedCategory = 'handmade';
              _hideItemsDelay();
            } else {
              _hideItems();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(0),
            child:Image.asset('assets/images/handmade.png', height: 40, width: 40),
          
          )),
      InkWell(
          onTap: () {
            if (selectedCategory != 'love') {
              selectedCategory = 'love';
              _hideItemsDelay();
            } else {
              _hideItems();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(5),
            child:Image.asset('assets/images/heart.png', height: 40, width: 40),
          
          )),
      InkWell(
          onTap: () {
            if (selectedCategory != 'default') {
              
              selectedCategory = 'default';
             _hideItemsDelay();
            } else {
             _hideItems();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(0),
            child:Image.asset('assets/images/zzz.png', height: 40, width: 40),
           
          )),
      InkWell(
          onTap: () {
            if (selectedCategory != 'male') {
              selectedCategory = 'male';

             _hideItemsDelay();
            } else {
            _hideItems();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Image.asset('assets/images/male.png', height: 40, width: 40),
           
          )),
      InkWell(
        onTap: () {
          if (selectedCategory != 'female') {
            selectedCategory = 'female';
          _hideItemsDelay();
          } else {
            _hideItems();
          }
        },
        child:Padding(
            padding: EdgeInsets.all(5),
            child: Image.asset('assets/images/female.png', height: 40, width: 40),
       
        ),
      ),
      InkWell(
          onTap: () {
           if(selectedCategory!='kids'){
             selectedCategory='kids';
             _hideItemsDelay();
           }else {
             _hideItems();
           }
          },
          child: Padding(
            padding: EdgeInsets.all(5),
            child:Image.asset('assets/images/kids.png', height: 40, width: 40),
           
          )),
      
    ];
    _animationController =
        AnimationController(duration: animationDuration, vsync: this);

   
   

   

    

    
    selectedCategory=widget.categImg;
    _showItems();
  }

  _hideItems() async {
    _isOpen = false;
    animH = false;
    _isAnimating=true;
    widget.updateNavBar(selectedCategory);

    Future.delayed(Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          firstItem = false;
          _isAnimating=false;
        });
        widget.entry.remove();
      }
    });

    Future.delayed(Duration(milliseconds: 1200), () {
      if (mounted)
        setState(() {
          secondItem = false;
          
        });
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted)
        setState(() {
          thirdItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted)
        setState(() {
          forthItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted)
        setState(() {
          fifthItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted)
        setState(() {
          sixthItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted)
        setState(() {
          seventhItem = false;
        });
    });
  }

  _hideItemsDelay() async {
    _isOpen = false;
    animH = false;
    _isAnimating=true;
  widget.updateNavBarDelayed(selectedCategory);
    

    Future.delayed(Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          firstItem = false;
          _isAnimating=false;
        });
        widget.entry.remove();
        
      }
    });

    Future.delayed(Duration(milliseconds: 1200), () {
      if (mounted)
        setState(() {
          secondItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted)
        setState(() {
          thirdItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted)
        setState(() {
          forthItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted)
        setState(() {
          fifthItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted)
        setState(() {
          sixthItem = false;
        });
    });

    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted)
        setState(() {
          seventhItem = false;
        });
    });
  }

  _showItems() async {
    animH = true;
    _isOpen = true;
    _isAnimating=true;
    widget.updateNavBar(selectedCategory);
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted)
        setState(() {
          firstItem = true;
        });
    });

    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted)
        setState(() {
          secondItem = true;
        });
    });

    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted)
        setState(() {
          thirdItem = true;
        });
    });

    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted)
        setState(() {
          forthItem = true;
        });
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted)
        setState(() {
          fifthItem = true;
        });
    });

    Future.delayed(Duration(milliseconds: 1200), () {
      if (mounted)
        setState(() {
          sixthItem = true;
        });
    });

    Future.delayed(Duration(milliseconds: 1400), () {
      if (mounted)
        setState(() {
          seventhItem = true;
          _isAnimating=false;
        });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _calculateProps();
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return SafeArea(
          child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          GestureDetector(
            onTap: _hideItems,
            child: AnimatedContainer(
                height: animH ? height : 0,
                duration: Duration(milliseconds: 500),
                
                color: Colors.transparent),
          ),
          Container(
            margin: fabMargin,
            // Removes the default FAB margin
            transform: Matrix4.translationValues(0.0, 0.0, 0.0),
            child: Stack(
              alignment: alignment,
              children: <Widget>[
                // Ring

                Stack(
                  children: children
                      .asMap()
                      .map((index, child) =>
                          MapEntry(index, _applyTransformations(child, index)))
                      .values
                      .toList(),
                )

                // Transform(
                //   transform:
                //       Matrix4.translationValues(_translationX, _translationY, 0.0)
                //         ..scale(_scaleAnimation.value),
                //   alignment: FractionalOffset.center,
                //   child: OverflowBox(
                //     maxWidth: width,
                //     maxHeight: width,
                //     child: Container(
                //       width: width,
                //       height: width,
                //       child: _scaleAnimation.value == 1.0
                //           ? Transform.rotate(
                //               angle: (2 * pi) *
                //                   _rotateAnimation.value *
                //                   _directionX *
                //                   _directionY,
                //               child: Container(
                //                 child: Stack(
                //                   alignment: Alignment.center,
                //                   children: children
                //                       .asMap()
                //                       .map((index, child) => MapEntry(index,
                //                           _applyTransformations(child, index)))
                //                       .values
                //                       .toList(),
                //                 ),
                //               ),
                //             )
                //           : Container(),
                //     ),
                //   ),
                // ),

                // FAB
                ,
                Container(
                  width: fabSize,
                  height: fabSize,
                  child: RawMaterialButton(highlightColor: Colors.transparent,splashColor: Colors.transparent,
                    shape: CircleBorder(),
                    elevation: fabElevation,
                    onPressed: () {
                      if (_isAnimating) return;

                      if (_isOpen) {
                        _hideItems();
                      } else {
                        _showItems();
                      }
                    },
                    child: Center(child: _isOpen ? Container(height: 50) : null),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _applyTransformations(Widget child, int index) {
    if (index == 0) {
      return Positioned(
        left: 0,
        bottom: firstItem ? 40 : 40,
        child: AnimatedOpacity(
            duration: Duration(milliseconds: 400),
            opacity: firstItem ? 1 : 0,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(5, 150, 197, 1),
                    Color.fromRGBO(18, 42, 76, 1),
                  ],
                  center: Alignment.center,
                  radius:  0.5,
                ),
              ),
              child: Material(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: child),
            )),
      );
    } else if (index == 1) {
      return Positioned(
        left: 30,
        bottom: 95,
        child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: secondItem ? 1 : 0,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(5, 150, 197, 1),
                    Color.fromRGBO(18, 42, 76, 1),
                  ],
                  center: Alignment.center,
                  radius:  0.5,
                ),
              ),
              child: Material(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: child),
            )),
      );
    } else if (index == 2) {
      return Positioned(
        left: 80,
        bottom: 135,
        child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: thirdItem ? 1 : 0,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(5, 150, 197, 1),
                    Color.fromRGBO(18, 42, 76, 1),
                  ],
                  center: Alignment.center,
                  radius:  0.5,
                ),
              ),
              child: Material(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: child),
            )),
      );
    } else if (index == 3) {
      return Positioned(
        left: (width / 2) - 40,
        bottom: 160,
        child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: forthItem ? 1 : 0,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white70,
                    Colors.white70,
                  ],
                  center: Alignment.center,
                  radius:  0.5,
                ),
              ),
              child: Material(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: child),
            )),
      );
    } else if (index == 4) {
      return Positioned(
        right: 80,
        bottom: 135,
        child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: fifthItem ? 1 : 0,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(5, 150, 197, 1),
                    Color.fromRGBO(18, 42, 76, 1),
                  ],
                  center: Alignment.center,
                  radius:  0.5,
                ),
              ),
              child: Material(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: child),
            )),
      );
    } else if (index == 5) {
      return Positioned(
        right: 30,
        bottom: 95,
        child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: sixthItem ? 1 : 0,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(5, 150, 197, 1),
                    Color.fromRGBO(18, 42, 76, 1),
                  ],
                  center: Alignment.center,
                  radius:  0.5,
                ),
              ),
              child: Material(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: child),
            )),
      );
    } else if (index == 6) {
      return Positioned(
        right: 0,
        bottom: 40,
        child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: seventhItem ? 1 : 0,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(5, 150, 197, 1),
                    Color.fromRGBO(18, 42, 76, 1),
                  ],
                  center: Alignment.center,
                  radius: 0.5,
                ),
              ),
              child: Material(
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: child),
            )),
      );
    } else {
      return Container();
    }
  
  }

  

  
}


  
