import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:timelines/timelines.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus_repository/model/model.dart';

class TripTimeline extends StatelessWidget {
  final Trip trip;

  /// The trip that precedes the current one
  final Trip? pred;
  final Function()? goToPred;

  /// What should happen when an item is pressed?
  final void Function(StopTime) onPressed;

  /// How should normal items be presented?
  final Widget Function(BuildContext, StopTime) itemBuilder;

  /// How should a marked item be represented?
  final Widget Function(BuildContext, StopTime) markedItemBuilder;

  /// A set of stoptime sequence numbers that requires a different
  /// presentation from the others.
  final Set<int> markedItems;

  /// The focused item is the one that is put middle screen when the timeline
  /// is first shown
  final int focusItem;

  /// What's the last stoptime visited
  final int lastItem;

  final ScrollController controller;

  TripTimeline({
    required this.trip,
    required this.onPressed,
    required this.itemBuilder,
    required this.markedItemBuilder,
    required this.markedItems,
    required this.lastItem,
    required this.focusItem,
    this.pred,
    this.goToPred,
    super.key,
  }) : controller = ScrollController(
          initialScrollOffset: focusItem <= 4 ? 0 : (focusItem - 4) * 60,
        );

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Widget timeline = _buildTimeline(theme);

    if (trip.lastUpdate == null && pred != null) {
      Widget predTimeline = GestureDetector(
        onTap: goToPred != null ? () => goToPred!() : null,
        child: Container(
          //height: 150,
          margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              boxShadow: Defaults.shadows,
              borderRadius: Defaults.borderRadius,
              border: Border.all(color: Colors.orange, width: 1.5),
              color: Colors.white),
          //color: Colors.orange.withAlpha(50),
          child: _buildPredTimeline(theme),
        ),
      );
      //return predTimeline;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [predTimeline, Expanded(child: timeline)],
      );
    }

    return timeline;
  }

  Widget _buildTimeIndicator(StopTime st, ThemeData theme) {
    Widget programmedTime = Text(
      format('{:0>2}:{:0>2}', st.arrivalTime.hour, st.arrivalTime.minute),
      style: theme.textTheme.bodyLarge,
    );

    int? delay;
    if (trip.lastSequenceDetection < st.stopSequence &&
        trip.lastUpdate != null) {
      delay = trip.delay.round();
    } else if (pred != null && pred!.lastUpdate != null) {
      delay = _getDelay(pred!);
      if (delay <= 0) {
        delay = null;
      }
    }

    if (delay != null) {
      DateTime actualArrival = st.arrivalTime.add(Duration(minutes: delay));
      Widget actualTime = Text(
        format('{:0>2}:{:0>2}', actualArrival.hour, actualArrival.minute),
        style: theme.textTheme.bodyLarge!.copyWith(
            color: delay < 0
                ? Colors.cyan
                : delay == 0
                    ? Colors.green
                    : delay < 5
                        ? Colors.orange
                        : Colors.red),
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [programmedTime, actualTime],
      );
    }

    return programmedTime;
  }

  Widget _buildPredTimeIndicator(StopTime st, ThemeData theme) {
    Widget programmedTime = Text(
      format('{:0>2}:{:0>2}', st.arrivalTime.hour, st.arrivalTime.minute),
      style: theme.textTheme.bodyLarge,
    );

    int delay = pred!.delay.round();
    DateTime actualArrival = st.arrivalTime.add(Duration(minutes: delay));
    Widget actualTime = Text(
      format('{:0>2}:{:0>2}', actualArrival.hour, actualArrival.minute),
      style: theme.textTheme.bodyLarge!.copyWith(
          color: delay < 0
              ? Colors.cyan
              : delay == 0
                  ? Colors.green
                  : delay < 5
                      ? Colors.orange
                      : Colors.red),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [programmedTime, actualTime],
    );
  }

  int _getDelay(Trip pred) {
    var offset = trip.stopTimes.first.arrivalTime
        .difference(pred.stopTimes.last.arrivalTime);
    var delay = pred.delay.round() - offset.inMinutes;
    return delay;
  }

  Widget _buildTimeline(ThemeData theme) {
    return Timeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
        connectorTheme: ConnectorThemeData(
          space: 40,
          thickness: 3.5,
          color: theme.colorScheme.secondary,
        ),
        indicatorTheme: IndicatorThemeData(
          size: 24.0,
          color: theme.colorScheme.secondary,
        ),
        indicatorPosition: 0.5,
      ),
      controller: controller,
      builder: TimelineTileBuilder.connected(
        contentsBuilder: (context2, index) {
          StopTime st = trip.stopTimes[index];

          Widget child;
          if (markedItems.contains(st.stopSequence) && pred == null) {
            child = markedItemBuilder(context2, st);
          } else {
            child = itemBuilder(context2, st);
          }

          return GestureDetector(
            onTap: () => onPressed(st),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [child, _buildTimeIndicator(st, theme)],
              ),
            ),
          );
        },
        connectorBuilder: (_, index, connectorType) {
          if (index >= lastItem) {
            return SolidLineConnector(
              indent: 4,
              endIndent: 4,
              color: theme.colorScheme.secondary.withAlpha(150),
            );
          } else {
            return SolidLineConnector(
              indent: connectorType == ConnectorType.start ? 0 : 2.0,
              endIndent: connectorType == ConnectorType.end ? 0 : 2.0,
            );
          }
        },
        indicatorBuilder: (_, index) {
          if (index >= lastItem) {
            return OutlinedDotIndicator(
              color: theme.colorScheme.primary,
            );
          }
          return DotIndicator(
            color: theme.colorScheme.primary,
          );
        },
        itemExtentBuilder: (_, __) => 60,
        itemCount: trip.stopTimes.length,
      ),
    );
  }

  Widget _buildPredTimeline(ThemeData theme) {
    return SizedBox(
      height: 120,
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          connectorTheme: ConnectorThemeData(
            space: 40,
            thickness: 3.5,
            color: theme.colorScheme.secondary,
          ),
          indicatorTheme: IndicatorThemeData(
            size: 24.0,
            color: theme.colorScheme.secondary,
          ),
          indicatorPosition: 0.5,
        ),
        shrinkWrap: false,
        builder: TimelineTileBuilder.connected(
          itemCount: 2,
          contentsBuilder: (context2, index) {
            Widget child;
            StopTime st;
            if (index == 0) {
              if (pred!.lastSequenceDetection == 0) {
                st = pred!.stopTimes.first;
                child = itemBuilder(context2, st);
              } else {
                st = pred!.stopTimes[pred!.lastSequenceDetection - 1];
                child = markedItemBuilder(context2, st);
              }
            } else {
              st = pred!.stopTimes.last;
              child = itemBuilder(context2, st);
            }

            return Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                  width: 1,
                  color: theme.colorScheme.secondary,
                )),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [child, _buildPredTimeIndicator(st, theme)],
              ),
            );
          },
          connectorBuilder: (_, index, connectorType) {
            return SolidLineConnector(
              indent: 4,
              endIndent: 4,
              color: theme.colorScheme.secondary.withAlpha(150),
            );
          },
          indicatorBuilder: (_, index) {
            if (index == 1) {
              return OutlinedDotIndicator(
                color: theme.colorScheme.primary,
              );
            }
            return DotIndicator(
              color: theme.colorScheme.primary,
            );
          },
          itemExtentBuilder: (_, __) => 60,
        ),
      ),
    );
  }
}
