import 'package:flutter/material.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/utils/app_alerts.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/message_translation_constants.dart';
import 'package:neom_core/domain/model/instrument.dart';
import 'package:neom_core/utils/enums/instrument_level.dart';
import 'package:sint/sint.dart';

import '../../utils/constants/instrument_translation_constants.dart';
import '../instrument_controller.dart';

/// ─── INSTRUMENT SELECTION GRID (replaces old plain ListView) ───────────

Widget buildInstrumentGrid(BuildContext context, InstrumentController controller) {
  final instruments = controller.filteredInstruments;

  if (instruments.isEmpty && controller.searchQuery.isNotEmpty) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColor.white25),
          const SizedBox(height: 12),
          Text(
            'Sin resultados para "${controller.searchQuery}"',
            style: TextStyle(color: AppColor.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth > 700;
      final crossAxisCount = isWide ? 3 : 2;
      final childAspectRatio = isWide ? 4.0 : 3.2;

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: instruments.length,
        itemBuilder: (context, index) {
          final instrument = instruments[index];
          final isFav = controller.favInstruments.containsKey(instrument.id);

          return _InstrumentSelectionCard(
            instrument: instrument,
            isFavorite: isFav,
            onToggle: () => _handleToggle(context, controller, instrument, isFav),
          );
        },
      );
    },
  );
}

Future<void> _handleToggle(
  BuildContext context,
  InstrumentController controller,
  Instrument instrument,
  bool isFav,
) async {
  if (isFav) {
    if (controller.favInstruments.length > 1) {
      await controller.removeInstrumentById(instrument.id);
      if (!controller.favInstruments.containsKey(instrument.id)) {
        AppAlerts.showAlert(context,
          title: instrument.name.tr,
          message: MessageTranslationConstants.instrumentRemoved.tr,
        );
      }
    } else {
      AppAlerts.showAlert(context,
        title: instrument.name.tr,
        message: MessageTranslationConstants.atLeastOneInstrument.tr,
      );
    }
  } else {
    await controller.addInstrumentById(instrument.id);
    if (controller.favInstruments.containsKey(instrument.id)) {
      AppAlerts.showAlert(context,
        title: instrument.name.tr,
        message: MessageTranslationConstants.instrumentAdded.tr,
      );
    }
  }
}

class _InstrumentSelectionCard extends StatelessWidget {
  final Instrument instrument;
  final bool isFavorite;
  final VoidCallback onToggle;

  const _InstrumentSelectionCard({
    required this.instrument,
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColor.getMain();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFavorite ? mainColor : AppColor.borderMedium,
              width: isFavorite ? 2.0 : 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFavorite
                ? [mainColor.withAlpha(60), mainColor.withAlpha(25)]
                : [AppColor.surfaceCard, AppColor.surfaceDim],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      instrument.name.tr.capitalizeFirst,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isFavorite ? Colors.white : AppColor.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isFavorite ? Icons.check_circle : Icons.add_circle_outline,
                      key: ValueKey(isFavorite),
                      color: isFavorite ? mainColor : AppColor.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
              if (instrument.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    instrument.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.textTertiary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── FAVORITES LIST (improved with cards) ──────────────────────────────

Widget buildInstrumentFavList(BuildContext context, InstrumentController controller) {
  if (controller.favInstruments.isEmpty) {
    return _buildEmptyFavState(context);
  }

  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth > 700;

      if (isWide) {
        return _buildFavGrid(context, controller);
      }
      return _buildFavListView(context, controller);
    },
  );
}

Widget _buildEmptyFavState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.library_add_outlined, size: 64, color: AppColor.white15),
        const SizedBox(height: 16),
        Text(
          AppTranslationConstants.instruments.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          InstrumentTranslationConstants.addInstrument.tr,
          style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Sint.toNamed('/instrument'),
          icon: const Icon(Icons.add, size: 18),
          label: Text(InstrumentTranslationConstants.instrumentSelection.tr),
          style: FilledButton.styleFrom(
            backgroundColor: AppColor.getMain(),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFavGrid(BuildContext context, InstrumentController controller) {
  final favList = controller.favInstruments.values.toList();

  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 4.0,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
    ),
    itemCount: favList.length,
    itemBuilder: (context, index) {
      return _FavInstrumentCard(
        instrument: favList[index],
        onMakeMain: () {
          controller.makeMainInstrument(favList[index]);
          AppAlerts.showAlert(context,
            title: AppTranslationConstants.instrumentsPreferences.tr,
            message: "${favList[index].name.tr} ${InstrumentTranslationConstants.selectedAsMainInstrument.tr}",
          );
        },
      );
    },
  );
}

Widget _buildFavListView(BuildContext context, InstrumentController controller) {
  final favList = controller.favInstruments.values.toList();

  return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    itemCount: favList.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _FavInstrumentCard(
          instrument: favList[index],
          onMakeMain: () {
            controller.makeMainInstrument(favList[index]);
            AppAlerts.showAlert(context,
              title: AppTranslationConstants.instrumentsPreferences.tr,
              message: "${favList[index].name.tr} ${InstrumentTranslationConstants.selectedAsMainInstrument.tr}",
            );
          },
        ),
      );
    },
  );
}

class _FavInstrumentCard extends StatelessWidget {
  final Instrument instrument;
  final VoidCallback onMakeMain;

  const _FavInstrumentCard({
    required this.instrument,
    required this.onMakeMain,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColor.getMain();
    final isMain = instrument.isMain;
    final level = instrument.instrumentLevel;
    final hasLevel = level != InstrumentLevel.notDetermined;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onMakeMain,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isMain ? mainColor : AppColor.borderMedium,
              width: isMain ? 2.0 : 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isMain
                ? [mainColor.withAlpha(50), mainColor.withAlpha(20)]
                : [AppColor.surfaceCard, AppColor.surfaceDim],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Main indicator
              if (isMain)
                Container(
                  width: 4,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            instrument.name.tr.capitalizeFirst,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isMain ? FontWeight.w700 : FontWeight.w500,
                              color: isMain ? Colors.white : AppColor.textSecondary,
                            ),
                          ),
                        ),
                        if (isMain)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: mainColor.withAlpha(40),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppTranslationConstants.mainInstrument.tr,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: mainColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (hasLevel) ...[
                      const SizedBox(height: 4),
                      Text(
                        level.name.tr.capitalizeFirst,
                        style: TextStyle(fontSize: 12, color: AppColor.textTertiary),
                      ),
                    ],
                    if (instrument.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        instrument.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.textMuted,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Action
              if (!isMain)
                IconButton(
                  icon: Icon(Icons.star_outline, color: AppColor.textMuted, size: 20),
                  onPressed: onMakeMain,
                  tooltip: InstrumentTranslationConstants.selectedAsMainInstrument.tr,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
