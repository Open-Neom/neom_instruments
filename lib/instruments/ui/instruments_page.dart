import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:neom_commons/core/ui/widgets/appbar_child.dart';
import 'package:neom_commons/core/utils/app_theme.dart';
import 'package:neom_commons/core/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/core/utils/constants/app_translation_constants.dart';
import 'instrument_controller.dart';
import 'widgets/instrument_widgets.dart';

class InstrumentPage extends StatelessWidget {
  const InstrumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstrumentController>(
      id: AppPageIdConstants.instruments,
      init: InstrumentController(),
      builder: (_) => Scaffold(
        appBar:  PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBarChild(title: AppTranslationConstants.instrumentSelection.tr)),
        body: Container(
          decoration: AppTheme.appBoxDecoration,
          child: Column(
              children: <Widget>[
                Obx(()=> Expanded(
                  child: buildInstrumentList(context, _),
                ),),
              ]
          ),
        ),
      ),
    );
  }
}
