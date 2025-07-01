enum Role { user, sellers, managment, shipper, admin }

enum PaymentMethod {
  qr, // QR code
  banking,
  momo,
  zalopay,
  thanhtoankhinhanhang,
}

enum OrderState {
  pending, // Đơn hàng mới tạo, chờ xác nhận
  confirmed, // Đơn hàng đã được xác nhận bởi nhà hàng
  preparing, // Nhà hàng đang chuẩn bị món
  waitingForShipper, // Đơn hàng đã sẵn sàng, chờ shipper nhận
  shipperAssigned, // Shipper đã nhận đơn
  delivering, // Shipper đang giao hàng
  delivered, // Đơn hàng đã giao thành công
  cancelled,
  ready, // Đơn hàng đã bị hủy
}

enum CategoryFood { pho, banhmi, mi, bun, com, garan, other }

enum PaymentState { pending, confirmed, delivering, cancelled, failed }

enum ShipperStatus { available, busy, inactive }

enum NotificationType { order, promotion, system }
