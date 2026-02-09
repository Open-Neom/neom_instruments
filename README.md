# neom_instruments

Instrument Preferences Module for the Open Neom ecosystem.

neom_instruments manages user preferences related to musical instruments or specialized tools relevant to a user's profile type. It provides a user-friendly interface for selecting, adding, removing, and designating a "main" instrument, enabling granular personalization and community connections based on shared expertise.

This module is crucial for enhancing profile personalization, particularly for "App Artist" profiles, but its design is extensible for other specialized roles. It adheres to Clean Architecture principles, ensuring robust, testable, and decoupled logic.

## Features & Components

### Instrument Selection
- **Browse instruments**: Full list loaded from JSON asset
- **Add/Remove favorites**: Manage personal instrument list
- **Main instrument**: Designate primary skill for profile
- **Sorted display**: Favorites prioritized at top

### Profile Integration
- **AppProfile sync**: Updates user profile with instruments
- **Main feature**: Sets profile's main feature for matching
- **Firestore persistence**: Real-time sync with backend

### UI Components
- **InstrumentsPage**: Full instrument catalog browser
- **InstrumentFavPage**: Manage favorite instruments
- **InstrumentWidgets**: Reusable instrument display components

## Architecture

```
lib/
├── data/
│   └── firestore/
│       └── profile_instruments_firestore.dart
├── ui/
│   ├── instrument_controller.dart
│   ├── instruments_page.dart
│   ├── instrument_fav_page.dart
│   └── widgets/
│       └── instrument_widgets.dart
├── utils/
│   └── constants/
│       └── instrument_translation_constants.dart
└── instrument_routes.dart
```

## Dependencies

```yaml
dependencies:
  neom_core: ^2.0.0      # Core services, models, Firebase
  neom_commons: ^1.0.0   # Shared UI components
```

## Usage

### Navigating to Instruments

```dart
import 'package:neom_instruments/instrument_routes.dart';

// View all instruments
Sint.toNamed(InstrumentRoutes.instruments);

// View favorite instruments
Sint.toNamed(InstrumentRoutes.instrumentFav);
```

### Using Instrument Controller

```dart
import 'package:sint/sint.dart';
import 'package:neom_instruments/ui/instrument_controller.dart';

class MyController extends SintController {
  final instrumentController = Sint.find<InstrumentController>();

  void addToFavorites(int index) {
    instrumentController.addInstrument(index);
  }

  void setAsMain(Instrument instrument) {
    instrumentController.makeMainInstrument(instrument);
  }
}
```

### Accessing Instruments

```dart
// Get all available instruments
Map<String, Instrument> all = instrumentController.instruments;

// Get user's favorite instruments
Map<String, Instrument> favorites = instrumentController.favInstruments;

// Get sorted list (favorites first)
Map<String, Instrument> sorted = instrumentController.sortedInstruments;
```

## Supported Instruments

The module includes 37 predefined instruments:

| Category | Instruments |
|----------|-------------|
| **Strings** | Guitar, Bass, Violin, Viola, Cello, Ukulele, Mandolin, Harp, Sitar, Guitarrón |
| **Keys** | Piano, Keyboard, Accordion, Melodica, Docerola |
| **Winds** | Flute, Clarinet, Oboe, Saxophone, Trumpet, Trombone, Tuba, Harmonica, Pan Flute, Piccolo |
| **Percussion** | Drums, Percussion, Tambourine, Marimba, Xylophone, Tibetan Bowl |
| **Electronic** | DJ, Turntable |
| **Voice** | Vocal |
| **Traditional** | Concertina |

## ROADMAP 2026

### Q1 2026 - Enhanced Instrument Data
- [ ] Skill level per instrument (beginner/intermediate/advanced/professional)
- [ ] Years of experience tracking
- [ ] Certification/education records
- [ ] Audio samples per instrument

### Q2 2026 - Discovery & Matching
- [ ] Find musicians by instrument
- [ ] Instrument compatibility suggestions
- [ ] Band formation recommendations
- [ ] Session musician marketplace

### Q3 2026 - Learning Integration
- [ ] Practice tracking
- [ ] Lesson scheduling with teachers
- [ ] Progress milestones
- [ ] Achievement badges

### Q4 2026 - Extended Categories
- [ ] Production tools (DAWs, plugins)
- [ ] Research instruments (biofeedback, sensors)
- [ ] Custom instrument definitions
- [ ] Gear and equipment tracking

## Technical Highlights

### Service Injection Pattern
```dart
class InstrumentController extends SintController implements InstrumentService {
  final userServiceImpl = Sint.find<UserService>();

  // Reactive state
  final RxMap<String, Instrument> _instruments = <String,Instrument>{}.obs;
  final RxMap<String, Instrument> _favInstruments = <String,Instrument>{}.obs;
}
```

### Loading from JSON Asset
```dart
Future<void> loadInstruments() async {
  String instrumentStr = await rootBundle.loadString(DataAssets.instrumentsJsonPath);
  List<dynamic> instrumentJSON = jsonDecode(instrumentStr);

  for (var instrJSON in instrumentJSON) {
    instrumentList.add(Instrument.fromJsonDefault(instrJSON));
  }
}
```

### Optimistic Updates
```dart
// Fire-and-forget for faster UX
InstrumentFirestore().addInstrument(profileId: profile.id, instrumentId: instrument.name);
favInstruments[instrument.id] = instrument;
sortFavInstruments();
update([AppPageIdConstants.instruments]);
```

## Translation Constants

All instrument names and UI strings support localization:

```dart
class InstrumentTranslationConstants {
  static const String instrumentSelection = "instrumentSelection";
  static const String addInstrument = "addInstrument";
  static const String selectedAsMainInstrument = "selectedAsMainInstrument";
  // ... instrument names
  static const String guitar = "guitar";
  static const String piano = "piano";
  // etc.
}
```

## Contributing

We welcome contributions to neom_instruments! If you're passionate about user preferences, data management, or enhancing personalization features, your contributions can significantly improve how users express themselves within Open Neom.

To understand the broader architectural context of Open Neom and how neom_instruments fits into the overall vision of Tecnozenism, please refer to the main project's MANIFEST.md.

## License

This project is licensed under the Apache License, Version 2.0, January 2004. See the LICENSE file for details.
