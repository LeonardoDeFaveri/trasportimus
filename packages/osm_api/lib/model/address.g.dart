// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      road: json['road'] as String?,
      municipality: json['municipality'] as String?,
      village: json['village'] as String?,
      county: json['county'] as String?,
      countyCode: Address._readCountyCode(json['ISO3166-2-lvl6'] as String?),
      state: json['state'] as String?,
      country: json['country'] as String?,
      countryCode: json['county_code'] as String?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'road': instance.road,
      'municipality': instance.municipality,
      'village': instance.village,
      'county': instance.county,
      'ISO3166-2-lvl6': Address._writeCountyCode(instance.countyCode),
      'state': instance.state,
      'country': instance.country,
      'county_code': instance.countryCode,
    };
