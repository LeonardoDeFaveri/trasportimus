import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:format/format.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trasportimus_repository/model/model.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

part 'route.g.dart';

@JsonSerializable()
class Route implements Equatable {
  late final int id;
  late final Area area;
  @JsonKey(fromJson: Route._readColor, toJson: Route._writeColor)
  late final Color color;
  late final String longName;
  late final String shortName;
  late final List<News> news;
  late final TransportType routeType;
  late final AreaType areaType;

  Route(
      {required this.area,
      required this.id,
      required this.longName,
      required this.shortName,
      required this.color,
      required this.routeType,
      required this.areaType,
      required this.news});

  Route.fromApiRoute(m.Route route) {
    id = route.id;
    area = AC.fromId(route.areaId);
    color = route.color;
    longName = route.longName;
    shortName = route.shortName;
    news = route.news.map((news) => News.fromApiNews(news)).toList();
    routeType = TTC.fromId(route.routeType.id);
    areaType = ATC.fromId(route.areaType.id);
  }

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
  Map<String, dynamic> toJson() => _$RouteToJson(this);

  @override
  List<Object?> get props => [id, area, color, longName, shortName, news];

  @override
  bool? get stringify => true;

  static Color _readColor(String value) {
    return Color(int.parse(value, radix: 16)).withAlpha(255);
  }

  static String _writeColor(Color value) {
    return format("{:0>2}{:0>2}{:0>2}", value.red.toRadixString(16),
        value.green.toRadixString(16), value.blue.toRadixString(16));
  }
}
