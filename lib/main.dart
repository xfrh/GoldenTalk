import 'service/auth_service.dart';
import 'service/locator.dart';
import 'service/market_service.dart';
import 'view/calls_edit_page.dart';
import 'view/login_signup_page.dart';
import 'view/navigationbar_page.dart';
import 'view/script_register.dart';
import 'view/widget/news/webview_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'view/introduct_screen.dart';
import 'view/widget/slide_list_view.dart';
import 'view/detailimage_screen.dart';
import 'view/script_registerEdit.dart';
import 'view/widget/stock_chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/board': (context) => OnBoardingPage(),
      '/chat': (context) => NavigatePage(),
      '/contact': (context) => CallseditPage(),
      '/script': (context) => ScriptRegisterPage(),
      WebViewPage.routeName: (context) => WebViewPage(),
      DetailScreen.routeName: (context) => DetailScreen(),
      ScriptRegisterEditPage.routeName: (context) => ScriptRegisterEditPage(),
      StockChartScreen.routeName: (context) => StockChartScreen(),
    },
    debugShowCheckedModeBanner: false,
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      title: new Text(
        'Welcome In SplashScreen',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      seconds: 8,
      navigateAfterSeconds: RootPage(),
      image: new Image.asset('assets/images/loading.gif'),
      backgroundColor: Colors.black,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 150.0,
      onClick: () => {},
      loaderColor: Colors.white,
    );
  }
}

class RootPage extends StatefulWidget {
  final auth = locator<AuthService>();
  final market = locator<MarketService>();

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.market.fetchprices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<FirebaseUser>(
          future: widget.auth.getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (widget.auth.activeUser != null) return NavigatePage();
            }
            return Container(
              child: SlideListView(
                view1: Container(child: LoginSignUpPage()),
                floatingActionButtonColor: Colors.yellow[800],
                floatingActionButtonIcon: AnimatedIcons.view_list,
                showFloatingActionButton: false,
                defaultView: "slides",
                duration: Duration(
                  milliseconds: 800,
                ),
              ),
            );
          }),
    );
  }
}
