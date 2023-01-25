import 'package:neom_commons/core/domain/model/genre.dart';

abstract class GenresService {

  Future<void> loadGenres();
  Future<void>  addGenre(int index);
  Future<void> removeGenre(int index);
  void makeMainGenre(Genre genre);
  void sortFavGenres();

}
