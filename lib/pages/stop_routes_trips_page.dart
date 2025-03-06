import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart' as pb;
import 'package:trasportimus/blocs/transport/transport_bloc.dart' as tb;
import 'package:trasportimus/pages/news_page.dart';
import 'package:trasportimus/pages/stop_trips_page.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/timeline/header.dart';
import 'package:trasportimus/widgets/timeline/timeline.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

class RouteTripsPageForStop extends StatefulWidget {
  final m.Stop stop;
  final List<m.Trip> trips;
  final int index;
  final DateTime? refTime;

  const RouteTripsPageForStop(this.stop, this.trips, this.index,
      {super.key, this.refTime});

  @override
  State<StatefulWidget> createState() => RouteTripsPageForStopState();
}

const Duration offset = Duration(hours: -1);
const Duration negOffset = Duration(hours: 1);

class RouteTripsPageForStopState extends State<RouteTripsPageForStop> {
  late final tb.TransportBloc transBloc;
  late final pb.PrefsBloc prefsBloc;
  late List<m.Trip> trips;
  late Set<m.Route> favRoutes;
  late DateTime refTime;
  late DateTime offTime;
  late int index;
  late bool isAutoReloading;
  late Timer autoReloadTimer;
  late AppLocalizations loc;

  @override
  void initState() {
    super.initState();
    refTime = widget.refTime ?? DateTime.now();
    offTime = refTime.add(offset);
    transBloc = context.read<tb.TransportBloc>();
    prefsBloc = context.read<pb.PrefsBloc>();
    prefsBloc.add(pb.FetchRoutes());
    trips = widget.trips;
    favRoutes = {};
    index = widget.index;
    isAutoReloading = false;
    _activateTimer();
    autoReloadTimer.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    autoReloadTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;
    if (!autoReloadTimer.isActive) {
      _activateTimer();
    }

    final trip = trips[index];
    final route = trip.route;
    final iconButton = [
      IconButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewsPage(route, route.news),
          ),
        ),
        icon: const Icon(MingCuteIcons.mgc_bell_ringing_fill),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.stop,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(MingCuteIcons.mgc_arrow_left_line),
        ),
        flexibleSpace: Container(
          decoration: Defaults.decoration,
        ),
        actions: (route.news.isNotEmpty) ? iconButton : null,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<tb.TransportBloc, tb.TransportState>(
            listener: (context2, state) {
              if (state is tb.TransportFetchFailed) {
                Defaults.showTrasportimusErrorSnackBar(context, state);
              }
            },
          ),
          BlocListener<pb.PrefsBloc, pb.PrefsState>(
            listener: (context2, state) {
              if (state is pb.PrefsLoadedRoutes) {
                setState(() {
                  favRoutes = state.routes;
                });
              }
              if (state is pb.PrefsRoutesUpdated) {
                setState(() {
                  favRoutes = state.routes;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<tb.TransportBloc, tb.TransportState>(
          bloc: transBloc,
          buildWhen: (previous, current) =>
              !(current is tb.TransportStillFetching && isAutoReloading),
          builder: (context, state) {
            if (state is tb.TransportStillFetching) {
              return Defaults.loader;
            }
            if (state is tb.TransportFetchedTripsForStop) {
              if (!autoReloadTimer.isActive) {
                _activateTimer();
              }

              offTime = state.refTime;
              refTime = offTime.add(negOffset);
              isAutoReloading = false;
              trips = sortTrips(state.trips, widget.stop, refTime);
              if (trips.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Expanded(child: Defaults.emptyResultWidget(context)),
                );
              }

              return DefaultTabController(
                length: min(5, trips.length),
                child: Builder(builder: (context) {
                  TabController tabCtrl = DefaultTabController.of(context);
                  PageController pageCtrl = PageController(initialPage: index);
                  _setTabIndicator(index, tabCtrl);

                  return Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            itemBuilder: (context, idx) {
                              m.Trip trip = trips[idx];
                              int? predIndex = _getPredTripIndex(trip);
                              m.Trip? pred;
                              if (predIndex != null) {
                                pred = trips[predIndex];
                                if (pred.lastUpdate == null ||
                                    pred.lastSequenceDetection ==
                                        pred.stopTimes.length ||
                                    trip.lastUpdate != null) {
                                  pred = null;
                                }
                              }
                              int stopSeq =
                                  getStopSt(trip, widget.stop, refTime)
                                      .stopSequence;
                              int lastSeq = 0;
                              if (pred == null) {
                                lastSeq = _getLastStopSeq(trip);
                              }

                              var tripTimelineHeader = TripTimelineHeader(
                                trip: trip,
                                pred: pred,
                                isFavourite: favRoutes.contains(trip.route),
                                refTime: refTime,
                                direction: trip.direction,
                                reloadData: () => transBloc.add(
                                  tb.FetchTripsForStop(
                                    widget.stop,
                                    offTime,
                                  ),
                                ),
                                loadData: (newOffTime, newDirection) {
                                  transBloc.add(tb.FetchTripsForStop(
                                    widget.stop,
                                    newOffTime,
                                  ));
                                },
                                allowRouteNavigation: true,
                                disableDirection: true,
                              );
                              var tripTimeline = TripTimeline(
                                trip: trip,
                                pred: pred,
                                goToPred: predIndex != null
                                    ? () => pageCtrl.jumpToPage(predIndex)
                                    : null,
                                onPressed: (st) => _goToStopPage(context, st),
                                itemBuilder: (context, st) => Text(
                                  st.stop.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                markedItemBuilder: (context, st) => Text(
                                  st.stop.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                markedItems: {stopSeq},
                                lastItem: lastSeq,
                                focusItem: stopSeq,
                              );
                              return Column(
                                children: [
                                  tripTimelineHeader,
                                  Expanded(
                                    child: tripTimeline,
                                  ),
                                ],
                              );
                            },
                            itemCount: trips.length,
                            controller: pageCtrl,
                            onPageChanged: (value) {
                              setState(() {
                                index = value;
                                _setTabIndicator(value, tabCtrl);
                              });
                            },
                          ),
                        ),
                        TabPageSelector(
                          controller: tabCtrl,
                          indicatorSize: 12,
                        ),
                      ],
                    ),
                  );
                }),
              );
            }
            return Defaults.noDataWidget(
              context,
              () => transBloc.add(tb.FetchTripsForStop(widget.stop, offTime)),
            );
          },
        ),
      ),
    );
  }

  void _setTabIndicator(int value, TabController tabCtrl) {
    if (trips.length <= 5) {
      tabCtrl.index = value;
    } else {
      if (value == 0) {
        tabCtrl.index = 0;
      } else if (value == trips.length - 1) {
        tabCtrl.index = 4;
      } else if (value == trips.length - 2) {
        tabCtrl.index = 3;
      } else if (value == 1) {
        tabCtrl.index = 1;
      } else {
        tabCtrl.index = 2;
      }
    }
  }

  void _activateTimer() {
    autoReloadTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        isAutoReloading = true;
      });
      //transBloc.add(tb.FetchTripsForStop(widget.stop, offTime));
    });
  }

  void _goToStopPage(BuildContext context2, m.StopTime st) {
    autoReloadTimer.cancel();
    Navigator.push(
        context2,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    tb.TransportBloc.reuse(repo: transBloc.repo),
              ),
              BlocProvider.value(value: prefsBloc),
            ],
            child: StopTripsPage(st.stop, refTime: st.arrivalTime),
          ),
        ));
  }

  /// Returns the sequence number [0-indexed] of the last stop visited. Either
  /// the number is taken directly from `trip` or it is derived from programmed
  /// schedule and current time information.
  int _getLastStopSeq(m.Trip trip) {
    if (trip.lastUpdate != null) {
      return trip.lastSequenceDetection;
    } else {
      DateTime now = DateTime.now();
      for (m.StopTime st in trip.stopTimes) {
        if (st.arrivalTime.isAfter(now)) {
          return st.stopSequence - 1;
        }
      }
    }
    return trip.stopTimes.length;
  }

  int? _getPredTripIndex(m.Trip trip) {
    var index = trips.lastIndexWhere((t) {
      return (t.direction != trip.direction ||
              t.stopTimes.first.stop.id == t.stopTimes.last.stop.id ||
              t.route.id == 623) &&
          t.route.id == trip.route.id &&
          t.stopTimes.last.arrivalTime
              .isBefore(trip.stopTimes.first.arrivalTime);
    });
    if (index >= 0) {
      return index;
    }
    return null;
  }
}
