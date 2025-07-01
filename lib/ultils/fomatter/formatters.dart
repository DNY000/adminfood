class TFormatter {
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 10) {
      return phoneNumber.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d{4})'),
          (Match m) => '${m[1]}-${m[2]}-${m[3]}');
      // Nếu là 10 số thì tách thành 3 3 4
    } else if (phoneNumber.length == 11) {
      return phoneNumber.replaceAllMapped(RegExp(r'(\d{3})(\d{4})(\d{4})'),
          (Match m) => '${m[1]}-${m[2]}-${m[3]}');
      // Nếu 11 số tách thành 4 4 3
    }
    return phoneNumber;
  }

  static String formatUserName(String userName) {
    return userName.replaceAll(' ', '').toLowerCase();
  }

  static String formatFullName(String firstName, String lastName) {
    return '$firstName $lastName';
  }

  /// Định dạng số điện thoại Việt Nam để hiển thị
  /// Chuyển đổi từ 0xxxxxxxxx thành +84 xxx xxx xxx
  static String formatPhoneNumberForDisplay(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';

    // Loại bỏ khoảng trắng và ký tự đặc biệt
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Đảm bảo số điện thoại bắt đầu bằng 0
    if (!cleaned.startsWith('0')) {
      cleaned = '0$cleaned';
    }

    // Đảm bảo số điện thoại có đủ 10 chữ số
    if (cleaned.length != 10) {
      return phoneNumber; // Trả về số gốc nếu không đúng định dạng
    }

    // Chuyển đổi từ 0xxxxxxxxx thành +84 xxxxxxxxx
    String international =
        '+84 ${cleaned.substring(1, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';

    return international;
  }

  /// Định dạng số điện thoại để gửi đến Firebase Auth
  /// Chuyển đổi từ 0xxxxxxxxx thành +84xxxxxxxxx
  static String formatPhoneNumberForFirebase(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';

    // Loại bỏ khoảng trắng và ký tự đặc biệt
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Đảm bảo số điện thoại bắt đầu bằng 0
    if (!cleaned.startsWith('0')) {
      cleaned = '0$cleaned';
    }

    // Đảm bảo số điện thoại có đủ 10 chữ số
    if (cleaned.length != 10) {
      return phoneNumber; // Trả về số gốc nếu không đúng định dạng
    }

    // Chuyển đổi từ 0xxxxxxxxx thành +84xxxxxxxxx
    String international = '+84${cleaned.substring(1)}';

    return international;
  }

  // static String formatDate(DateTime date) {
  //   return DateFormat('yyyy-MM-dd').format(date).toString();
  // }
}
