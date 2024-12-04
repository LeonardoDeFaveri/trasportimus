import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address extends Equatable {
  @JsonKey(name: 'road')
  final String? road;
  @JsonKey(name: 'municipality')
  final String? municipality;
  @JsonKey(name: 'village')
  final String? village;
  @JsonKey(name: 'county')
  final String? county;
  @JsonKey(
      name: 'ISO3166-2-lvl6',
      fromJson: Address._readCountyCode,
      toJson: Address._writeCountyCode)
  final String? countyCode;
  @JsonKey(name: 'state')
  final String? state;
  @JsonKey(name: 'country')
  final String? country;
  @JsonKey(name: 'county_code')
  final String? countryCode;

  static String? _readCountyCode(String? value) {
    if (value == null) {
      return null;
    }

    if (value.length >= 5) {
      return value.substring(3);
    }
    return '';
  }

  static String? _writeCountyCode(String? value) {
    if (value == null) {
      return null;
    }

    if (value.isNotEmpty) {
      return 'IT-$value';
    }
    return value;
  }

  const Address({
    this.road,
    this.municipality,
    this.village,
    this.county,
    this.countyCode,
    this.state,
    this.country,
    this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  List<Object?> get props => [];
}
