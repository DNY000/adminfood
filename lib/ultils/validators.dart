class Validators {
  // Kiểm tra email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }

    // Regex cho email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  // Kiểm tra mật khẩu
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    // Kiểm tra có ít nhất 1 chữ hoa
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }

    // Kiểm tra có ít nhất 1 số
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }

    return null;
  }

  // Kiểm tra xác nhận mật khẩu
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != password) {
      return 'Mật khẩu không khớp';
    }

    return null;
  }

  // Kiểm tra số điện thoại
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    // Regex cho số điện thoại Việt Nam
    final phoneRegex = RegExp(r'^(0|84)?[0-9]{9,10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }

    return null;
  }

  // Kiểm tra tên
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên';
    }

    if (value.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }

    return null;
  }

  // Kiểm tra địa chỉ
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }

    if (value.length < 10) {
      return 'Địa chỉ phải có ít nhất 10 ký tự';
    }

    return null;
  }

  // Kiểm tra ngày tháng
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ngày';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'Ngày không hợp lệ';
      }
    } catch (e) {
      return 'Định dạng ngày không hợp lệ';
    }

    return null;
  }

  // Kiểm tra số
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Vui lòng chỉ nhập số';
    }

    return null;
  }

  // Kiểm tra độ dài tối thiểu
  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return 'Trường này không được để trống';
    }

    if (value.length < minLength) {
      return 'Phải có ít nhất $minLength ký tự';
    }

    return null;
  }

  // Kiểm tra độ dài tối đa
  static String? validateMaxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return 'Trường này không được để trống';
    }

    if (value.length > maxLength) {
      return 'Không được vượt quá $maxLength ký tự';
    }

    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã OTP';
    }
    if (value.length != 6) {
      return 'Mã OTP phải có 6 số';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Mã OTP chỉ được chứa số';
    }
    return null;
  }
}
