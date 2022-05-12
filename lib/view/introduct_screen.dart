import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../service/auth_service.dart';
import '../service/locator.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  final _auth = locator<AuthService>();
  void _onIntroEnd() async {
    if (_auth.activeUser == null) {
      await _auth.getCurrentUser();
    }
    Navigator.pushNamed(context, '/chat');
  }

  void _onIntroSkip() {
    Navigator.pushNamed(context, '/');
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/$assetName.png', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
        bodyTextStyle: bodyStyle,
        descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        pageColor: Colors.white,
        imagePadding: EdgeInsets.only(top: 90.0));

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Idea shares",
          body:
              "'GoldenTalk' is an open investment community.Your ideas will be heard and you take others opinion freely",
          image: _buildImage('mountain'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Learn as you go",
          body:
              "Join the community, you're granted to donwload and share valuable information from all experts",
          image: _buildImage('world'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Scripts and Follows",
          body:
              "Scripts are those experienced in investment,they can track stoks 24/7 and place trades that you approve",
          image: _buildImage('home'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Apply for scripter",
          body:
              "Scripter is able to make group chat and leading followers, and be award by followers",
          image: _buildImage('home'),
          footer: RaisedButton(
            onPressed: () {
              //introKey.currentState?.animateScroll(4);
              Navigator.pushNamed(context, '/script');
            },
            child: const Text(
              'Apply Script User',
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Fill out form for scripts",
          bodyWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Click on ", style: bodyStyle),
              IconButton(icon: Icon(Icons.edit), onPressed: null),
              Text(" to edit a post", style: bodyStyle),
            ],
          ),
          image: _buildImage('mountain'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(),
      onSkip: () => _onIntroSkip(), // You can override onSkip callback

      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
