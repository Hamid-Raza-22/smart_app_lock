import '../../../../export.dart';

class AppCardWidget extends StatelessWidget {
  final AppInfoModel app;
  final bool isSelected;
  final AppMode currentMode;
  final VoidCallback onTap;
  final VoidCallback onSelectionToggle;
  final VoidCallback onLongPress;

  const AppCardWidget({
    Key? key,
    required this.app,
    required this.isSelected,
    required this.currentMode,
    required this.onTap,
    required this.onSelectionToggle,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                // App icon
                Container(
                  width: 50,
                  height: 50,
                  child: app.iconData != null
                      ? Image.memory(
                    app.iconData!,
                    fit: BoxFit.contain,
                  )
                      : Icon(
                    Icons.android,
                    color: Colors.green[700],
                    size: 40,
                  ),
                ),
                // Selection indicator
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      currentMode == AppMode.advanced
                          ? Icons.lock
                          : Icons.block,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            // App name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                app.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Version info (optional)
            // if (app.versionName.isNotEmpty)
            //   Text(
            //     'v${app.versionName}',
            //     style: TextStyle(
            //       fontSize: 9,
            //       color: Colors.grey[600],
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}