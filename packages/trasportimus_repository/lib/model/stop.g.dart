// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stop _$StopFromJson(Map<String, dynamic> json) => Stop(
      routes: (json['routes'] as List<dynamic>)
          .map((e) => Route.fromJson(e as Map<String, dynamic>))
          .toList(),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      id: (json['id'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      level: (json['level'] as num).toInt(),
      street: json['street'] as String,
      town: json['town'] as String,
      areaType: $enumDecode(_$AreaTypeEnumMap, json['areaType']),
      wheelchairBoarding: (json['wheelchairBoarding'] as num).toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StopToJson(Stop instance) => <String, dynamic>{
      'distance': instance.distance,
      'routes': instance.routes,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'level': instance.level,
      'street': instance.street,
      'town': instance.town,
      'areaType': _$AreaTypeEnumMap[instance.areaType]!,
      'wheelchairBoarding': instance.wheelchairBoarding,
    };

const _$AreaTypeEnumMap = {
  AreaType.urban: 'U',
  AreaType.extraurban: 'E',
  AreaType.unknown: 'unknown',
};
