import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neom_commons/commons/app_flavour.dart';
import 'package:neom_commons/commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_core/core/app_config.dart';
import 'package:neom_core/core/data/firestore/instrument_firestore.dart';
import 'package:neom_core/core/data/implementations/app_drawer_controller.dart';
import 'package:neom_core/core/data/implementations/user_controller.dart';
import 'package:neom_core/core/domain/model/app_profile.dart';
import 'package:neom_core/core/domain/model/instrument.dart';
import 'package:neom_core/core/utils/constants/data_assets.dart';
import 'package:neom_core/core/utils/enums/app_in_use.dart';

import '../domain/use_cases/instrument_service.dart';

class InstrumentController extends GetxController implements InstrumentService {

  final userController = Get.find<UserController>();

  RxMap<String, Instrument> instruments = <String,Instrument>{}.obs;
  RxMap<String, Instrument> favInstruments = <String,Instrument>{}.obs;
  RxMap<String, Instrument> sortedInstruments = <String,Instrument>{}.obs;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool isLoading) => _isLoading.value = isLoading;

  AppProfile profile = AppProfile();

  @override
  void onInit() async {
    super.onInit();
    AppConfig.logger.t("Instruments Init");
    if(AppFlavour.appInUse != AppInUse.c) await loadInstruments();

    if(userController.profile.instruments != null) {
      favInstruments.value = userController.profile.instruments!;
    }

    profile = userController.profile;

    sortFavInstruments();

  }

  @override
  Future<void> loadInstruments() async {
    AppConfig.logger.t("loadInstruments");

    try {
      String instrumentStr = await rootBundle.loadString(DataAssets.instrumentsJsonPath);

      List<dynamic> instrumentJSON = jsonDecode(instrumentStr);
      List<Instrument> instrumentList = [];
      for (var instrJSON in instrumentJSON) {
        instrumentList.add(Instrument.fromJsonDefault(instrJSON));
      }

      AppConfig.logger.d("${instrumentList.length} loaded instruments from json");

      instruments.value = { for (var e in instrumentList) e.name : e };
    } catch(e) {
      AppConfig.logger.d(e.toString());
    }


    isLoading = false;
    update([AppPageIdConstants.instruments]);
  }

  @override
  Future<void>  addInstrument(int index) async {
    AppConfig.logger.d("");

    Instrument instrument = sortedInstruments.values.elementAt(index);
    sortedInstruments[instrument.id]!.isFavorite = true;

    AppConfig.logger.i("Adding instrument ${instrument.name}");
    InstrumentFirestore().addInstrument(profileId: profile.id, instrumentId:  instrument.name);
    favInstruments[instrument.id] = instrument;
        
    sortFavInstruments();
    update([AppPageIdConstants.instruments]);
  }

  @override
  Future<void> removeInstrument(int index) async {
    AppConfig.logger.d("Removing Instrument");
    Instrument instrument = sortedInstruments.values.elementAt(index);

    sortedInstruments[instrument.id]!.isFavorite = false;
    AppConfig.logger.d("Removing instrument ${instrument.name}");

    ///DEPRECATED - NOT WAITING AS IS NOT NECESSARY TO VERIFY IT - ITS PREFERIBLE TO BE FASTER THAN CORRECT
    // if(await InstrumentFirestore().removeInstrument(profileId: profile.id, instrumentId: instrument.id)){
    //   favInstruments.remove(instrument.id);
    // }

    InstrumentFirestore().removeInstrument(profileId: profile.id, instrumentId: instrument.id);
    favInstruments.remove(instrument.id);
    sortFavInstruments();
    update([AppPageIdConstants.instruments]);
  }

  @override
  void makeMainInstrument(Instrument instrument){
    AppConfig.logger.d("Main instrument ${instrument.name}");

    String prevInstrId = "";
    for (var instr in favInstruments.values) {
      if(instr.isMain) {
        instr.isMain = false;
        prevInstrId = instr.id;
      }
    }
    instrument.isMain = true;
    favInstruments.update(instrument.name, (instrument) => instrument);
    InstrumentFirestore().updateMainInstrument(profileId: profile.id,
      instrumentId: instrument.id, prevInstrId:  prevInstrId);

    profile.instruments![instrument.id] = instrument;
    profile.mainFeature = instrument.name;
    Get.find<AppDrawerController>().updateProfile(profile);
    update([AppPageIdConstants.instruments, AppPageIdConstants.profile]);

  }

  @override
  void sortFavInstruments(){

    sortedInstruments.value = {};

    for (var instrument in instruments.values) {
      if (favInstruments.containsKey(instrument.id)) {
        sortedInstruments[instrument.id] = favInstruments[instrument.id]!;
      }
    }

    for (var instrument in instruments.values) {
      if (!favInstruments.containsKey(instrument.id)) {
        sortedInstruments[instrument.id] = instruments[instrument.id]!;
      }
    }

  }

}
