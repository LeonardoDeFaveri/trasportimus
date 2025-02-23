import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart' as pb;
import 'package:trasportimus/blocs/transport/transport_bloc.dart' as tb;
import 'package:trasportimus/location_utils.dart';
import 'package:trasportimus/pages/stop_trips_page.dart';
import 'package:trasportimus/widgets/map/decode_polyline.dart';
import 'package:trasportimus/widgets/map/direction_info_viewer.dart';
import 'package:trasportimus/widgets/map/hints_type.dart';
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
  late final MapController mapCtrl;
  late final StreamController<Way?> pathsStream;
  late bool shouldAlignPosition;
  late bool shouldAlignDirection;
  late LatLng? currentPosition;
  late double currentZoom;
  late Set<Stop> favStops;
  late TabController tabCtrl;
  late bool canPop;
  late Way? previousData;

  @override
  void initState() {
    super.initState();
    transBloc = context.read<tb.TransportBloc>();
    transBloc.add(tb.FetchStops());
    prefsBloc = context.read<pb.PrefsBloc>();
    pathsStream = StreamController.broadcast();
    prefsBloc.add(pb.FetchStops());
    mapCtrl = MapController();
    shouldAlignPosition = false;
    shouldAlignDirection = false;
    currentZoom = initialZoom;
    canPop = true;
    previousData = null;

    favStops = {};

    LocationUtils.instance.createStreams().then((value) {
      if (value == LocationStatus.ok) {
        _goToCurrentPosition();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    tabCtrl = DefaultTabController.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (canPop) {
          tabCtrl.animateTo(0);
        }
      },
      child: Scaffold(
        body: _buildMap(context),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: trentoFsStation,
        initialZoom: initialZoom,
        keepAlive: true,
        minZoom: 8,
        onMapEvent: (event) {
          if (event is MapEventScrollWheelZoom ||
              event is MapEventDoubleTapZoom ||
              event is MapEventMoveEnd) {
            setState(() {
              currentZoom = event.camera.zoom;
            });
          }
        },
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && shouldAlignPosition) {
            setState(() {
              shouldAlignPosition = false;
              shouldAlignDirection = false;
            });
          }
        },
      ),
      mapController: mapCtrl,
      children: [
        TileLayer(
          // Display map tiles from any source
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'trasportimus',
          maxNativeZoom: 19,
          minNativeZoom: 1,
          minZoom: 5,
        ),
        _buildTripLayer(context),
        _buildStartStopMarkers(context),
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
            child: MapSearchBar(
              transBloc,
              favStops,
              mapCtrl,
              _sendDirectionInfoRequest,
            ),
          ),
        ),
        DirectionInfoViewer(
          pathsStream,
          (status) => setState(() {
            canPop = status == ViewerStatus.noData;
          }),
        ),
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

  /// Produces a query to the repository asking for direction info.
  void _sendDirectionInfoRequest(
      List<HintType> routeComponents, DateTime refTime) async {
    List<LatLng> positions = [];
    bool ok = true;
    for (HintType hint in routeComponents) {
      switch (hint.runtimeType) {
        case const (YourPositionHint):
          LatLng? pos = await _getCurrentPosition();
          if (pos != null) {
            positions.add(pos);
          } else {
            ok = false;
          }
        case const (LocationHint):
          var loc = (hint as LocationHint).location;
          positions.add(LatLng(loc.lat, loc.lon));
        case const (StopHint):
          var loc = (hint as StopHint).stop;
          positions.add(LatLng(loc.latitude, loc.longitude));
      }
    }
    if (ok) {
      transBloc.add(
          tb.FetchDirectionInfo(positions[0], positions[1], refTime.toUtc()));
    }
  }

  /// Build the marker showing current location in the map when location info
  /// are available.
  Widget _buildLocationMarkerLayer(BuildContext context) {
    var theme = Theme.of(context);
    AlignOnUpdate alignPosition = AlignOnUpdate.never;
    if (shouldAlignPosition) {
      alignPosition = AlignOnUpdate.always;
    }
    AlignOnUpdate alignDirection = AlignOnUpdate.never;
    if (shouldAlignDirection) {
      alignDirection = AlignOnUpdate.always;
    }

    return StreamBuilder(
      stream: Geolocator.getServiceStatusStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == ServiceStatus.enabled) {
          return FutureBuilder(
            future: LocationUtils.instance.createStreams(requestService: false),
            builder: (context, snapshot) {
              if (snapshot.data != LocationStatus.ok) {
                return SizedBox();
              }

              return CurrentLocationLayer(
                positionStream: LocationUtils.instance.getPositionStream(),
                headingStream: LocationUtils.instance.getHeadingStream(),
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
                alignDirectionOnUpdate: alignDirection,
                alignPositionOnUpdate: alignPosition,
              );
            },
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  /// Builds the button which moves to view to current location (and asks for
  /// permission when this is disabled) and toggles heading attach.
  Widget _buildLocationButton() {
    var theme = Theme.of(context);
    Widget noDataIcon = Icon(
      MingCuteIcons.mgc_aiming_2_line,
      color: theme.colorScheme.error,
      size: 32,
    );
    Widget noDataButton = FloatingActionButton(
      onPressed: () {
        LocationUtils.instance
            .createStreams(requestService: true)
            .then((status) {
          if (status == LocationStatus.ok) {
            _goToCurrentPosition(attachPosition: true);
          }
        });
      },
      shape: CircleBorder(),
      backgroundColor: theme.colorScheme.surface,
      child: noDataIcon,
    );

    return StreamBuilder(
      stream: Geolocator.getServiceStatusStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: LocationUtils.checkServiceStatus(),
            initialData: LocationStatus.disabled,
            builder: (context, snapshot) {
              return _buildButtons(snapshot.data!, noDataButton, theme);
            },
          );
        } else {
          var status = snapshot.data! == ServiceStatus.enabled
              ? LocationStatus.ok
              : LocationStatus.disabled;
          return _buildButtons(status, noDataButton, theme);
        }
      },
    );
  }

  /// Builds the actual location button based on its state.
  Widget _buildButtons(
      LocationStatus status, Widget onDisabled, ThemeData theme) {
    if (status == LocationStatus.ok) {
      Widget child;
      bool attachDirection = false;
      if (shouldAlignPosition && shouldAlignDirection) {
        child = Icon(
          MingCuteIcons.mgc_compass_3_fill,
          color: theme.colorScheme.primary,
          size: 32,
        );
      } else if (shouldAlignPosition && !shouldAlignDirection) {
        child = Icon(
          MingCuteIcons.mgc_aiming_2_fill,
          color: theme.colorScheme.primary,
          size: 32,
        );
        attachDirection = true;
      } else {
        child = Icon(
          MingCuteIcons.mgc_aiming_2_line,
          color: theme.colorScheme.primary,
          size: 32,
        );
      }
      return FloatingActionButton(
        onPressed: () => _goToCurrentPosition(
          attachPosition: true,
          attachDirection: attachDirection,
        ),
        shape: CircleBorder(),
        backgroundColor: theme.colorScheme.surface,
        child: child,
      );
    } else {
      shouldAlignPosition = false;
      return onDisabled;
    }
  }

  /// Builds stop markers.
  Widget _buildMarkerLayer(BuildContext context) {
    var theme = Theme.of(context);

    return BlocConsumer<pb.PrefsBloc, pb.PrefsState>(
      bloc: prefsBloc,
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
          buildWhen: (previous, current) =>
              (current is tb.TransportStillFetching &&
                  current.event is tb.FetchStops) ||
              current is tb.TransportFetchedStops,
          builder: (context, state) {
            List<Marker> markers = [];
            if (state is tb.TransportFetchedStops) {
              for (Stop stop in state.stops) {
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
            return MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 45 * (20 - currentZoom.floor()),
                size: const Size(50, 50),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                markers: markers,
                markerChildBehavior: true,
                rotate: true,
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: theme.colorScheme.primary,
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Moves the map to the current position and attach the position, i.e. the map
  /// center moves along with the position. If `attachPosition` is `true`,
  /// `attachDirection` makes the map rotate to follow user heading. Position
  /// accuracy in low by default, medium if `attachPosition` and high if
  /// `attachDirection`.
  void _goToCurrentPosition(
      {bool? attachPosition, bool? attachDirection}) async {
    var status = await LocationUtils.askForService();
    if (status == LocationStatus.accessDenied) {
      return;
    }

    try {
      LocationAccuracy accuracy = LocationAccuracy.low;
      if (attachPosition == true && attachDirection != true) {
        accuracy = LocationAccuracy.medium;
      } else if (attachPosition == true && attachDirection == true) {
        accuracy = LocationAccuracy.high;
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      );
      currentPosition = LatLng(position.latitude, position.longitude);
      mapCtrl.moveAndRotate(currentPosition!, currentZoom, 0);
      setState(() {
        shouldAlignPosition = attachPosition ?? false;
        shouldAlignDirection = attachDirection ?? false;
      });
    } catch (ex) {
      // Do nothing
    }
  }

  /// Retrieves current position is available (service enabled and permissions
  /// granted).
  Future<LatLng?> _getCurrentPosition() async {
    var status = await LocationUtils.askForService();
    if (status == LocationStatus.accessDenied) {
      return null;
    }

    try {
      LocationAccuracy accuracy = LocationAccuracy.high;
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (ex) {
      // Do nothing
    }

    return null;
  }

  /// When a stop marker is tapped go to the relative `StopTripPage`.
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

  /// Builds the polyline that shows the overall path of a trip from source
  /// to dest.
  Widget _buildTripLayer(BuildContext context) {
    return StreamBuilder(
      stream: pathsStream.stream,
      builder: (context, snapshot) {
        List<Polyline> lines = [];
        if (snapshot.data != null) {
          var way = snapshot.data!;
          for (var step in way.steps) {
            var line = decodePolyline(step.polyline).unpackPolyline();
            bool dotted = true;
            Color color = Colors.grey;
            if (step.travelMode is Transit) {
              var mode = step.travelMode as Transit;
              dotted = false;
              color = mode.info.getRouteColor();
              if (color == Colors.white) {
                color = Colors.grey[300]!;
              } else if (color == Colors.black) {
                color = Theme.of(context).colorScheme.primary;
              }
            }
            lines.add(Polyline(
                points: line,
                color: color,
                pattern:
                    dotted ? StrokePattern.dotted() : StrokePattern.solid(),
                strokeWidth: 10,
                strokeJoin: StrokeJoin.round,
                strokeCap: StrokeCap.round));
          }
          if (snapshot.data != previousData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              var bounds =
                  LatLngBounds(way.bounds.northEast, way.bounds.southWest);
              mapCtrl.fitCamera(CameraFit.bounds(bounds: bounds));
            });
          }
          previousData = snapshot.data;
        }
        return PolylineLayer(
          cullingMargin: null,
          polylines: lines,
        );
      },
    );
  }

  Widget _buildStartStopMarkers(BuildContext context) {
    return StreamBuilder(
      stream: pathsStream.stream,
      builder: (context, snapshot) {
        List<Marker> markers = [];
        if (snapshot.data != null) {
          var way = snapshot.data!;
          markers.add(Marker(
            height: 500,
            width: 500,
            point: way.arrivalPointCoords,
            child: const Icon(
              MingCuteIcons.mgc_location_fill,
              color: Colors.red,
              size: 45,
            ),
          ));
          markers.add(Marker(
            height: 20,
            width: 20,
            point: way.departurePointCoords,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.grey
              ),
            )
          ));
        }
        return MarkerLayer(
          markers: markers,
          rotate: true,
        );
      },
    );
  }
}
