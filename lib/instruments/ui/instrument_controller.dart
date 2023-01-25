import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neom_commons/core/data/implementations/app_drawer_controller.dart';
import 'package:neom_commons/core/domain/model/app_profile.dart';
import 'package:neom_commons/core/domain/model/instrument.dart';
import 'package:neom_commons/core/data/implementations/user_controller.dart';
import 'package:neom_commons/core/utils/app_utilities.dart';
import 'package:neom_commons/core/utils/constants/app_assets.dart';
import 'package:neom_commons/core/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/core/data/firestore/instrument_firestore.dart';
import '../domain/use_cases/instrument_service.dart';

class InstrumentController extends GetxController implements InstrumentService {

  var logger = AppUtilities.logger;
  final userController = Get.find<UserController>();

  final RxMap<String, Instrument> _instruments = <String,Instrument>{}.obs;
  Map<String, Instrument> get instruments =>  _instruments;
  set instruments(Map<String,Instrument> instruments) => _instruments.value = instruments;

  final RxMap<String, Instrument> _favInstruments = <String,Instrument>{}.obs;
  Map<String,Instrument> get favInstruments =>  _favInstruments;
  set favInstruments(Map<String,Instrument> favInstruments) => _favInstruments.value = favInstruments;

  final RxMap<String, Instrument> _sortedInstruments = <String,Instrument>{}.obs;
  Map<String,Instrument> get sortedInstruments =>  _sortedInstruments;
  set sortedInstruments(Map<String,Instrument> sortedInstruments) => _sortedInstruments.value = sortedInstruments;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool isLoading) => _isLoading.value = isLoading;

  AppProfile profile = AppProfile();

  @override
  void onInit() async {
    super.onInit();
    logger.d("Instruments Init");
    await loadInstruments();

    if(userController.profile.instruments != null) {
      favInstruments = userController.profile.instruments!;
    }

    profile = userController.profile;

    sortFavInstruments();

  }

  @override
  Future<void> loadInstruments() async {
    logger.d("");
    String instrumentStr = await rootBundle.loadString(AppAssets.instrumentsJsonPath);
    
    List<dynamic> instrumentJSON = jsonDecode(instrumentStr);
    List<Instrument> instrumentList = [];
    for (var instrJSON in instrumentJSON) {
      instrumentList.add(Instrument.fromJsonDefault(instrJSON));
    }

    logger.d("${instrumentList.length} loaded instruments from json");

    instruments = { for (var e in instrumentList) e.name : e };

    isLoading = false;
    update([AppPageIdConstants.instruments]);
  }

  @override
  Future<void>  addInstrument(int index) async {
    logger.d("");

    Instrument instrument = sortedInstruments.values.elementAt(index);
    sortedInstruments[instrument.id]!.isFavorite = true;

    logger.i("Adding instrument ${instrument.name}");
    if(await InstrumentFirestore().addInstrument(profileId: profile.id, instrumentId:  instrument.name)){
      favInstruments[instrument.id] = instrument;
    }

    sortFavInstruments();
    update([AppPageIdConstants.instruments]);
  }

  @override
  Future<void> removeInstrument(int index) async {
    logger.d("Removing Instrument");
    Instrument instrument = sortedInstruments.values.elementAt(index);

    sortedInstruments[instrument.id]!.isFavorite = false;
    logger.d("Removing instrument ${instrument.name}");

    if(await InstrumentFirestore().removeInstrument(profileId: profile.id, instrumentId: instrument.id)){
      favInstruments.remove(instrument.id);
    }

    sortFavInstruments();
    update([AppPageIdConstants.instruments]);
  }

  @override
  void makeMainInstrument(Instrument instrument){
    logger.d("Main instrument ${instrument.name}");

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
    Get.find<AppDrawerController>().updateProfile(profile);
    update([AppPageIdConstants.instruments]);

  }

  @override
  void sortFavInstruments(){

    sortedInstruments = {};

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
