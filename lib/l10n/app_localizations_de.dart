// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get favRoutes => 'Ihre zeilen';

  @override
  String get noFavRoutes => 'Hier findest du deine lieblingszeilen';

  @override
  String get favStops => 'Ihre stopps';

  @override
  String get noFavStops => 'Hier finden sie ihre lieblingsstopps';

  @override
  String get routes => 'Linien und routen';

  @override
  String get pickArea => 'Wählen sie einen bereich aus';

  @override
  String get railwaysAndCableways => 'Eisenbahnen und Seilbahnen';

  @override
  String get extraurban => 'Außerstädtisch';

  @override
  String get urban => 'Urban';

  @override
  String get railways => 'Eisenbahnen';

  @override
  String get cableways => 'Seilbahnen';

  @override
  String area(int id) {
    return 'Bereich $id';
  }

  @override
  String urbanRoutes(String area) {
    return 'Urbans für gebiet $area';
  }

  @override
  String extraurbanRoutes(int area) {
    return 'Außerorts für gebiet $area';
  }

  @override
  String get stops => 'Stoppliste';

  @override
  String get stopSearchHint => 'Suchstopps';

  @override
  String get filterArea => 'Hach bereich filtern';

  @override
  String get all => 'Alle';

  @override
  String route(String name) {
    return 'Linie $name';
  }

  @override
  String get noRealTimeData => 'Echtzeitdaten nicht verfügbar';

  @override
  String get onTime => 'Rechtzeitig';

  @override
  String late(int time) {
    return '$time\' zu spät';
  }

  @override
  String early(int time) {
    return '$time\' vor dem zeitplan';
  }

  @override
  String get yetToStart => 'Die reise des fahrzeugs hat noch nicht begonnen';

  @override
  String get ended => 'Die Reise des Fahrzeugs ist beendet';

  @override
  String get noReading => 'Keine erkennung';

  @override
  String lastReading(String time) {
    return 'Letzte Erkennung um $time';
  }

  @override
  String get noReadingAlert => 'Der vormarsch des fahrzeugs richtet sich ausschließlich nach der geschätzten zeit. Verzögerungen nicht berücksichtigt.';

  @override
  String get predictedReadingAlert => 'Der fahrzeugfortschrittsstatus ist nicht verfügbar. Möglicherweise muss ein anderes fahrzeug seine fahrt beenden, bevor dieses beginnen kann. Bei den hier angezeigten informationen handelt es sich um schätzungen und sie können falsch sein.';

  @override
  String get noReadingAlertTitle => 'Seien sie vorsichtig';

  @override
  String get directionChoice => 'Filtern nach richtung';

  @override
  String get bothDirections => 'Beide';

  @override
  String get forwardOnly => 'Nach vorne';

  @override
  String get backwardOnly => 'Rückwärts';

  @override
  String news(String name) {
    return 'Notizen zu zeile $name';
  }

  @override
  String get goToNews => 'Zur pressemitteilung';

  @override
  String get stop => 'Stoppen';

  @override
  String results(int count) {
    return '$count ergebnisse';
  }

  @override
  String get result => '1 ergebnis';

  @override
  String get towards => 'in richtung';

  @override
  String get noRouteMsg => 'Oh... ich habe keine Routen gefunden';

  @override
  String get noRouteHint => 'Versuchen sie es mit einem anderen zeitplan';

  @override
  String get noDataTitle => 'Oh Neeeeeeee!';

  @override
  String get noDataErr => 'Ich kann die daten nicht wiederherstellen :-(';

  @override
  String get noDataRetryTitle => 'Oh-oh!';

  @override
  String get noDataRetryErr => 'Ich konnte die daten nicht wiederherstellen, aber sie können es erneut versuchen!';

  @override
  String get retry => 'versuchen sie es erneut';

  @override
  String get mapSearchHint => 'Suche nach einer stelle';

  @override
  String get mapStopsLoading => 'Haltestellendaten werden geladen';

  @override
  String get mapStopsLoadingFailed => 'Keine stoppdaten';

  @override
  String get routeStart => 'Wählen sie einen startpunkt';

  @override
  String get routeEnd => 'Wählen sie ein ziel';

  @override
  String get yourPosition => 'Ihr standort';

  @override
  String get routePlan => 'Plan';

  @override
  String get noDirectionInfo => 'Die wegbeschreibung finden sie hier';

  @override
  String fullTimeInfo(int h, int min) {
    return '$h h $min min';
  }

  @override
  String shortTimeInfo(int min) {
    return '$min min';
  }

  @override
  String get bus => 'BUS';

  @override
  String get rail => 'ZUG';

  @override
  String get cableway => 'ATW';

  @override
  String get noStepInfo => 'Keine informationen zur route verfügbar';

  @override
  String stepInfo(String time, String place) {
    return 'Geplante abfahrt: $time von $place';
  }

  @override
  String onFootInfo(String time, String distance) {
    return 'Etwa $time zu fuß ($distance)';
  }

  @override
  String onFootInfoWait(String time, String distance, String wait) {
    return 'Ungefähr $time zu fuß ($distance), dann warten bis $wait';
  }

  @override
  String get departureTimeInfo => 'Nach zeitplan';

  @override
  String get transferring => 'Übertragung';

  @override
  String distance(int km, int m) {
    return '$km,${m}km';
  }

  @override
  String get minute => '1 minute';

  @override
  String minutes(int min) {
    return '$min minuten';
  }

  @override
  String get hour => '1 jetzt';

  @override
  String hours(int h) {
    return '$h std';
  }

  @override
  String time(int h, int min) {
    return '${h}h ${min}min';
  }

  @override
  String intermediateStop(String time) {
    return '1 haltestelle mit öffentlichen verkehrsmitteln ($time)';
  }

  @override
  String intermediateStops(int stops, String time) {
    return '$stops haltestellen des öffentlichen nahverkehrs ($time)';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Zunge';
}
