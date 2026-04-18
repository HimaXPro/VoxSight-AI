import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _deviceOnline = true;
  double _temperature = 42.0;
  double _battery = 0.72;
  double _dataUsed = 0.58;
  double _storageUsed = 0.34;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _tempColor {
    if (_temperature < 40) return AppColors.accentGreen;
    if (_temperature < 55) return AppColors.accentOrange;
    return AppColors.accentRed;
  }

  Color get _batteryColor {
    if (_battery > 0.5) return AppColors.accentGreen;
    if (_battery > 0.2) return AppColors.accentOrange;
    return AppColors.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dashboard',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'VoxSight AI Monitoring',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                StatusBadge(
                                  text: _deviceOnline ? 'Online' : 'Offline',
                                  isOnline: _deviceOnline,
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.notifications_outlined,
                                      color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Device Info Card
                _DeviceCard(isOnline: _deviceOnline),
                const SizedBox(height: 24),

                // Section: Temperature
                const SectionHeader(title: 'System Status'),
                const SizedBox(height: 16),

                // Temperature & Battery Row
                Row(
                  children: [
                    Expanded(
                      child: _GaugeCard(
                        title: 'Temperature',
                        value: '${_temperature.toInt()}°C',
                        percent: (_temperature / 100).clamp(0.0, 1.0),
                        color: _tempColor,
                        icon: Icons.thermostat_outlined,
                        subtitle: _temperature < 55 ? 'Normal' : 'Too Hot',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _GaugeCard(
                        title: 'Battery',
                        value: '${(_battery * 100).toInt()}%',
                        percent: _battery,
                        color: _batteryColor,
                        icon: Icons.battery_charging_full_outlined,
                        subtitle: _battery > 0.2 ? 'Good' : 'Low',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Data Usage
                InfoCard(
                  title: 'Data Usage',
                  value: '${(_dataUsed * 10).toStringAsFixed(1)}',
                  unit: '/ 10 GB',
                  icon: Icons.data_usage_outlined,
                  iconColor: AppColors.accent,
                  iconBg: AppColors.accent.withValues(alpha: 0.12),
                  trailing: SizedBox(
                    width: 100,
                    child: LinearPercentIndicator(
                      lineHeight: 8,
                      percent: _dataUsed,
                      progressColor: AppColors.accent,
                      backgroundColor: AppColors.border,
                      barRadius: const Radius.circular(6),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Storage
                InfoCard(
                  title: 'Storage',
                  value: '${(_storageUsed * 64).toStringAsFixed(0)}',
                  unit: '/ 64 GB',
                  icon: Icons.storage_outlined,
                  iconColor: AppColors.accentOrange,
                  iconBg: AppColors.accentOrange.withValues(alpha: 0.12),
                  trailing: SizedBox(
                    width: 100,
                    child: LinearPercentIndicator(
                      lineHeight: 8,
                      percent: _storageUsed,
                      progressColor: AppColors.accentOrange,
                      backgroundColor: AppColors.border,
                      barRadius: const Radius.circular(6),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [
                    _QuickActionCard(
                      label: 'Restart Device',
                      icon: Icons.restart_alt_rounded,
                      color: AppColors.accent,
                    ),
                    _QuickActionCard(
                      label: 'Sync Data',
                      icon: Icons.sync_rounded,
                      color: AppColors.accentGreen,
                    ),
                    _QuickActionCard(
                      label: 'Audio Mode',
                      icon: Icons.volume_up_outlined,
                      color: AppColors.accentOrange,
                    ),
                    _QuickActionCard(
                      label: 'Update FW',
                      icon: Icons.system_update_outlined,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Last Activity
                const SectionHeader(title: 'Recent Activity'),
                const SizedBox(height: 12),
                ..._activities.map((a) => _ActivityTile(activity: a)),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Object detected: Door',
      'time': '10:42 AM',
      'icon': Icons.door_back_door_outlined,
      'color': AppColors.accent,
    },
    {
      'title': 'Low battery alert sent',
      'time': '09:15 AM',
      'icon': Icons.battery_alert_outlined,
      'color': AppColors.accentRed,
    },
    {
      'title': 'GPS location updated',
      'time': '08:50 AM',
      'icon': Icons.location_on_outlined,
      'color': AppColors.accentGreen,
    },
    {
      'title': 'Connected to WiFi',
      'time': '08:12 AM',
      'icon': Icons.wifi_outlined,
      'color': AppColors.primary,
    },
  ];
}

class _DeviceCard extends StatelessWidget {
  final bool isOnline;
  const _DeviceCard({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.remove_red_eye_outlined,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VoxSight AI-001',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Smart Glasses • ID: VS2024-001',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                StatusBadge(
                  text: isOnline ? 'Connected' : 'Disconnected',
                  isOnline: isOnline,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white54, size: 16),
        ],
      ),
    );
  }
}

class _GaugeCard extends StatelessWidget {
  final String title;
  final String value;
  final double percent;
  final Color color;
  final IconData icon;
  final String subtitle;

  const _GaugeCard({
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 42,
            lineWidth: 7,
            percent: percent.clamp(0.0, 1.0),
            center: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.12),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity['icon'] as IconData,
                color: activity['color'] as Color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity['title'] as String,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            activity['time'] as String,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
