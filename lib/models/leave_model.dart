import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveType { sick, casual, earned, unpaid, other }

enum LeaveStatus { pending, approved, rejected }

class LeaveModel {
  final String id;
  final String userId;
  final String userName;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final String reason;
  final LeaveStatus status;
  final String? rejectionReason;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.rejectionReason,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'numberOfDays': numberOfDays,
      'reason': reason,
      'status': status.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      type: _parseLeaveType(map['type']),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      numberOfDays: map['numberOfDays'] ?? 0,
      reason: map['reason'] ?? '',
      status: _parseStatus(map['status']),
      rejectionReason: map['rejectionReason'],
      approvedBy: map['approvedBy'],
      approvedAt: (map['approvedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory LeaveModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaveModel.fromMap(data);
  }

  static LeaveType _parseLeaveType(String? type) {
    switch (type) {
      case 'sick':
        return LeaveType.sick;
      case 'casual':
        return LeaveType.casual;
      case 'earned':
        return LeaveType.earned;
      case 'unpaid':
        return LeaveType.unpaid;
      case 'other':
        return LeaveType.other;
      default:
        return LeaveType.casual;
    }
  }

  static LeaveStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return LeaveStatus.pending;
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }

  LeaveModel copyWith({
    String? id,
    String? userId,
    String? userName,
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfDays,
    String? reason,
    LeaveStatus? status,
    String? rejectionReason,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
  bool get isRejected => status == LeaveStatus.rejected;
}
