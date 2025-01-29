import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart' as pb;
import 'package:trasportimus/blocs/transport/transport_bloc.dart' as tb;
import 'package:trasportimus/pages/stop_routes_trips_page.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/tiles/route.dart';
import 'package:trasportimus/widgets/stop_trips/stop_trip_info.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

class StopTripsPage extends StatefulWidget {
  final m.Stop stop;
  final DateTime? refTime;

  const StopTripsPage(this.stop, {super.key, this.refTime});

  @override
  State<StatefulWidget> createState() => StopTripsPageState();
}

const Duration offset = Duration(hours: -1);
const Duration negOffset = Duration(hours: 1);

class StopTripsPageState extends State<StopTripsPage> {
  late final tb.TransportBloc transBloc;
  late final pb.PrefsBloc prefsBloc;
  late List<m.Trip> trips;
  late bool isFavourite;
  late DateTime refTime;
  late DateTime offTime;
  late bool isAutoReloading;
  late Timer autoReloadTimer;

  @override
  void initState() {
    super.initState();
    refTime = widget.refTime ?? DateTime.now();
    offTime = refTime.add(offset);
    transBloc = context.read<tb.TransportBloc>();
    transBloc.add(tb.FetchTripsForStop(widget.stop, offTime));
    prefsBloc = context.read<pb.PrefsBloc>();
    prefsBloc.add(pb.FetchStops());
    trips = [];
    isFavourite = false;
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
    var theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;

    if (!autoReloadTimer.isActive) {
      _activateTimer();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.stop,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(MingCuteIcons.mgc_arrow_left_line),
        ),
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
              if (state is pb.PrefsLoadedStops) {
                setState(() {
                  isFavourite = state.stops.contains(widget.stop);
                });
              }
              if (state is pb.PrefsStopsUpdated) {
                setState(() {
                  isFavourite = state.stops.contains(widget.stop);
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
            if (state is tb.TransportStillFetching ||
                state is tb.TransportInitial) {
              return Defaults.loader;
            }
            if (state is tb.TransportFetchedTripsForStop ||
                state is tb.TransportFetchedTripDetails) {
              if (state is tb.TransportFetchedTripsForStop) {
                if (state.stop != widget.stop) {
                  return Defaults.loader;
                }
                offTime = state.refTime;
                refTime = offTime.add(negOffset);
                isAutoReloading = false;
                trips = sortTrips(state.trips, widget.stop, refTime);
              }
              if (!autoReloadTimer.isActive) {
                _activateTimer();
              }

              Widget content = Defaults.emptyResultWidget(context);
              if (trips.isNotEmpty) {
                content = ListView.builder(
                  itemBuilder: (context, index) {
                    var trip = trips[index];

                    var tile = ListTile(
                      leading: RouteTile(
                        trip.route,
                        margin: EdgeInsets.only(right: 3),
                      ),
                      title: Text(
                        trip.route.longName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: Transform.translate(
                        offset: Offset(15, 0),
                        child: _buildTimeIndicator(trip, theme),
                      ),
                      subtitle: Text('${loc.towards} ${_lastStop(trip).name}'),
                      horizontalTitleGap: 4,
                      shape: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      onTap: () => _goToRoutePage(context, index),
                    );

                    return tile;
                  },
                  itemCount: trips.length,
                );
              }

              return Container(
                padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    StopTripsInfo(trips, widget.stop, isFavourite, offTime),
                    Expanded(child: content),
                  ],
                ),
              );
            }

            return Defaults.noDataWidget(
                context,
                () =>
                    transBloc.add(tb.FetchTripsForStop(widget.stop, offTime)));
          },
        ),
      ),
    );
  }

  Widget _buildTimeIndicator(m.Trip trip, ThemeData theme) {
    m.StopTime st = getStopSt(trip, widget.stop, refTime);

    Widget programmedTime = Text(
      formatTime(st.arrivalTime.hour, st.arrivalTime.minute),
      style: theme.textTheme.bodyMedium,
    );
    Widget actualTime;
    if (trip.lastSequenceDetection <= st.stopSequence &&
        trip.lastUpdate != null) {
      int minutes = trip.delay.round();
      DateTime actualArrival = st.arrivalTime.add(Duration(minutes: minutes));
      actualTime = Text(
        formatTime(actualArrival.hour, actualArrival.minute),
        style: theme.textTheme.bodyMedium!.copyWith(
            color: minutes < 0
                ? Colors.cyan
                : minutes == 0
                    ? Colors.green
                    : minutes < 5
                        ? Colors.orange
                        : Colors.red),
      );
    } else {
      actualTime = Icon(
        MingCuteIcons.mgc_alert_diamond_line,
        color: theme.colorScheme.error,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [programmedTime, actualTime],
    );
  }

  void _activateTimer() {
    autoReloadTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        isAutoReloading = true;
      });
      transBloc.add(tb.FetchTripsForStop(widget.stop, offTime));
    });
  }

  m.Stop _lastStop(m.Trip trip) => trip.stopTimes.last.stop;

  void _goToRoutePage(BuildContext context, int index) {
    autoReloadTimer.cancel();
    Navigator.push(context, MaterialPageRoute(builder: (navContext) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => tb.TransportBloc.reuse(
              repo: transBloc.repo,
              initial: tb.TransportFetchedTripsForStop(
                trips,
                widget.stop,
                offTime,
                m.Direction.both,
              ),
            ),
          ),
          BlocProvider.value(value: prefsBloc)
        ],
        child:
            RouteTripsPageForStop(widget.stop, trips, index, refTime: refTime),
      );
    }));
  }
}
