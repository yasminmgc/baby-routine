import 'package:json_annotation/json_annotation.dart';

part 'report_data.g.dart';

@JsonSerializable()
class SleepReportItem {
  final String date;
  @JsonKey(name: 'totalDurationMin')
  final double totalDurationMin;
  @JsonKey(name: 'eventsCount')
  final int eventsCount;

  const SleepReportItem({
    required this.date,
    required this.totalDurationMin,
    required this.eventsCount,
  });

  factory SleepReportItem.fromJson(Map<String, dynamic> json) =>
      _$SleepReportItemFromJson(json);

  Map<String, dynamic> toJson() => _$SleepReportItemToJson(this);
}

@JsonSerializable()
class FeedingReportItem {
  final String date;
  final int bottle;
  final int breast;
  final int solids;

  const FeedingReportItem({
    required this.date,
    required this.bottle,
    required this.breast,
    required this.solids,
  });

  factory FeedingReportItem.fromJson(Map<String, dynamic> json) =>
      _$FeedingReportItemFromJson(json);

  Map<String, dynamic> toJson() => _$FeedingReportItemToJson(this);
}

@JsonSerializable()
class DiapersReportItem {
  final String date;
  final int pee;
  final int poop;
  final int both;

  const DiapersReportItem({
    required this.date,
    required this.pee,
    required this.poop,
    required this.both,
  });

  factory DiapersReportItem.fromJson(Map<String, dynamic> json) =>
      _$DiapersReportItemFromJson(json);

  Map<String, dynamic> toJson() => _$DiapersReportItemToJson(this);
}

@JsonSerializable()
class GrowthReportItem {
  final String id;
  final DateTime measuredAt;
  @JsonKey(name: 'weightKg')
  final double? weightKg;
  @JsonKey(name: 'heightCm')
  final double? heightCm;
  @JsonKey(name: 'headCircumferenceCm')
  final double? headCircumferenceCm;

  const GrowthReportItem({
    required this.id,
    required this.measuredAt,
    this.weightKg,
    this.heightCm,
    this.headCircumferenceCm,
  });

  factory GrowthReportItem.fromJson(Map<String, dynamic> json) =>
      _$GrowthReportItemFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthReportItemToJson(this);
}

@JsonSerializable()
class MedicationReportItem {
  final String id;
  final DateTime? occurredAt;
  @JsonKey(name: 'medicationName')
  final String medicationName;
  final String dose;
  final String? reason;
  final String? notes;

  const MedicationReportItem({
    required this.id,
    this.occurredAt,
    required this.medicationName,
    required this.dose,
    this.reason,
    this.notes,
  });

  factory MedicationReportItem.fromJson(Map<String, dynamic> json) =>
      _$MedicationReportItemFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationReportItemToJson(this);
}
