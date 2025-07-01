class TFormatException implements Exception {
  final String message;

  TFormatException(this.message);

  factory TFormatException.fromMessage(String message) {
    return TFormatException(message);
  }

  static String getMessageFromErrorType(String type) {
    switch (type) {
      // Số và định dạng số
      case 'invalid-number-format':
        return 'Định dạng số không hợp lệ';
      case 'invalid-double':
        return 'Số thập phân không hợp lệ';
      case 'invalid-integer':
        return 'Số nguyên không hợp lệ';
      case 'number-out-of-range':
        return 'Số nằm ngoài phạm vi cho phép';

      // Ngày tháng
      case 'invalid-date-format':
        return 'Định dạng ngày tháng không hợp lệ';
      case 'invalid-time-format':
        return 'Định dạng thời gian không hợp lệ';
      case 'invalid-datetime':
        return 'Ngày giờ không hợp lệ';

      // Email và điện thoại
      case 'invalid-email-format':
        return 'Định dạng email không hợp lệ';
      case 'invalid-phone-format':
        return 'Định dạng số điện thoại không hợp lệ';

      // URL và đường dẫn
      case 'invalid-url-format':
        return 'Định dạng URL không hợp lệ';
      case 'invalid-uri-format':
        return 'Định dạng URI không hợp lệ';
      case 'invalid-path-format':
        return 'Định dạng đường dẫn không hợp lệ';

      // Mã và ID
      case 'invalid-code-format':
        return 'Định dạng mã không hợp lệ';
      case 'invalid-id-format':
        return 'Định dạng ID không hợp lệ';

      // Tên và văn bản
      case 'invalid-name-format':
        return 'Định dạng tên không hợp lệ';
      case 'invalid-text-length':
        return 'Độ dài văn bản không hợp lệ';
      case 'invalid-character':
        return 'Ký tự không hợp lệ';

      // File và dữ liệu
      case 'invalid-file-format':
        return 'Định dạng tệp không hợp lệ';
      case 'invalid-json-format':
        return 'Định dạng JSON không hợp lệ';
      case 'invalid-xml-format':
        return 'Định dạng XML không hợp lệ';

      // Mật khẩu
      case 'invalid-password-format':
        return 'Định dạng mật khẩu không hợp lệ';
      case 'password-too-weak':
        return 'Mật khẩu quá yếu';
      case 'password-no-match':
        return 'Mật khẩu không khớp';

      // Tiền tệ
      case 'invalid-currency-format':
        return 'Định dạng tiền tệ không hợp lệ';
      case 'invalid-amount-format':
        return 'Định dạng số tiền không hợp lệ';

      // Địa chỉ
      case 'invalid-address-format':
        return 'Định dạng địa chỉ không hợp lệ';
      case 'invalid-postal-code':
        return 'Mã bưu chính không hợp lệ';

      // Khác
      case 'empty-field':
        return 'Trường không được để trống';
      case 'required-field':
        return 'Trường bắt buộc phải nhập';
      case 'invalid-format':
        return 'Định dạng không hợp lệ';
      case 'unsupported-format':
        return 'Định dạng không được hỗ trợ';

      default:
        return 'Lỗi định dạng không xác định';
    }
  }

  @override
  String toString() => message;
}
