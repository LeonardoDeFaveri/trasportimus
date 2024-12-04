import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:pulsator/pulsator.dart';
import 'package:trasportimus/blocs/osm/osm_bloc.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/map/search_hints.dart';
import 'package:trasportimus_repository/model/model.dart';

enum Status { ok, pending, failed }

class MapSearchBar extends StatefulWidget {
  final TransportBloc transBloc;
  final Set<Stop> favStops;
  final MapController mapCtrl;

  const MapSearchBar(this.transBloc, this.favStops, this.mapCtrl, {super.key});

  @override
  State<StatefulWidget> createState() => MapSearchBarState();
}

class MapSearchBarState extends State<MapSearchBar> {
  late final OsmBloc osmBloc;
  late AppLocalizations loc;
  late bool isExpanded;
  late Status fetchingOsmDataStatus;
  late Status fetchingStopsDataStatus;
  late StreamController<String> textStream;
  late SearchController ctrl;
  late List<Stop> stops;

  @override
  void initState() {
    super.initState();
    isExpanded = false;
    fetchingOsmDataStatus = Status.ok;
    fetchingStopsDataStatus = Status.pending;
    textStream = StreamController.broadcast();
    ctrl = SearchController();
    osmBloc = OsmBloc();
    stops = [];
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<OsmBloc, OsmState>(
          bloc: osmBloc,
          listener: (context, state) {
            if (state is OsmStillFetching) {
              setState(() {
                fetchingOsmDataStatus = Status.pending;
              });
            } else if (state is OsmData && state.key == ctrl.text) {
              setState(() {
                fetchingOsmDataStatus = Status.ok;
              });
            } else if (state is OsmFetchFailed && state.key == ctrl.text) {
              setState(() {
                fetchingOsmDataStatus = Status.failed;
              });
              Defaults.showOsmErrorSnackBar(context);
            }
          },
        ),
        BlocListener<TransportBloc, TransportState>(
          bloc: widget.transBloc,
          listener: (context, state) {
            if (state is TransportStillFetching) {
              setState(() {
                fetchingStopsDataStatus = Status.pending;
              });
            } else if (state is TransportFetchedStops) {
              setState(() {
                fetchingStopsDataStatus = Status.ok;
                stops = state.stops;
              });
            } else if (state is TransportFetchFailed) {
              setState(() {
                fetchingStopsDataStatus = Status.failed;
              });
              Defaults.showTrasportimusErrorSnackBar(context, state);
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          Widget child;

          if (!isExpanded) {
            child = _buildSimpleSearchBar(context, theme);
          } else {
            child = _buildRouteBar(context, theme);
          }

          if (fetchingStopsDataStatus == Status.pending) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                child,
                const SizedBox(height: 5),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: Defaults.shadows,
                    borderRadius: Defaults.borderRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          loc.mapStopsLoading,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const PulseIcon(
                        icon: MingCuteIcons.mgc_arrow_down_circle_fill,
                        pulseColor: Colors.lightGreen,
                        pulseSize: 50,
                        iconSize: 18,
                        iconColor: Colors.white,
                      )
                    ],
                  ),
                )
              ],
            );
          }
          if (fetchingStopsDataStatus == Status.failed) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                child,
                const SizedBox(height: 5),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: Defaults.shadows,
                      borderRadius: Defaults.borderRadius),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          loc.mapStopsLoadingFailed,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.transBloc.add(FetchStops()),
                        child: const PulseIcon(
                          icon: MingCuteIcons.mgc_alert_diamond_fill,
                          pulseColor: Colors.red,
                          pulseSize: 50,
                          iconSize: 18,
                          iconColor: Colors.white,
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }

          return child;
        },
      ),
    );
  }

  Widget _buildSimpleSearchBar(BuildContext context, ThemeData theme) {
    Widget? indicator;
    if (fetchingOsmDataStatus == Status.pending) {
      indicator = Container(
        margin: const EdgeInsets.only(left: 10),
        child: const PulseIcon(
          icon: MingCuteIcons.mgc_search_3_line,
          pulseColor: Colors.lightGreen,
          iconSize: 18,
          pulseSize: 45,
        ),
      );
    } else if (fetchingOsmDataStatus == Status.failed) {
      indicator = Container(
        margin: const EdgeInsets.only(left: 10),
        child: const PulseIcon(
          icon: MingCuteIcons.mgc_alert_diamond_line,
          pulseColor: Colors.red,
          iconSize: 18,
          pulseSize: 45,
        ),
      );
    }

    List<Widget> trailing = [];
    if (indicator != null && ctrl.text.isNotEmpty) {
      trailing.add(indicator);
    }
    trailing.add(
      IconButton(
        onPressed: () => setState(() {
          isExpanded = true;
        }),
        icon: Icon(MingCuteIcons.mgc_route_line),
      ),
    );

    var searchBar = SearchBar(
      constraints: const BoxConstraints(maxHeight: 50, minHeight: 50),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: Defaults.borderRadius),
      ),
      leading: const Padding(
        padding: EdgeInsets.only(left: 6.0),
        child: Icon(MingCuteIcons.mgc_search_3_line),
      ),
      trailing: trailing,
      hintText: loc.mapSearchHint,
      autoFocus: false,
      controller: ctrl,
      onChanged: (value) {
        if (value.length >= 3) {
          textStream.add(value);
          osmBloc.add(Search(value));
        }
      },
    );

    return TapRegion(
      onTapOutside: (event) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
        ctrl.clear();
        textStream.add("");
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          searchBar,
          SizedBox(
            height: 5,
          ),
          SearchHintsViewer(
            textStream.stream,
            osmBloc,
            ctrl,
            stops,
            widget.favStops,
            onTap: (lat, lon) {
              ctrl.clear();
              textStream.add("");
              widget.mapCtrl.move(LatLng(lat, lon), 17.5);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRouteBar(BuildContext context, ThemeData theme) {
    var backButton = IconButton(
      onPressed: () => setState(() {
        isExpanded = false;
      }),
      icon: const Icon(MingCuteIcons.mgc_arrow_left_line),
    );

    return Container(
      constraints: BoxConstraints(maxHeight: 100),
      decoration: BoxDecoration(
          boxShadow: Defaults.shadows,
          borderRadius: Defaults.borderRadius,
          color: theme.colorScheme.surface),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          backButton,
        ],
      ),
    );
  }
}
