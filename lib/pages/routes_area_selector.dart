import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus/pages/routes_list_per_area.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus_repository/model/utils.dart' as m;

enum Area { railway, extraurban, urban }

class AreaChoosingPage extends StatefulWidget {
  const AreaChoosingPage({super.key});

  @override
  State<StatefulWidget> createState() => AreaChoosingPageState();
}

class AreaChoosingPageState extends State<AreaChoosingPage> {
  late Area selectedArea;
  late AppLocalizations loc;
  late TabController ctrl;

  @override
  void initState() {
    super.initState();
    selectedArea = Area.urban;
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;
    ctrl = DefaultTabController.of(context);

    var map = switch (selectedArea) {
      Area.urban => _buildUrbanAreas(),
      Area.extraurban => _buildExtraurbanAreas(),
      Area.railway => _buildRailwayAreas(),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => ctrl.animateTo(0),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.routes,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          flexibleSpace: Container(
            decoration: Defaults.decoration,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                loc.pickArea,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              flex: 4,
              child: map,
            ),
            const Expanded(
              flex: 1,
              child: Text(''),
            ),
          ],
        ),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  loc.railwaysAndCableways,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: 'railwayBtn',
                  onPressed: () => _setArea(Area.railway),
                  shape: const CircleBorder(),
                  backgroundColor: Colors.red[300]!,
                  child: const Icon(
                    MingCuteIcons.mgc_train_line,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  loc.extraurban,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: 'extraurbanBtn',
                  onPressed: () => _setArea(Area.extraurban),
                  shape: const CircleBorder(),
                  backgroundColor: Colors.green[300]!,
                  child: const Icon(
                    MingCuteIcons.mgc_tree_line,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  loc.urban,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: 'urbanBtn',
                  onPressed: () => _setArea(Area.urban),
                  shape: const CircleBorder(),
                  backgroundColor: Colors.cyan[400]!,
                  child: const Icon(
                    MingCuteIcons.mgc_building_1_line,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setArea(Area area) {
    setState(() {
      selectedArea = area;
    });
  }

  void _chooseArea(m.Area area) {
    TransportBloc bloc = BlocProvider.of<TransportBloc>(context);
    bloc.add(FetchRoutes(area));
    Navigator.push(context, MaterialPageRoute(builder: (contextRouteLsit) {
      return BlocProvider.value(
        value: bloc,
        child: RoutesList(area),
      );
    }));
  }

  Widget _buildUrbanAreas() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Image.asset('assets/trentino_map_blue.webp'),
        _buildPin('Trento', () => _chooseArea(m.Area.trento), -20, 0),
        _buildPin('Pergine', () => _chooseArea(m.Area.pergine), 135, -20),
        _buildPin('Rovereto', () => _chooseArea(m.Area.rovereto), -30, 120),
        _buildPin('Alto Garda', () => _chooseArea(m.Area.altoGarda), -200, 110)
      ],
    );
  }

  Widget _buildExtraurbanAreas() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Image.asset('assets/trentino_map_green.webp'),
        _buildPin(loc.area(1), () => _chooseArea(m.Area.area1), 165, -85),
        _buildPin(loc.area(2), () => _chooseArea(m.Area.area2), -200, 0),
        _buildPin(loc.area(3), () => _chooseArea(m.Area.area3), -50, 120),
        _buildPin(loc.area(4), () => _chooseArea(m.Area.area4), 150, 12),
        _buildPin(loc.area(5), () => _chooseArea(m.Area.area5), 265, -40),
        _buildPin(loc.area(6), () => _chooseArea(m.Area.area6), -80, -150),
      ],
    );
  }

  Widget _buildRailwayAreas() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Image.asset('assets/trentino_map_red.webp'),
        _buildPin(loc.railways, () => _chooseArea(m.Area.railway), -150, 0),
        _buildPin(loc.cableways, () => _chooseArea(m.Area.cableway), 100, 0),
      ],
    );
  }

  Widget _buildPin(String text, Function()? onTap, double dx, double dy) {
    return Container(
      margin: EdgeInsets.only(
        top: dy > 0 ? dy : 0,
        bottom: dy < 0 ? -dy : 0,
        left: dx > 0 ? dx : 0,
        right: dx < 0 ? -dx : 0,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                bottom: 35,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Icon(
                    MingCuteIcons.mgc_location_line,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
