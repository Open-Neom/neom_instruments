
import 'package:neom_core/core/domain/model/instrument.dart';

abstract class InstrumentService {

  Future<void> loadInstruments();
  Future<void>  addInstrument(int index);
  Future<void> removeInstrument(int index);
  void makeMainInstrument(Instrument instrument);
  void sortFavInstruments();

}
