import 'package:flutter/material.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';

import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:sint/sint.dart';

import '../utils/constants/instrument_translation_constants.dart';
import 'instrument_controller.dart';
import 'widgets/instrument_widgets.dart';

class InstrumentPage extends StatelessWidget {
  const InstrumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SintBuilder<InstrumentController>(
      id: AppPageIdConstants.instruments,
      init: InstrumentController(),
      builder: (controller) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SintAppBar(
            title: InstrumentTranslationConstants.instrumentSelection.tr,
          ),
        ),
        body: Container(
          decoration: AppTheme.appBoxDecoration,
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  onChanged: (value) => controller.searchQuery = value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '${InstrumentTranslationConstants.instrumentSelection.tr}...',
                    hintStyle: TextStyle(color: AppColor.textMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColor.textTertiary, size: 20),
                    filled: true,
                    fillColor: AppColor.surfaceDim,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.getMain(), width: 1.5),
                    ),
                  ),
                ),
              ),
              // Selected count chip
              Obx(() {
                final count = controller.favInstruments.length;
                if (count == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.getMain().withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count seleccionados',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.getMain(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Grid
              Expanded(
                child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : buildInstrumentGrid(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
