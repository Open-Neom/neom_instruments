import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';

import '../utils/constants/instrument_translation_constants.dart';
import 'instrument_controller.dart';
import 'widgets/instrument_widgets.dart';

class InstrumentFavPage extends StatelessWidget {
  const InstrumentFavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstrumentController>(
      id: AppPageIdConstants.instruments,
      init: InstrumentController(),
      builder: (_) => Scaffold(
        appBar: AppBarChild(title: AppTranslationConstants.instruments.tr),
        body: _.isLoading ? const Center(child: CircularProgressIndicator())
            : Container(
          decoration: AppTheme.appBoxDecoration,
          child: Column(
              children: <Widget>[
                Expanded(
                  child: buildInstrumentFavList(context, _),
                ),
              ]
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: InstrumentTranslationConstants.addInstrument.tr,
          onPressed: ()=>{
            Get.toNamed(AppRouteConstants.instruments)
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
