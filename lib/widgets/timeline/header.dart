import 'package:choice/choice.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:format/format.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:pulsator/pulsator.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/tiles/route.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trasportimus_repository/model/route.dart' as r;

const Duration offset = Duration(hours: -1);
const Duration negOffset = Duration(hours: 1);

class TripTimelineHeader extends StatelessWidget {
  final Trip? trip;
  final Trip? pred;
  final r.Route? route;
  final bool isFavourite;
  final void Function() reloadData;
  final void Function(DateTime, Direction) loadData;
  final bool allowRouteNavigation;
  final bool disableDirection;
  final DateTime refTime;
  final Direction direction;
  final DateTime offTime;

  TripTimelineHeader({
    required this.trip,
    required this.isFavourite,
    required this.reloadData,
    required this.loadData,
    required this.refTime,
    required this.direction,
    bool? allowRouteNavigation,
    bool? disableDirection,
    this.pred,
    super.key,
  })  : route = null,
        offTime = refTime.add(offset),
        allowRouteNavigation = allowRouteNavigation ?? false,
        disableDirection = disableDirection ?? false;

  TripTimelineHeader.noStatus({
    required this.route,
    required this.isFavourite,
    required this.reloadData,
    required this.loadData,
    required this.refTime,
    required this.direction,
    bool? allowRouteNavigation,
    bool? disableDirection,
    super.key,
  })  : trip = null,
        pred = null,
        offTime = refTime.add(offset),
        allowRouteNavigation = allowRouteNavigation ?? false,
        disableDirection = disableDirection ?? false;

  @override
  Widget build(BuildContext context) {
    PrefsBloc prefsBloc = context.read<PrefsBloc>();

    List<Widget> headerRows;
    if (route == null) {
      headerRows = [
        _buildTitleRow(context, prefsBloc),
        _buildStatusRow(context),
        _buildFilterRow(context),
      ];
    } else {
      headerRows = [
        _buildTitleRow(context, prefsBloc),
        _buildFilterRow(context),
      ];
    }

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

  Row _buildTitleRow(BuildContext context, PrefsBloc prefsBloc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RouteTile(
          trip?.route ?? route!,
          refTime: refTime,
          isClickable: allowRouteNavigation,
        ),
        Expanded(
          child: Text(
            trip?.route.longName ?? route!.longName,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () => isFavourite
              ? prefsBloc.add(RemoveRoute(trip?.route ?? route!))
              : prefsBloc.add(AddRoute(trip?.route ?? route!)),
          icon: Icon(
            isFavourite
                ? MingCuteIcons.mgc_heart_fill
                : MingCuteIcons.mgc_heart_line,
            color: Colors.redAccent,
          ),
        )
      ],
    );
  }

  Text _buildStatusLabel(BuildContext context, Trip? pred) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    String status;
    if (trip!.lastUpdate == null && pred == null) {
      status = loc.noRealTimeData;
    } else if (trip!.lastUpdate != null) {
      if (trip!.lastSequenceDetection == 0 && DateTime.now().isAfter(offTime)) {
        status = loc.yetToStart;
      } else if (trip!.lastSequenceDetection == trip!.stopTimes.length) {
        status = loc.ended;
      } else if (trip!.delay == 0) {
        status = loc.onTime;
      } else {
        if (trip!.delay < 0) {
          status = loc.early(-1 * trip!.delay.round());
        } else {
          status = loc.late(trip!.delay.round());
        }
      }
    } else {
      if (pred!.lastUpdate == null) {
        status = loc.noRealTimeData;
      } else {
        // Time offset between termination of pred and beginning of current trip
        int delay = _getDelay(pred);
        if (delay > 0) {
          status = loc.late(delay);
        } else {
          status = loc.yetToStart;
        }
      }
    }

    return Text(
      status,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }

  int _getDelay(Trip pred) {
    var offset = trip!.stopTimes.first.arrivalTime
        .difference(pred.stopTimes.last.arrivalTime);
    var delay = pred.delay.round() - offset.inMinutes;
    return delay;
  }

  Row _buildStatusRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusLabel(context, pred),
                _buildLastUpdateLabel(context, pred),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildStatusIndicator(context, pred),
            IconButton(
              onPressed: reloadData,
              icon: Icon(MingCuteIcons.mgc_refresh_1_line),
            )
          ],
        ),
      ],
    );
  }

  Text _buildLastUpdateLabel(BuildContext context, Trip? pred) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    String text = loc.noReading;
    if (trip!.lastUpdate != null) {
      text = loc.lastReading(
          formatTime(trip!.lastUpdate!.hour + 1, trip!.lastUpdate!.minute));
    } else if (pred != null && pred.lastUpdate != null) {
      text = loc.lastReading(format(
          '{:0>2}:{:0>2}', pred.lastUpdate!.hour + 1, pred.lastUpdate!.minute));
    }
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildStatusIndicator(BuildContext context, Trip? pred) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    IconData icon = MingCuteIcons.mgc_alert_diamond_fill;
    Color color = Colors.red;
    String text = loc.noReadingAlert;

    if (trip!.lastUpdate != null) {
      icon = MingCuteIcons.mgc_check_fill;
      color = Colors.lightGreen;
    } else if (pred != null && pred.lastUpdate != null) {
      color = Colors.orange;
      text = loc.predictedReadingAlert;
    }

    Widget pulser = Container(
      margin: const EdgeInsets.only(left: 10),
      child: PulseIcon(
        icon: icon,
        pulseColor: color,
        iconSize: 18,
        pulseSize: 50,
      ),
    );
    if (trip!.lastUpdate == null) {
      return PromptedChoice.single(
        promptDelegate: Defaults.delegatePopupDialog(),
        itemCount: 1,
        itemBuilder: (_, __) => Text(''),
        listBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            text,
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        anchorBuilder: (state, openModal) {
          return GestureDetector(
            onTap: openModal,
            child: pulser,
          );
        },
        modalHeaderBuilder: ChoiceModal.createHeader(
          automaticallyImplyLeading: false,
          title: Text(
            loc.noReadingAlertTitle,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          elevation: 5,
        ),
      );
    } else {
      return pulser;
    }
  }

  Container _buildFilterRow(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Builder(builder: (context) {
            Map<Direction, String> values = {
              Direction.forward: loc.forwardOnly,
              Direction.backward: loc.backwardOnly,
              Direction.both: loc.bothDirections
            };
            const Map<Direction, IconData> icons = {
              Direction.forward: MingCuteIcons.mgc_arrow_right_line,
              Direction.backward: MingCuteIcons.mgc_arrow_left_line,
              Direction.both: MingCuteIcons.mgc_transfer_line
            };

            Widget child;
            if (disableDirection) {
              child = Row(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(icons[direction]),
                ),
                Text(values[direction]!)
              ]);
            } else {
              child = _buildDirectionPrompt(values, context, icons, loc);
            }

            return Expanded(
              child: child,
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
                    loadData(value.add(offset), direction);
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
                  Text(format('{:0>2}/{:0>2} {:0>2}:{:0>2}', refTime.day,
                      refTime.month, refTime.hour, refTime.minute))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PromptedChoice<Direction> _buildDirectionPrompt(
      Map<Direction, String> values,
      BuildContext context,
      Map<Direction, IconData> icons,
      AppLocalizations loc) {
    return PromptedChoice<Direction>.single(
      promptDelegate: Defaults.delegatePopupDialog(),
      itemCount: values.length,
      itemBuilder: (state, index) {
        MapEntry<Direction, String> val = values.entries.elementAt(index);
        return ChoiceChip(
          label: Text(
            val.value,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          selected: val.key == direction,
          onSelected: (value) => state.select(val.key),
          selectedColor: Theme.of(context).colorScheme.secondary.withAlpha(200),
        );
      },
      listBuilder: ChoiceList.createWrapped(
        padding: EdgeInsets.all(10),
        spacing: 10,
      ),
      anchorBuilder: (state, openModal) {
        return GestureDetector(
          onTap: openModal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(icons[direction]),
              ),
              Text(values[direction]!)
            ],
          ),
        );
      },
      modalHeaderBuilder: ChoiceModal.createHeader(
        automaticallyImplyLeading: false,
        title: Text(
          loc.directionChoice,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        elevation: 5,
      ),
      onChanged: (value) {
        loadData(offTime, value!);
      },
    );
  }
}
