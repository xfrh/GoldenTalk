import '../dynamiclinke_service.dart';
import '../locator.dart';

class DynamicStartupMode{
  final _dynamicLinkService= locator<DynamicLinkService>();
  Future handleStartupLogic() async{
    await _dynamicLinkService.handleDynamicLinks();
  }
}