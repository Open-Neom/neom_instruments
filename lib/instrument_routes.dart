import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:sint/sint.dart';

import 'ui/instrument_fav_page.dart';
import 'ui/instruments_page.dart';

class InstrumentRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
      name: AppRouteConstants.instrumentsFav,
      page: () => const InstrumentFavPage(),
      transition: Transition.zoom,
    ),
    SintPage(
      name: AppRouteConstants.instruments,
      page: () => const InstrumentPage(),
      transition: Transition.downToUp,
    ),
  ];

}
