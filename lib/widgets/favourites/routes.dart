import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/tiles/route.dart';
import 'package:trasportimus_repository/model/model.dart' as model;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavouriteRoutes extends StatefulWidget {
  final List<model.Route> routes;
  late final bool expanded;

  FavouriteRoutes(this.routes, {super.key, bool? expanded}) {
    this.expanded = expanded ?? false;
  }

  @override
  State<StatefulWidget> createState() => FavouriteRoutesState();
}

class FavouriteRoutesState extends State<FavouriteRoutes> {
  late bool expanded;

  @override
  void initState() {
    super.initState();
    expanded = widget.expanded;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    Widget tiles = SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              MingCuteIcons.mgc_angel_line,
              color: theme.colorScheme.primary,
              size: 36,
            ),
            Text(
              AppLocalizations.of(context)!.noFavRoutes,
              style: theme.textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );

    if (widget.routes.isNotEmpty) {
      widget.routes.sort(compareRoutes);
      if (expanded) {
        tiles = ListView.builder(
          itemBuilder: (context, index) =>
              RouteExpanded(widget.routes[index], true),
          itemCount: widget.routes.length,
          shrinkWrap: true,
        );
      } else {
        tiles = Wrap(
          children: widget.routes
              .map((route) => RouteTile(
                    route,
                    isClickable: true,
                  ))
              .toList(),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.all(25.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: Defaults.shadows,
      ),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 50,
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              gradient: Defaults.gradient,
            ),
            padding: const EdgeInsets.only(
              top: 3,
              left: 7,
              right: 5,
              bottom: 3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.favRoutes,
                  textAlign: TextAlign.left,
                  style: theme.textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => setState(() {
                    expanded = !expanded;
                  }),
                  icon: Icon(
                    expanded
                        ? MingCuteIcons.mgc_up_line
                        : MingCuteIcons.mgc_down_line,
                  ),
                )
              ],
            ),
          ),
          tiles,
        ],
      ),
    );
  }
}
