import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('it')
  ];

  /// Title for favourite routes widget
  ///
  /// In en, this message translates to:
  /// **'Your routes'**
  String get favRoutes;

  /// No description provided for @noFavRoutes.
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll find your favourire routes'**
  String get noFavRoutes;

  /// Title for favourite stops widget
  ///
  /// In en, this message translates to:
  /// **'Your stops'**
  String get favStops;

  /// No description provided for @noFavStops.
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll find your favourire stops'**
  String get noFavStops;

  /// Title for routes area selector
  ///
  /// In en, this message translates to:
  /// **'Routes and areas'**
  String get routes;

  /// Pick an area message
  ///
  /// In en, this message translates to:
  /// **'Choose an area'**
  String get pickArea;

  /// No description provided for @railwaysAndCableways.
  ///
  /// In en, this message translates to:
  /// **'Railways and Cableways'**
  String get railwaysAndCableways;

  /// No description provided for @extraurban.
  ///
  /// In en, this message translates to:
  /// **'Extra-urban'**
  String get extraurban;

  /// No description provided for @urban.
  ///
  /// In en, this message translates to:
  /// **'Urban'**
  String get urban;

  /// No description provided for @railways.
  ///
  /// In en, this message translates to:
  /// **'Railways'**
  String get railways;

  /// No description provided for @cableways.
  ///
  /// In en, this message translates to:
  /// **'Cableways'**
  String get cableways;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area {id}'**
  String area(int id);

  /// No description provided for @urbanRoutes.
  ///
  /// In en, this message translates to:
  /// **'Urbans for {area}'**
  String urbanRoutes(String area);

  /// No description provided for @extraurbanRoutes.
  ///
  /// In en, this message translates to:
  /// **'Extra-urbans for area {area}'**
  String extraurbanRoutes(int area);

  /// Title for all stops page
  ///
  /// In en, this message translates to:
  /// **'All stops'**
  String get stops;

  /// No description provided for @stopSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Find stops'**
  String get stopSearchHint;

  /// No description provided for @filterArea.
  ///
  /// In en, this message translates to:
  /// **'Pick an area'**
  String get filterArea;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Title for route detail page
  ///
  /// In en, this message translates to:
  /// **'Line {name}'**
  String route(String name);

  /// No description provided for @noRealTimeData.
  ///
  /// In en, this message translates to:
  /// **'No real-time data available'**
  String get noRealTimeData;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get onTime;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'{time}\' late'**
  String late(int time);

  /// No description provided for @early.
  ///
  /// In en, this message translates to:
  /// **'{time}\' early'**
  String early(int time);

  /// No description provided for @yetToStart.
  ///
  /// In en, this message translates to:
  /// **'Trip not started yet'**
  String get yetToStart;

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Trip finished'**
  String get ended;

  /// No description provided for @noReading.
  ///
  /// In en, this message translates to:
  /// **'No reading'**
  String get noReading;

  /// No description provided for @lastReading.
  ///
  /// In en, this message translates to:
  /// **'Last reading at {time}'**
  String lastReading(String time);

  /// No description provided for @noReadingAlert.
  ///
  /// In en, this message translates to:
  /// **'Trip progress is solely based on expected arrival time at stops. Delays are not considered. '**
  String get noReadingAlert;

  /// No description provided for @predictedReadingAlert.
  ///
  /// In en, this message translates to:
  /// **'Real-time info for this trip are not currently available. This might be because another trip has to end its journey for this one to start. An hypothesis on this has been made and informations shown here are highly speculative, so use them with care.'**
  String get predictedReadingAlert;

  /// No description provided for @noReadingAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Be careful'**
  String get noReadingAlertTitle;

  /// No description provided for @directionChoice.
  ///
  /// In en, this message translates to:
  /// **'Pick a direction'**
  String get directionChoice;

  /// No description provided for @bothDirections.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get bothDirections;

  /// No description provided for @forwardOnly.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forwardOnly;

  /// No description provided for @backwardOnly.
  ///
  /// In en, this message translates to:
  /// **'Backward'**
  String get backwardOnly;

  /// Title for news page
  ///
  /// In en, this message translates to:
  /// **'News for line {name}'**
  String news(String name);

  /// No description provided for @goToNews.
  ///
  /// In en, this message translates to:
  /// **'Go to full news'**
  String get goToNews;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop info'**
  String get stop;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String results(int count);

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'1 result'**
  String get result;

  /// No description provided for @towards.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get towards;

  /// No description provided for @noRouteMsg.
  ///
  /// In en, this message translates to:
  /// **'Oh... I\'ve found no routes'**
  String get noRouteMsg;

  /// No description provided for @noRouteHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different schedule'**
  String get noRouteHint;

  /// No description provided for @noDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Oh nooo!'**
  String get noDataTitle;

  /// No description provided for @noDataErr.
  ///
  /// In en, this message translates to:
  /// **'I could not retrieve any data :-('**
  String get noDataErr;

  /// No description provided for @noDataRetryTitle.
  ///
  /// In en, this message translates to:
  /// **'Oh-oh!'**
  String get noDataRetryTitle;

  /// No description provided for @noDataRetryErr.
  ///
  /// In en, this message translates to:
  /// **'I could not retrieve any data, but you may retry'**
  String get noDataRetryErr;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @mapSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Look for a location'**
  String get mapSearchHint;

  /// No description provided for @mapStopsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading stops data'**
  String get mapStopsLoading;

  /// No description provided for @mapStopsLoadingFailed.
  ///
  /// In en, this message translates to:
  /// **'No stop data'**
  String get mapStopsLoadingFailed;

  /// No description provided for @routeStart.
  ///
  /// In en, this message translates to:
  /// **'Pick a starting point'**
  String get routeStart;

  /// No description provided for @routeEnd.
  ///
  /// In en, this message translates to:
  /// **'Pick a destination point'**
  String get routeEnd;

  /// No description provided for @yourPosition.
  ///
  /// In en, this message translates to:
  /// **'Your position'**
  String get yourPosition;

  /// No description provided for @routePlan.
  ///
  /// In en, this message translates to:
  /// **'Plan your trip'**
  String get routePlan;

  /// No description provided for @noDirectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Trip directions will appear here'**
  String get noDirectionInfo;

  /// No description provided for @fullTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'{h} h {min} min'**
  String fullTimeInfo(int h, int min);

  /// No description provided for @shortTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String shortTimeInfo(int min);

  /// No description provided for @bus.
  ///
  /// In en, this message translates to:
  /// **'BUS'**
  String get bus;

  /// No description provided for @rail.
  ///
  /// In en, this message translates to:
  /// **'TRAIN'**
  String get rail;

  /// No description provided for @cableway.
  ///
  /// In en, this message translates to:
  /// **'C.WAY'**
  String get cableway;

  /// No description provided for @noStepInfo.
  ///
  /// In en, this message translates to:
  /// **'No route information is available'**
  String get noStepInfo;

  /// No description provided for @stepInfo.
  ///
  /// In en, this message translates to:
  /// **'Planned departure: {time} from {place}'**
  String stepInfo(String time, String place);

  /// No description provided for @onFootInfo.
  ///
  /// In en, this message translates to:
  /// **'About {time} on foot ({distance})'**
  String onFootInfo(String time, String distance);

  /// No description provided for @onFootInfoWait.
  ///
  /// In en, this message translates to:
  /// **'About {time} on foot ({distance}), then wait up to {wait}'**
  String onFootInfoWait(String time, String distance, String wait);

  /// No description provided for @departureTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'According to schedule'**
  String get departureTimeInfo;

  /// No description provided for @transferring.
  ///
  /// In en, this message translates to:
  /// **'Transferring'**
  String get transferring;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'{km}.{m}km'**
  String distance(int km, int m);

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get minute;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{min} minutes'**
  String minutes(int min);

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'{h} hours'**
  String hours(int h);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'{h}h {min}min'**
  String time(int h, int min);

  /// No description provided for @intermediateStop.
  ///
  /// In en, this message translates to:
  /// **'1 stop with public transport ({time})'**
  String intermediateStop(String time);

  /// No description provided for @intermediateStops.
  ///
  /// In en, this message translates to:
  /// **'{stops} stops with public transport ({time})'**
  String intermediateStops(int stops, String time);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
