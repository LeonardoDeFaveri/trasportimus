import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:timelines/timelines.dart';
import 'package:trasportimus_repository/model/model.dart';

class TripTimeline extends StatelessWidget {
  final Trip trip;

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
    super.key,
  }) : controller = ScrollController(
          initialScrollOffset: focusItem <= 4 ? 0 : (focusItem - 4) * 60,
        );

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

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
          if (markedItems.contains(st.stopSequence)) {
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
                )),
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
              color: Theme.of(context).colorScheme.secondary.withAlpha(150),
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
              color: Theme.of(context).colorScheme.primary,
            );
          }
          return DotIndicator(
            color: Theme.of(context).colorScheme.primary,
          );
        },
        itemExtentBuilder: (_, __) => 60,
        itemCount: trip.stopTimes.length,
      ),
    );
  }

  Widget _buildTimeIndicator(StopTime st, ThemeData theme) {
    Widget programmedTime = Text(
      format('{:0>2}:{:0>2}', st.arrivalTime.hour, st.arrivalTime.minute),
      style: theme.textTheme.bodyLarge,
    );
    if (trip.lastSequenceDetection < st.stopSequence &&
        trip.lastUpdate != null) {
      int minutes = trip.delay.round();
      DateTime actualArrival = st.arrivalTime.add(Duration(minutes: minutes));
      Widget actualTime = Text(
        format('{:0>2}:{:0>2}', actualArrival.hour, actualArrival.minute),
        style: theme.textTheme.bodyLarge!.copyWith(
            color: minutes < 0
                ? Colors.cyan
                : minutes == 0
                    ? Colors.green
                    : minutes < 5
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
}
