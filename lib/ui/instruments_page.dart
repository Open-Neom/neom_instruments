import 'package:flutter/material.dart';
import 'package:sint/sint.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';

import '../utils/constants/instrument_translation_constants.dart';
import 'instrument_controller.dart';
import 'widgets/instrument_widgets.dart';

class InstrumentPage extends StatelessWidget {
  const InstrumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SintBuilder<InstrumentController>(
      id: AppPageIdConstants.instruments,
      init: InstrumentController(),
      builder: (controller) => Scaffold(
        appBar:  PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBarChild(title: InstrumentTranslationConstants.instrumentSelection.tr)),
        body: Container(
          decoration: AppTheme.appBoxDecoration,
          child: Column(
              children: <Widget>[
                Obx(()=> Expanded(
                  child: buildInstrumentList(context, controller),
                ),),
              ]
          ),
        ),
      ),
    );
  }
}
