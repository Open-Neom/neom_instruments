import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:neom_commons/core/data/firestore/constants/app_firestore_collection_constants.dart';
import 'package:neom_commons/core/domain/model/app_profile.dart';
import 'package:neom_commons/core/utils/app_utilities.dart';
import 'package:neom_commons/core/utils/enums/profile_type.dart';
import '../../domain/repository/profile_instruments_repository.dart';

class ProfileInstrumentsFirestore implements ProfileInstrumentsRepository {

  var logger = AppUtilities.logger;
  final profileInstrumentsReference = FirebaseFirestore.instance.collection(AppFirestoreCollectionConstants.profileInstruments);
  int documentTimelineCounter = 0;

  @override
  Future<List<AppProfile>> retrieveAll() async {
    logger.i("Retrieving ProfileInstruments to improve finding musicians.");

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
    logger.e(e.toString());
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

    logger.d("RetrievingProfiles by specs");

    Map<String,AppProfile> mainInstrumentProfiles = <String, AppProfile>{};
    Map<String,AppProfile> noMainInstrumentProfiles = <String, AppProfile>{};

    try {
      await profileInstrumentsReference
          .get().then((querySnapshot) async {
        for (var document in querySnapshot.docs) {
          AppProfile profile = AppProfile.fromProfileInstruments(document.data());
          profile.id = document.id;
          if(profile.id != selfProfileId && profile.type == ProfileType.instrumentist
              && mainInstrumentProfiles.length < maxProfiles
          ) {

            if(AppUtilities.distanceBetweenPositionsRounded(profile.position!, currentPosition!) < maxDistance) {
              if(profile.instruments!.keys.contains(instrumentId)) {
                if((instrumentId == profile.mainFeature)) {
                  mainInstrumentProfiles[profile.id] = profile;
                } else {
                  noMainInstrumentProfiles[profile.id] = profile;
                }
              }
            } else {
              logger.d("Profile ${profile.id} is out of max distance");
            }
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
      logger.e(e.toString());
    }

    logger.d("${mainInstrumentProfiles.length} profiles found");
    return mainInstrumentProfiles;
  }

}
