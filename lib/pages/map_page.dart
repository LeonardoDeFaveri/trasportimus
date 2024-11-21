import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as l;
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart' as pb;
import 'package:trasportimus/blocs/transport/transport_bloc.dart' as tb;
import 'package:trasportimus/pages/stop_trips_page.dart';
import 'package:trasportimus/widgets/map/search_bar.dart';
import 'package:trasportimus/widgets/tiles/stop.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => MapPageState();
}

const LatLng trentoFsStation = LatLng(46.071756, 11.119511);
const double initialZoom = 16.5;

class MapPageState extends State<MapPage> {
  late final tb.TransportBloc transBloc;
  late final pb.PrefsBloc prefsBloc;
  late final MapController ctrl;
  late Stream<Position> _geolocatorStream;
  late final Stream<CompassEvent?> _flutterCompassStream;
  late Stream<LocationMarkerPosition?> _positionStream;
  late final Stream<LocationMarkerHeading?> _headingStream;
  late LatLng? currentPosition;
  late double currentZoom;
  late List<Stop> stops;
  late Set<Stop> favStops;

  @override
  void initState() {
    super.initState();
    transBloc = context.read<tb.TransportBloc>();
    transBloc.add(tb.FetchStops());
    prefsBloc = context.read<pb.PrefsBloc>();
    prefsBloc.add(pb.FetchStops());
    ctrl = MapController();
    var locationSettings = AndroidSettings(accuracy: LocationAccuracy.low);
    _geolocatorStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .asBroadcastStream();
    _flutterCompassStream = FlutterCompass.events!.asBroadcastStream();
    const factory = LocationMarkerDataStreamFactory();
    _positionStream = factory.fromGeolocatorPositionStream(
      stream: _geolocatorStream,
    );
    _headingStream = factory.fromCompassHeadingStream(
      stream: _flutterCompassStream,
    );
    currentZoom = initialZoom;
    stops = [];
    favStops = {};

    _goToCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMap(context),
    );
  }

  Widget _buildMap(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: trentoFsStation,
        initialZoom: initialZoom,
        keepAlive: true,
        minZoom: 10,
        onMapEvent: (event) {
          if (event is MapEventScrollWheelZoom ||
              event is MapEventDoubleTapZoom ||
              event is MapEventMoveEnd) {
            setState(() {
              currentZoom = event.camera.zoom;
            });
          }
        },
      ),
      mapController: ctrl,
      children: [
        TileLayer(
          // Display map tiles from any source
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'trasportimus',
          maxNativeZoom: 19,
          minNativeZoom: 1,
        ),
        _buildLocationMarkerLayer(context),
        _buildMarkerLayer(context),
        Positioned(
          bottom: 50,
          right: 10,
          child: _buildLocationButton(),
        ),
        Positioned(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: MapSearchBar(transBloc, favStops, ctrl),
        )),
        RichAttributionWidget(
          // Include a stylish prebuilt attribution widget that meets all requirments
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => launchUrl(
                Uri.parse('https://openstreetmap.org/copyright'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  CurrentLocationLayer _buildLocationMarkerLayer(BuildContext context) {
    var theme = Theme.of(context);

    return CurrentLocationLayer(
      positionStream: _positionStream,
      headingStream: _headingStream,
      style: LocationMarkerStyle(
        headingSectorColor: theme.colorScheme.primary,
        accuracyCircleColor: Colors.white38,
        marker: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
            border: Border.all(width: 2, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    var theme = Theme.of(context);

    return StreamBuilder(
      stream: Geolocator.getServiceStatusStream(),
      builder: (context, snapshot) {
        Widget noDataIcon = Icon(
          MingCuteIcons.mgc_aiming_2_line,
          color: theme.colorScheme.error,
          size: 32,
        );
        if (snapshot.data != ServiceStatus.enabled) {
          return FloatingActionButton(
            onPressed: () => _goToCurrentPosition(attach: true),
            shape: CircleBorder(),
            backgroundColor: theme.colorScheme.surface,
            child: noDataIcon,
          );
        }
        return StreamBuilder(
          stream: _positionStream,
          builder: (context, snapshot) {
            var child = noDataIcon;
            if (snapshot.hasData) {
              var position =
                  LatLng(snapshot.data!.latitude, snapshot.data!.longitude);

              if (ctrl.camera.center == position) {
                child = Icon(
                  MingCuteIcons.mgc_aiming_2_fill,
                  color: theme.colorScheme.primary,
                  size: 32,
                );
              } else {
                child = Icon(
                  MingCuteIcons.mgc_aiming_2_line,
                  color: theme.colorScheme.primary,
                  size: 32,
                );
              }
            }
            return FloatingActionButton(
              onPressed: () => _goToCurrentPosition(attach: true),
              shape: CircleBorder(),
              backgroundColor: theme.colorScheme.surface,
              child: child,
            );
          },
        );
      },
    );
  }

  Widget _buildMarkerLayer(BuildContext context) {
    return BlocConsumer<pb.PrefsBloc, pb.PrefsState>(
      listener: (context, state) {
        if (state is pb.PrefsLoadedStops) {
          setState(() {
            favStops = state.stops;
          });
        }
        if (state is pb.PrefsStopsUpdated) {
          setState(() {
            favStops = state.stops;
          });
        }
      },
      builder: (context, state) {
        return BlocBuilder(
          bloc: transBloc,
          builder: (context, state) {
            List<Marker> markers = [];
            if (state is tb.TransportFetchedStops) {
              stops = state.stops;
              for (Stop stop in stops) {
                markers.add(
                  Marker(
                    height: 500,
                    width: 500,
                    point: LatLng(stop.latitude, stop.longitude),
                    child: GestureDetector(
                      onTap: () => _goToStopPage(context, stop),
                      child: Center(
                        child: Transform.scale(
                          // Favourite stops are larger
                          scale: (favStops.contains(stop)) ? 1 : 0.75,
                          child: StopTile(stop),
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
            return MarkerLayer(rotate: true, markers: markers);
          },
        );
      },
    );
  }

  void _goToCurrentPosition({bool? attach}) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!await l.Location().requestService()) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        ctrl.move(currentPosition!, currentZoom);
        if (attach == true) {}
      });
    }
  }

  void _goToStopPage(BuildContext context2, Stop stop) {
    Navigator.push(
      context2,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(providers: [
          BlocProvider(
            create: (context) => tb.TransportBloc.reuse(repo: transBloc.repo),
          ),
        ], child: StopTripsPage(stop)),
      ),
    );
  }
}
