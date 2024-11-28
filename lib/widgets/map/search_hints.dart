import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/tiles/stop.dart';
import 'package:trasportimus_repository/model/stop.dart';

class SearchHintsViewer extends StatefulWidget {
  final Stream<String> texts;
  final SearchController ctrl;
  final bool showCurrentPosition;
  final List<Stop> stops;
  final Set<Stop> favStops;
  final Function(Stop) onTap;

  const SearchHintsViewer(this.texts, this.ctrl, this.stops, this.favStops,
      {required this.onTap, bool? showCurrentPosition, super.key})
      : showCurrentPosition = showCurrentPosition ?? false;

  @override
  State<StatefulWidget> createState() => SearchHintsViewerState();
}

class SearchHintsViewerState extends State<SearchHintsViewer> {
  late List<Stop> found;

  @override
  void initState() {
    super.initState();
    found = [];
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return StreamBuilder(
      stream: widget.texts,
      builder: (context, snapshot) {
        if ((snapshot.data ?? "").isEmpty) {
          return Container();
        }

        var text = snapshot.data!.trim().toLowerCase();
        _filterStops(text);
        if (found.isEmpty) {
          return Container();
        }

        return Container(
          decoration: BoxDecoration(
            boxShadow: Defaults.shadows,
            borderRadius: Defaults.borderRadius,
            color: theme.colorScheme.surface,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            minHeight: 0,
          ),
          width: double.infinity,
          child: ListView.builder(
            itemCount: min(6, found.length),
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 12.0, right: 8.0),
            itemExtent: 60,
            itemBuilder: (context, index) {
              var stop = found[index];
              String subtitle = '';
              if (stop.street != '' && stop.town != '') {
                subtitle = '${stop.street}, ${stop.town}';
              } else if (stop.street == '') {
                subtitle = stop.town;
              } else {
                subtitle = stop.street;
              }

              return ListTile(
                leading: Transform.scale(scale: 0.9, child: StopTile(stop)),
                title: Text(
                  stop.name,
                  overflow: TextOverflow.clip,
                ),
                subtitle: Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  widget.favStops.contains(stop)
                      ? MingCuteIcons.mgc_heart_fill
                      : MingCuteIcons.mgc_heart_line,
                  color: Colors.redAccent,
                ),
                horizontalTitleGap: 5,
                isThreeLine: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                onTap: () => widget.onTap(stop),
              );
            },
          ),
        );
      },
    );
  }

  void _filterStops(String text) {
    found = widget.stops
        .where((stop) => stop.name.toLowerCase().contains(text))
        .toList();

    // Favourite stops are shown before the others
    found.sort((a, b) {
      var favA = widget.favStops.contains(a);
      var favB = widget.favStops.contains(b);

      if (favA ^ favB) {
        return favA ? -1 : 1;
      }
      return compareStops(a, b);
    });
  }
}
