import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neom_commons/core/data/firestore/genre_firestore.dart';
import 'package:neom_commons/core/data/implementations/app_drawer_controller.dart';
import 'package:neom_commons/core/data/implementations/user_controller.dart';
import 'package:neom_commons/core/domain/model/app_profile.dart';
import 'package:neom_commons/core/domain/model/genre.dart';
import 'package:neom_commons/core/utils/app_color.dart';
import 'package:neom_commons/core/utils/app_utilities.dart';
import 'package:neom_commons/core/utils/constants/app_assets.dart';
import 'package:neom_commons/core/utils/constants/app_page_id_constants.dart';

import '../../domain/use_cases/genres_service.dart';

class GenresController extends GetxController implements GenresService {

  var logger = AppUtilities.logger;
  final userController = Get.find<UserController>();

  final RxMap<String, Genre> genres = <String, Genre>{}.obs;
  final RxMap<String, Genre> favGenres = <String,Genre>{}.obs;
  final RxMap<String, Genre> sortedGenres = <String,Genre>{}.obs;
  final RxBool isLoading = true.obs;

  RxList<Genre> selectedGenres = <Genre>[].obs;

  AppProfile profile = AppProfile();

  @override
  void onInit() async {
    super.onInit();
    logger.t("Genres Init");
    await loadGenres();

    if(userController.profile.genres != null) {
      favGenres.value = userController.profile.genres!;
    }

    profile = userController.profile;

    sortFavGenres();

  }


  @override
  Future<void> loadGenres() async {
    logger.t("loadGenres");
    String genreStr = await rootBundle.loadString(AppAssets.genresJsonPath);
    
    List<dynamic> genresJSON = jsonDecode(genreStr);
    List<Genre> genresList = [];
    for (var genreJSON in genresJSON) {
      genresList.add(Genre.fromJsonDefault(genreJSON));
    }

    logger.d("${genresList.length} loaded genres from json");

    genres.value = {for (var e in genresList) e.name : e};

    isLoading.value = false;
    update([AppPageIdConstants.genres]);
  }


  @override
  Future<void> addGenre(int index) async {
    logger.t("addGenre");

    Genre genre = sortedGenres.values.elementAt(index);
    sortedGenres[genre.id]!.isFavorite = true;

    logger.d("Adding genre ${genre.name}");
    if(await GenreFirestore().addGenre(profileId: profile.id, genreId:  genre.name)){
      favGenres[genre.id] = genre;
    }

    sortFavGenres();
    update([AppPageIdConstants.genres]);
  }

  @override
  Future<void> removeGenre(int index) async {
    logger.t("Removing Genre");
    Genre genre = sortedGenres.values.elementAt(index);

    sortedGenres[genre.id]!.isFavorite = false;
    logger.d("Removing genre ${genre.name}");

    if(await GenreFirestore().removeGenre(profileId: profile.id, genreId: genre.id)){
      favGenres.remove(genre.id);
    }

    sortFavGenres();
    update([AppPageIdConstants.genres]);
  }

  @override
  void makeMainGenre(Genre genre){
    logger.d("Main genre ${genre.name}");

    String prevGenreId = "";
    for (var g in favGenres.values) {
      if(g.isMain) {
        g.isMain = false;
        prevGenreId = g.id;
      }
    }

    genre.isMain = true;
    favGenres.update(genre.name, (g) => g);
    GenreFirestore().updateMainGenre(profileId: profile.id,
      genreId: genre.id, prevGenreId:  prevGenreId);

    profile.genres![genre.id] = genre;
    Get.find<AppDrawerController>().updateProfile(profile);
    update([AppPageIdConstants.genres]);


  }

  @override
  void sortFavGenres(){

    sortedGenres.value = {};

    for (var genre in genres.values) {
      if (favGenres.containsKey(genre.id)) {
        sortedGenres[genre.id] = favGenres[genre.id]!;
      }
    }

    for (var genre in genres.values) {
      if (!favGenres.containsKey(genre.id)) {
        sortedGenres[genre.id] = genres[genre.id]!;
      }
    }

  }

  Iterable<Widget> get genreChips sync* {

    for (Genre genre in genres.values) {
      yield Padding(
        padding: const EdgeInsets.all(5.0),
        child: FilterChip(
          backgroundColor: AppColor.main50,
          avatar: CircleAvatar(
            backgroundColor: Colors.cyan.shade500,
            child: Text(genre.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          label: Text(genre.name.capitalize, style: const TextStyle(fontSize: 12),),
          selected: selectedGenres.contains(genre),
          selectedColor: AppColor.main50,
          onSelected: (bool selected) {
            genre.isFavorite = true;
            selected ? addGenreFromChips(genre) : removeGenreFromChips(genre);
          },
        ),
      );
    }
  }

  void addGenreFromChips(Genre genre) {
    selectedGenres.add(genre);
    update();
  }

  void removeGenreFromChips(Genre genre){
    selectedGenres.removeWhere((g) {
      return g == genre;
    });
    update();
  }


}
