import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:osm_api/model/location.dart';
import 'package:trasportimus/blocs/osm/osm_bloc.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/map/hints_type.dart';
import 'package:trasportimus/widgets/tiles/location.dart';
import 'package:trasportimus/widgets/tiles/position.dart';
import 'package:trasportimus/widgets/tiles/stop.dart';
import 'package:trasportimus_repository/model/stop.dart';

class SearchHintsViewer extends StatefulWidget {
  final Stream<String> texts;
  final OsmBloc osmBloc;
  final SearchController ctrl;
  final bool showCurrentPosition;
  final List<Stop> stops;
  final Set<Stop> favStops;
  final Function(HintType) onTap;

  const SearchHintsViewer(
      this.texts, this.osmBloc, this.ctrl, this.stops, this.favStops,
      {required this.onTap, bool? showCurrentPosition, super.key})
      : showCurrentPosition = showCurrentPosition ?? false;

  @override
  State<StatefulWidget> createState() => SearchHintsViewerState();
}

class SearchHintsViewerState extends State<SearchHintsViewer> {
  late Set<Stop> favStops;
  late List<Location> locations;
  late String key;
  late bool waitingForLocations;

  @override
  void initState() {
    super.initState();
    favStops = widget.favStops;
    locations = [];
    key = "";
    waitingForLocations = false;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return MultiBlocListener(
        listeners: [
          BlocListener<PrefsBloc, PrefsState>(
            listener: (context, state) {
              if (state is PrefsStopsUpdated) {
                setState(() {
                  favStops = state.stops;
                });
              }
            },
          ),
          BlocListener<OsmBloc, OsmState>(
            bloc: widget.osmBloc,
            listener: (context, state) {
              if (state is OsmData && state.key == key) {
                setState(() {
                  locations = state.locations;
                  waitingForLocations = false;
                });
              } else if (state is OsmStillFetching) {
                setState(() {
                  waitingForLocations = true;
                });
              } else {
                setState(() {
                  waitingForLocations = false;
                });
              }
            },
          ),
        ],
        child: StreamBuilder(
          stream: widget.texts,
          builder: (context, snapshot) {
            List<Object> all = [];
            if (widget.showCurrentPosition) {
              all.add(YourPosition());
            }

            if ((snapshot.data ?? "").isNotEmpty) {
              key = snapshot.data!;
              var filteredStops = _filterStops(snapshot.data!);
              all.addAll(filteredStops);
              all.addAll(locations);
              if (waitingForLocations) {
                all.add(Loader());
              }
            } else {
              key = "";
            }

            if (all.isEmpty) {
              return Container();
            }

            return Container(
              decoration: BoxDecoration(
                boxShadow: Defaults.shadows,
                borderRadius: Defaults.borderRadius,
                color: theme.colorScheme.surface,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                minHeight: 0,
              ),
              width: double.infinity,
              child: ListView.builder(
                itemCount: all.length,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
                itemExtent: 60,
                itemBuilder: (context, index) {
                  var el = all[index];

                  if (el is Stop) {
                    return StopExpanded(
                      el,
                      widget.favStops.contains(el),
                      onTap: (stop) => widget.onTap(StopHint(stop)),
                    );
                  } else if (el is YourPosition) {
                    return YourPositionExpanded(
                        onTap: () => widget.onTap(YourPositionHint()));
                  } else if (el is Location) {
                    return LocationExpanded(
                      el,
                      onTap: (location) {
                        widget.onTap(LocationHint(location));
                      },
                    );
                  } else {
                    return LoaderExpanded();
                  }
                },
              ),
            );
          },
        ));
  }

  List<Stop> _filterStops(String text) {
    var results = extractTop(
      query: text,
      choices: widget.stops,
      limit: 6,
      cutoff: 75,
      getter: (stop) => stop.name,
    );
    var found = results.map((el) => widget.stops[el.index]).toList();

    // Favourite stops are shown before the others
    found.sort((a, b) {
      var favA = widget.favStops.contains(a);
      var favB = widget.favStops.contains(b);

      if (favA ^ favB) {
        return favA ? -1 : 1;
      }
      return compareStops(a, b);
    });
    return found;
  }
}

final class YourPosition {}

final class Loader {}
