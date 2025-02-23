import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart';
import 'package:trasportimus/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

const supportedLocales = {'it': 'Italiano', 'en': 'English'};

class SettingsPageState extends State<SettingsPage> {
  late final PrefsBloc prefs;
  late AppLocalizations loc;
  late String selectedLocale;
  late bool hasChanged;

  @override
  void initState() {
    super.initState();
    prefs = context.read<PrefsBloc>();
    prefs.add(GetLocale());
    hasChanged = false;
    selectedLocale = 'en';
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.settings,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Defaults.gradient,
            boxShadow: Defaults.shadows,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      body: BlocConsumer<PrefsBloc, PrefsState>(
        bloc: prefs,
        listener: (context, state) {
          if (state is PrefsLocaleRead) {
            if (state.locale != null) {
              setState(() {
                selectedLocale = state.locale!;
              });
            }
          } else if (state is PrefsLocaleUpdated) {
            setState(() {
              selectedLocale = state.locale;
            });
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 8),
                width: double.infinity,
                padding: EdgeInsets.all(12.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: Defaults.borderRadius),
                  child: PromptedChoice<String>.single(
                    title: loc.language,
                    value: selectedLocale,
                    onChanged: (selected) {
                      if (selected != null) {
                        prefs.add(SetLocale(selected));
                      }
                    },
                    itemCount: supportedLocales.length,
                    itemBuilder: (state, i) {
                      var code =
                          AppLocalizations.supportedLocales[i].languageCode;
                      return RadioListTile(
                        value: code,
                        groupValue: state.single,
                        dense: true,
                        onChanged: (value) {
                          state.select(code);
                        },
                        title: ChoiceText(
                          supportedLocales[code]!,
                        ),
                      );
                    },
                    promptDelegate: ChoicePrompt.delegatePopupDialog(
                      maxHeightFactor: 0.17,
                      shape: RoundedRectangleBorder(borderRadius: Defaults.borderRadius),
                    ),
                    anchorBuilder: ChoiceAnchor.create(inline: true),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
