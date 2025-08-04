import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/data/firestore/constants/app_firestore_collection_constants.dart';
import 'package:neom_core/domain/model/app_profile.dart';
import 'package:neom_core/domain/repository/profile_instruments_repository.dart';
import 'package:neom_core/utils/enums/profile_type.dart';
import 'package:neom_core/utils/position_utilities.dart';

class ProfileInstrumentsFirestore implements ProfileInstrumentsRepository {
  
  final profileInstrumentsReference = FirebaseFirestore.instance.collection(AppFirestoreCollectionConstants.profileInstruments);
  int documentTimelineCounter = 0;

  @override
  Future<List<AppProfile>> retrieveAll() async {
    AppConfig.logger.i("Retrieving ProfileInstruments to improve finding musicians.");

    List<AppProfile> musicianProfiles = [];

    try {

      QuerySnapshot querySnapshot = await profileInstrumentsReference.get();
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        if (queryDocumentSnapshot.exists) {
          AppProfile musician = AppProfile.fromProfileInstruments(queryDocumentSnapshot.data());
          musician.id = queryDocumentSnapshot.id;
          musicianProfiles.add(musician);
        }
      }
    } catch (e) {
    AppConfig.logger.e(e.toString());
    }

    return musicianProfiles;
  }


  @override
  Future<Map<String,AppProfile>> retrieveProfilesBySpecs({
    String instrumentId = "",
    String selfProfileId = "",
    Position? currentPosition,
    int maxDistance = 100,
    int maxProfiles = 50,
  }) async {

    AppConfig.logger.d("RetrievingProfiles by specs");

    Map<String,AppProfile> mainInstrumentProfiles = <String, AppProfile>{};
    Map<String,AppProfile> noMainInstrumentProfiles = <String, AppProfile>{};

    try {
      await profileInstrumentsReference.get().then((querySnapshot) async {
        for (var document in querySnapshot.docs) {
          AppProfile profile = AppProfile.fromProfileInstruments(document.data());
          profile.id = document. id;
          AppConfig.logger.d("Profile ${profile.id} ${profile.name} to evaluate and retrieve");


          if(profile.id != selfProfileId && profile.type == ProfileType.appArtist
              && mainInstrumentProfiles.length < maxProfiles
              && profile.position != null && currentPosition != null) {

            if(PositionUtilities.distanceBetweenPositionsRounded(profile.position!, currentPosition) < maxDistance) {
              if(profile.instruments!.keys.contains(instrumentId)) {
                if((instrumentId == profile.mainFeature)) {
                  mainInstrumentProfiles[profile.id] = profile;
                } else {
                  noMainInstrumentProfiles[profile.id] = profile;
                }
              }
            } else {
              AppConfig.logger.t("Profile ${profile.id} ${profile.name} is out of max distance");
            }
          } else {
            AppConfig.logger.t("Profile ${profile.id} ${profile.name} not compatible with specs");
          }
        }

        if(mainInstrumentProfiles.length < maxProfiles && noMainInstrumentProfiles.isNotEmpty) {
          noMainInstrumentProfiles.forEach((profileId, profile) {
            if(mainInstrumentProfiles.length < maxProfiles) {
              mainInstrumentProfiles[profileId] = profile;
            }
          });
        }
      });
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    AppConfig.logger.d("${mainInstrumentProfiles.length} profiles found");
    return mainInstrumentProfiles;
  }

}
