import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address extends Equatable {
  @JsonKey(name: 'road')
  final String road;
  @JsonKey(name: 'village')
  final String village;
  @JsonKey(name: 'county')
  final String county;
  @JsonKey(name: 'ISO3166-2-lvl6', fromJson: Address._readCountyCode, toJson: Address._writeCountyCode)
  final String countyCode;
  @JsonKey(name: 'state')
  final String state;
  @JsonKey(name: 'country')
  final String country;
  @JsonKey(name: 'county_code')
  final String countryCode;

  static String _readCountyCode(String value) {
    if (value.length >= 5) {
      return value.substring(3);
    }
    return '';
  }

  static String _writeCountyCode(String value) {
    if (value.isNotEmpty) {
      return 'IT-$value';
    }
    return value;
  }

  const Address({
    required this.road,
    required this.village,
    required this.county,
    required this.countyCode,
    required this.state,
    required this.country,
    required this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  List<Object?> get props => [];
}