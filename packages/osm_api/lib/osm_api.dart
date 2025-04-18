import 'package:http/http.dart' as http;
import 'dart:convert' show json;

import 'package:osm_api/model/location.dart';

const String baseUrl = 'nominatim.openstreetmap.org';

class OsmApiClient {
  final http.Client client;
  final Map<String, String> queryHeaders;
  final Duration timeout = const Duration(seconds: 30);

  OsmApiClient()
      : client = http.Client(),
        queryHeaders = {
          'format': 'json',
          'addressdetails': '1',
          'accept-language': 'it',
          'countrycodes': 'it',
          'limit': '10',
          'layer': 'address,poi',
          'q': ''
        };

  /// Returns a list of locations searching them by `key`.
  Future<ApiResult<List<Location>>> getLocations(String key) async {
    queryHeaders['q'] = key;
    var uri = Uri.https(baseUrl, '/search', queryHeaders);

    var response = await client
        .get(uri)
        .catchError((err) => http.Response(err.toString(), 400));
    if (response.statusCode == 200) {
      List<Location> locations = List.empty(growable: true);
      var locationJson = json.decode(response.body) as List<dynamic>;
      for (Map<String, dynamic> location in locationJson) {
        // Filter out non-places. Should look for a better way
        var locationClass = location['class'];
        if (locationClass == 'place') {
          // Filter out places outside of valid areas
          var addr = location['address'] ?? {};
          var state = addr['state'] ?? '';
          if (state == 'Veneto' ||
              state == 'Lombardia' ||
              state == 'Trentino-Alto Adige' ||
              state == '') {
            locations.add(Location.fromJson(location));
          }
        } else if (locationClass == 'boundary') {
          var addrType = location['addresstype'];
          if (addrType == 'city' ||
              addrType == 'village' ||
              addrType == 'town') {
            locations.add(Location.fromJson(location));
          }
        }
      }
      return ApiOk(locations);
    }
    return ApiErr(response.statusCode, response.body);
  }
}

sealed class ApiResult<T> {}

final class ApiOk<T> extends ApiResult<T> {
  final T result;

  ApiOk(this.result);
}

final class ApiErr<T> extends ApiResult<T> {
  final int errorCode;
  final String errorMessage;
  late final bool mayRetry;
  late final int _errorClass;
  late final String explanation;

  ApiErr(this.errorCode, this.errorMessage) {
    _errorClass = errorCode ~/ 100;
    switch (_errorClass) {
      case 1 || 3:
        mayRetry = true;
        explanation = 'Info: try sending the request again';
        break;
      case 4:
        mayRetry = false;
        explanation = 'App error: wrong request';
        break;
      case 5:
        mayRetry = false;
        explanation =
            'Service error: the service was unable to serve the request';
    }
  }
}
