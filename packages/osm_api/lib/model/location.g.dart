// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      id: (json['osm_id'] as num).toInt(),
      lat: double.parse(json['lat'] ?? '0.0'),
      lon: double.parse(json['lon'] ?? '0.0'),
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'osm_id': instance.id,
      'lat': instance.lat,
      'lon': instance.lon,
      'name': instance.name,
      'display_name': instance.displayName,
      'address': instance.address,
    };
