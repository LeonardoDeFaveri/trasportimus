import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/stop_tile.dart';
import 'package:trasportimus_repository/model/model.dart' as model;

class FavouriteStops extends StatefulWidget {
  final List<model.Stop> stops;

  const FavouriteStops(this.stops, {super.key});

  @override
  State<StatefulWidget> createState() => FavouriteStopsState();
}

const String emptyMsg = 'Prova ad aggiungere alcune fermate ai preferiti';

class FavouriteStopsState extends State<FavouriteStops> {
  @override
  void initState() {
    super.initState();
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
              AppLocalizations.of(context)!.noFavStops,
              style: theme.textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );

    if (widget.stops.isNotEmpty) {
      tiles = Container(
        constraints: BoxConstraints.loose(Size.fromHeight(300)),
        child: ListView.builder(
          itemBuilder: (context, index) =>
              StopExpanded(widget.stops[index], true),
          itemCount: widget.stops.length,
          shrinkWrap: true,
        ),
      );
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
            child: Text(
              AppLocalizations.of(context)!.favStops,
              textAlign: TextAlign.left,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          tiles,
        ],
      ),
    );
  }
}
