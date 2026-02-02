import 'package:flutter/material.dart';
import 'package:sint/sint.dart';
import 'package:neom_commons/utils/app_alerts.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/message_translation_constants.dart';
import 'package:neom_core/domain/model/instrument.dart';

import '../../utils/constants/instrument_translation_constants.dart';
import '../instrument_controller.dart';

Widget buildInstrumentFavList(BuildContext context, InstrumentController controller) {
  return ListView.separated(
    separatorBuilder:  (context, index) => const Divider(),
    itemBuilder: (__, index) {
      Instrument instrument = controller.favInstruments.values.toList()[index];
      String instrumentLevel = instrument.instrumentLevel.name;

      return ListTile(
          title: Text(instrument.name.tr.capitalizeFirst),
          subtitle: Text(instrument.isMain ?
          "${AppTranslationConstants.mainInstrument.tr} ${instrumentLevel != InstrumentTranslationConstants.notDetermined.tr ? " - $instrumentLevel" : ""}"
              : instrumentLevel != InstrumentTranslationConstants.notDetermined.tr ? instrumentLevel : ""),
          trailing: IconButton(
              icon: const Icon(
                Icons.toc,
              ),
              onPressed: () {
                controller.makeMainInstrument(instrument);
                AppAlerts.showAlert(context, title: AppTranslationConstants.instrumentsPreferences.tr,
                    message: "${instrument.name.tr} ${InstrumentTranslationConstants.selectedAsMainInstrument.tr}");
              })
      );
    },
    itemCount: controller.favInstruments.length,
  );
}

Widget buildInstrumentList(BuildContext context, InstrumentController controller) {
  return ListView.separated(
    itemCount: controller.sortedInstruments.length,
    separatorBuilder:  (context, index) => const Divider(),
    itemBuilder: (__, index) {
      Instrument instrument = controller.sortedInstruments.values.elementAt(index);
      if (controller.favInstruments[instrument.id] != null) {
        instrument = controller.favInstruments[instrument.id]!;
      }
      return ListTile(
          title: Text(instrument.name.tr.capitalizeFirst),
          trailing: IconButton(
              icon: Icon(
                instrument.isFavorite ? Icons.remove : Icons.add,
              ),
              onPressed: () async {
                if(instrument.isFavorite) {
                  if (controller.favInstruments.length > 1) {
                    await controller.removeInstrument(index);
                    if(controller.favInstruments.containsKey(instrument.id)) {
                      AppAlerts.showAlert(context, title: instrument.name.tr, message: MessageTranslationConstants.instrumentNotRemoved.tr);
                    } else {
                      AppAlerts.showAlert(context, title: instrument.name.tr, message: MessageTranslationConstants.instrumentRemoved.tr);
                    }
                  } else {
                    AppAlerts.showAlert(context, title: instrument.name.tr, message: MessageTranslationConstants.atLeastOneInstrument.tr);
                  }
                } else {
                  await controller.addInstrument(index);
                  if(controller.favInstruments.containsKey(instrument.id)) {
                    AppAlerts.showAlert(context, title: instrument.name.tr, message: MessageTranslationConstants.instrumentAdded.tr);
                  } else {
                    AppAlerts.showAlert(context, title: instrument.name.tr, message: MessageTranslationConstants.instrumentNotAdded.tr);
                  }
                }
              }
          )
      );
    },
  );
}
