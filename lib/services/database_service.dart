import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ATTENDANCE OPERATIONS

  // Mark attendance (check-in or check-out)
  Future<void> markAttendance(AttendanceModel attendance) async {
    try {
      await _firestore
          .collection('attendance')
          .doc(attendance.id)
          .set(attendance.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to mark attendance: $e';
    }
  }

  // Get attendance for a specific date
  Future<AttendanceModel?> getAttendanceByDate(
      String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AttendanceModel.fromDocument(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch attendance: $e';
    }
  }

  // Get attendance history for a user
  Future<List<AttendanceModel>> getAttendanceHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query =
            query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch attendance history: $e';
    }
  }

  // Get all attendance for a specific date (Admin)
  Future<List<AttendanceModel>> getAllAttendanceByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch all attendance: $e';
    }
  }

  // Stream of today's attendance for all employees
  Stream<List<AttendanceModel>> getTodayAttendanceStream() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _firestore
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromDocument(doc))
            .toList());
  }

  // Get attendance statistics for a user
  Future<Map<String, dynamic>> getAttendanceStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final attendanceList = await getAttendanceHistory(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      int presentDays = 0;
      int absentDays = 0;
      int lateDays = 0;
      int halfDays = 0;
      double totalWorkHours = 0;

      for (var attendance in attendanceList) {
        switch (attendance.status) {
          case AttendanceStatus.present:
            presentDays++;
            break;
          case AttendanceStatus.absent:
            absentDays++;
            break;
          case AttendanceStatus.late:
            lateDays++;
            break;
          case AttendanceStatus.halfDay:
            halfDays++;
            break;
          case AttendanceStatus.onLeave:
            break;
        }

        if (attendance.workHours != null) {
          totalWorkHours += attendance.workHours!;
        }
      }

      return {
        'totalDays': attendanceList.length,
        'presentDays': presentDays,
        'absentDays': absentDays,
        'lateDays': lateDays,
        'halfDays': halfDays,
        'totalWorkHours': totalWorkHours,
        'averageWorkHours':
            attendanceList.isNotEmpty ? totalWorkHours / attendanceList.length : 0,
      };
    } catch (e) {
      throw 'Failed to calculate attendance statistics: $e';
    }
  }

  // LEAVE OPERATIONS

  // Submit leave request
  Future<void> submitLeaveRequest(LeaveModel leave) async {
    try {
      await _firestore.collection('leave_requests').doc(leave.id).set(leave.toMap());
    } catch (e) {
      throw 'Failed to submit leave request: $e';
    }
  }

  // Update leave status
  Future<void> updateLeaveStatus(
    String leaveId,
    LeaveStatus status, {
    String? approvedBy,
    String? rejectionReason,
  }) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == LeaveStatus.approved && approvedBy != null) {
        updateData['approvedBy'] = approvedBy;
        updateData['approvedAt'] = FieldValue.serverTimestamp();
      }

      if (status == LeaveStatus.rejected && rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }

      await _firestore.collection('leave_requests').doc(leaveId).update(updateData);
    } catch (e) {
      throw 'Failed to update leave status: $e';
    }
  }

  // Get leave requests for a user
  Future<List<LeaveModel>> getUserLeaveRequests(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('leave_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LeaveModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch leave requests: $e';
    }
  }

  // Get all pending leave requests (Admin)
  Future<List<LeaveModel>> getPendingLeaveRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('leave_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => LeaveModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch pending leave requests: $e';
    }
  }

  // Stream of pending leave requests
  Stream<List<LeaveModel>> getPendingLeaveRequestsStream() {
    return _firestore
        .collection('leave_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LeaveModel.fromDocument(doc)).toList());
  }

  // Get all leave requests (Admin)
  Future<List<LeaveModel>> getAllLeaveRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('leave_requests')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LeaveModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch all leave requests: $e';
    }
  }

  // Delete leave request
  Future<void> deleteLeaveRequest(String leaveId) async {
    try {
      await _firestore.collection('leave_requests').doc(leaveId).delete();
    } catch (e) {
      throw 'Failed to delete leave request: $e';
    }
  }

  // USER OPERATIONS

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user: $e';
    }
  }
}
