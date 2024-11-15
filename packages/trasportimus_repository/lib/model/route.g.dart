// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
      area: $enumDecode(_$AreaEnumMap, json['area']),
      id: (json['id'] as num).toInt(),
      longName: json['longName'] as String,
      shortName: json['shortName'] as String,
      color: Route._readColor(json['color'] as String),
      routeType: $enumDecode(_$TransportTypeEnumMap, json['routeType']),
      areaType: $enumDecode(_$AreaTypeEnumMap, json['areaType']),
      news: (json['news'] as List<dynamic>)
          .map((e) => News.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
      'id': instance.id,
      'area': _$AreaEnumMap[instance.area]!,
      'color': Route._writeColor(instance.color),
      'longName': instance.longName,
      'shortName': instance.shortName,
      'news': instance.news,
      'routeType': _$TransportTypeEnumMap[instance.routeType]!,
      'areaType': _$AreaTypeEnumMap[instance.areaType]!,
    };

const _$AreaEnumMap = {
  Area.area1: 1,
  Area.area2: 2,
  Area.area3: 3,
  Area.area4: 4,
  Area.area5: 5,
  Area.area6: 6,
  Area.railway: 7,
  Area.cableway: 8,
  Area.pergine: 21,
  Area.altoGarda: 22,
  Area.trento: 23,
  Area.rovereto: 24,
  Area.unknown: 'unknown',
};

const _$TransportTypeEnumMap = {
  TransportType.unknown: 'unknown',
  TransportType.rail: 2,
  TransportType.bus: 3,
  TransportType.cableway: 5,
};

const _$AreaTypeEnumMap = {
  AreaType.urban: 'U',
  AreaType.extraurban: 'E',
  AreaType.unknown: 'unknown',
};
