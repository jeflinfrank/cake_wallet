import 'package:flutter/material.dart';
import 'package:cake_wallet/src/widgets/picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:cake_wallet/generated/i18n.dart';

import 'package:cake_wallet/entities/seed_type.dart';

class BeldexSeedLanguagePickerOption {
  BeldexSeedLanguagePickerOption(this.name, this.nameLocalized, this.image, this.supportedSeedTypes);

  final String name;
  final String nameLocalized;
  final Image image;
  final List<BeldexSeedType> supportedSeedTypes;
}

final List<BeldexSeedLanguagePickerOption> beldexSeedLanguages = [
  BeldexSeedLanguagePickerOption(
    'English',
    S.current.seed_language_english,
    Image.asset('assets/images/flags/usa.png'),
    [BeldexSeedType.legacy, BeldexSeedType.polyseed, BeldexSeedType.bip39],
  ),
  BeldexSeedLanguagePickerOption('Chinese (Simplified)', S.current.seed_language_chinese,
      Image.asset('assets/images/flags/chn.png'), [BeldexSeedType.legacy, BeldexSeedType.polyseed]),
  BeldexSeedLanguagePickerOption('Chinese (Traditional)', S.current.seed_language_chinese_traditional,
      Image.asset('assets/images/flags/chn.png'), [BeldexSeedType.polyseed]),
  BeldexSeedLanguagePickerOption('Dutch', S.current.seed_language_dutch,
      Image.asset('assets/images/flags/nld.png'), [BeldexSeedType.legacy]),
  BeldexSeedLanguagePickerOption('German', S.current.seed_language_german,
      Image.asset('assets/images/flags/deu.png'), [BeldexSeedType.legacy]),
  BeldexSeedLanguagePickerOption('Japanese', S.current.seed_language_japanese,
      Image.asset('assets/images/flags/jpn.png'), [BeldexSeedType.legacy, BeldexSeedType.polyseed]),
  BeldexSeedLanguagePickerOption('Korean', S.current.seed_language_korean,
      Image.asset('assets/images/flags/kor.png'), [BeldexSeedType.polyseed]),
  BeldexSeedLanguagePickerOption('Portuguese', S.current.seed_language_portuguese,
      Image.asset('assets/images/flags/prt.png'), [BeldexSeedType.legacy, BeldexSeedType.polyseed]),
  BeldexSeedLanguagePickerOption('Russian', S.current.seed_language_russian,
      Image.asset('assets/images/flags/rus.png'), [BeldexSeedType.legacy]),
  BeldexSeedLanguagePickerOption('Czech', S.current.seed_language_czech,
      Image.asset('assets/images/flags/czk.png'), [BeldexSeedType.polyseed]),
  BeldexSeedLanguagePickerOption('Spanish', S.current.seed_language_spanish,
      Image.asset('assets/images/flags/esp.png'), [BeldexSeedType.legacy, BeldexSeedType.polyseed]),
  BeldexSeedLanguagePickerOption('French', S.current.seed_language_french,
      Image.asset('assets/images/flags/fra.png'), [BeldexSeedType.legacy, BeldexSeedType.polyseed]),
  BeldexSeedLanguagePickerOption('Italian', S.current.seed_language_italian,
      Image.asset('assets/images/flags/ita.png'), [BeldexSeedType.legacy, BeldexSeedType.polyseed]),
];

const beldexdefaultSeedLanguage = 'English';

enum Places { topLeft, topRight, bottomLeft, bottomRight, inside }

class BeldexSeedLanguagePicker extends StatefulWidget {
  BeldexSeedLanguagePicker({
    Key? key,
    this.selected = beldexdefaultSeedLanguage,
    this.seedType = BeldexSeedType.defaultSeedType,
    required this.onItemSelected,
  }) : super(key: key);

  final BeldexSeedType seedType;
  final String selected;
  final Function(String) onItemSelected;

  @override
  BeldexSeedLanguagePickerState createState() => BeldexSeedLanguagePickerState(
      selected: selected, onItemSelected: onItemSelected, seedType: seedType);
}

class BeldexSeedLanguagePickerState extends State<BeldexSeedLanguagePicker> {
  BeldexSeedLanguagePickerState(
      {required this.selected, required this.onItemSelected, required this.seedType});

  final BeldexSeedType seedType;
  final String selected;
  final Function(String) onItemSelected;

  @override
  Widget build(BuildContext context) {
    final availableSeedLanguages = beldexSeedLanguages
        .where((BeldexSeedLanguagePickerOption e) => e.supportedSeedTypes.contains(seedType));

    return Picker(
      selectedAtIndex: availableSeedLanguages.map((e) => e.name).toList().indexOf(selected),
      items: availableSeedLanguages.map((e) => e.name).toList(),
      images: availableSeedLanguages.map((e) => e.image).toList(),
      isGridView: true,
      title: S.of(context).seed_choose,
      hintText: S.of(context).seed_choose,
      matchingCriteria: (String language, String searchText) {
        return language.toLowerCase().contains(searchText);
      },
      onItemSelected: onItemSelected,
    );
  }
}
