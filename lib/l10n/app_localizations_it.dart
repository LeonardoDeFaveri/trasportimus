// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get favRoutes => 'Le tue corse';

  @override
  String get noFavRoutes => 'Qui troverai le tue corse preferite';

  @override
  String get favStops => 'Le tue fermate';

  @override
  String get noFavStops => 'Qui troverai le tue fermate preferite';

  @override
  String get routes => 'Linee e tratte';

  @override
  String get pickArea => 'Scegli un area di riferimento';

  @override
  String get railwaysAndCableways => 'Ferrovie e Funivie';

  @override
  String get extraurban => 'Extraurbano';

  @override
  String get urban => 'Urbano';

  @override
  String get railways => 'Ferrovie';

  @override
  String get cableways => 'Funivie';

  @override
  String area(int id) {
    return 'Bacino $id';
  }

  @override
  String urbanRoutes(String area) {
    return 'Urbane area $area';
  }

  @override
  String extraurbanRoutes(int area) {
    return 'Extraurbane bacino $area';
  }

  @override
  String get stops => 'Lista fermate';

  @override
  String get stopSearchHint => 'Cerca fermate';

  @override
  String get filterArea => 'Filtra per area';

  @override
  String get all => 'Tutte';

  @override
  String route(String name) {
    return 'Linea $name';
  }

  @override
  String get noRealTimeData => 'Dati in tempo reale non disponibili';

  @override
  String get onTime => 'In orario';

  @override
  String late(int time) {
    return 'In ritardo di $time\'';
  }

  @override
  String early(int time) {
    return 'In anticipo di $time\'';
  }

  @override
  String get yetToStart => 'Corsa non ancora iniziata';

  @override
  String get ended => 'Corsa terminata';

  @override
  String get noReading => 'Nessun rilevamento';

  @override
  String lastReading(String time) {
    return 'Ultimo rilevamento alle $time';
  }

  @override
  String get noReadingAlert => 'Lo stato di avanzamento della corsa è basato unicamente sull\'orario previsto. Ritardi ed anticipi non sono considerati.';

  @override
  String get predictedReadingAlert => 'Lo stato della corsa non è disponibile. Può essere che un\'altra corsa debba terminare prima che questa possa iniziare. Le informazioni qui mostrate sono frutto di una stima e potrebbero quindi essere errate.';

  @override
  String get noReadingAlertTitle => 'Occhio';

  @override
  String get directionChoice => 'Filtra per direzione';

  @override
  String get bothDirections => 'Entrambe';

  @override
  String get forwardOnly => 'Andata';

  @override
  String get backwardOnly => 'Ritorno';

  @override
  String news(String name) {
    return 'Avvisi per la linea $name';
  }

  @override
  String get goToNews => 'Vai al comunicato';

  @override
  String get stop => 'Fermata';

  @override
  String results(int count) {
    return '$count risultati';
  }

  @override
  String get result => '1 risultato';

  @override
  String get towards => 'verso';

  @override
  String get noRouteMsg => 'Oh... non ho trovato corse';

  @override
  String get noRouteHint => 'Prova con un altro orario';

  @override
  String get noDataTitle => 'Oh nooo!';

  @override
  String get noDataErr => 'Non riesco a recuperare i dati :-(';

  @override
  String get noDataRetryTitle => 'Oh-oh!';

  @override
  String get noDataRetryErr => 'Non sono riuscito a recuperare i dati, ma potresti riprovare!';

  @override
  String get retry => 'Riprova';

  @override
  String get mapSearchHint => 'Cerca una località';

  @override
  String get mapStopsLoading => 'Sto recuperando le fermate';

  @override
  String get mapStopsLoadingFailed => 'Nessuna fermata trovata';

  @override
  String get routeStart => 'Scegli un punto di partenza';

  @override
  String get routeEnd => 'Scegli una destinazione';

  @override
  String get yourPosition => 'La tua posizione';

  @override
  String get routePlan => 'Pianifica';

  @override
  String get noDirectionInfo => 'Le indicazioni appariranno qui';

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
  String get rail => 'TRENO';

  @override
  String get cableway => 'FUN';

  @override
  String get noStepInfo => 'Nessuna informazione disponibile sul percorso';

  @override
  String stepInfo(String time, String place) {
    return 'Partenza prevista: $time da $place';
  }

  @override
  String onFootInfo(String time, String distance) {
    return 'Circa $time a piedi ($distance)';
  }

  @override
  String onFootInfoWait(String time, String distance, String wait) {
    return 'Circa $time a piedi ($distance), poi attendi fino a $wait';
  }

  @override
  String get departureTimeInfo => 'Secondo l\'orario previsto';

  @override
  String get transferring => 'Trasferimento';

  @override
  String distance(int km, int m) {
    return '$km,${m}km';
  }

  @override
  String get minute => '1 minuto';

  @override
  String minutes(int min) {
    return '$min minuti';
  }

  @override
  String get hour => '1 ora';

  @override
  String hours(int h) {
    return '$h ore';
  }

  @override
  String time(int h, int min) {
    return '${h}h ${min}min';
  }

  @override
  String intermediateStop(String time) {
    return '1 fermata con trasporto pubblico ($time)';
  }

  @override
  String intermediateStops(int stops, String time) {
    return '$stops fermate con trasporto pubblico ($time)';
  }

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';
}
