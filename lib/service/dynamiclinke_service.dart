import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'locator.dart';
import 'navigation_service.dart';

class DynamicLinkService {
  final _navigationSerive = locator<NavigationService>();
  Future handleDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeeplinkData(data);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLinkData) async {
      _handleDeeplinkData(dynamicLinkData);
    }, onError: (OnLinkErrorException e) async {
      print('dynamic link Failed:${e.message}');
    });
  }

  void _handleDeeplinkData(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDepplink | deeplink:$deepLink');
      var isPost = deepLink.pathSegments.contains('metalinfo');
      if (isPost != null) {
        _navigationSerive.navigateTo('/');
      }
    }
  }
}
