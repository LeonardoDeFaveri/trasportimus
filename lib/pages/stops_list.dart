import 'dart:collection';

import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart' as pb;
import 'package:trasportimus/blocs/transport/transport_bloc.dart' as tb;
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/stop_tile.dart';
import 'package:trasportimus_repository/model/model.dart';

class StopsList extends StatefulWidget {
  const StopsList({super.key});

  @override
  State<StatefulWidget> createState() => StopsListState();
}

class StopsListState extends State<StopsList> {
  late final tb.TransportBloc transportBloc;
  late final pb.PrefsBloc prefsBloc;
  late bool isErroroneous;
  late bool isSearchActive;
  late String filterText;
  late List<Stop>? allStops;
  late List<Stop> foundStops;
  late HashSet<Stop> favStops;
  late AreaType selectedArea;
  late AppLocalizations loc;

  @override
  void initState() {
    super.initState();
    transportBloc = context.read<tb.TransportBloc>()..add(tb.FetchStops());
    prefsBloc = context.read<pb.PrefsBloc>()..add(pb.FetchStops());
    isErroroneous = false;
    isSearchActive = false;
    allStops = null;
    foundStops = [];
    favStops = HashSet<Stop>();
    selectedArea = AreaType.unknown;
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;

    var baseTitle = Text(
      loc.stops,
      style: Theme.of(context).textTheme.headlineLarge,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    var backButton = IconButton(
      onPressed: () => setState(() {
        isSearchActive = false;
        if (allStops != null) {
          foundStops = allStops!;
        }
      }),
      icon: const Icon(MingCuteIcons.mgc_close_line),
    );
    var searchBar = SearchBar(
      constraints: BoxConstraints(maxHeight: 50),
      autoFocus: true,
      trailing: [backButton],
      hintText: loc.stopSearchHint,
      onChanged: (value) => setState(() {
        if (allStops == null) return;
        foundStops = allStops!
            .where(
              (stop) => stop.name.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();
      }),
    );
    var actions = [
      IconButton(
        onPressed: () => setState(() {
          isSearchActive = true;
        }),
        icon: const Icon(
          MingCuteIcons.mgc_search_3_line,
        ),
      ),
      filter(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: isSearchActive ? searchBar : baseTitle,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Defaults.gradient,
            boxShadow: Defaults.shadows,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        actions: isSearchActive ? null : actions,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<tb.TransportBloc, tb.TransportState>(
            bloc: transportBloc,
            listener: (context, state) {
              if (state is tb.TransportFetchedStops) {
                setState(() {
                  allStops = state.stops;
                  allStops!.sort(compareStops);
                  foundStops = allStops!;
                });
              } else if (state is tb.TransportFetchFailed) {
                Defaults.showErrorSnackBar(context, state);
              }
            },
          ),
          BlocListener<pb.PrefsBloc, pb.PrefsState>(
            bloc: prefsBloc,
            listener: (context, state) {
              if (state is pb.PrefsLoadedStops) {
                setState(() {
                  favStops = state.stops;
                });
              } else if (state is pb.PrefsStopsUpdated) {
                setState(() {
                  favStops = state.stops;
                });
              }
            },
          )
        ],
        child: BlocBuilder<tb.TransportBloc, tb.TransportState>(
          bloc: transportBloc,
          builder: (context, state) {
            if (state is tb.TransportStillFetching) {
              return Defaults.loader;
            }
            if (state is tb.TransportFetchedStops || foundStops.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 5),
                child: ListView.builder(
                  itemBuilder: (context, index) => StopExpanded(
                      foundStops[index], favStops.contains(foundStops[index])),
                  itemCount: foundStops.length,
                ),
              );
            }

            return Defaults.noDataWidget(
                context, () => transportBloc.add(tb.FetchStops()));
          },
        ),
      ),
    );
  }

  Widget filter(BuildContext context) {
    Map<String, AreaType> values = {
      loc.all: AreaType.unknown,
      loc.urban: AreaType.urban,
      loc.extraurban: AreaType.extraurban,
    };

    return PromptedChoice<AreaType>.single(
        promptDelegate: Defaults.delegatePopupDialog(),
        itemCount: values.length,
        itemBuilder: (state, index) {
          MapEntry<String, AreaType> val = values.entries.elementAt(index);
          return ChoiceChip(
            label: Text(
              val.key,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            selected: val.value == selectedArea,
            onSelected: (value) => state.select(val.value),
            selectedColor:
                Theme.of(context).colorScheme.secondary.withAlpha(200),
          );
        },
        listBuilder: ChoiceList.createWrapped(
          padding: EdgeInsets.all(10),
          spacing: 10,
        ),
        anchorBuilder: (state, openModal) {
          return IconButton(
              onPressed: () => openModal(),
              icon: Icon(
                MingCuteIcons.mgc_filter_line,
                size: Theme.of(context).iconTheme.size,
              ));
        },
        modalHeaderBuilder: ChoiceModal.createHeader(
          automaticallyImplyLeading: false,
          title: Text(
            loc.filterArea,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          elevation: 5,
        ),
        onChanged: (value) {
          if (value != null && allStops != null) {
            setState(() {
              selectedArea = value;
              if (value == AreaType.unknown) {
                foundStops = allStops!;
              } else {
                foundStops =
                    allStops!.where((s) => s.areaType == selectedArea).toList();
              }
            });
          }
        });
  }
}
