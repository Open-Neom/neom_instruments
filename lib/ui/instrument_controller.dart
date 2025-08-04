import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/data/firestore/instrument_firestore.dart';
import 'package:neom_core/domain/model/app_profile.dart';
import 'package:neom_core/domain/model/instrument.dart';
import 'package:neom_core/domain/use_cases/app_drawer_service.dart';
import 'package:neom_core/domain/use_cases/instrument_service.dart';
import 'package:neom_core/domain/use_cases/user_service.dart';
import 'package:neom_core/utils/constants/data_assets.dart';
import 'package:neom_core/utils/enums/app_in_use.dart';

class InstrumentController extends GetxController implements InstrumentService {

  final userServiceImpl = Get.find<UserService>();

  final RxMap<String, Instrument> _instruments = <String,Instrument>{}.obs;
  final RxMap<String, Instrument> _favInstruments = <String,Instrument>{}.obs;
  final RxMap<String, Instrument> _sortedInstruments = <String,Instrument>{}.obs;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool isLoading) => _isLoading.value = isLoading;

  AppProfile profile = AppProfile();

  @override
  void onInit() async {
    super.onInit();
    AppConfig.logger.t("Instruments Init");
    if(AppConfig.instance.appInUse != AppInUse.c && AppConfig.instance.appInUse != AppInUse.o) await loadInstruments();

    if(userServiceImpl.profile.instruments != null) {
      _favInstruments.value = userServiceImpl.profile.instruments!;
    }

    profile = userServiceImpl.profile;

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

      _instruments.value = { for (var e in instrumentList) e.name : e };
    } catch(e) {
      AppConfig.logger.d(e.toString());
    }


    isLoading = false;
    update([AppPageIdConstants.instruments]);
  }

  @override
  Future<void>  addInstrument(int index) async {
    AppConfig.logger.d("");

    Instrument instrument = _sortedInstruments.values.elementAt(index);
    _sortedInstruments[instrument.id]!.isFavorite = true;

    AppConfig.logger.i("Adding instrument ${instrument.name}");
    InstrumentFirestore().addInstrument(profileId: profile.id, instrumentId:  instrument.name);
    favInstruments[instrument.id] = instrument;
        
    sortFavInstruments();
    update([AppPageIdConstants.instruments]);
  }

  @override
  Future<void> removeInstrument(int index) async {
    AppConfig.logger.d("Removing Instrument");
    Instrument instrument = _sortedInstruments.values.elementAt(index);

    _sortedInstruments[instrument.id]!.isFavorite = false;
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
    Get.find<AppDrawerService>().updateProfile(profile);
    update([AppPageIdConstants.instruments, AppPageIdConstants.profile]);

  }

  @override
  void sortFavInstruments(){

    _sortedInstruments.value = {};

    for (var instrument in instruments.values) {
      if (favInstruments.containsKey(instrument.id)) {
        _sortedInstruments[instrument.id] = favInstruments[instrument.id]!;
      }
    }

    for (var instrument in instruments.values) {
      if (!favInstruments.containsKey(instrument.id)) {
        _sortedInstruments[instrument.id] = instruments[instrument.id]!;
      }
    }

  }

  @override
  Map<String, Instrument> get favInstruments => _favInstruments.value;

  @override
  Map<String, Instrument> get instruments => _instruments.value;

  @override
  Map<String, Instrument> get sortedInstruments => _sortedInstruments.value;

}
