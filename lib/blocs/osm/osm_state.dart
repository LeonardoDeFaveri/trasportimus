part of 'osm_bloc.dart';

sealed class OsmState extends Equatable {
  const OsmState();

  @override
  List<Object> get props => [];
}

final class OsmInitial extends OsmState {}

final class OsmStillFetching extends OsmState {}

final class OsmData extends OsmState {
  final String key;
  final List<Location> locations;

  const OsmData(this.key, this.locations);

  @override
  List<Object> get props => [key, locations];
}

final class OsmFetchFailed extends OsmState {
  final String key;
  final int errorCode;

  const OsmFetchFailed(this.key, this.errorCode);

  @override
  List<Object> get props => [key, errorCode];
}
