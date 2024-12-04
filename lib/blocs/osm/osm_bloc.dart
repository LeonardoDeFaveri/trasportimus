import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:osm_api/model/location.dart';
import 'package:osm_api/osm_api.dart';

part 'osm_event.dart';
part 'osm_state.dart';

class OsmBloc extends Bloc<OsmEvent, OsmState> {
  final OsmApiClient client;

  OsmBloc()
      : client = OsmApiClient(),
        super(OsmInitial()) {
    on<Search>((event, emit) async {
      emit(OsmStillFetching());
      List<Location>? locations;
      do {
        var result = await client.getLocations(event.key);
        switch (result.runtimeType) {
          case const (ApiOk<List<Location>>):
            locations = (result as ApiOk<List<Location>>).result;
            break;
          case const (ApiErr<List<Location>>):
            var err = result as ApiErr<List<Location>>;
            emit(OsmFetchFailed(event.key, err.errorCode));
            return;
        }
      } while (locations == null);
      emit(OsmData(event.key, locations));
    });
  }
}
