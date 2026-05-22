import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:neom_core/ui/deferred_loader.dart';
import 'package:sint/sint.dart';

import 'ui/instrument_fav_page.dart' deferred as instrumentFav;
import 'ui/instruments_page.dart' deferred as instruments;

class InstrumentRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
      name: AppRouteConstants.instrumentsFav,
      page: () => DeferredLoader(instrumentFav.loadLibrary, () => instrumentFav.InstrumentFavPage()),
      transition: Transition.zoom,
    ),
    SintPage(
      name: AppRouteConstants.instruments,
      page: () => DeferredLoader(instruments.loadLibrary, () => instruments.InstrumentPage()),
      transition: Transition.downToUp,
    ),
  ];

}
