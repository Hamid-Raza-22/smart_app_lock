
import '../../../export.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Lock'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshApps,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Obx(
            () => controller.isLoading.value
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 16),
              Text('Loading installed apps...'),
            ],
          ),
        )
            : RefreshIndicator(
          onRefresh: controller.refreshApps,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Mode Selector
                ModeSelectorWidget(
                  currentMode: controller.currentMode.value,
                  onModeChanged: controller.toggleMode,
                ),

                // Dashboard Stats
                DashboardStatsWidget(
                  totalApps: controller.installedApps.length,
                  lockedApps: controller.selectedApps.length,
                  currentMode: controller.currentMode.value,
                ),

                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: controller.searchApps,
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      prefixIcon: Icon(Icons.search, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),

                // Apps Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Installed Apps',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            '${controller.filteredApps.length} apps',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      controller.filteredApps.isEmpty
                          ? Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.apps_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No apps found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: controller.filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = controller.filteredApps[index];
                          final isSelected = controller.selectedApps
                              .any((a) => a.packageName == app.packageName);

                          return AppCardWidget(
                            app: app,
                            isSelected: isSelected,
                            currentMode: controller.currentMode.value,
                            onTap: () => controller.openApp(app),
                            onSelectionToggle: () =>
                                controller.toggleAppSelection(app),
                            onLongPress: () => _showAppOptions(context, app),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show app options menu
  void _showAppOptions(BuildContext context, AppInfoModel app) {
    final isSelected = controller.selectedApps
        .any((a) => a.packageName == app.packageName);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  child: app.iconData != null
                      ? Image.memory(app.iconData!)
                      : Icon(Icons.android, size: 48),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        app.packageName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.open_in_new,
                color: Colors.green,
              ),
              title: Text('Open App'),
              onTap: () {
                Get.back();
                controller.openApp(app);
              },
            ),
            ListTile(
              leading: Icon(
                isSelected ? Icons.lock_open : Icons.lock,
                color: isSelected ? Colors.orange : Colors.green,
              ),
              title: Text(isSelected ? 'Remove Protection' : 'Add Protection'),
              onTap: () {
                Get.back();
                controller.toggleAppSelection(app);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.blue,
              ),
              title: Text('App Settings'),
              onTap: () {
                Get.back();
                controller.openAppSettings(app);
              },
            ),
            if (!app.systemApp)
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text('Uninstall'),
                onTap: () async {
                  Get.back();
                  bool? confirm = await Get.dialog<bool>(
                    AlertDialog(
                      title: Text('Uninstall ${app.name}?'),
                      content: Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          child: Text('Uninstall'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final appRepository = controller.appRepository;
                    await appRepository.uninstallApp(app.packageName);
                    controller.refreshApps();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

}