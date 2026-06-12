// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_data.dart';

SleepReportItem _$SleepReportItemFromJson(Map<String, dynamic> json) =>
    SleepReportItem(
      date: json['date'] as String,
      totalDurationMin: (json['totalDurationMin'] as num).toDouble(),
      eventsCount: json['eventsCount'] as int,
    );

Map<String, dynamic> _$SleepReportItemToJson(SleepReportItem instance) =>
    <String, dynamic>{
      'date': instance.date,
      'totalDurationMin': instance.totalDurationMin,
      'eventsCount': instance.eventsCount,
    };

FeedingReportItem _$FeedingReportItemFromJson(Map<String, dynamic> json) =>
    FeedingReportItem(
      date: json['date'] as String,
      bottle: json['bottle'] as int,
      breast: json['breast'] as int,
      solids: json['solids'] as int,
    );

Map<String, dynamic> _$FeedingReportItemToJson(FeedingReportItem instance) =>
    <String, dynamic>{
      'date': instance.date,
      'bottle': instance.bottle,
      'breast': instance.breast,
      'solids': instance.solids,
    };

DiapersReportItem _$DiapersReportItemFromJson(Map<String, dynamic> json) =>
    DiapersReportItem(
      date: json['date'] as String,
      pee: json['pee'] as int,
      poop: json['poop'] as int,
      both: json['both'] as int,
    );

Map<String, dynamic> _$DiapersReportItemToJson(DiapersReportItem instance) =>
    <String, dynamic>{
      'date': instance.date,
      'pee': instance.pee,
      'poop': instance.poop,
      'both': instance.both,
    };

GrowthReportItem _$GrowthReportItemFromJson(Map<String, dynamic> json) =>
    GrowthReportItem(
      id: json['id'] as String,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      headCircumferenceCm:
          (json['headCircumferenceCm'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$GrowthReportItemToJson(GrowthReportItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'measuredAt': instance.measuredAt.toIso8601String(),
      if (instance.weightKg != null) 'weightKg': instance.weightKg,
      if (instance.heightCm != null) 'heightCm': instance.heightCm,
      if (instance.headCircumferenceCm != null)
        'headCircumferenceCm': instance.headCircumferenceCm,
    };

MedicationReportItem _$MedicationReportItemFromJson(
        Map<String, dynamic> json) =>
    MedicationReportItem(
      id: json['id'] as String,
      occurredAt: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'] as String)
          : null,
      medicationName: json['medicationName'] as String,
      dose: json['dose'] as String,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MedicationReportItemToJson(
        MedicationReportItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.occurredAt != null)
        'occurredAt': instance.occurredAt!.toIso8601String(),
      'medicationName': instance.medicationName,
      'dose': instance.dose,
      if (instance.reason != null) 'reason': instance.reason,
      if (instance.notes != null) 'notes': instance.notes,
    };
