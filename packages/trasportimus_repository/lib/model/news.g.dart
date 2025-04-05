// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
      agencyId: json['agencyId'] as String,
      details: json['details'] as String,
      header: json['header'] as String,
      routeIds: (json['routeIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      serviceType: json['serviceType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      url: Uri.parse(json['url'] as String),
      stopId: (json['stopId'] as num?)?.toInt(),
      idFeed: (json['idFeed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'agencyId': instance.agencyId,
      'details': instance.details,
      'header': instance.header,
      'idFeed': instance.idFeed,
      'routeIds': instance.routeIds,
      'serviceType': instance.serviceType,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'stopId': instance.stopId,
      'url': instance.url.toString(),
    };
