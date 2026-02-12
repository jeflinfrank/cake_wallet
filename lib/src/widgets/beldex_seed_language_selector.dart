import 'package:cake_wallet/entities/seed_type.dart';
import 'package:cake_wallet/generated/i18n.dart';
import 'package:cake_wallet/src/screens/new_wallet/widgets/select_button.dart';
import 'package:cake_wallet/src/widgets/beldex_seed_language_picker.dart';
import 'package:cake_wallet/utils/show_pop_up.dart';
import 'package:flutter/material.dart';

class BeldexSeedLanguageSelector extends StatefulWidget {
  BeldexSeedLanguageSelector({
    required this.initialSelected,
    this.seedType = BeldexSeedType.defaultSeedType,
    this.buttonKey,
    this.borderRadius,
    Key? key,
  }) : super(key: key);

  final String initialSelected;
  final BeldexSeedType seedType;
  final Key? buttonKey;
  final BorderRadius? borderRadius;

  @override
  BeldexSeedLanguageSelectorState createState() => BeldexSeedLanguageSelectorState(selected: initialSelected);
}

class BeldexSeedLanguageSelectorState extends State<BeldexSeedLanguageSelector> {
  BeldexSeedLanguageSelectorState({required this.selected});
  String selected;

  @override
  Widget build(BuildContext context) {
    return SelectButton(
      borderRadius: widget.borderRadius,
      key: widget.buttonKey,
      image: null,
      text:
          "${beldexSeedLanguages.firstWhere((e) => e.name == selected).nameLocalized} (${S.of(context).seed_language})",
      onTap: () async {
        await showPopUp<String>(
          context: context,
          builder: (_) => BeldexSeedLanguagePicker(
            selected: this.selected,
            seedType: widget.seedType,
            onItemSelected: (String selected) => setState(() => this.selected = selected),
          ),
        );
      },
    );
  }
}
