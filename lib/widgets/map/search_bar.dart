import 'dart:async';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:format/format.dart';
import 'package:latlong2/latlong.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:pulsator/pulsator.dart';
import 'package:trasportimus/blocs/osm/osm_bloc.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/map/hints_type.dart';
import 'package:trasportimus/widgets/map/route_picker.dart';
import 'package:trasportimus/widgets/map/search_hints.dart';
import 'package:trasportimus_repository/model/model.dart';

enum Status { ok, pending, failed }

class MapSearchBar extends StatefulWidget {
  final TransportBloc transBloc;
  final Set<Stop> favStops;
  final MapController mapCtrl;
  final void Function(List<HintType> routeComponents, DateTime refTime) planner;

  const MapSearchBar(this.transBloc, this.favStops, this.mapCtrl, this.planner,
      {super.key});

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
  late SearchController searchCtrl;
  late List<SearchController> routeCtrls;
  late List<HintType?> routeComponents;
  late int selectedCtrl;
  late bool showPosition;
  late List<Stop> stops;
  late DateTime refTime;
  late bool enabled;

  @override
  void initState() {
    super.initState();
    isExpanded = false;
    fetchingOsmDataStatus = Status.ok;
    fetchingStopsDataStatus = Status.pending;
    textStream = StreamController.broadcast();
    searchCtrl = SearchController();
    routeCtrls = [SearchController(), SearchController()];
    routeComponents = [null, null];
    selectedCtrl = 0;
    showPosition = false;
    osmBloc = OsmBloc();
    stops = [];
    refTime = DateTime.now();
    enabled = false;
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
            } else if (state is OsmData && state.key == searchCtrl.text) {
              setState(() {
                fetchingOsmDataStatus = Status.ok;
              });
            } else if (state is OsmFetchFailed &&
                state.key == searchCtrl.text) {
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
              if (state.event is FetchStops) {
                setState(() {
                  fetchingStopsDataStatus = Status.pending;
                });
              }
            } else if (state is TransportFetchedStops) {
              setState(() {
                fetchingStopsDataStatus = Status.ok;
                stops = state.stops;
              });
            } else if (state is TransportFetchFailed) {
              if (state.event is FetchStops) {
                setState(() {
                  fetchingStopsDataStatus = Status.failed;
                });
                Defaults.showTrasportimusErrorSnackBar(context, state);
              }
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
    Widget? indicator = buildSearchIndicator();

    List<Widget> trailing = [];
    if (indicator != null && searchCtrl.text.isNotEmpty) {
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
      controller: searchCtrl,
      onChanged: searchKey,
    );

    return TapRegion(
      onTapOutside: (event) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
        searchCtrl.clear();
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
            searchCtrl,
            stops,
            widget.favStops,
            onTap: (hint) {
              double lat = 0, lon = 0;
              if (hint is StopHint) {
                lat = hint.stop.latitude;
                lon = hint.stop.longitude;
              } else if (hint is LocationHint) {
                lat = hint.location.lat;
                lon = hint.location.lon;
              }
              searchCtrl.clear();
              textStream.add("");
              widget.mapCtrl.move(LatLng(lat, lon), 17.5);
            },
          ),
        ],
      ),
    );
  }

  Widget? buildSearchIndicator() {
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
    return indicator;
  }

  Widget _buildRouteBar(BuildContext context, ThemeData theme) {
    var backButton = IconButton(
      onPressed: () => setState(() {
        isExpanded = false;
      }),
      icon: const Icon(MingCuteIcons.mgc_arrow_left_line),
    );

    return TapRegion(
      onTapOutside: (event) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
        textStream.add("");
        setState(() {
          showPosition = false;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 500,
            ),
            decoration: BoxDecoration(
              boxShadow: Defaults.shadows,
              borderRadius: Defaults.borderRadius,
              color: theme.colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: backButton,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RoutePicker(
                              [loc.routeStart, loc.routeEnd],
                              routeCtrls,
                              onTap: (index) {
                                setState(() {
                                  selectedCtrl = index;
                                  if (routeComponents[selectedCtrl] != null) {
                                    routeCtrls[selectedCtrl].clear();
                                  }
                                  showPosition = true;
                                });
                              },
                              onChanged: searchKey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              onPressed: reverseRoute,
                              icon: Icon(MingCuteIcons.mgc_transfer_2_line),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: refTime,
                        lastDate: DateTime(2100),
                      ).then((DateTime? date) async {
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(refTime),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          return DateTimeField.combine(date, time);
                        } else {
                          return refTime;
                        }
                      }).then(
                        (value) {
                          if (value != refTime) {
                            setState(() {
                              refTime = value;
                            });
                          }
                        },
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 12.0, right: 8.0),
                            child:
                                Icon(MingCuteIcons.mgc_calendar_time_add_line),
                          ),
                          Text(
                            format('{:0>2}/{:0>2} {:0>2}:{:0>2}', refTime.day,
                                refTime.month, refTime.hour, refTime.minute),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 5.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: Defaults.borderRadius)),
                            backgroundColor: WidgetStatePropertyAll(
                                theme.colorScheme.primary),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return theme.colorScheme.onPrimary
                                      .withAlpha(200);
                                } else {
                                  return theme.colorScheme.onPrimary;
                                }
                              },
                            ),
                          ),
                          onPressed: enabled
                              ? () {
                                  setState(() {
                                    showPosition = false;
                                  });
                                  widget.planner(
                                      routeComponents
                                          .map((comp) => comp!)
                                          .toList(),
                                      refTime);
                                }
                              : null,
                          child: Text(loc.routePlan)),
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SearchHintsViewer(
            textStream.stream,
            osmBloc,
            routeCtrls[selectedCtrl],
            stops,
            widget.favStops,
            onTap: (hint) {
              var ctrl = routeCtrls[selectedCtrl];
              if (hint is YourPositionHint) {
                ctrl.text = loc.yourPosition;
              } else if (hint is StopHint) {
                ctrl.text = hint.stop.name;
              } else if (hint is LocationHint) {
                ctrl.text = hint.location.name;
              }
              textStream.add("");
              routeComponents[selectedCtrl] = hint;
              selectedCtrl = (selectedCtrl + 1) % 2;
              if (!routeComponents.contains(null)) {
                setState(() {
                  enabled = true;
                });
              }
            },
            showCurrentPosition: showPosition,
          )
        ],
      ),
    );
  }

  void reverseRoute() {
    setState(() {
      routeCtrls = routeCtrls.reversed.toList();
      routeComponents = routeComponents.reversed.toList();
    });
  }

  void searchKey(String key) {
    if (key.length >= 3) {
      textStream.add(key);
      osmBloc.add(Search(key));
    }
  }
}
