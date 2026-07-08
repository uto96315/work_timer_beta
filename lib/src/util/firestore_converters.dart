import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object? toJson(DateTime object) => Timestamp.fromDate(object);
}

class GeoPointConverter implements JsonConverter<GeoPoint?, Object?> {
  const GeoPointConverter();

  @override
  GeoPoint? fromJson(Object? json) => json as GeoPoint?;

  @override
  Object? toJson(GeoPoint? object) => object;
}

class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}
