import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:timelines/timelines.dart';

class RoutePicker extends StatelessWidget {
  final List<String> hints;
  final List<SearchController> ctrls;
  final Function(int) onTap;
  final Function(String) onChanged;

  const RoutePicker(this.hints, this.ctrls,
      {required this.onTap, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

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
          color: theme.colorScheme.primary,
        ),
        indicatorPosition: 0.5,
      ),
      padding: EdgeInsets.symmetric(vertical: 6.0),
      shrinkWrap: true,
      builder: TimelineTileBuilder.connected(
        itemCount: 2,
        contentsBuilder: (context, index) {
          return SearchBar(
            controller: ctrls[index],
            constraints: const BoxConstraints(maxHeight: 45),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: theme.colorScheme.primary)),
            ),
            elevation: WidgetStatePropertyAll(0),
            padding: WidgetStatePropertyAll(EdgeInsets.all(4.0)),
            hintText: hints[index],
            onTap: () => onTap(index),
            onChanged: onChanged,
          );
        },
        connectorBuilder: (context, index, type) {
          var indent = 10.0;
          var endIndent = 1.0;
          if (type == ConnectorType.start) {
            indent = 1.0;
            endIndent = 4.2;
          }
          return DashedLineConnector(
            indent: indent,
            endIndent: endIndent,
            gap: 2,
          );
        },
        indicatorBuilder: (context, index) {
          if (index == 0) {
            return OutlinedDotIndicator(
              size: 15,
            );
          } else {
            return Icon(
              MingCuteIcons.mgc_location_fill,
              size: 18,
              color: theme.colorScheme.primary,
            );
          }
        },
        itemExtent: 45,
      ),
    );
  }
}
