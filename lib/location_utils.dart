import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

enum LocationStatus {
  ok,
  disabled,
  accessDenied,
}

class LocationUtils {
  late Stream<Position>? _geolocatorStream;
  late Stream<CompassEvent?>? _flutterCompassStream;
  late Stream<LocationMarkerPosition?>? _positionStream;
  late Stream<LocationMarkerHeading?>? _headingStream;

  LocationUtils()
      : _geolocatorStream = null,
        _flutterCompassStream = null,
        _positionStream = null,
        _headingStream = null;

  static final LocationUtils instance = LocationUtils();

  /// Returns `true` only if the location is enabled and accessible from the
  /// application
  static Future<LocationStatus> checkServiceStatus() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return LocationStatus.accessDenied;
    }

    var enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return LocationStatus.disabled;
    }

    return LocationStatus.ok;
  }

  /// Tries to enable location services asking for permisions if necessary
  static Future<LocationStatus> askForService({bool? requestService}) async {
    var status = await checkServiceStatus();
    if (status == LocationStatus.accessDenied) {
      var permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationStatus.accessDenied;
      }
    } else {
      if (status == LocationStatus.disabled && requestService == true) {
        // This prompts a 'enabled location services?' prompt
        if (await Location.instance.requestService()) {
          return LocationStatus.ok;
        }
      }
    }

    return status;
  }

  Future<LocationStatus> createStreams({bool? requestService}) async {
    var status = await askForService(requestService: requestService);
    if (status == LocationStatus.accessDenied) {
      return status;
    }
    // To avoid having two prompts for location enabling function must return
    // when service activation has already been explicitly requested [true case]
    // If requestService is false, it means that another request has been
    // produced by another call to this function.
    if (status == LocationStatus.disabled && requestService != null) {
      return status;
    }

    try {
      // This prompts a 'enabled location services?' prompt
      _geolocatorStream = Geolocator.getPositionStream();
      _flutterCompassStream = FlutterCompass.events!.asBroadcastStream();
      const factory = LocationMarkerDataStreamFactory();
      _positionStream = factory.fromGeolocatorPositionStream(
        stream: _geolocatorStream,
      );
      _headingStream = factory.fromCompassHeadingStream(
        stream: _flutterCompassStream,
      );
      return LocationStatus.ok;
    } catch (ex) {
      return LocationStatus.disabled;
    }
  }

  Stream<LocationMarkerPosition?>? getPositionStream() {
    return _positionStream;
  }

  Stream<LocationMarkerHeading?>? getHeadingStream() {
    return _headingStream;
  }
}
