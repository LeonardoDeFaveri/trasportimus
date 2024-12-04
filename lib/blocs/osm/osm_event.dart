part of 'osm_bloc.dart';

sealed class OsmEvent extends Equatable {
  const OsmEvent();

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => true;
}

class Search extends OsmEvent {
  final String key;

  const Search(this.key);

  @override
  List<Object> get props => [key];
}
