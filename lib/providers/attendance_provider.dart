import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/database_service.dart';

class AttendanceProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<AttendanceModel> _attendanceHistory = [];
  AttendanceModel? _todayAttendance;
  Map<String, dynamic>? _attendanceStats;
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceModel> get attendanceHistory => _attendanceHistory;
  AttendanceModel? get todayAttendance => _todayAttendance;
  Map<String, dynamic>? get attendanceStats => _attendanceStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasCheckedInToday => _todayAttendance?.hasCheckedIn ?? false;
  bool get hasCheckedOutToday => _todayAttendance?.hasCheckedOut ?? false;

  // Mark attendance
  Future<bool> markAttendance(AttendanceModel attendance) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.markAttendance(attendance);
      _todayAttendance = attendance;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get today's attendance
  Future<void> getTodayAttendance(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayAttendance =
          await _databaseService.getAttendanceByDate(userId, DateTime.now());
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get attendance history
  Future<void> getAttendanceHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _attendanceHistory = await _databaseService.getAttendanceHistory(
        userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get attendance statistics
  Future<void> getAttendanceStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _attendanceStats = await _databaseService.getAttendanceStats(
        userId,
        startDate,
        endDate,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all attendance for a date (Admin)
  Future<List<AttendanceModel>> getAllAttendanceByDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<AttendanceModel> result =
          await _databaseService.getAllAttendanceByDate(date);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear data
  void clearData() {
    _attendanceHistory = [];
    _todayAttendance = null;
    _attendanceStats = null;
    _errorMessage = null;
    notifyListeners();
  }
}
