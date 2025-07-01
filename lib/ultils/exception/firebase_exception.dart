class TFirebaseException implements Exception {
  TFirebaseException(this.code);
  final String code;

  String get message {
    switch (code) {
      case 'unknown':
        return 'Lỗi không xác định. Vui lòng thử lại.';
      case 'network-request-failed':
        return 'Lỗi mạng. Vui lòng kiểm tra kết nối internet và thử lại.';
      case 'user-not-found':
        return 'No user found with the provided credentials.';
      case 'wrong-password':
        return 'Mật khẩu không đúng. Vui lòng thử lại.';
      case 'email-already-in-use':
        return 'Email đã được sử dụng bởi tài khoản khác.';
      case 'invalid-email':
        return 'The email address is invalid. Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Thao tác không được phép. Vui lòng liên hệ hỗ trợ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different credential.';
      case 'user-disabled':
        return 'Tài khoản người dùng đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.';
      case 'invalid-verification-code':
        return 'Mã xác minh không đúng. Vui lòng thử lại.';
      case 'invalid-verification-id':
        return 'Mã xác minh không đúng. Vui lòng thử lại.';
      case 'resource-exhausted':
        return 'Tài nguyên đã cạn kiệt. Vui lòng thử lại sau.';
      case 'failed-precondition':
        return 'Điều kiện tiên quyết không được đáp ứng. Vui lòng thử lại.';
      case 'aborted':
        return 'Thao tác đã bị hủy bỏ. Vui lòng thử lại.';
      case 'deadline-exceeded':
        return 'Quá thời gian chờ. Vui lòng thử lại.';
      case 'cancelled':
        return 'Thao tác đã bị hủy. Vui lòng thử lại.';
      case 'unimplemented':
        return 'Chức năng chưa được triển khai. Vui lòng liên hệ hỗ trợ.';
      case 'internal':
        return 'Lỗi nội bộ. Vui lòng thử lại sau.';
      case 'unavailable':
        return 'Dịch vụ hiện không khả dụng. Vui lòng thử lại sau.';
      case 'object-not-found':
        return 'Không tìm thấy đối tượng. Vui lòng kiểm tra lại.';
      case 'bucket-not-found':
        return 'Không tìm thấy bucket. Vui lòng kiểm tra lại.';
      case 'quota-exceeded':
        return 'Đã vượt quá hạn mức. Vui lòng thử lại sau.';
      case 'unauthorized':
        return 'Không có quyền truy cập. Vui lòng đăng nhập lại.';
      case 'retry-limit-exceeded':
        return 'Đã vượt quá số lần thử lại. Vui lòng thử lại sau.';
      default:
        return 'Lỗi không xác định. Vui lòng thử lại.';
    }
  }
}
