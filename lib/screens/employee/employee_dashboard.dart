import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../config/theme.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
  }

  Future<void> _loadTodayAttendance() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await attendanceProvider
          .getTodayAttendance(authProvider.currentUser!.id);
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Consumer2<AuthProvider, AttendanceProvider>(
        builder: (context, authProvider, attendanceProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTodayAttendance,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      if (user.designation != null)
                                        Text(
                                          user.designation!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppTheme
                                                    .textSecondaryColor,
                                              ),
                                        ),
                                      if (user.department != null)
                                        Text(
                                          user.department!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: attendanceProvider.hasCheckedInToday
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Today\'s Status',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Icon(
                                  attendanceProvider.hasCheckedInToday
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: attendanceProvider.hasCheckedInToday
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              attendanceProvider.hasCheckedInToday
                                  ? attendanceProvider.hasCheckedOutToday
                                      ? 'Checked In & Out'
                                      : 'Checked In'
                                  : 'Not Checked In',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: attendanceProvider.hasCheckedInToday
                                        ? AppTheme.successColor
                                        : AppTheme.warningColor,
                                  ),
                            ),
                            if (attendanceProvider.todayAttendance
                                    ?.checkInTime !=
                                null)
                              Text(
                                'Check-in: ${_formatTime(attendanceProvider.todayAttendance!.checkInTime!)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            if (attendanceProvider.todayAttendance
                                    ?.checkOutTime !=
                                null)
                              Text(
                                'Check-out: ${_formatTime(attendanceProvider.todayAttendance!.checkOutTime!)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildDashboardCard(
                          context,
                          icon: Icons.fingerprint,
                          title: 'Mark\nAttendance',
                          color: AppTheme.primaryColor,
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/mark-attendance');
                          },
                        ),
                        _buildDashboardCard(
                          context,
                          icon: Icons.history,
                          title: 'View\nHistory',
                          color: AppTheme.secondaryColor,
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/attendance-history');
                          },
                        ),
                        _buildDashboardCard(
                          context,
                          icon: Icons.event_available,
                          title: 'Apply\nLeave',
                          color: AppTheme.accentColor,
                          onTap: () {
                            Navigator.of(context).pushNamed('/apply-leave');
                          },
                        ),
                        _buildDashboardCard(
                          context,
                          icon: Icons.person,
                          title: 'View\nProfile',
                          color: AppTheme.successColor,
                          onTap: () {
                            Navigator.of(context).pushNamed('/profile');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
