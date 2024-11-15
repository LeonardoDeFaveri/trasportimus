import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus/pages/route_trips_page.dart';
import 'package:trasportimus_repository/model/model.dart' as model;

class RouteTile extends StatelessWidget {
  final model.Route route;
  final DateTime? refTime;
  final bool isClickable;
  final EdgeInsets margin;

  const RouteTile(this.route,
      {this.refTime, bool? isClickable, EdgeInsets? margin, super.key})
      : isClickable = isClickable ?? false,
        margin = margin ?? const EdgeInsets.all(8);

  @override
  Widget build(BuildContext context) {
    var tile = Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        color: route.color,
      ),
      margin: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
            ),
            padding:
                const EdgeInsets.only(top: 3, right: 5, left: 5, bottom: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  switch (route.routeType) {
                    model.TransportType.bus => MingCuteIcons.mgc_bus_line,
                    model.TransportType.rail => MingCuteIcons.mgc_train_2_line,
                    model.TransportType.cableway =>
                      MingCuteIcons.mgc_aerial_lift_fill,
                    model.TransportType.unknown => MingCuteIcons.mgc_bus_2_line,
                  },
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  route.shortName,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          )
        ],
      ),
    );
    if (isClickable) {
      return GestureDetector(
        onTap: () => _goToRoutePage(context, route, refTime),
        child: tile,
      );
    } else {
      return tile;
    }
  }
}

class RouteExpanded extends StatelessWidget {
  final model.Route route;
  final bool isFavourite;
  final DateTime? refTime;

  const RouteExpanded(this.route, this.isFavourite, {this.refTime, super.key});

  @override
  Widget build(BuildContext context) {
    var prefsBloc = context.read<PrefsBloc>();

    return ListTile(
      leading: RouteTile(route),
      trailing: GestureDetector(
        onTap: () => isFavourite
            ? prefsBloc.add(RemoveRoute(route))
            : prefsBloc.add(AddRoute(route)),
        child: Icon(
          isFavourite
              ? MingCuteIcons.mgc_heart_fill
              : MingCuteIcons.mgc_heart_line,
          color: Colors.redAccent,
        ),
      ),
      title: Text(
        route.longName,
        overflow: TextOverflow.clip,
      ),
      horizontalTitleGap: 4,
      onTap: () => _goToRoutePage(context, route, refTime),
    );
  }
}

class RouteSmall extends StatelessWidget {
  final model.Route route;

  const RouteSmall(this.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        color: route.color,
      ),
      margin: EdgeInsets.all(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              route.shortName,
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontSize: 11),
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

void _goToRoutePage(BuildContext context, model.Route route, DateTime? refTime) {
  TransportBloc transBloc = BlocProvider.of<TransportBloc>(context);
  PrefsBloc prefsBloc = BlocProvider.of<PrefsBloc>(context);
  Navigator.push(context, MaterialPageRoute(builder: (navContext) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransportBloc.reuse(repo: transBloc.repo),
        ),
        BlocProvider.value(
          value: prefsBloc,
        )
      ],
      child: RouteTripsPage(route, refTime: refTime),
    );
  }));
}
