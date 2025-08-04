### 1.3.0 - Architectural Enhancements & Translations

This release for `neom_instruments` introduces significant architectural refinements, primarily focusing on enhancing decoupling and integrating module-specific translations, in line with the broader Open Neom refactoring efforts.

**Key Architectural & Feature Improvements:**

* **Service Decoupling for User Data:**
    * The `InstrumentController` now interacts with user profile data through the `UserService` interface (instead of directly with `UserController`). This promotes the Dependency Inversion Principle (DIP), making the module more robust and testable by abstracting the user data source.

* **Module-Specific Translations:**
    * Introduced `InstrumentTranslationConstants` to centralize and manage all module-specific translation keys. This ensures that `neom_instruments`' UI text is easily localizable and maintainable, aligning with Open Neom's comprehensive internationalization strategy.
    * Examples of new translation keys include: `instrumentSelection`, `addInstrument`, `notDetermined`, `selectedAsMainInstrument`, `instrumentPreferences`, `defaultInstrumentLevel`.

* **Enhanced Instrument Management:**
    * Improved logic for loading instruments from a local JSON asset, making the instrument list readily available.
    * Refined the process for adding, removing, and designating a "main" instrument for a user's profile.
    * Enhanced sorting of instruments to prioritize favorited ones, improving user experience.

* **Integration with Global Architectural Changes:**
    * Adopts the updated service injection patterns established in `neom_core`'s recent refactor, ensuring consistent dependency management across the ecosystem.
    * Benefits from consolidated utilities and shared UI components from `neom_commons`.

**Overall Benefits of this Release:**

* **Increased Testability:** Decoupling from concrete controllers allows for easier mocking and unit testing of `InstrumentController`'s business logic.
* **Improved Maintainability:** Clearer separation of concerns makes the module easier to understand, debug, and extend.
* **Enhanced Localization:** Dedicated translation constants streamline the process of supporting multiple languages for instrument-related UI.
* **Richer User Personalization:** Provides a more robust and flexible way for users to manage their instrument preferences, contributing to a more detailed profile.