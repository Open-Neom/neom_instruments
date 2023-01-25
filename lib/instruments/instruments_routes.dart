import 'package:get/get.dart';

import 'package:neom_commons/core/utils/constants/app_route_constants.dart';
import 'ui/instrument_fav_page.dart';
import 'ui/instruments_page.dart';

class InstrumentsRoutes {

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRouteConstants.instrumentsFav,
      page: () => const InstrumentFavPage(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: AppRouteConstants.instruments,
      page: () => const InstrumentPage(),
      transition: Transition.rightToLeft,
    ),
  ];

}
