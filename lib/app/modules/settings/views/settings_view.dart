import '../../../export.dart';

class SettingsView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Obx(
            () => ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Security Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.green[700]),
                    title: Text('Change Password'),
                    subtitle: Text(
                      controller.hasPassword.value
                          ? 'Update your app password'
                          : 'Set a new password',
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.changePassword,
                  ),
                  if (controller.hasPassword.value)
                    ListTile(
                      leading: Icon(Icons.lock_reset, color: Colors.orange),
                      title: Text('Reset Password'),
                      subtitle: Text('Remove password protection'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: controller.resetPassword,
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Data Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text('Clear All Data'),
                    subtitle: Text('Remove all settings and configurations'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.clearAllData,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.green[700]),
                    title: Text('App Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  ListTile(
                    leading: Icon(Icons.security, color: Colors.green[700]),
                    title: Text('Security Info'),
                    subtitle: Text('Advanced mode includes factory reset protection'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}