import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:timelines/timelines.dart';
import 'package:trasportimus/widgets/map/direction_details_tokens.dart';
import 'package:trasportimus/widgets/map/token_tiles.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

class DirectionDetails extends StatefulWidget {
  final m.Way way;
  final DateTime refDateTime;

  const DirectionDetails(this.way, this.refDateTime, {super.key});

  @override
  State<StatefulWidget> createState() => DirectionDetailsState();
}

class DirectionDetailsState extends State<DirectionDetails> {
  late Set<int> expandedSteps;

  @override
  void initState() {
    super.initState();
    expandedSteps = {};
  }

  @override
  Widget build(BuildContext context) {
    var controller = ScrollController();
    var theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    var tokens = _buildTokens();
    List<Widget> tiles = [];
    bool showBorder = true;

    for (var token in tokens) {
      Widget indicator, content;
      Widget startConnector = Connector.transparent();
      Widget endConnector = Connector.transparent();
      double extent;
      if (token is StartLocation) {
        indicator = Icon(
          MingCuteIcons.mgc_location_fill,
          size: 24,
          color: Colors.blueGrey,
        );
        content = buildStartLocationTile(token, context, theme);
        if (token.showWalking) {
          endConnector = _buildWalkingConnector();
        }
        extent = 65;
      } else if (token is WalkingInfo) {
        indicator = _buildWalkingIndicator();
        content = buildWalkingTile(token, theme, loc);
        startConnector = _buildWalkingConnector(start: true);
        endConnector = _buildWalkingConnector();
        extent = 65;
      } else if (token is Transferring) {
        indicator = _buildWalkingIndicator();
        content = buildTransferringTile(token, theme, loc);
        startConnector = _buildWalkingConnector(start: true);
        endConnector = _buildWalkingConnector();
        extent = 50;
      } else if (token is TransitStartLocation) {
        indicator = _buildTransitStartLocationIndicator(token);
        content = buildTransitStartLocationTile(token, context, theme);
        if (token.showWalking) {
          startConnector = _buildWalkingConnector(start: true);
        }
        endConnector =
            _buildTransitConnector(token.transitInfo.getRouteColor());
        extent = 65;
      } else if (token is TransitRouteInfo) {
        indicator = Indicator.transparent(
          size: 0,
        );
        content = buildTransitRouteInfoTile(token, context, theme, loc);
        startConnector = _buildTransitConnector(token.color);
        endConnector = _buildTransitConnector(token.color);
        extent = 85;
      } else if (token is TransitIntermediateLocationHeader) {
        indicator = Indicator.transparent(
          size: 0,
        );
        content = buildTransitIntermediateLocationHeader(
          token,
          theme,
          expandedSteps.contains(token.id),
          token.canExpand ? () => toggleExpandedStep(token.id) : null,
          loc,
        );
        startConnector = _buildTransitConnector(token.color);
        endConnector = _buildTransitConnector(token.color);
        extent = 60;
      } else if (token is TransitIntermediateLocationSingle) {
        indicator = _buildTransitIntermediateLocationIndictor(token);
        content = buildTransitIntermediateLocationSingle(token, theme);
        startConnector = _buildTransitConnector(token.color);
        endConnector = _buildTransitConnector(token.color);
        extent = 32;
        showBorder = false;
      } else if (token is TransitStopLocation) {
        indicator = _buildTransitStopLocationIndicator(token);
        content = buildTransitStopLocationTile(token, context, theme);
        startConnector =
            _buildTransitConnector(token.transitInfo.getRouteColor());
        if (token.showWalking) {
          endConnector = _buildWalkingConnector();
        }
        extent = 65;
        showBorder = true;
      } else {
        var localToken = token as EndLocation;
        showBorder = false;
        indicator = Icon(
          MingCuteIcons.mgc_location_fill,
          size: 24,
          color: Colors.blueGrey,
        );
        content = buildEndLocationTile(localToken, context, theme);
        if (localToken.showWalking) {
          startConnector = _buildWalkingConnector();
        }
        extent = 65;
      }

      tiles.add(TimelineTile(
        contents: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: showBorder
              ? BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    width: 0.8,
                  )),
                )
              : null,
          alignment: Alignment.center,
          child: content,
        ),
        nodePosition: 0.025,
        node: TimelineNode(
          indicator: indicator,
          startConnector: startConnector,
          endConnector: endConnector,
        ),
        mainAxisExtent: extent,
      ));
    }

    return Timeline(
      shrinkWrap: true,
      controller: controller,
      padding: EdgeInsets.only(top: 2),
      theme: TimelineThemeData(
        indicatorPosition: 0.5,
        nodePosition: 0.025,
        nodeItemOverlap: false,
        indicatorTheme: IndicatorThemeData(
          size: 24,
          color: Colors.blueGrey,
        ),
        connectorTheme:
            ConnectorThemeData(color: Colors.blueGrey, thickness: 5),
      ),
      children: tiles,
    );
  }

  List<DirectionDetailsToken> _buildTokens() {
    List<DirectionDetailsToken> tokens = [];
    DateTime departure = widget.way.departureTime ?? widget.refDateTime;
    // Used to compute the waiting time for walking steps
    DateTime prevArrival = departure;
    // A walking step is left pending so that waiting time can be computed
    // if next step is Transit
    // A Transit step is left pending to decide later if showWalking should
    // be true or false
    DirectionDetailsToken? pending;

    for (var (index, step) in widget.way.steps.indexed) {
      var mode = step.travelMode;
      if (mode is m.Walking) {
        if (step.duration.inMinutes > 0) {
          if (tokens.isEmpty) {
            var (name, address) = _splitName(widget.way.departurePointName);
            tokens.add(StartLocation(
              name,
              address,
              widget.way.departurePointCoords,
              widget.way.departureTime ?? departure,
              null,
              showWalking: true,
            ));
          }
          if (pending != null && pending is TransitStopLocation) {
            tokens.add(TransitStopLocation(
              pending.name,
              pending.address,
              pending.location,
              pending.stop,
              pending.transitInfo,
              pending.arrivalTime,
              pending.color,
              showWalking: true,
            ));
          }
          pending = WalkingInfo(step.duration, step.distance, null);
          prevArrival = prevArrival.add(step.duration);
        }
      } else {
        var transit = mode as m.Transit;
        var showWalking = false;
        if (tokens.isEmpty) {
          var (name, address) = _splitName(widget.way.departurePointName);
          tokens.add(StartLocation(
            name,
            address,
            widget.way.departurePointCoords,
            widget.way.departureTime ?? departure,
            null,
            showWalking: false,
          ));
        }
        if (pending != null && pending is WalkingInfo) {
          Duration waitTime = transit.departureTime.difference(prevArrival);
          tokens.add(WalkingInfo(pending.duration, pending.distance, waitTime));
          showWalking = true;
          pending = null;
        } else if (pending != null && pending is TransitStopLocation) {
          tokens.add(TransitStopLocation(
            pending.name,
            pending.address,
            pending.location,
            pending.stop,
            pending.transitInfo,
            pending.arrivalTime,
            pending.color,
            showWalking: true,
          ));
          tokens.add(Transferring());
          showWalking = true;
          pending = null;
        }

        m.Trip? trip;
        m.Stop? depStop, arrStop;
        int stopsCount;
        bool isExpanded = false;
        var info = transit.info;
        if (info is m.RichInfo) {
          var info = transit.info as m.RichInfo;
          trip = info.trip;
          depStop = info.trip.stopTimes[info.departureStopIndex].stop;
          arrStop = info.trip.stopTimes[info.arrivalStopIndex].stop;
          stopsCount = info.arrivalStopIndex - info.departureStopIndex + 1;
          isExpanded = expandedSteps.contains(index);
        } else {
          stopsCount = transit.numberOfStops;
        }
        var color = trip?.route.color ?? info.getRouteColor();

        tokens.add(TransitStartLocation(
          depStop?.name ?? info.getDepartureStopName(),
          depStop?.street ?? '',
          info.getDepartureStopLoc(),
          transit.departureTime,
          mode.mode,
          depStop,
          info,
          showWalking: showWalking,
        ));
        tokens.add(TransitRouteInfo(
          trip?.route.shortName ?? info.getRouteShortName(),
          trip?.route.longName ?? info.getRouteFullName(),
          info.getRouteHeadSign(),
          transit.departureTime,
          color,
          mode.mode,
          trip,
        ));
        tokens.add(TransitIntermediateLocationHeader(
          stopsCount,
          step.duration,
          isExpanded,
          trip != null,
          color,
          index,
        ));
        if (isExpanded) {
          var info = transit.info as m.RichInfo;
          for (int i = info.departureStopIndex;
              i < info.arrivalStopIndex;
              i++) {
            var stop = info.trip.stopTimes[i].stop;
            tokens
                .add(TransitIntermediateLocationSingle(stop.name, stop, color));
          }
        }
        pending = TransitStopLocation(
          arrStop?.name ?? info.getArrivalStopName(),
          arrStop?.street ?? '',
          info.getArrivalStopLoc(),
          arrStop,
          info,
          transit.arrivalTime,
          color,
          showWalking: false,
        );
        prevArrival = transit.arrivalTime;
      }
    }

    if (pending != null) {
      tokens.add(pending);
    }

    var (name, address) = _splitName(widget.way.arrivalPointName);
    tokens.add(EndLocation(
      name,
      address,
      widget.way.arrivalPointCoords,
      widget.way.arrivalTime ?? departure.add(widget.way.duration),
      null,
      showWalking: pending != null && pending is WalkingInfo,
    ));

    return tokens;
  }

  (String, String) _splitName(String name) {
    int index = name.indexOf(',');
    String a = name.substring(0, index).trim();
    String b = name.substring(index + 1).trim();
    return (a, b);
  }

  Widget _buildWalkingConnector({bool? start}) {
    if (start == true) {
      return Connector.dashedLine(
        indent: 2,
        endIndent: 5,
        gap: 3,
      );
    } else {
      return Connector.dashedLine(
        indent: 5,
        endIndent: 2,
        gap: 3,
      );
    }
  }

  Widget _buildTransitConnector(Color routeColor) {
    if (routeColor == Colors.white) {
      routeColor = Colors.grey[300]!;
    }
    return Connector.solidLine(
      color: routeColor,
      thickness: 20,
      indent: 0,
      endIndent: 0,
    );
  }

  Widget _buildWalkingIndicator() {
    return Icon(
      MingCuteIcons.mgc_walk_line,
      size: 24,
      color: Colors.blueGrey,
    );
  }

  Widget _buildTransitStartLocationIndicator(TransitStartLocation token) {
    var icon = switch (token.mode) {
      m.TransportType.bus => MingCuteIcons.mgc_bus_fill,
      m.TransportType.rail => MingCuteIcons.mgc_train_2_fill,
      m.TransportType.cableway => MingCuteIcons.mgc_aerial_lift_fill,
      m.TransportType.unknown => MingCuteIcons.mgc_bus_2_fill,
    };

    var routeColor = token.transitInfo.getRouteColor();
    if (routeColor == Colors.white) {
      routeColor = Colors.grey[300]!;
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          width: 20,
          height: 24,
          decoration: BoxDecoration(
            color: routeColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
        ),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTransitStopLocationIndicator(TransitStopLocation token) {
    var routeColor = token.transitInfo.getRouteColor();
    if (routeColor == Colors.white) {
      routeColor = Colors.grey[300]!;
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: routeColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildTransitIntermediateLocationIndictor(
      TransitIntermediateLocationSingle token) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          width: 20,
          height: 10,
          color: token.color,
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  void toggleExpandedStep(int stepIndex) {
    if (expandedSteps.contains(stepIndex)) {
      expandedSteps.remove(stepIndex);
    } else {
      expandedSteps.add(stepIndex);
    }
    setState(() {});
  }
}
