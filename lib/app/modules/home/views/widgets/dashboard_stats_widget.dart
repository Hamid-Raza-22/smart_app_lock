import '../../../../export.dart';

class DashboardStatsWidget extends StatelessWidget {
  final int totalApps;
  final int lockedApps;
  final AppMode currentMode;

  const DashboardStatsWidget({
    Key? key,
    required this.totalApps,
    required this.lockedApps,
    required this.currentMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total Apps',
              value: totalApps.toString(),
              icon: Icons.apps,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: currentMode == AppMode.advanced ? 'Locked' : 'Protected',
              value: lockedApps.toString(),
              icon: currentMode == AppMode.advanced ? Icons.lock : Icons.shield,
              color: Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Unprotected',
              value: (totalApps - lockedApps).toString(),
              icon: Icons.lock_open,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}