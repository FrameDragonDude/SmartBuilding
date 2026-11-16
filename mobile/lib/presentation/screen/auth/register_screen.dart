import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/theme/app_color.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeTerms = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (!_agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đồng ý với Điều khoản sử dụng'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      context.read<AuthCubit>().register(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Đăng Ký Cư Dân",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else if (state is AuthSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.tertiary,
                    ),
                  );
                  Navigator.pop(context); // Go back to login
                }
              },
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header notice
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.secondary, size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Tài khoản cư dân sẽ được tự động kết nối với dịch vụ Smart Building sau khi xác thực.",
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      _buildTextField(
                        label: "Họ và tên",
                        hint: "Nhập họ và tên đầy đủ",
                        icon: Icons.person_outline,
                        controller: _fullNameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập họ và tên" : null,
                      ),

                      _buildTextField(
                        label: "Số điện thoại",
                        hint: "Nhập số điện thoại chính chủ",
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập số điện thoại" : null,
                      ),

                      _buildTextField(
                        label: "Địa chỉ Email",
                        hint: "Nhập email liên hệ",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Vui lòng nhập email";
                          if (!v.contains('@')) return "Email không hợp lệ";
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: "Tên đăng nhập",
                        hint: "Tạo tên đăng nhập (viết liền không dấu)",
                        icon: Icons.account_circle_outlined,
                        controller: _usernameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng tạo tên đăng nhập" : null,
                      ),

                      _buildTextField(
                        label: "Mật khẩu",
                        hint: "Nhập mật khẩu (tối thiểu 6 ký tự)",
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Vui lòng nhập mật khẩu";
                          if (v.length < 6) return "Mật khẩu phải từ 6 ký tự trở lên";
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: "Xác nhận mật khẩu",
                        hint: "Nhập lại mật khẩu",
                        icon: Icons.lock_reset_outlined,
                        controller: _confirmPasswordController,
                        isPassword: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (v) {
                          if (v != _passwordController.text) return "Mật khẩu xác nhận không khớp";
                          return null;
                        },
                      ),

                      // Terms agreement checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreeTerms,
                              activeColor: AppColors.secondary,
                              onChanged: (val) {
                                setState(() {
                                  _agreeTerms = val ?? true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Tôi đồng ý với Quy định Cư dân & Điều khoản dịch vụ Smart Building",
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: state is AuthLoading ? null : () => _onRegister(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "ĐĂNG KÝ TÀI KHOẢN",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Login Footer Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Đã có tài khoản? ",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Đăng nhập ngay",
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
