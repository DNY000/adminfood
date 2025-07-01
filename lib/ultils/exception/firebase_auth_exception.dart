class TFirebaseAuthException implements Exception {
  TFirebaseAuthException(this.code);
  final String code;

  String get message {
    switch (code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng sử dụng email khác.';
      case 'invalid-email':
        return 'Email không hợp lệ. Vui lòng kiểm tra lại.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.';
      case 'operation-not-allowed':
        return 'Hoạt động không được phép. Vui lòng liên hệ hỗ trợ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Sai mật khẩu. Vui lòng thử lại.';
      case 'invalid-verification-code':
        return 'Mã xác thực không hợp lệ. Vui lòng thử lại.';
      case 'invalid-verification-id':
        return 'ID xác thực không hợp lệ. Vui lòng thử lại.';
      case 'quota-exceeded':
        return 'Đã vượt quá giới hạn. Vui lòng thử lại sau.';
      case 'email-already-exists':
        return 'Email này đã tồn tại trong hệ thống.';
      case 'provider-already-linked':
        return 'Tài khoản đã được liên kết với phương thức đăng nhập này.';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để thực hiện thao tác này.';
      case 'credential-already-in-use':
        return 'Thông tin đăng nhập này đã được sử dụng bởi một tài khoản khác.';
      case 'user-mismatch':
        return 'Thông tin người dùng không khớp.';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ.';
      case 'invalid-continue-uri':
        return 'URL tiếp tục không hợp lệ.';
      case 'invalid-dynamic-link-domain':
        return 'Domain của dynamic link không hợp lệ.';
      case 'invalid-phone-number':
        return 'Số điện thoại không hợp lệ.';
      case 'invalid-tenant-id':
        return 'ID tenant không hợp lệ.';
      case 'missing-android-pkg-name':
        return 'Thiếu tên package Android.';
      case 'missing-continue-uri':
        return 'Thiếu URL tiếp tục.';
      case 'missing-ios-bundle-id':
        return 'Thiếu ID bundle iOS.';
      case 'missing-verification-code':
        return 'Thiếu mã xác thực.';
      case 'missing-verification-id':
        return 'Thiếu ID xác thực.';
      case 'session-expired':
        return 'Phiên làm việc đã hết hạn. Vui lòng thử lại.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'unauthorized-continue-uri':
        return 'URL tiếp tục không được ủy quyền.';
      case 'user-cancelled':
        return 'Người dùng đã hủy thao tác.';
      case 'user-token-expired':
        return 'Token người dùng đã hết hạn. Vui lòng đăng nhập lại.';
      case 'web-storage-unsupported':
        return 'Trình duyệt không hỗ trợ web storage.';
      case 'app-not-authorized':
        return 'Ứng dụng chưa được ủy quyền. Vui lòng liên hệ hỗ trợ.';
      case 'app-not-installed':
        return 'Ứng dụng chưa được cài đặt. Vui lòng cài đặt ứng dụng.';
      case 'captcha-check-failed':
        return 'Xác thực CAPTCHA thất bại. Vui lòng thử lại.';
      case 'invalid-api-key':
        return 'API key không hợp lệ. Vui lòng liên hệ hỗ trợ.';
      case 'invalid-app-credential':
        return 'Thông tin xác thực ứng dụng không hợp lệ.';
      case 'invalid-custom-token':
        return 'Custom token không hợp lệ.';
      case 'invalid-message-payload':
        return 'Nội dung tin nhắn không hợp lệ.';
      case 'invalid-recipient-email':
        return 'Email người nhận không hợp lệ.';
      case 'invalid-sender':
        return 'Người gửi không hợp lệ.';
      case 'invalid-verification-url':
        return 'URL xác thực không hợp lệ.';
      case 'network-request-failed':
        return 'Yêu cầu mạng thất bại. Vui lòng kiểm tra kết nối.';
      case 'no-such-provider':
        return 'Nhà cung cấp không tồn tại.';
      case 'operation-not-supported-in-this-environment':
        return 'Hoạt động không được hỗ trợ trong môi trường này.';
      case 'popup-blocked':
        return 'Popup đã bị chặn. Vui lòng cho phép popup.';
      case 'popup-closed-by-user':
        return 'Popup đã bị đóng bởi người dùng.';
      case 'redirect-cancelled-by-user':
        return 'Chuyển hướng đã bị hủy bởi người dùng.';
      case 'redirect-operation-pending':
        return 'Đang có hoạt động chuyển hướng khác.';
      case 'rejected-credential':
        return 'Thông tin đăng nhập bị từ chối.';
      case 'second-factor-already-in-use':
        return 'Xác thực hai yếu tố đã được sử dụng.';
      case 'maximum-second-factor-count-exceeded':
        return 'Đã vượt quá số lượng xác thực hai yếu tố cho phép.';
      case 'tenant-id-mismatch':
        return 'ID tenant không khớp.';
      case 'unsupported-first-factor':
        return 'Phương thức xác thực đầu tiên không được hỗ trợ.';
      case 'unsupported-persistence-type':
        return 'Loại lưu trữ không được hỗ trợ.';
      case 'unsupported-tenant-operation':
        return 'Hoạt động không được hỗ trợ cho tenant này.';
      default:
        return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
    }
  }
}
