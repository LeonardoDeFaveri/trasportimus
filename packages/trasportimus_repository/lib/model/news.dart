import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trentino_trasporti_api/model/model.dart' as m;

part 'news.g.dart';

@JsonSerializable()
class News implements Equatable {
  late final String agencyId;
  late final String details;
  late final String header;
  late final int? idFeed;
  late final List<int> routeIds;
  late final String serviceType;
  late final DateTime startDate;
  late final DateTime endDate;
  late final int? stopId;
  late final Uri url;

  News(
      {required this.agencyId,
      required this.details,
      required this.header,
      required this.routeIds,
      required this.serviceType,
      required this.startDate,
      required this.endDate,
      required this.url,
      this.stopId,
      this.idFeed});

  News.fromApiNews(m.News news) {
    agencyId = news.agencyId;
    details = news.details;
    header = news.header;
    idFeed = news.idFeed;
    routeIds = news.routeIds;
    serviceType = news.serviceType;
    startDate = news.startDate;
    endDate = news.endDate;
    stopId = news.stopId;
    url = news.url;
  }

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);
  Map<String, dynamic> toJson() => _$NewsToJson(this);

  @override
  List<Object?> get props => [
        agencyId,
        details,
        header,
        idFeed,
        routeIds,
        serviceType,
        startDate,
        endDate,
        stopId,
        url
      ];

  @override
  bool? get stringify => true;
}
