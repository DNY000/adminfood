class TPlatformException implements Exception {
  TPlatformException(this.code);
  final String code;

  String get message {
    switch (code) {
      case 'sign_in_canceled':
        return 'Đăng nhập bị hủy bỏ bởi người dùng.';
      case 'sign_in_required':
        return 'Đăng nhập là bắt buộc để hoàn thành thao tác này.';
      case 'invalid-argument':
        return 'An invalid argument was provided. Please check your input.';
      case 'permission-denied':
        return 'Không có quyền truy cập. Bạn không có quyền truy cập vào tài nguyên này.';
      case 'timeout':
        return 'Yêu cầu không được thực hiện. Vui lòng thử lại sau.';
      case 'failed-precondition':
        return 'Operation failed due to an unmet precondition.';
      case 'not-found':
        return 'Tài nguyên được yêu cầu không được tìm thấy.';
      case 'unauthenticated':
        return 'Cần đăng nhập. Vui lòng đăng nhập và thử lại.';
      case 'unavailable':
        return 'Dịch vụ hiện không khả dụng. Vui lòng thử lại sau.';
      case 'already-exists':
        return 'The resource already exists.';
      case 'data-loss':
        return 'Mất dữ liệu. Vui lòng liên hệ hỗ trợ.';
      case 'network-error':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      case 'server-error':
        return 'Lỗi máy chủ. Vui lòng thử lại sau.';
      case 'invalid-response':
        return 'Phản hồi không hợp lệ từ máy chủ.';
      case 'parse-error':
        return 'Lỗi phân tích dữ liệu. Vui lòng thử lại.';
      case 'connection-timeout':
        return 'Kết nối quá thời gian chờ. Vui lòng thử lại.';
      case 'socket-error':
        return 'Lỗi kết nối socket. Vui lòng thử lại.';
      case 'ssl-error':
        return 'Lỗi SSL. Vui lòng kiểm tra chứng chỉ.';
      case 'host-not-found':
        return 'Không tìm thấy máy chủ. Vui lòng kiểm tra kết nối.';
      case 'connection-refused':
        return 'Kết nối bị từ chối. Vui lòng thử lại sau.';
      case 'connection-reset':
        return 'Kết nối bị reset. Vui lòng thử lại.';
      case 'no-internet':
        return 'Không có kết nối internet. Vui lòng kiểm tra kết nối.';
      case 'dns-error':
        return 'Lỗi DNS. Vui lòng kiểm tra kết nối.';
      case 'proxy-error':
        return 'Lỗi proxy. Vui lòng kiểm tra cấu hình proxy.';
      case 'certificate-error':
        return 'Lỗi chứng chỉ. Vui lòng kiểm tra chứng chỉ.';
      case 'handshake-error':
        return 'Lỗi bắt tay SSL. Vui lòng thử lại.';
      case 'protocol-error':
        return 'Lỗi giao thức. Vui lòng thử lại.';
      case 'unsupported-operation':
        return 'Hoạt động không được hỗ trợ trên nền tảng này.';
      case 'platform-version-unsupported':
        return 'Phiên bản nền tảng không được hỗ trợ.';
      case 'device-not-supported':
        return 'Thiết bị không được hỗ trợ.';
      case 'feature-not-available':
        return 'Tính năng không khả dụng trên thiết bị này.';
      case 'storage-full':
        return 'Bộ nhớ đầy. Vui lòng giải phóng bớt dung lượng.';
      case 'battery-low':
        return 'Pin yếu. Vui lòng sạc pin.';
      case 'location-disabled':
        return 'Dịch vụ vị trí đã bị tắt. Vui lòng bật lại.';
      case 'camera-disabled':
        return 'Quyền truy cập camera đã bị tắt. Vui lòng bật lại.';
      case 'microphone-disabled':
        return 'Quyền truy cập microphone đã bị tắt. Vui lòng bật lại.';
      case 'storage-permission-denied':
        return 'Quyền truy cập bộ nhớ bị từ chối. Vui lòng cấp quyền.';
      case 'location-permission-denied':
        return 'Quyền truy cập vị trí bị từ chối. Vui lòng cấp quyền.';
      case 'camera-permission-denied':
        return 'Quyền truy cập camera bị từ chối. Vui lòng cấp quyền.';
      case 'microphone-permission-denied':
        return 'Quyền truy cập microphone bị từ chối. Vui lòng cấp quyền.';
      default:
        return 'Lỗi không xác định. Vui lòng thử lại.';
    }
  }
}
