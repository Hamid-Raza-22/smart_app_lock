import '../../../export.dart';

class PasswordVerifyView extends GetView<PasswordVerifyController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Obx(
              () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: Colors.green[700],
              ),
              SizedBox(height: 24),
              Text(
                'Access Protected App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Enter password to access ${controller.app.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              TextField(
                controller: controller.passwordController,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  errorText: controller.errorMessage.value.isEmpty
                      ? null
                      : controller.errorMessage.value,
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: controller.failedAttempts.value > 0
                      ? Colors.red[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.failedAttempts.value > 0
                        ? Colors.red
                        : Colors.blue,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: controller.failedAttempts.value > 0
                          ? Colors.red[700]
                          : Colors.blue[700],
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed Attempts: ${controller.failedAttempts.value}/3',
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.failedAttempts.value > 0
                              ? Colors.red[900]
                              : Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.verifyPassword,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Unlock', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}