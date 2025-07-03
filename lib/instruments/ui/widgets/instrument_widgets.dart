// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/commons/utils/app_alerts.dart';
import 'package:neom_commons/commons/utils/constants/app_translation_constants.dart';
import 'package:neom_commons/commons/utils/constants/message_translation_constants.dart';
import 'package:neom_core/core/domain/model/instrument.dart';

import '../instrument_controller.dart';

Widget buildInstrumentFavList(BuildContext context, InstrumentController _) {
  return ListView.separated(
    separatorBuilder:  (context, index) => const Divider(),
    itemBuilder: (__, index) {
      Instrument instrument = _.favInstruments.values.toList()[index];
      String instrumentLevel = instrument.instrumentLevel.name;

      return ListTile(
          title: Text(instrument.name.tr.capitalizeFirst),
          subtitle: Text(instrument.isMain ?
          "${AppTranslationConstants.mainInstrument.tr} ${instrumentLevel != AppTranslationConstants.notDetermined.tr ? " - $instrumentLevel" : ""}"
              : instrumentLevel != AppTranslationConstants.notDetermined.tr ? instrumentLevel : ""),
          trailing: IconButton(
              icon: const Icon(
                Icons.toc,
              ),
              onPressed: () {
                _.makeMainInstrument(instrument);
                AppAlerts.showAlert(context, title: AppTranslationConstants.instrumentsPreferences.tr,
                    message: "${instrument.name.tr} ${AppTranslationConstants.selectedAsMainInstrument.tr}");
              })
      );
    },
    itemCount: _.favInstruments.length,
  );
}

Widget buildInstrumentList(BuildContext context, InstrumentController _) {
  return ListView.separated(
    itemCount: _.sortedInstruments.length,
    separatorBuilder:  (context, index) => const Divider(),
    itemBuilder: (__, index) {
      Instrument instrument = _.sortedInstruments.values.elementAt(index);
      if (_.favInstruments[instrument.id] != null) {
        instrument = _.favInstruments[instrument.id]!;
      }
      return ListTile(
          title: Text(instrument.name.tr.capitalizeFirst),
          trailing: IconButton(
              icon: Icon(
                instrument.isFavorite ? Icons.remove : Icons.add,
              ),
              onPressed: () async {
                if(instrument.isFavorite) {
                  if (_.favInstruments.length > 1) {
                    await _.removeInstrument(index);
                    if(_.favInstruments.containsKey(instrument.id)) {
                      AppAlerts.showAlert(context, title: instrument.name.tr, message: MessageTranslationConstants.instrumentNotRemoved.tr);
                    } else {
                      AppAlerts.showAlert(context, title: instrument.name.tr, message: MessageTranslationConstants.instrumentRemoved.tr);
                    }
                  } else {
                    AppAlerts.showAlert(context, title: instrument.name.tr, message: MessageTranslationConstants.atLeastOneInstrument.tr);
                  }
                } else {
                  await _.addInstrument(index);
                  if(_.favInstruments.containsKey(instrument.id)) {
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
