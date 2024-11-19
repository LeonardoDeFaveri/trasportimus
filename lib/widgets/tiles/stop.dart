import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus/pages/stop_trips_page.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

class StopTile extends StatelessWidget {
  final m.Stop stop;

  const StopTile(this.stop, {super.key});

  @override
  Widget build(BuildContext context) {
    Color background = switch (stop.areaType) {
      m.AreaType.urban => Colors.cyan[400]!,
      _ => Colors.green[300]!,
    };

    Widget wheelchair = const Text('');
    if (stop.wheelchairBoarding == 1) {
      wheelchair = Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(width: 0.3),
        ),
        child: const Icon(MingCuteIcons.mgc_disabled_line, size: 18),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            ),
            color: background,
          ),
          margin: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                ),
                padding:
                    const EdgeInsets.only(top: 3, right: 5, left: 5, bottom: 3),
                child: Icon(
                  switch (stop.areaType) {
                    m.AreaType.urban => MingCuteIcons.mgc_building_1_line,
                    m.AreaType.extraurban => MingCuteIcons.mgc_tree_line,
                    m.AreaType.unknown => MingCuteIcons.mgc_desk_line,
                  },
                  size: 28,
                ),
              ),
              const SizedBox(
                height: 5,
              )
            ],
          ),
        ),
        wheelchair,
      ],
    );
  }
}

class StopExpanded extends StatelessWidget {
  final m.Stop stop;
  final bool isFavourite;

  const StopExpanded(this.stop, this.isFavourite, {super.key});

  @override
  Widget build(BuildContext context) {
    var prefsBloc = context.read<PrefsBloc>();
    String subtitle = '';
    if (stop.street != '' && stop.town != '') {
      subtitle = '${stop.street}, ${stop.town}';
    } else if (stop.street == '') {
      subtitle = stop.town;
    } else {
      subtitle = stop.street;
    }

    return ListTile(
      leading: StopTile(stop),
      trailing: GestureDetector(
          onTap: () => isFavourite
              ? prefsBloc.add(RemoveStop(stop))
              : prefsBloc.add(AddStop(stop)),
          child: Icon(
            isFavourite
                ? MingCuteIcons.mgc_heart_fill
                : MingCuteIcons.mgc_heart_line,
            color: Colors.redAccent,
          )),
      title: Text(
        stop.name,
        overflow: TextOverflow.clip,
      ),
      subtitle: Text(subtitle),
      horizontalTitleGap: 5,
      isThreeLine: false,
      onTap: () => _goToStopPage(context, stop),
    );
  }
}

void _goToStopPage(BuildContext context, m.Stop stop) {
  TransportBloc transBloc = BlocProvider.of<TransportBloc>(context);
  PrefsBloc prefsBloc = BlocProvider.of<PrefsBloc>(context);
  Navigator.push(context, MaterialPageRoute(builder: (navContext) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: transBloc,
        ),
        BlocProvider.value(
          value: prefsBloc,
        )
      ],
      child: StopTripsPage(stop),
    );
  }));
}
