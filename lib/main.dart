import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus/l10n/l10n.dart';
import 'package:trasportimus/pages/main_page.dart';
import 'package:trasportimus/pages/map_page.dart';
import 'package:trasportimus/pages/routes_area_selector.dart';
import 'package:trasportimus/pages/settings.dart';
import 'package:trasportimus/pages/stops_list.dart';
import 'package:trasportimus/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesWithCache prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {'stops', 'routes', 'locale'},
    ),
  );
  runApp(MyApp(prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferencesWithCache prefs;

  const MyApp(this.prefs, {super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late final PrefsBloc prefsBloc;
  late String locale;

  @override
  void initState() {
    super.initState();
    prefsBloc = PrefsBloc(widget.prefs);
    prefsBloc.add(GetLocale());
    locale = Platform.localeName;
    locale = locale.substring(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<TransportBloc>(
          create: (context) => TransportBloc(),
        ),
        BlocProvider<PrefsBloc>.value(
          value: prefsBloc,
        )
      ],
      child: BlocListener<PrefsBloc, PrefsState>(
        bloc: prefsBloc,
        listener: (context, state) {
          if (state is PrefsLocaleRead) {
            if (state.locale != null) {
              setState(() {
                locale = state.locale!;
              });
            }
          } else if (state is PrefsLocaleUpdated) {
            setState(() {
              locale = state.locale;
            });
          }
        },
        child: MaterialApp(
          title: 'Transportimus',
          theme: Defaults.themeData,
          supportedLocales: L10n.all,
          locale: L10n.names.contains(locale) ? Locale(locale) : Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: AnimatedSplashScreen.withScreenFunction(
            splash: Center(
              child: Defaults.loader,
            ),
            screenFunction: () async {
              return const DefaultTabController(
                length: 5,
                child: Scaffold(
                  body: TabBarView(children: [
                    MainPage(),
                    AreaChoosingPage(),
                    StopsList(),
                    MapPage(),
                    SettingsPage(),
                  ]),
                  bottomNavigationBar: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    labelPadding: EdgeInsets.all(8),
                    labelStyle: TextStyle(fontSize: 32),
                    tabs: [
                      Icon(MingCuteIcons.mgc_home_1_line),
                      Icon(MingCuteIcons.mgc_bus_2_line),
                      Icon(MingCuteIcons.mgc_desk_line),
                      Icon(MingCuteIcons.mgc_route_line),
                      Icon(MingCuteIcons.mgc_settings_4_line),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
