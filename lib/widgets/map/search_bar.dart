import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:pulsator/pulsator.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/map/search_hints.dart';
import 'package:trasportimus_repository/model/model.dart';

class MapSearchBar extends StatefulWidget {
  final TransportBloc transBloc;
  final Set<Stop> favStops;
  final MapController mapCtrl;

  const MapSearchBar(this.transBloc, this.favStops, this.mapCtrl, {super.key});

  @override
  State<StatefulWidget> createState() => MapSearchBarState();
}

class MapSearchBarState extends State<MapSearchBar> {
  late List<Stop> stops;
  late AppLocalizations loc;
  late bool isExpanded;
  late StreamController<String> textStream;
  late SearchController ctrl;

  @override
  void initState() {
    super.initState();
    isExpanded = false;
    stops = List.empty();
    textStream = StreamController.broadcast();
    ctrl = SearchController();
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;
    var theme = Theme.of(context);
    Widget child;

    if (!isExpanded) {
      child = _buildSimpleSearchBar(context, theme);
    } else {
      child = _buildRouteBar(context, theme);
    }

    return BlocConsumer<TransportBloc, TransportState>(
      bloc: widget.transBloc,
      listenWhen: (previous, current) =>
          previous is TransportFetchedStops && current is TransportFetchFailed,
      listener: (context, state) {
        Defaults.showErrorSnackBar(context, state as TransportFetchFailed);
      },
      buildWhen: (previous, current) => !(previous is! TransportFetchedStops &&
          current is TransportFetchFailed),
      builder: (context, state) {
        if (state is TransportStillFetching) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              child,
              SizedBox(height: 5),
              Container(
                height: 50,
                decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: Defaults.shadows,
                    borderRadius: Defaults.borderRadius),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        loc.mapStopsLoading,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    PulseIcon(
                      icon: MingCuteIcons.mgc_arrow_down_circle_fill,
                      pulseColor: Colors.lightGreen,
                      pulseSize: 50,
                      iconSize: 18,
                      iconColor: Colors.white,
                    )
                  ],
                ),
              )
            ],
          );
        }
        if (state is TransportFetchFailed) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              child,
              SizedBox(height: 5),
              Container(
                height: 50,
                decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: Defaults.shadows,
                    borderRadius: Defaults.borderRadius),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        loc.mapStopsLoadingFailed,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.transBloc.add(FetchStops()),
                      child: PulseIcon(
                        icon: MingCuteIcons.mgc_alert_diamond_fill,
                        pulseColor: Colors.red,
                        pulseSize: 50,
                        iconSize: 18,
                        iconColor: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }

        if (state is TransportFetchedStops) {
          stops = state.stops;
        }

        return child;
      },
    );
  }

  Widget _buildSimpleSearchBar(BuildContext context, ThemeData theme) {
    var searchBar = SearchBar(
      constraints: const BoxConstraints(maxHeight: 50, minHeight: 50),
      shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Defaults.borderRadius)),
      leading: const Padding(
        padding: EdgeInsets.only(left: 6.0),
        child: Icon(MingCuteIcons.mgc_search_3_line),
      ),
      trailing: [
        IconButton(
          onPressed: () => setState(() {
            isExpanded = true;
          }),
          icon: Icon(MingCuteIcons.mgc_route_line),
        )
      ],
      hintText: loc.mapSearchHint,
      autoFocus: false,
      controller: ctrl,
      onChanged: (value) => textStream.add(value),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        searchBar,
        SizedBox(
          height: 5,
        ),
        SearchHintsViewer(
          textStream.stream,
          ctrl,
          stops,
          widget.favStops,
          onTap: (stop) {
            ctrl.clear();
            textStream.add("");
            widget.mapCtrl.move(LatLng(stop.latitude, stop.longitude), 17.5);
          },
        ),
      ],
    );
  }

  Widget _buildRouteBar(BuildContext context, ThemeData theme) {
    var backButton = IconButton(
      onPressed: () => setState(() {
        isExpanded = false;
      }),
      icon: const Icon(MingCuteIcons.mgc_arrow_left_line),
    );

    return Container(
      constraints: BoxConstraints(maxHeight: 100),
      decoration: BoxDecoration(
          boxShadow: Defaults.shadows,
          borderRadius: Defaults.borderRadius,
          color: theme.colorScheme.surface),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          backButton,
        ],
      ),
    );
  }
}
