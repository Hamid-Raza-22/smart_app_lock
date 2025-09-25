import '../../../../export.dart';

class ModeSelectorWidget extends StatelessWidget {
  final AppMode currentMode;
  final Function(AppMode) onModeChanged;

  const ModeSelectorWidget({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Protection Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  mode: AppMode.normal,
                  isSelected: currentMode == AppMode.normal,
                  onTap: () => onModeChanged(AppMode.normal),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ModeButton(
                  mode: AppMode.advanced,
                  isSelected: currentMode == AppMode.advanced,
                  onTap: () => onModeChanged(AppMode.advanced),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            currentMode.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final AppMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    Key? key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mode == AppMode.normal ? Icons.security : Icons.enhanced_encryption,
              color: isSelected ? Colors.green[700] : Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                mode.name,
                style: TextStyle(
                  color: isSelected ? Colors.green[700] : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}