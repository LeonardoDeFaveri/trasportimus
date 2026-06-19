// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get favRoutes => 'Your routes';

  @override
  String get noFavRoutes => 'Here you\'ll find your favourire routes';

  @override
  String get favStops => 'Your stops';

  @override
  String get noFavStops => 'Here you\'ll find your favourire stops';

  @override
  String get routes => 'Routes and areas';

  @override
  String get pickArea => 'Choose an area';

  @override
  String get railwaysAndCableways => 'Railways and Cableways';

  @override
  String get extraurban => 'Extra-urban';

  @override
  String get urban => 'Urban';

  @override
  String get railways => 'Railways';

  @override
  String get cableways => 'Cableways';

  @override
  String area(int id) {
    return 'Area $id';
  }

  @override
  String urbanRoutes(String area) {
    return 'Urbans for $area';
  }

  @override
  String extraurbanRoutes(int area) {
    return 'Extra-urbans for area $area';
  }

  @override
  String get stops => 'All stops';

  @override
  String get stopSearchHint => 'Find stops';

  @override
  String get filterArea => 'Pick an area';

  @override
  String get all => 'All';

  @override
  String route(String name) {
    return 'Line $name';
  }

  @override
  String get noRealTimeData => 'No real-time data available';

  @override
  String get onTime => 'On time';

  @override
  String late(int time) {
    return '$time\' late';
  }

  @override
  String early(int time) {
    return '$time\' early';
  }

  @override
  String get yetToStart => 'Trip not started yet';

  @override
  String get ended => 'Trip finished';

  @override
  String get noReading => 'No reading';

  @override
  String lastReading(String time) {
    return 'Last reading at $time';
  }

  @override
  String get noReadingAlert => 'Trip progress is solely based on expected arrival time at stops. Delays are not considered. ';

  @override
  String get predictedReadingAlert => 'Real-time info for this trip are not currently available. This might be because another trip has to end its journey for this one to start. An hypothesis on this has been made and informations shown here are highly speculative, so use them with care.';

  @override
  String get noReadingAlertTitle => 'Be careful';

  @override
  String get directionChoice => 'Pick a direction';

  @override
  String get bothDirections => 'Both';

  @override
  String get forwardOnly => 'Forward';

  @override
  String get backwardOnly => 'Backward';

  @override
  String news(String name) {
    return 'News for line $name';
  }

  @override
  String get goToNews => 'Go to full news';

  @override
  String get stop => 'Stop info';

  @override
  String results(int count) {
    return '$count results';
  }

  @override
  String get result => '1 result';

  @override
  String get towards => 'To';

  @override
  String get noRouteMsg => 'Oh... I\'ve found no routes';

  @override
  String get noRouteHint => 'Try a different schedule';

  @override
  String get noDataTitle => 'Oh nooo!';

  @override
  String get noDataErr => 'I could not retrieve any data :-(';

  @override
  String get noDataRetryTitle => 'Oh-oh!';

  @override
  String get noDataRetryErr => 'I could not retrieve any data, but you may retry';

  @override
  String get retry => 'Retry';

  @override
  String get mapSearchHint => 'Look for a location';

  @override
  String get mapStopsLoading => 'Loading stops data';

  @override
  String get mapStopsLoadingFailed => 'No stop data';

  @override
  String get routeStart => 'Pick a starting point';

  @override
  String get routeEnd => 'Pick a destination point';

  @override
  String get yourPosition => 'Your position';

  @override
  String get routePlan => 'Plan your trip';

  @override
  String get noDirectionInfo => 'Trip directions will appear here';

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
  String get rail => 'TRAIN';

  @override
  String get cableway => 'C.WAY';

  @override
  String get noStepInfo => 'No route information is available';

  @override
  String stepInfo(String time, String place) {
    return 'Planned departure: $time from $place';
  }

  @override
  String onFootInfo(String time, String distance) {
    return 'About $time on foot ($distance)';
  }

  @override
  String onFootInfoWait(String time, String distance, String wait) {
    return 'About $time on foot ($distance), then wait up to $wait';
  }

  @override
  String get departureTimeInfo => 'According to schedule';

  @override
  String get transferring => 'Transferring';

  @override
  String distance(int km, int m) {
    return '$km.${m}km';
  }

  @override
  String get minute => '1 minute';

  @override
  String minutes(int min) {
    return '$min minutes';
  }

  @override
  String get hour => '1 hour';

  @override
  String hours(int h) {
    return '$h hours';
  }

  @override
  String time(int h, int min) {
    return '${h}h ${min}min';
  }

  @override
  String intermediateStop(String time) {
    return '1 stop with public transport ($time)';
  }

  @override
  String intermediateStops(int stops, String time) {
    return '$stops stops with public transport ($time)';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';
}
