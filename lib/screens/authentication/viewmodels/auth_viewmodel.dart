import 'package:admin/data/repositories/user_repository.dart';
import 'package:admin/main.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/routes/name_router.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/routes/seller_router.dart';
import 'package:admin/ultils/local_storage/storage_utilly.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _usermode;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  AuthViewModel() {
    // _initLocalStorage();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool _obscureConfirmPassword = true;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  UserModel? get currentUser => _usermode;

  // Sign in with email and password
  Future<String?> signInWithEmailAndPassword(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        return 'Vui lòng nhập đầy đủ thông tin';
      }

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        final currentUser = userCredential.user;
        final userRepository = UserRepository();
        final userModel = await userRepository.getUserById(currentUser!.uid);
        _usermode = userModel;
        notifyListeners();
        if (userModel != null && userModel.role == Role.sellers) {
          // Check if restaurant info is completed
          final isRestaurantInfoCompleted = await TLocalStorage.instance()
              .readData('restaurant_info_completed_${currentUser.uid}');

          if (isRestaurantInfoCompleted == true || userModel.token.isNotEmpty) {
            GoRouter.of(context).go(SellerRouter.dashboard);
          } else {
            GoRouter.of(context).go(SellerRouter.registerRestaurant);
          }
        } else {
          // For non-seller roles or if userModel is null, go to admin dashboard
          GoRouter.of(context).go(NameRouter.dashboard);
        }
        return null; // Success
      } else {
        return 'Đăng nhập thất bại';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này';
        case 'wrong-password':
          return 'Mật khẩu không chính xác';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'user-disabled':
          return 'Tài khoản đã bị vô hiệu hóa';
        default:
          return 'Đăng nhập thất bại: ${e.message}';
      }
    } catch (e) {
      return 'Có lỗi xảy ra: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register with email and password
  Future<String?> registerWithEmailAndPassword(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (usernameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        return 'Vui lòng nhập đầy đủ thông tin';
      }

      if (passwordController.text != confirmPasswordController.text) {
        return 'Mật khẩu không khớp';
      }

      if (passwordController.text.length < 6) {
        return 'Mật khẩu phải có ít nhất 6 ký tự';
      }

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          email: emailController.text.trim(),
          name: usernameController.text.trim(),
          avatarUrl: '',
          createdAt: DateTime.now(),
          dateOfBirth: null,
          gender: '',
          favorites: [],
          role: Role.sellers,
          phoneNumber: '',
          profilePicture: '',
          token: userCredential.user!.uid,
          addresses: [],
        );

        await UserRepository().saveUser(user);

        // Save the restaurant info completion flag as false
        await TLocalStorage.instance().saveData(
          'restaurant_info_completed_${userCredential.user!.uid}',
          false,
        );

        GoRouter.of(context).go(NameRouter.login);
        return null; // Success
      } else {
        return 'Đăng ký thất bại';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email đã được sử dụng';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'operation-not-allowed':
          return 'Đăng ký tài khoản đã bị vô hiệu hóa';
        case 'weak-password':
          return 'Mật khẩu quá yếu';
        default:
          return 'Đăng ký thất bại: ${e.message}';
      }
    } catch (e) {
      return 'Có lỗi xảy ra: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await FirebaseAuth.instance.signOut();
      navigatorKey.currentState?.pushReplacementNamed(NameRouter.login);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
