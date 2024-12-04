import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart' as pf;
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/tiles/route.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

class RoutesList extends StatefulWidget {
  final m.Area area;

  const RoutesList(this.area, {super.key});

  @override
  State<StatefulWidget> createState() => RoutesListState();
}

class RoutesListState extends State<RoutesList> {
  late final m.Area area;
  late String title;
  late bool shouldBuild;
  late final TransportBloc bloc;
  late AppLocalizations loc;

  @override
  void initState() {
    super.initState();
    area = widget.area;
    shouldBuild = true;
    bloc = context.read<TransportBloc>();
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;
    title = switch (area) {
      m.Area.cableway => loc.cableways,
      m.Area.railway => loc.railways,
      m.Area.trento => loc.urbanRoutes('Trento'),
      m.Area.altoGarda => loc.urbanRoutes('Alto Gardo'),
      m.Area.pergine => loc.urbanRoutes('Pergine'),
      m.Area.rovereto => loc.urbanRoutes('Rovereto'),
      _ => loc.extraurbanRoutes(area.id)
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(MingCuteIcons.mgc_arrow_left_line),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        flexibleSpace: Container(
            decoration: BoxDecoration(
          gradient: Defaults.gradient,
          boxShadow: Defaults.shadows,
          borderRadius: BorderRadius.circular(10),
        )),
      ),
      body: BlocConsumer<TransportBloc, TransportState>(
        bloc: bloc,
        listener: (context2, state) {
          if (state is TransportFetchFailed) {
            Defaults.showTrasportimusErrorSnackBar(context, state);
          }
        },
        buildWhen: (previous, current) => shouldBuild,
        builder: (context2, state) {
          if (state is TransportStillFetching) {
            return Defaults.loader;
          }
          if (state is TransportFetchedRoutes) {
            state.routes.sort(compareRoutes);
            var prefsBloc = context.read<pf.PrefsBloc>();
            prefsBloc.add(pf.FetchRoutes());

            return BlocBuilder<pf.PrefsBloc, pf.PrefsState>(
              builder: (context3, prefs) {
                HashSet favs = HashSet();
                if (prefs is pf.PrefsLoadedRoutes) {
                  favs = prefs.routes;
                } else if (prefs is pf.PrefsRoutesUpdated) {
                  favs = prefs.routes;
                }

                shouldBuild = false;
                return Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: ListView.builder(
                    itemBuilder: (context, index) => RouteExpanded(
                        state.routes[index],
                        favs.contains(state.routes[index])),
                    itemCount: state.routes.length,
                  ),
                );
              },
            );
          }

          return Defaults.noDataWidget(
              context, () => bloc.add(FetchRoutes(area)));
        },
      ),
    );
  }
}
