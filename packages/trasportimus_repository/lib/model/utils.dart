import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

/// Area in which a route operates.
enum Area {
  @JsonValue(1)
  area1,
  @JsonValue(2)
  area2,
  @JsonValue(3)
  area3,
  @JsonValue(4)
  area4,
  @JsonValue(5)
  area5,
  @JsonValue(6)
  area6,

  /// Any railway
  @JsonValue(7)
  railway,

  /// Trento-Sardagna cableway
  @JsonValue(8)
  cableway,

  /// Pergine urban area
  @JsonValue(21)
  pergine,

  /// Alto Garda urban area
  @JsonValue(22)
  altoGarda,

  /// Trento urban area
  @JsonValue(23)
  trento,

  /// Rovereto urban area
  @JsonValue(24)
  rovereto,
  unknown,
}

extension AC on Area {
  static Area fromId(int id) {
    return switch (id) {
      1 => Area.area1,
      2 => Area.area2,
      3 => Area.area3,
      4 => Area.area4,
      5 => Area.area5,
      6 => Area.area6,
      7 => Area.railway,
      8 => Area.cableway,
      21 => Area.pergine,
      22 => Area.altoGarda,
      23 => Area.trento,
      24 => Area.rovereto,
      _ => Area.unknown,
    };
  }

  int get id {
    return switch (this) {
      Area.area1 => 1,
      Area.area2 => 2,
      Area.area3 => 3,
      Area.area4 => 4,
      Area.area5 => 5,
      Area.area6 => 6,
      Area.railway => 7,
      Area.cableway => 8,
      Area.pergine => 21,
      Area.altoGarda => 22,
      Area.trento => 23,
      Area.rovereto => 24,
      Area.unknown => 0,
    };
  }
}

enum AreaType {
  @JsonValue('U')
  urban,
  @JsonValue('E')
  extraurban,
  unknown
}

extension ATC on AreaType {
  static AreaType fromId(String id) {
    return switch (id) {
      'E' => AreaType.extraurban,
      'U' => AreaType.urban,
      _ => AreaType.unknown
    };
  }

  String get id {
    return switch (this) {
      AreaType.extraurban => 'E',
      AreaType.urban => 'U',
      AreaType.unknown => '-'
    };
  }
}

enum Direction { both, forward, backward }

extension DC on Direction {
  static Direction fromId(int id) {
    return switch (id) {
      0 => Direction.forward,
      1 => Direction.backward,
      _ => Direction.both
    };
  }

  int get id {
    return switch (this) {
      Direction.forward => 0,
      Direction.backward => 1,
      Direction.both => 2
    };
  }
}

enum TransportType {
  unknown,
  @JsonValue(2)
  rail,
  @JsonValue(3)
  bus,
  @JsonValue(5)
  cableway
}

extension TTC on TransportType {
  static TransportType fromId(int id) {
    return switch (id) {
      2 => TransportType.rail,
      3 => TransportType.bus,
      5 => TransportType.cableway,
      _ => TransportType.unknown
    };
  }

  int get id {
    return switch (this) {
      TransportType.rail => 2,
      TransportType.bus => 3,
      TransportType.cableway => 5,
      TransportType.unknown => 0
    };
  }
}

sealed class Result<T> implements Equatable {
  @override
  bool? get stringify => true;
}

final class Ok<T> extends Result<T> {
  final T result;

  Ok(this.result);

  @override
  List<Object?> get props => [result];
}

enum ErrorType { serviceunreachable, tryAgain }

final class Err<T> extends Result<T> {
  final ErrorType errorType;

  Err(this.errorType);

  @override
  List<Object?> get props => [errorType];
}

/// Key that univocally identitifies a Stop or a Route
class Key extends Equatable {
  final int id;
  final AreaType areaType;

  const Key(this.id, this.areaType);

  @override
  List<Object?> get props => [id, areaType.id];

  @override
  bool? get stringify => true;
}
