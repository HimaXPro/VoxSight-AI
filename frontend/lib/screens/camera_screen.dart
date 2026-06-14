import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _cameraActive = true;
  String _selectedFilter = 'Normal';

  final List<String> _filters = ['Normal', 'Edge Detection', 'Depth Map', 'Night Vision'];

  final List<Map<String, dynamic>> _detections = [
    {
      'object': 'Door',
      'confidence': 0.97,
      'distance': '1.2 m',
      'time': '10:42:05',
      'color': AppColors.accentGreen,
    },
    {
      'object': 'Person',
      'confidence': 0.92,
      'distance': '2.5 m',
      'time': '10:42:03',
      'color': AppColors.accent,
    },
    {
      'object': 'Chair',
      'confidence': 0.88,
      'distance': '3.1 m',
      'time': '10:41:55',
      'color': AppColors.accentOrange,
    },
    {
      'object': 'Table',
      'confidence': 0.85,
      'distance': '3.4 m',
      'time': '10:41:48',
      'color': AppColors.accentOrange,
    },
    {
      'object': 'Wall',
      'confidence': 0.99,
      'distance': '5.0 m',
      'time': '10:41:40',
      'color': AppColors.primary,
    },
  ];

  final List<Map<String, dynamic>> _cameraStatus = [
    {
      'title': 'Lens Clarity',
      'status': 'Clear',
      'value': 'Good',
      'icon': Icons.lens_outlined,
      'isGood': true,
    },
    {
      'title': 'Focus',
      'status': 'Auto',
      'value': 'Active',
      'icon': Icons.center_focus_strong_outlined,
      'isGood': true,
    },
    {
      'title': 'Light Condition',
      'status': 'Adequate',
      'value': '340 lux',
      'icon': Icons.wb_sunny_outlined,
      'isGood': true,
    },
    {
      'title': 'Frame Rate',
      'status': '30 FPS',
      'value': 'Normal',
      'icon': Icons.speed_outlined,
      'isGood': true,
    },
    {
      'title': 'IR Sensor',
      'status': 'Active',
      'value': 'Enabled',
      'icon': Icons.sensors_outlined,
      'isGood': true,
    },
    {
      'title': 'Blur Level',
      'status': 'Low',
      'value': '2%',
      'icon': Icons.blur_on_outlined,
      'isGood': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            title: Column(
              children: [
                Text('Camera Tracking',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                Text('Object Detection & Lens Monitor',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    )),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.screenshot_outlined,
                    color: Colors.white, size: 22),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Live View'),
                Tab(text: 'Lens Status'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _LiveViewTab(
              cameraActive: _cameraActive,
              selectedFilter: _selectedFilter,
              filters: _filters,
              detections: _detections,
              onToggle: (v) => setState(() => _cameraActive = v),
              onFilter: (f) => setState(() => _selectedFilter = f),
            ),
            _LensStatusTab(statusItems: _cameraStatus),
          ],
        ),
      ),
    );
  }
}

class _LiveViewTab extends StatelessWidget {
  final bool cameraActive;
  final String selectedFilter;
  final List<String> filters;
  final List<Map<String, dynamic>> detections;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onFilter;

  const _LiveViewTab({
    required this.cameraActive,
    required this.selectedFilter,
    required this.filters,
    required this.detections,
    required this.onToggle,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Camera preview box
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (cameraActive)
                  // Simulated camera feed
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bounding boxes simulation
                        CustomPaint(
                          size: const Size(260, 140),
                          painter: _BoundingBoxPainter(),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_off_outlined,
                            color: Colors.white38, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Camera Inactive',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                // HUD
                if (cameraActive) ...[
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text('LIVE',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        selectedFilter,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                // Toggle button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => onToggle(!cameraActive),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cameraActive
                            ? AppColors.accentRed.withValues(alpha: 0.85)
                            : AppColors.accentGreen.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cameraActive
                                ? Icons.videocam_off
                                : Icons.videocam,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            cameraActive ? 'Stop' : 'Start',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final sel = filters[i] == selectedFilter;
                return GestureDetector(
                  onTap: () => onFilter(filters[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            sel ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      filters[i],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: sel
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: 'Detected Objects'),
          const SizedBox(height: 12),
          ...detections.map((d) => _DetectionTile(data: d)),
        ],
      ),
    );
  }
}

class _BoundingBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGreen = Paint()
      ..color = const Color(0xFF27AE60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final paintBlue = Paint()
      ..color = const Color(0xFF4A90D9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Door box
    canvas.drawRect(
        const Rect.fromLTWH(10, 10, 80, 110), paintGreen);
    // Person box
    canvas.drawRect(
        const Rect.fromLTWH(140, 20, 55, 90), paintBlue);
    // Chair box
    canvas.drawRect(
        const Rect.fromLTWH(200, 60, 50, 70),
        Paint()
          ..color = const Color(0xFFF39C12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetectionTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DetectionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final double conf = data['confidence'] as double;
    final Color color = data['color'] as Color;

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.crop_free, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['object'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${data['distance']}  •  ${data['time']}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(conf * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                'Confidence',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LensStatusTab extends StatelessWidget {
  final List<Map<String, dynamic>> statusItems;
  const _LensStatusTab({required this.statusItems});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentGreen, Color(0xFF1E8E50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camera is Healthy',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'All systems operating normally',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: 'Sensor Details'),
          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: statusItems.length,
            itemBuilder: (_, i) {
              final item = statusItems[i];
              final bool isGood = item['isGood'] as bool;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isGood
                              ? AppColors.accentGreen
                              : AppColors.accentRed,
                          size: 20,
                        ),
                        const Spacer(),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isGood
                                ? AppColors.accentGreen
                                : AppColors.accentRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item['value'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item['status'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isGood
                            ? AppColors.accentGreen
                            : AppColors.accentRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
