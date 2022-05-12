import 'package:get_it/get_it.dart';
import '../manager/expertmanager.dart';
import '../manager/notifymanager.dart';
import '../manager/postmanager.dart';
import '../manager/roommanager.dart';
import '../manager/videochatmanager.dart';
import '../service/message_service.dart';
import '../service/permission_service.dart';
import '../service/rsakey_service.dart';
import 'auth_service.dart';
import 'dynamiclinke_service.dart';
import 'market_service.dart';
import 'navigation_service.dart';
import 'news_service.dart';

GetIt locator = GetIt.instance;
void setupLocator() async {
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => NotifyManager());
  locator.registerLazySingleton(() => ExpertManager());
  locator.registerLazySingleton(() => RoomManager());
  locator.registerLazySingleton(() => PostManager());
  locator.registerLazySingleton(() => DynamicLinkService());
  locator.registerLazySingleton(() => MarketService());
  locator.registerLazySingleton(() => GoldTrendNews());
  locator.registerLazySingleton(() => VideoChatManager());
  var instance_key = await RsaKeyService.getInstance();
  locator.registerSingleton<RsaKeyService>(instance_key);

  // var instance_message = await MessageService.getInstance();
  // locator.registerSingleton<MessageService>(instance_message);

  locator.registerLazySingleton<PermissionsService>(() => PermissionsService());
}
