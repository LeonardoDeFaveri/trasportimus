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

class RouteTripsPage extends StatefulWidget {
  final m.Route route;
  final String? initialTrip;
  final DateTime? refTime;

  const RouteTripsPage(this.route, {this.refTime, this.initialTrip, super.key});

  @override
  State<StatefulWidget> createState() => RouteTripsPageState();
}

const Duration offset = Duration(hours: -1);
const Duration negOffset = Duration(hours: 1);

class RouteTripsPageState extends State<RouteTripsPage> {
  late final tb.TransportBloc transBloc;
  late final pb.PrefsBloc prefsBloc;
  late List<m.Trip> trips;
  late bool isFavourite;
  late DateTime refTime;
  late DateTime offTime;
  late m.Direction direction;
  late int? pageIndex;
  late bool autoReload;
  late Timer autoReloadTimer;
  late AppLocalizations loc;
  late tb.TransportFetchedTripsForRoute? oldState;
  String? initialTrip;

  @override
  void initState() {
    super.initState();
    refTime = widget.refTime ?? DateTime.now();
    offTime = refTime.add(offset);
    direction = m.Direction.both;
    transBloc = context.read<tb.TransportBloc>();
    transBloc.add(tb.FetchTripsForRoute(widget.route, offTime, direction));
    prefsBloc = context.read<pb.PrefsBloc>();
    prefsBloc.add(pb.FetchRoutes());
    trips = [];
    isFavourite = false;
    pageIndex = null;
    autoReload = false;
    oldState = null;
    initialTrip = widget.initialTrip;
    _activateTimer();
    // I should start the timer only once I've got the first useful data
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
    var iconButton = [
      IconButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewsPage(widget.route, widget.route.news),
          ),
        ),
        icon: const Icon(MingCuteIcons.mgc_bell_ringing_fill),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.route(widget.route.shortName),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(MingCuteIcons.mgc_arrow_left_line),
        ),
        actions: (widget.route.news.isNotEmpty) ? iconButton : null,
        flexibleSpace: Container(
          decoration: Defaults.decoration,
        ),
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
                  isFavourite = state.routes.contains(widget.route);
                });
              }
              if (state is pb.PrefsRoutesUpdated) {
                setState(() {
                  isFavourite = state.routes.contains(widget.route);
                });
              }
            },
          ),
        ],
        child: BlocBuilder<tb.TransportBloc, tb.TransportState>(
          bloc: transBloc,
          buildWhen: (previous, current) =>
              !(current is tb.TransportStillFetching && autoReload),
          builder: (context, state) {
            if (state is tb.TransportStillFetching ||
                state is tb.TransportInitial) {
              return Defaults.loader;
            }
            if (state is tb.TransportFetchedTripsForRoute || oldState != null) {
              if (state is tb.TransportFetchedTripsForRoute) {
                oldState = state;
              }
              if (!autoReloadTimer.isActive) {
                _activateTimer();
              }

              offTime = oldState!.refTime;
              refTime = offTime.add(negOffset);
              direction = oldState!.direction;
              autoReload = false;
              trips = oldState!.trips;
              if (trips.isEmpty) {
                return _buildNoTripView(context);
              }
              if (initialTrip != null) {
                pageIndex = _findIndexFromTrip(initialTrip!);
              }
              pageIndex ??= _findClosestToRefTime();

              return DefaultTabController(
                length: trips.length,
                child: Builder(builder: (context) {
                  TabController tabCtrl = DefaultTabController.of(context);
                  PageController pageCtrl =
                      PageController(initialPage: pageIndex!);
                  tabCtrl.index = pageIndex!;

                  return Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            itemBuilder: (context, index) {
                              m.Trip trip = trips[index];
                              int? predIndex = _getPredTripIndex(trip);
                              m.Trip? pred;
                              if (predIndex != null) {
                                pred = trips[predIndex];
                                if (pred.lastUpdate == null ||
                                    pred.lastSequenceDetection ==
                                        pred.stopTimes.length) {
                                  pred = null;
                                }
                              }
                              int lastSeq = 0;
                              if (pred == null) {
                                lastSeq = _getLastStopSeq(trip);
                              }

                              var tripTimelineHeader = TripTimelineHeader(
                                trip: trip,
                                pred: pred,
                                isFavourite: isFavourite,
                                refTime: refTime,
                                direction: direction,
                                reloadData: () {
                                  return transBloc.add(tb.FetchTripsForRoute(
                                    widget.route,
                                    offTime,
                                    direction,
                                  ));
                                },
                                loadData: (newOffTime, newDirection) {
                                  transBloc.add(tb.FetchTripsForRoute(
                                    widget.route,
                                    newOffTime,
                                    newDirection,
                                  ));
                                },
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
                                markedItems: {lastSeq + 1},
                                lastItem: lastSeq,
                                focusItem: lastSeq,
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
                              tabCtrl.index = value;
                              pageIndex = value;
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

            // If oldState is null and there's no useful data in the bloc, show
            // no data view
            autoReloadTimer.cancel();
            return Defaults.noDataWidget(
              context,
              () => transBloc
                  .add(tb.FetchTripsForRoute(widget.route, offTime, direction)),
            );
          },
        ),
      ),
    );
  }

  Container _buildNoTripView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          TripTimelineHeader.noStatus(
            route: widget.route,
            isFavourite: isFavourite,
            reloadData: () {
              transBloc
                  .add(tb.FetchTripsForRoute(widget.route, offTime, direction));
            },
            loadData: (newOffTime, newDirection) {
              transBloc.add(tb.FetchTripsForRoute(
                  widget.route, newOffTime, newDirection));
            },
            refTime: refTime,
            direction: direction,
          ),
          Expanded(child: Defaults.emptyResultWidget(context)),
        ],
      ),
    );
  }

  int _findClosestToRefTime() {
    int index = max(
        0,
        trips.indexed
            .firstWhere(
              (el) => el.$2.stopTimes[0].arrivalTime.isAfter(refTime),
              orElse: () => (trips.length - 1, trips[trips.length - 1]),
            )
            .$1);
    if (index != 0 && index != trips.length - 1) {
      index -= 1;
    }
    return index;
  }

  void _activateTimer() {
    autoReloadTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        autoReload = true;
      });
      transBloc.add(tb.FetchTripsForRoute(widget.route, offTime, direction));
    });
  }

  void _goToStopPage(BuildContext context2, m.StopTime st) {
    autoReloadTimer.cancel();
    Navigator.push(
        context2,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(providers: [
            BlocProvider(
              create: (context) => tb.TransportBloc.reuse(repo: transBloc.repo),
            ),
            BlocProvider.value(value: prefsBloc)
          ], child: StopTripsPage(st.stop, refTime: st.arrivalTime)),
        ));
  }

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
              // Need a specific
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

  int? _findIndexFromTrip(String id) {
    for (var (i, trip) in trips.indexed) {
      if (trip.tripId == id) {
        return i;
      }
    }
    return null;
  }
}
