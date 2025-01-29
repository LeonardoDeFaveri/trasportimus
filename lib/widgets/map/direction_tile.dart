import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

const sep = Icon(MingCuteIcons.mgc_right_fill);

class DirectionTile extends StatelessWidget {
  final m.Way way;
  final DateTime refDateTime;

  const DirectionTile(this.way, this.refDateTime, {super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainRow(loc, theme),
          SizedBox(height: 5,),
          _buildTimeRow(theme),
          SizedBox(height: 5,),
          _buildDepartureInfoRow(loc, theme),
          SizedBox(height: 2,),
        ],
      ),
    );
  }

  Widget _buildMainRow(AppLocalizations loc, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTransportIndicators(theme),
        SizedBox(width: 10,),
        _buildTimeInfo(loc, theme),
      ],
    );
  }

  Widget _buildTransportIndicators(ThemeData theme) {
    List<Widget> children = [];
    bool skip = false;

    for (var step in way.steps) {
      if (children.isNotEmpty && !skip) {
        children.add(sep);
      }

      if (step.travelMode is m.Walking) {
        if (step.duration.inMinutes > 0) {
          children.add(WalkingTile(step.duration));
        } else {
          skip = true;
        }
      } else {
        var mode = step.travelMode as m.Transit;
        var icon = switch (mode.mode) {
          m.TransportType.bus => MingCuteIcons.mgc_bus_line,
          m.TransportType.rail => MingCuteIcons.mgc_train_2_line,
          m.TransportType.cableway => MingCuteIcons.mgc_aerial_lift_fill,
          m.TransportType.unknown => MingCuteIcons.mgc_bus_2_line,
        };
        children.add(Icon(
          icon,
          color: Colors.grey[850],
        ));
        children.add(TransitTile(mode.info, mode.mode));
      }
    }

    return Expanded(
        child: SizedBox(
          height: 31,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
          ),
        )
      );
  }

  Widget _buildTimeInfo(AppLocalizations loc, ThemeData theme) {
    String text;
    int hours = way.duration.inHours;
    int minutes = way.duration.inMinutes;
    if (way.duration.inHours > 0) {
      minutes -= hours * 60;
      text = loc.fullTimeInfo(hours, minutes);
    } else {
      text = loc.shortTimeInfo(minutes);
    }
    return Text(
      text,
      style: theme.textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
  
  Widget _buildTimeRow(ThemeData theme) {
    DateTime dep = way.departureTime ?? refDateTime;
    DateTime arr = way.arrivalTime ?? refDateTime.add(way.duration);
    DateTime today = DateTime.now();

    String departureTimeStr = formatTime(dep.hour, dep.minute);
    String departureDayStr = '';
    if (dep.day != today.day || dep.month != today.month || dep.year != today.year) {
      departureDayStr = ' (${DateFormat.MMMd().format(dep)})';
    }

    String arrivalTimeStr = formatTime(arr.hour, arr.minute);
    String arrivalDayStr = '';
    if (arr.day != today.day || arr.month != today.month || arr.year != today.year) {
      arrivalDayStr = ' (${DateFormat.MMMd().format(arr)})';
    }

    if (departureDayStr == arrivalDayStr) {
      arrivalDayStr = '';
    }

    return Text(
      '$departureTimeStr$departureDayStr - $arrivalTimeStr$arrivalDayStr',
      style: theme.textTheme.bodyLarge,
    );
  }
  
  Widget _buildDepartureInfoRow(AppLocalizations loc, ThemeData theme) {
    String text;
    try {
      var step = way.steps.firstWhere((step) => step.travelMode is m.Transit);
      var mode = step.travelMode as m.Transit;
      String place;
      switch (mode.info.runtimeType) {
        case const (m.RichInfo):
          var info = (mode.info as m.RichInfo);
          place = info.trip.stopTimes[info.departureStopIndex].stop.name;
        default:
          var info = (mode.info as m.PoorInfo);
          place = info.departureStopName;
      }
      var dep = mode.departureTime;
      var time = formatTime(dep.hour, dep.minute);
      text = loc.stepInfo(time, place);
    } catch (e) {
      text = loc.noStepInfo;
    }
    
    return Text(text, overflow: TextOverflow.ellipsis,);
  }
}

class WalkingTile extends StatelessWidget {
  final Duration duration;

  const WalkingTile(this.duration, {super.key});

  @override
  Widget build(BuildContext context) {
    int minutes = duration.inMinutes;
    return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MingCuteIcons.mgc_walk_fill,
            color: Colors.grey[850],
          ),
          Text(
            minutes.toString(),
            style:
              Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
          )
        ],
      );
  }
}

class TransitTile extends StatelessWidget {
  final m.TransitInfo info;
  final m.TransportType mode;

  const TransitTile(this.info, this.mode, {super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    String name;
    Color color;
    if (info is m.RichInfo) {
      var richInfo = info as m.RichInfo;
      name = richInfo.trip.route.shortName;
      color = richInfo.trip.route.color;
    } else {
      var poorInfo = info as m.PoorInfo;
      if (poorInfo.routeShortName == null && poorInfo.routeFullName != null && poorInfo.routeFullName!.length > 5) {
        name = switch (mode) {
          m.TransportType.rail => loc.rail,
          m.TransportType.cableway => loc.cableway,
          _ => loc.bus
        };
      } else {
        name = poorInfo.routeShortName ?? poorInfo.routeFullName!;
      }
      color = poorInfo.routeColor;
    }

    var showBorder = false;
    if (color == Colors.white) {
      showBorder = true;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        border: showBorder ? Border.all(color: Colors.black12) : null,
        color: showBorder ? Colors.black12 : color,
      ),
      margin: EdgeInsets.all(showBorder ? 2 : 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              name,
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
