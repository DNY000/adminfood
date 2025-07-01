import 'package:flutter/material.dart';

/// Extension cho State
extension CommonExtension on State {
  void endEditing() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

/// Extension cho String → ImageProvider?
extension AvatarImageExtension on String {
  ImageProvider? toAvatarImage() {
    if (isEmpty) return null;

    if (startsWith('http://') || startsWith('https://')) {
      return NetworkImage(this);
    }

    if (startsWith('assets/')) {
      return AssetImage(this);
    }

    return null; // fallback mặc định nếu không phải asset hoặc network
  }
}
