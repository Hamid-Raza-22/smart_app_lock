class Validators {
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 4) return false;
    // Add more validation rules as needed
    return true;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-()]+$').hasMatch(phone);
  }
}