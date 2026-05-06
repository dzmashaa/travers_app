import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/models/user_role.dart';
import 'package:travers_app/providers/auth_provider.dart';
import 'package:travers_app/providers/role_provider.dart';
import 'package:travers_app/screens/main_shell.dart';
import 'package:travers_app/utils/app_constants.dart';
import 'package:travers_app/utils/dialog_helpers.dart';
import 'package:travers_app/utils/snackbar_utils.dart';
import 'package:travers_app/widgets/custom_text_field.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.wantsHeadJudgeRole});
  final bool wantsHeadJudgeRole;

  @override
  ConsumerState<AuthScreen> createState() {
    return AuthScreenState();
  }
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        await authService.signIn(email, password);
      } else {
        await authService.signUp(email, password, _nameController.text.trim());
      }

      if (!mounted) return;
      await _handleRoleAndNavigation();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarUtils.show(context, e.toString());
    }
  }

  Future<void> _googleAuth() async {
    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);

    try {
      await authService.signInWithGoogle();
      await _handleRoleAndNavigation();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarUtils.show(context, e.toString());
    }
  }

  Future<void> _handleRoleAndNavigation() async {
    final authService = ref.read(authServiceProvider);

    UserRole existingRole = UserRole.judge;
    try {
      final fetchedRole = await authService.getUserRole();
      if (fetchedRole != null) {
        existingRole = fetchedRole;
      }
    } catch (e) {
      debugPrint('Помилка отримання ролі: $e');
    }

    UserRole finalRole = existingRole;
    bool askForCode = false;
    if (widget.wantsHeadJudgeRole) {
      if (existingRole == UserRole.headJudge) {
        askForCode = false;
      } else {
        askForCode = true;
      }
    }
    if (askForCode && mounted) {
      final isCodeValid = await DialogHelpers.showAccessCodeDialog(
        context,
        title: 'Код організатора',
        message:
            'Введіть спеціальний код для доступу до функцій Головного судді.',
        correctCode: AppConstants.headJudgeAccessCode,
      );

      if (isCodeValid) {
        finalRole = UserRole.headJudge;
      } else {
        finalRole = UserRole.judge;
      }
    }
    try {
      await authService.updateUserRole(
        finalRole,
        fallbackName: _nameController.text.trim(),
      );
    } catch (e) {
      if (mounted) SnackbarUtils.show(context, e.toString(), isError: true);
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    _navigateToCompetitions(finalRole);
  }

  void _navigateToCompetitions(UserRole role) async {
    await ref.read(roleProvider.notifier).setRole(role);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainShell()),
    );
  }

  Future<void> _resetPassword() async {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Відновлення пароля'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Введіть ваш email, і ми надішлемо посилання для скидання пароля.',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: resetEmailController,
                label: 'Електронна пошта',
                icon: Icons.mail_outline,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  SnackbarUtils.show(context, 'Введіть коректний email');
                  return;
                }
                try {
                  Navigator.of(ctx).pop();
                  await ref.read(authServiceProvider).resetPassword(email);
                  if (!mounted) return;
                  SnackbarUtils.show(
                    context,
                    'Посилання для відновлення надіслано!',
                    isError: false,
                  );
                } catch (e) {
                  if (!mounted) return;
                  SnackbarUtils.show(context, e.toString());
                }
              },
              child: const Text('Надіслати'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(child: Text('TS', style: theme.textTheme.titleLarge)),
        ),
        const SizedBox(height: 12),
        Text('TraverScore', style: theme.textTheme.displayMedium),
      ],
    );
  }

  Widget _buildAuthCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                _isLogin ? 'Вхід' : 'Реєстрація',
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 24),
              if (!_isLogin) ...[
                CustomTextField(
                  controller: _nameController,
                  key: const ValueKey('name_field'),
                  label: 'Ім\'я та прізвище',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Будь ласка, введіть ім\'я'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              CustomTextField(
                controller: _emailController,
                key: const ValueKey('email_field'),
                label: 'Електронна пошта',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введіть email';
                  if (!value.contains('@')) return 'Введіть коректний email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                key: const ValueKey('password_field'),
                label: 'Пароль',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) => value != null && value.length < 6
                    ? 'Пароль має бути від 6 символів'
                    : null,
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Забули пароль?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  key: const ValueKey('confirm_password_field'),
                  label: 'Підтвердження паролю',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) => value != _passwordController.text
                      ? 'Паролі не співпадають'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: theme.textTheme.labelLarge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isLogin ? 'Увійти' : 'Зареєструватися'),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: _isLogin
                            ? 'Не маєте акаунту? '
                            : 'Вже маєте акаунт? ',
                      ),
                      TextSpan(
                        text: _isLogin ? 'Зареєструватися' : 'Увійти',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Text('або', style: TextStyle(color: Colors.black45)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _googleAuth,
                icon: Image.asset('assets/search.png', height: 20),
                label: const Text(
                  'Продовжити з Google',
                  style: TextStyle(color: Colors.black87),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 20),
                  _buildAuthCard(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
