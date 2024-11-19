import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trasportimus/blocs/prefs/prefs_bloc.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus/widgets/favourites/routes.dart';
import 'package:trasportimus/widgets/favourites/stops.dart';
import 'package:trasportimus_repository/model/model.dart' as model;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

const String title = 'Bon Voyage!';

class _MainPageState extends State<MainPage> {
  late HashSet<model.Route> routes;
  late HashSet<model.Stop> stops;
  late final PrefsBloc bloc;

  @override
  void initState() {
    super.initState();
    routes = HashSet();
    stops = HashSet();
    bloc = context.read<PrefsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Defaults.gradient,
            boxShadow: Defaults.shadows,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      body: BlocBuilder(
        bloc: bloc..add(FetchAll()),
        builder: (context, state) {
          if (state is PrefsLoadedAll) {
            routes = state.routes;
            stops = state.stops;
          } else if (state is PrefsRoutesUpdated) {
            routes = state.routes;
          } else if (state is PrefsStopsUpdated) {
            stops = state.stops;
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FavouriteRoutes(routes.toList()..sort(compareRoutes)),
                FavouriteStops(stops.toList()..sort(compareStops)),
              ],
            ),
          );
        },
      ),
    );
  }
}
