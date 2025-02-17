import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart' as tb;
import 'package:trasportimus/pages/route_trips_page.dart';
import 'package:trasportimus/pages/stop_trips_page.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/map/direction_details_tokens.dart';
import 'package:trasportimus/widgets/map/direction_tile.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

Widget buildWalkingTile(
    WalkingInfo token, ThemeData theme, AppLocalizations loc) {
  String time = _getTimeStr(token.duration, loc);
  String distance = _getDistanceStr(token.distance, loc);
  String text;

  if (token.waitingTime != null) {
    text = loc.onFootInfoWait(
        time, distance, _getTimeStr(token.waitingTime!, loc));
  } else {
    text = loc.onFootInfo(time, distance);
  }

  return SizedBox(
    width: double.infinity,
    child: Text(text),
  );
}

Widget buildTransferringTile(
    Transferring token, ThemeData theme, AppLocalizations loc) {
  return SizedBox(
    width: double.infinity,
    child: Text(loc.transferring),
  );
}

Widget buildStartLocationTile(
    StartLocation token, BuildContext context, ThemeData theme) {
  return _buildStopTile(
    token.stop,
    token.name,
    token.address,
    token.time,
    context,
    theme,
    showTime: false,
  );
}

Widget buildEndLocationTile(
    EndLocation token, BuildContext context, ThemeData theme) {
  return _buildStopTile(
      token.stop, token.name, token.address, token.time, context, theme);
}

Widget buildTransitStartLocationTile(
    TransitStartLocation token, BuildContext context, ThemeData theme) {
  return _buildStopTile(
      token.stop, token.name, token.address, token.time, context, theme,
      showTime: false);
}

Widget buildTransitRouteInfoTile(TransitRouteInfo token, BuildContext context,
    ThemeData theme, AppLocalizations loc) {
  List<Widget> children = [
    Text(
      formatTime(token.time.hour, token.time.minute),
      style: theme.textTheme.bodyLarge
          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
    )
  ];

  if (token.trip != null) {
    children.add(Icon(MingCuteIcons.mgc_arrow_right_line));
  } else {
    children.add(const Text(""));
  }

  return GestureDetector(
    onTap: token.trip != null
        ? () => _goToRoutePage(context, token.trip!, token.time)
        : null,
    child: SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TransitTile.fromData(
                      token.shortName,
                      token.longName,
                      token.color,
                      token.mode,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        token.headSign,
                        style: theme.textTheme.bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                Text(loc.departureTimeInfo),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: children,
          )
        ],
      ),
    ),
  );
}

Widget buildTransitStopLocationTile(
    TransitStopLocation token, BuildContext context, ThemeData theme) {
  return _buildStopTile(
      token.stop, token.name, token.address, token.arrivalTime, context, theme);
}

Widget buildTransitIntermediateLocationHeader(
    TransitIntermediateLocationHeader token,
    ThemeData theme,
    bool expanded,
    void Function()? toggle,
    AppLocalizations loc) {
  Widget text;
  if (token.quantity == 1) {
    text = Expanded(
      child: Text(
        loc.intermediateStop(_getTimeStr(token.duration, loc)),
        softWrap: true,
      ),
    );
  } else {
    text = Expanded(
      child: Text(
        loc.intermediateStops(token.quantity, _getTimeStr(token.duration, loc)),
        softWrap: true,
      ),
    );
  }

  if (toggle == null || token.quantity == 1) {
    return Row(
      children: [text],
    );
  } else {
    IconData icon;
    if (expanded) {
      icon = MingCuteIcons.mgc_up_line;
    } else {
      icon = MingCuteIcons.mgc_down_line;
    }

    return GestureDetector(
      onTap: toggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Icon(icon), SizedBox(width: 5), text],
      ),
    );
  }
}

Widget buildTransitIntermediateLocationSingle(
    TransitIntermediateLocationSingle token, ThemeData theme) {
  return Row(children: [
    Text(
      token.name,
      style: theme.textTheme.bodySmall,
      overflow: TextOverflow.ellipsis,
    )
  ]);
}

Widget _buildStopTile(m.Stop? stop, String name, String address, DateTime? time,
    BuildContext context, ThemeData theme,
    {bool? showTime}) {
  String addr = _getAddressStr(stop, address);
  String timeStr = time != null && showTime != false
      ? formatTime(time.hour, time.minute)
      : "";

  List<Widget> children = [
    Text(
      timeStr,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
    )
  ];

  if (stop != null) {
    children.add(Icon(MingCuteIcons.mgc_arrow_right_line));
  } else {
    children.add(const Text(""));
  }

  return GestureDetector(
    onTap: stop != null ? () => _goToStopPage(context, stop, time) : null,
    child: SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.bodyLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    addr,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: children,
          )
        ],
      ),
    ),
  );
}

void _goToStopPage(BuildContext context, m.Stop stop, DateTime? refTime) {
  var transBloc = context.read<tb.TransportBloc>();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => tb.TransportBloc.reuse(repo: transBloc.repo),
        ),
      ], child: StopTripsPage(stop, refTime: refTime)),
    ),
  );
}

void _goToRoutePage(BuildContext context, m.Trip trip, DateTime refTime) {
  var transBloc = context.read<tb.TransportBloc>();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => tb.TransportBloc.reuse(repo: transBloc.repo),
          ),
        ],
        child: RouteTripsPage(
          trip.route,
          initialTrip: trip.tripId,
          refTime: refTime,
        ),
      ),
    ),
  );
}

String _getAddressStr(m.Stop? stop, String defaultAddress) {
  String address = '';
  if (stop != null) {
    if (stop.street != '' && stop.town != '') {
      address = '${stop.street}, ${stop.town}';
    } else if (stop.street == '') {
      address = stop.town;
    } else {
      address = stop.street;
    }
  } else {
    address = defaultAddress;
  }
  return address;
}

String _getDistanceStr(int meters, AppLocalizations loc) {
  if (meters < 1000) {
    return '${meters}m';
  } else {
    int km = meters ~/ 1000;
    meters %= 1000;
    return loc.distance(km, meters);
  }
}

String _getTimeStr(Duration duration, AppLocalizations loc) {
  int h = duration.inHours;
  int min = duration.inMinutes;
  min -= h * 60;
  if (h > 0 && min > 0) {
    return loc.time(h, min);
  } else if (h > 1 && min == 0) {
    return loc.hours(h);
  } else if (h == 1 && min == 0) {
    return loc.hour;
  } else if (h == 0 && min > 1) {
    return loc.minutes(min);
  } else {
    return loc.minute;
  }
}
