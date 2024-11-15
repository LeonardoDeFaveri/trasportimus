import 'dart:collection';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:format/format.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart' as pb;
import 'package:trasportimus/blocs/transport/transport_bloc.dart' as tb;
import 'package:trasportimus/pages/stop_trips_page.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/route_tile.dart';
import 'package:trasportimus/widgets/stop_tile.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

class StopTripsInfo extends StatelessWidget {
  final List<m.Trip> trips;
  final m.Stop stop;
  final bool isFavourite;
  final DateTime offTime;

  const StopTripsInfo(this.trips, this.stop, this.isFavourite, this.offTime,
      {super.key});

  @override
  Widget build(BuildContext context) {
    pb.PrefsBloc prefsBloc = context.read<pb.PrefsBloc>();
    tb.TransportBloc transBloc = context.read<tb.TransportBloc>();
    DateTime refTime = offTime.add(negOffset);
    AppLocalizations loc = AppLocalizations.of(context)!;

    var headerRows = [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StopTile(stop),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          stop.name,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 0,
                    children: _createRoutesIndicators(),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => isFavourite
                    ? prefsBloc.add(pb.RemoveStop(stop))
                    : prefsBloc.add(pb.AddStop(stop)),
                icon: Icon(
                  isFavourite
                      ? MingCuteIcons.mgc_heart_fill
                      : MingCuteIcons.mgc_heart_line,
                  color: Colors.redAccent,
                ),
                padding: EdgeInsets.all(0),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => transBloc.add(
                  tb.FetchTripsForStop(stop, offTime),
                ),
                icon: const Icon(MingCuteIcons.mgc_refresh_1_line),
                padding: EdgeInsets.all(0),
              ),
            ],
          )
        ],
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Builder(builder: (context) {
              String text;
              if (trips.length == 1) {
                text = loc.result;
              } else {
                text = loc.results(trips.length);
              }

              return Expanded(
                flex: 1,
                child: Text(text),
              );
            }),
            Expanded(
              flex: 1,
              child: GestureDetector(
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
                    return offTime;
                  }
                }).then(
                  (value) {
                    if (value != offTime) {
                      transBloc.add(
                        tb.FetchTripsForStop(stop, value.add(offset)),
                      );
                    }
                  },
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(MingCuteIcons.mgc_calendar_time_add_line),
                    ),
                    Text(format(
                        '{:0>2}/{:0>2} {:0>2}:{:0>2}',
                        refTime.add(negOffset).day,
                        refTime.month,
                        refTime.hour,
                        refTime.minute))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ];
    return Container(
      decoration: BoxDecoration(
          boxShadow: Defaults.shadows,
          borderRadius: Defaults.borderRadius,
          color: Colors.white),
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: headerRows,
      ),
    );
  }

  List<Transform> _createRoutesIndicators() {
    HashSet<m.Route> routes = HashSet();

    for (m.Trip trip in trips) {
      routes.add(trip.route);
    }
    List<m.Route> sorted = routes.toList()..sort(compareRoutes);
    return sorted
        .map((route) => Transform.scale(scale: 1, child: RouteSmall(route)))
        .toList();
  }
}
