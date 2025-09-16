import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apis/auth_api.dart';
import '../utils/snack_bar.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final String username;

  const OtpPage({super.key, required this.email, required this.username});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 300; // 5 minutes countdown (300 seconds)
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOtp() async {
    final otpCode = _getOtpCode();

    if (otpCode.length != 6) {
      showErrorSnackTop(context, 'Please enter all 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthApi.verifyOtp(email: widget.email, otp: otpCode);

      if (!mounted) return;
      showSuccessSnackTop(context, 'Email verified successfully!');
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      showErrorSnackTop(context, message);

      // Clear OTP fields on error
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      await AuthApi.resendOtp(email: widget.email);

      if (!mounted) return;
      showSuccessSnackTop(
        context,
        'OTP sent successfully. Please check your email.',
      );
      _startCountdown();
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      showErrorSnackTop(context, message);
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight > 600 ? 16 : 8),

                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight > 600 ? 20 : 16),

                      // Logo and App Name
                      Column(
                        children: [
                          SizedBox(
                            width: constraints.maxHeight > 600 ? 80 : 60,
                            height: constraints.maxHeight > 600 ? 80 : 60,
                            child: Image.asset(
                              'assets/images/sign_in_up_page/1.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.inventory_2,
                                  color: const Color(0xFF4A90E2),
                                  size: constraints.maxHeight > 600 ? 60 : 45,
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: constraints.maxHeight > 600 ? 12 : 8,
                          ),
                          Text(
                            'Nagav Inventory',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: constraints.maxHeight > 600 ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: constraints.maxHeight > 600 ? 32 : 24),

                      // Verification Title
                      Text(
                        'Email Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: constraints.maxHeight > 600 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight > 600 ? 12 : 8),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'We\'ve sent a 6-digit verification code to\n${widget.email}\n\nThis code will expire in 5 minutes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight > 600 ? 32 : 24),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4A4A4A),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4A4A4A),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4A90E2),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) => _onOtpChanged(index, value),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: constraints.maxHeight > 600 ? 24 : 20),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOtp,
                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: const Color(
                                  0xFF4A90E2,
                                ).withOpacity(0.3),
                              ).copyWith(
                                overlayColor: WidgetStateProperty.all(
                                  Colors.white.withOpacity(0.1),
                                ),
                              ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.verified_user, size: 24),
                                    SizedBox(width: 12),
                                    Text(
                                      'Verify Email',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight > 600 ? 20 : 16),

                      // Resend OTP Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t receive the code? ',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: _countdown > 0 ? null : _resendOtp,
                            child: _isResending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4A90E2),
                                      ),
                                    ),
                                  )
                                : Text(
                                    _countdown > 0
                                        ? 'Resend in ${_formatCountdown(_countdown)}'
                                        : 'Resend OTP',
                                    style: TextStyle(
                                      color: _countdown > 0
                                          ? Colors.grey[600]
                                          : const Color(0xFF4A90E2),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: _countdown > 0
                                          ? TextDecoration.none
                                          : TextDecoration.underline,
                                    ),
                                  ),
                          ),
                        ],
                      ),

                      const Expanded(child: SizedBox(height: 20)),

                      // Help Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Check your spam folder if you don\'t see the email in your inbox.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
