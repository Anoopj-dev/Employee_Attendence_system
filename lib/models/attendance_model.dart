import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, late, halfDay, onLeave }

enum AttendanceType { checkIn, checkOut }

class AttendanceModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? checkInFaceImageUrl;
  final String? checkOutFaceImageUrl;
  final double? workHours;
  final String? notes;
  final bool isManualEntry;
  final String? manualEntryBy;
  final String? manualEntryReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInFaceImageUrl,
    this.checkOutFaceImageUrl,
    this.workHours,
    this.notes,
    this.isManualEntry = false,
    this.manualEntryBy,
    this.manualEntryReason,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'date': Timestamp.fromDate(date),
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'status': status.toString().split('.').last,
      'checkInLatitude': checkInLatitude,
      'checkInLongitude': checkInLongitude,
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'checkInAddress': checkInAddress,
      'checkOutAddress': checkOutAddress,
      'checkInFaceImageUrl': checkInFaceImageUrl,
      'checkOutFaceImageUrl': checkOutFaceImageUrl,
      'workHours': workHours,
      'notes': notes,
      'isManualEntry': isManualEntry,
      'manualEntryBy': manualEntryBy,
      'manualEntryReason': manualEntryReason,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkInTime: (map['checkInTime'] as Timestamp?)?.toDate(),
      checkOutTime: (map['checkOutTime'] as Timestamp?)?.toDate(),
      status: _parseStatus(map['status']),
      checkInLatitude: map['checkInLatitude']?.toDouble(),
      checkInLongitude: map['checkInLongitude']?.toDouble(),
      checkOutLatitude: map['checkOutLatitude']?.toDouble(),
      checkOutLongitude: map['checkOutLongitude']?.toDouble(),
      checkInAddress: map['checkInAddress'],
      checkOutAddress: map['checkOutAddress'],
      checkInFaceImageUrl: map['checkInFaceImageUrl'],
      checkOutFaceImageUrl: map['checkOutFaceImageUrl'],
      workHours: map['workHours']?.toDouble(),
      notes: map['notes'],
      isManualEntry: map['isManualEntry'] ?? false,
      manualEntryBy: map['manualEntryBy'],
      manualEntryReason: map['manualEntryReason'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory AttendanceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel.fromMap(data);
  }

  static AttendanceStatus _parseStatus(String? status) {
    switch (status) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'halfDay':
        return AttendanceStatus.halfDay;
      case 'onLeave':
        return AttendanceStatus.onLeave;
      default:
        return AttendanceStatus.absent;
    }
  }

  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? userName,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    AttendanceStatus? status,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkOutLatitude,
    double? checkOutLongitude,
    String? checkInAddress,
    String? checkOutAddress,
    String? checkInFaceImageUrl,
    String? checkOutFaceImageUrl,
    double? workHours,
    String? notes,
    bool? isManualEntry,
    String? manualEntryBy,
    String? manualEntryReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      checkInAddress: checkInAddress ?? this.checkInAddress,
      checkOutAddress: checkOutAddress ?? this.checkOutAddress,
      checkInFaceImageUrl: checkInFaceImageUrl ?? this.checkInFaceImageUrl,
      checkOutFaceImageUrl: checkOutFaceImageUrl ?? this.checkOutFaceImageUrl,
      workHours: workHours ?? this.workHours,
      notes: notes ?? this.notes,
      isManualEntry: isManualEntry ?? this.isManualEntry,
      manualEntryBy: manualEntryBy ?? this.manualEntryBy,
      manualEntryReason: manualEntryReason ?? this.manualEntryReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;
  bool get isComplete => hasCheckedIn && hasCheckedOut;
}
