import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart' as pb;
import 'package:trasportimus/blocs/transport/transport_bloc.dart' as tb;
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/map/direction_details.dart';
import 'package:trasportimus/widgets/map/direction_tile.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

enum Status { all, single, pending, error, noData }

class DirectionInfoViewer extends StatefulWidget {
  const DirectionInfoViewer({super.key});

  @override
  State<StatefulWidget> createState() => DirectionInfoViewerState();
}

class DirectionInfoViewerState extends State<DirectionInfoViewer> {
  late final tb.TransportBloc transBloc;
  late final pb.PrefsBloc prefsBloc;
  late AppLocalizations loc;
  late m.DirectionInfo? info;
  late DateTime refDateTime;
  late Status status;
  late tb.TransportEvent? event;
  late bool ignoreNextData;
  late m.Way? selected;

  @override
  void initState() {
    super.initState();
    transBloc = context.read<tb.TransportBloc>();
    prefsBloc = context.read<pb.PrefsBloc>();
    status = Status.noData;
    ignoreNextData = false;
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<pb.PrefsBloc, pb.PrefsState>(
          bloc: prefsBloc,
          listener: (context, state) {},
        ),
        BlocListener<tb.TransportBloc, tb.TransportState>(
          bloc: transBloc,
          listener: (context, state) {
            if (state is tb.TransportStillFetching &&
                state.event is tb.FetchDirectionInfo) {
              setState(() {
                status = Status.pending;
              });
            } else if (state is tb.TransportFetchedDirectionInfo) {
              if (ignoreNextData) {
                setState(() {
                  ignoreNextData = false;
                });
              } else {
                setState(() {
                  info = state.directionInfo;
                  refDateTime = state.refDateTime;
                  status = Status.all;
                });
              }
            } else if (state is tb.TransportFetchFailed &&
                state.event is tb.FetchDirectionInfo) {
              setState(() {
                status = Status.error;
                event = state.event;
              });
            }
          },
        ),
      ],
      child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (status == Status.single) {
              setState(() {
                status = Status.all;
              });
            } else {
              setState(() {
                ignoreNextData = status == Status.pending;
                status = Status.noData;
              });
            }
          },
          child: _buildDraggableScrollSheet(context)),
    );
  }

  Widget _buildDraggableScrollSheet(BuildContext context) {
    ThemeData theme = Theme.of(context);

    double appBarHeight = 3;
    List<Widget> appBarChildren = [
      Center(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          height: 4,
          width: 40,
          margin: const EdgeInsets.only(top: 10, bottom: 5),
        ),
      ),
    ];

    if (status == Status.single) {
      appBarChildren.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 6,
            ),
            TransportIndicator(selected!),
            IconButton(
              onPressed: () => setState(() {
                status = Status.all;
              }),
              icon: Icon(MingCuteIcons.mgc_close_circle_line),
            )
          ],
        ),
      );
      appBarHeight = 48;
    }

    double minChildSize = 0.03;
    double maxChildSize, initialChildSize;
    Widget child;
    switch (status) {
      case Status.noData:
        maxChildSize = 0.15;
        initialChildSize = 0.03;
        child = _buildNoDataView(context, theme);
        break;
      case Status.pending:
        maxChildSize = 0.15;
        initialChildSize = 0.15;
        child = _buildPendingView(context, theme);
      case Status.error:
        maxChildSize = 0.2;
        initialChildSize = 0.2;
        child = _buildErrorView(context, theme);
      case Status.all:
        maxChildSize = 0.6;
        initialChildSize = 0.6;
        child = _buildAllView(context, theme);
      case Status.single:
        maxChildSize = 0.8;
        initialChildSize = 0.8;
        child = _buildSingleView(context, theme);
    }

    return DraggableScrollableSheet(
      maxChildSize: maxChildSize,
      minChildSize: minChildSize,
      initialChildSize: initialChildSize,
      builder: (BuildContext context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.canvasColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: Defaults.shadows,
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                flexibleSpace: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: appBarChildren,
                ),
                toolbarHeight: appBarHeight,
                pinned: true,
              ),
              child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoDataView(BuildContext context, ThemeData theme) {
    return SliverPadding(
      padding: EdgeInsets.all(8.0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              MingCuteIcons.mgc_route_line,
              size: 32.0,
              color: theme.colorScheme.primary,
            ),
            Text(loc.noDirectionInfo, style: theme.textTheme.bodyLarge)
          ],
        ),
      ),
    );
  }

  Widget _buildPendingView(BuildContext context, ThemeData theme) {
    return SliverPadding(
      padding: EdgeInsets.all(12.0),
      sliver: SliverToBoxAdapter(
          child: Center(
        child: Defaults.loader,
      )),
    );
  }

  Widget _buildErrorView(BuildContext context, ThemeData theme) {
    return SliverPadding(
      padding: EdgeInsets.all(8.0),
      sliver: SliverToBoxAdapter(
        child: Defaults.noDataWidget(context, () => transBloc.add(event!)),
      ),
    );
  }

  Widget _buildAllView(BuildContext context, ThemeData theme) {
    List<m.Way> ways = info!.ways;
    return SliverList.builder(
      itemCount: ways.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => setState(() {
            selected = ways[index];
            status = Status.single;
          }),
          child: DirectionTile(ways[index], refDateTime),
        );
      },
    );
  }

  Widget _buildSingleView(BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(child: DirectionDetails(selected!));
  }
}
