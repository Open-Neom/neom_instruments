import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neom_commons/core/data/firestore/genre_firestore.dart';
import 'package:neom_commons/core/data/implementations/app_drawer_controller.dart';
import 'package:neom_commons/core/domain/model/app_profile.dart';
import 'package:neom_commons/core/domain/model/genre.dart';
import 'package:neom_commons/core/data/implementations/user_controller.dart';
import 'package:neom_commons/core/utils/app_utilities.dart';
import 'package:neom_commons/core/utils/constants/app_assets.dart';
import 'package:neom_commons/core/utils/constants/app_page_id_constants.dart';
import 'package:neom_instruments/genres/domain/use_cases/genres_service.dart';

class GenresController extends GetxController implements GenresService {

  var logger = AppUtilities.logger;
  final userController = Get.find<UserController>();

  final RxMap<String, Genre> _genres = <String, Genre>{}.obs;
  Map<String, Genre> get genres =>  _genres;
  set genres(Map<String, Genre> genres) => _genres.value = genres;

  final RxMap<String, Genre> _favGenres = <String,Genre>{}.obs;
  Map<String,Genre> get favGenres =>  _favGenres;
  set favGenres(Map<String,Genre> favGenres) => _favGenres.value = favGenres;

  final RxMap<String, Genre> _sortedGenres = <String,Genre>{}.obs;
  Map<String,Genre> get sortedGenres =>  _sortedGenres;
  set sortedGenres(Map<String,Genre> sortedGenres) => _sortedGenres.value = sortedGenres;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool isLoading) => _isLoading.value = isLoading;

  AppProfile profile = AppProfile();

  @override
  void onInit() async {
    super.onInit();
    logger.d("Genres Init");
    await loadGenres();

    if(userController.profile.genres != null) {
      favGenres = userController.profile.genres!;
    }

    profile = userController.profile;

    sortFavGenres();

  }


  @override
  Future<void> loadGenres() async {
    logger.d("");
    String genreStr = await rootBundle.loadString(AppAssets.genresJsonPath);
    
    List<dynamic> genresJSON = jsonDecode(genreStr);
    List<Genre> genresList = [];
    for (var genreJSON in genresJSON) {
      genresList.add(Genre.fromJsonDefault(genreJSON));
    }

    logger.d("${genresList.length} loaded genres from json");

    genres = { for (var e in genresList) e.name : e };

    isLoading = false;
    update([AppPageIdConstants.genres]);
  }


  @override
  Future<void>  addGenre(int index) async {
    logger.d("");

    Genre genre = sortedGenres.values.elementAt(index);
    sortedGenres[genre.id]!.isFavorite = true;

    logger.i("Adding genre ${genre.name}");
    if(await GenreFirestore().addGenre(profileId: profile.id, genreId:  genre.name)){
      favGenres[genre.id] = genre;
    }

    sortFavGenres();
    update([AppPageIdConstants.genres]);
  }

  @override
  Future<void> removeGenre(int index) async {
    logger.d("Removing Genre");
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
    for (var genr in favGenres.values) {
      if(genr.isMain) {
        genr.isMain = false;
        prevGenreId = genr.id;
      }
    }
    genre.isMain = true;
    favGenres.update(genre.name, (genr) => genr);
    GenreFirestore().updateMainGenre(profileId: profile.id,
      genreId: genre.id, prevGenreId:  prevGenreId);

    profile.genres![genre.id] = genre;
    Get.find<AppDrawerController>().updateProfile(profile);
    update([AppPageIdConstants.genres]);


  }

  @override
  void sortFavGenres(){

    sortedGenres = {};

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


}
