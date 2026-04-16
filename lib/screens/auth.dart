import 'package:flutter/material.dart';
import 'package:travers_app/models/user_role.dart';
import 'package:travers_app/screens/competitions.dart';
import 'package:travers_app/widgets/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.wantsHeadJudgeRole});
  final bool wantsHeadJudgeRole;

  @override
  State<StatefulWidget> createState() {
    return AuthScreenState();
  }
}

class AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = false;
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

  void _submit() async {
    /*     final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Коректно заповніть виділені поля та повторіть спробу'),
        ),
      );
      return;
    } */
    if (!_formKey.currentState!.validate()) {
      return;
    }
    //Firebase
    setState(() {
      _isLoading = true;
    });

    // 2. Імітуємо запит до сервера (потім тут буде Firebase)
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (widget.wantsHeadJudgeRole) {
      _showCodeDialog();
      //_navigateToCompetitions(UserRole.headJudge);
    } else {
      _navigateToCompetitions(UserRole.judge);
    }
  }

  void _showCodeDialog() {
    _codeController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Код організатора'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Введіть спеціальний код для доступу до функцій Головного судді.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'Введіть код...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToCompetitions(UserRole.judge);
              },
              child: const Text('Продовжити як Суддя'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_codeController.text.trim() == '1234') {
                  Navigator.of(context).pop();
                  _navigateToCompetitions(UserRole.headJudge);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Невірний код! Спробуйте ще раз.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Підтвердити'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCompetitions(UserRole role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompetitionsScreen(userRole: role),
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
                  const SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text('TS', style: theme.textTheme.titleLarge),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('TraverScore', style: theme.textTheme.displayMedium),
                  const SizedBox(height: 20),

                  Card(
                    margin: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: Colors.white,
                    elevation: 2,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                _isLogin ? 'Вхід' : 'Реєстрація',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (!_isLogin) ...[
                                CustomTextField(
                                  controller: _nameController,
                                  label: 'Ім\'я та прізвище',
                                  icon: Icons.person_outline,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Будь ласка, введіть ім\'я'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                              ],

                              CustomTextField(
                                controller: _emailController,
                                label: 'Електронна пошта',
                                icon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Введіть email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Введіть коректний email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                controller: _passwordController,
                                label: 'Пароль',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validator: (value) =>
                                    value != null && value.length < 6
                                    ? 'Пароль має бути від 6 символів'
                                    : null,
                              ),
                              if (_isLogin)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      minimumSize: Size.zero,
                                    ),
                                    child: Text(
                                      'Забули пароль?',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.black54),
                                    ),
                                  ),
                                ),
                              if (!_isLogin) ...[
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Підтвердження паролю',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Паролі не співпадають';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              SizedBox(
                                width: 250,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.secondary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
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
                                      : Text(
                                          _isLogin
                                              ? 'Увійти'
                                              : 'Зареєструватися',
                                        ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
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
                                        text: _isLogin
                                            ? 'Зареєструватися'
                                            : 'Увійти',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const Text(
                                'або',
                                style: TextStyle(color: Colors.black45),
                              ),
                              const SizedBox(height: 8),

                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/search.png',
                                  height: 20,
                                ),
                                label: const Text(
                                  'Увійти через Google',
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
