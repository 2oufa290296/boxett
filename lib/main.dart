import 'package:boxet/LoginActivity.dart';
import 'package:boxet/LoginState.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boxet/AssistantDone.dart';
import 'package:boxet/ChatPage.dart';
import 'package:boxet/CustomNavBar.dart';
import 'package:boxet/FavPage.dart';
import 'package:boxet/GiftPage.dart';
import 'package:boxet/classes/HeaderGifts.dart';
import 'package:boxet/HomePage.dart';
import 'package:boxet/OrderPlaced.dart';
import 'package:boxet/Profile.dart';
import 'package:boxet/MapsPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:boxet/Welcome.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppLocalizations.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   'This channel is used for important notifications.', // description
//   importance: Importance.high,
// );

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      //  Color.fromRGBO(55, 57, 56, 1.0),
      statusBarBrightness: Brightness.dark,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return new MaterialApp(
      routes: <String, WidgetBuilder>{
        '/myApp': (BuildContext context) => MyApp(),
        '/homePage': (BuildContext context) => MyHomePage(),
        '/giftPage': (BuildContext context) =>
            GiftPage(ModalRoute.of(context).settings.arguments),
        '/orderPlaced': (BuildContext context) => OrderPlaced(),
        '/assistantdone': (BuildContext context) => AssistantDone()
      },
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      title: 'Boxet',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          iconTheme: IconThemeData(color: Color.fromRGBO(5, 150, 197, 1)),
          accentIconTheme: IconThemeData(color: Color.fromRGBO(5, 150, 197, 1)),
          scaffoldBackgroundColor: Colors.black,
          accentColor: Color.fromRGBO(5, 150, 197, 1)),
      home: ChangeNotifierProvider<LoginState>(
        create: (_) => LoginState(),
        child: new Welcome(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.attachment}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String attachment;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<HomePageState> homeKey = GlobalKey();
  GlobalKey<ChatPageState> chatKey = GlobalKey();
  final _auth = FirebaseAuth.instance;
  // List<Gifts> data = [];
  List<HeaderGifts> headerD = [];
  int currentLength = 0;
  final int increment = 10;
  bool isLoading = false;
  double width, height, bottom;
  List myList, dataa, headerData;
  OverlayEntry overlayEntry;
  OverlayState overlayState;
  SharedPreferences sharedPref;
  bool menuOpened = false;
  String uid = "";
  String profImg = "";
  int count = 5;
  String category = "";
  Widget mainWidget;

  int bottomBarIndex = 2;

  Color color0 = Colors.white;
  Color color1 = Colors.white;
  Color color2 = Colors.white;
  Color color3 = Colors.white;
  Color color4 = Colors.white;

  _getSharedPref() async {
    sharedPref = await SharedPreferences.getInstance();
    uid = sharedPref.getString('uid');
    profImg = sharedPref.getString('imgURL');
  }

  backHome() {
    setState(() {
      bottomBarIndex = 2;
      mainWidget = HomePage(key: homeKey);
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.attachment != null) {
      if (widget.attachment == 'profile') {
        mainWidget = Profile();
        bottomBarIndex = 0;
      } else if (widget.attachment == 'chat') {
        mainWidget = ChatPage(
            key: chatKey, uid: uid, profImg: profImg, backHome: backHome);
        bottomBarIndex = 4;
      } else {
        mainWidget = HomePage(
          key: homeKey,
        );
      }
    } else {
      mainWidget = HomePage(
        key: homeKey,
      );
    }

    _getSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return WillPopScope(
      onWillPop: () async {
        if (bottomBarIndex != 2) {
          backHome();
        } else {
          SystemNavigator.pop();
        }

        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Scaffold(
            body: mainWidget,
            // floatingActionButtonLocation:
            //     FloatingActionButtonLocation.centerDocked,

            extendBody: true,
            bottomNavigationBar: CustomNavBar(
              reloadMain: (String categ) {
                setState(() {
                  homeKey.currentState.refresh(categ);
                });
              },
              // openingCat: (bool open) {
              //   homeKey.currentState.openingCat(open);
              // },
              chatKey: chatKey,
              height: 50,
              backgroundColor: Colors.transparent,
              index: bottomBarIndex,
              items: <Widget>[
                Icon(
                  Icons.person,
                  color: color4,
                ),
                Icon(
                  Icons.location_on,
                  color: color1,
                ),
                Icon(
                  Icons.home,
                  color: color2,
                ),
                Icon(
                  Icons.favorite,
                  color: color3,
                ),
                Icon(
                  MdiIcons.forum,
                  color: color0,
                )
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    if (_auth.currentUser != null) {
                      setState(() {
                        bottomBarIndex = 0;
                        mainWidget = Profile();
                      });
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  new LoginActivity('main', 'profile')));
                    }

                    break;

                  case 1:
                    setState(() {
                      bottomBarIndex = 1;
                      mainWidget = MapsPage();

                      // mainWidget = Center(child: CircularProgressIndicator());
                    });

                    break;

                  case 2:
                    setState(() {
                      mainWidget = HomePage(key: homeKey);
                    });

                    break;

                  case 3:
                    setState(() {
                      bottomBarIndex = 3;
                      mainWidget = FavPage();
                    });

                    break;

                  case 4:
                    if (_auth.currentUser != null) {
                      setState(() {
                        bottomBarIndex = 4;
                        mainWidget = ChatPage(
                            key: chatKey,
                            uid: uid,
                            profImg: profImg,
                            backHome: backHome);
                      });
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  new LoginActivity('main', 'chat')));
                    }

                    break;

                  default:
                    break;
                }
              },
            ),
            // floatingActionButton:
            //     Stack(children: <Widget>[BreathingButton(shown)]),
          ),
        ),
      ),
    );
  }
}
