import 'package:flutter/material.dart';
import '../view/expertlist_page.dart';
import 'metalist_page.dart';
import 'profilepage.dart';
import 'Stories.dart';
import 'home.dart';

class NavigatePage extends StatefulWidget {
  NavigatePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DashboardScreenState createState() => new _DashboardScreenState();
}

class _DashboardScreenState extends State<NavigatePage> {
  PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void navigationTapped(int page) {
    // Animating to the page.
    // You can use whatever duration and curve you like
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 10), curve: Curves.linear);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new PageView(
        children: [
          new Home("Home"),
          new ExpertsListPage("Scripts"),
          new MetalistPage("Prices"),
          new StoriesPage("Stories"),
          new ProfilePage("Profile"),
        ],
        onPageChanged: onPageChanged,
        controller: _pageController,
      ),
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Colors.white,
        ), // sets the inactive color of the `BottomNavigationBar`
        child: new BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          fixedColor: const Color(0xFF2845E7),
          items: [
            new BottomNavigationBarItem(
              icon: new Icon(
                Icons.home,
              ),
              title: new Text(
                "Home",
              ),
            ),
            new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.call,
                ),
                title: new Text(
                  "Calls",
                )),
            new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.graphic_eq,
                ),
                title: new Text(
                  "Market",
                )),
            new BottomNavigationBarItem(
                icon: new Stack(children: <Widget>[
                  new Icon(Icons.favorite),
                  new Positioned(
                      top: -1.0,
                      right: -1.0,
                      child: new Stack(
                        children: <Widget>[
                          new Icon(
                            Icons.brightness_1,
                            size: 12.0,
                            color: const Color(0xFF2845E7),
                          ),
                        ],
                      ))
                ]),
                title: new Text(
                  "Stories",
                )),
            new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.account_circle,
                ),
                title: new Text(
                  "Settings",
                )),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }
}
