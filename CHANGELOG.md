# Changelog

All notable changes to neom_instruments will be documented in this file.

## [1.5.0] - 2026-02-08

### Added
- Comprehensive README with ROADMAP 2026
- Architecture documentation with directory structure
- Usage examples for controller and navigation
- Complete instrument translation constants (37 instruments)
- Instrument catalog table by category

### Documentation
- Detailed Q1-Q4 2026 roadmap including:
  - Skill levels and experience tracking
  - Musician discovery and matching
  - Learning integration and practice tracking
  - Extended categories (DAWs, research tools)

### Changed
- Updated flutter_lints to ^6.0.0

## [1.4.0] - 2025-12-01

### Added
- Extended instrument name translations
- All 37 instruments now have translation constants

## [1.3.0] - 2025-10-15

### Architectural Enhancements

#### Service Decoupling
- InstrumentController now uses UserService interface instead of UserController
- Implemented Dependency Inversion Principle (DIP) for improved testability

#### Module-Specific Translations
- Introduced InstrumentTranslationConstants for all module-specific keys
- Translation keys: instrumentSelection, addInstrument, notDetermined, selectedAsMainInstrument, etc.

#### Enhanced Instrument Management
- Improved logic for loading instruments from JSON asset
- Refined add/remove/main instrument workflow
- Enhanced sorting to prioritize favorites

### Integration
- Adopted updated service injection patterns from neom_core
- Benefits from consolidated utilities from neom_commons

## [1.2.0] - 2025-08-01

### Added
- InstrumentFavPage for managing favorite instruments
- Main instrument designation feature
- AppDrawerService integration for profile updates

### Changed
- Optimistic updates for faster UX (fire-and-forget Firestore calls)
- Improved sorting algorithm for instrument display

## [1.1.0] - 2025-06-15

### Added
- InstrumentsPage for full instrument catalog
- JSON asset loading for instrument data
- Firestore integration for persistence

### Fixed
- Duplicate instrument handling
- Null safety for profile instruments

## [1.0.0] - 2025-05-01

### Initial Release
- Basic instrument CRUD operations
- Profile instrument integration
- Favorite instruments management
- Main instrument selection
