import 'package:flutter/material.dart';
import 'package:travers_app/core/utils/app_decorations.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    required this.icon,
    this.initialValue,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onSaved,
  });

  final TextEditingController? controller;
  final String label;
  final IconData icon;
  final String? initialValue;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  @override
  State<StatefulWidget> createState() {
    return CustomTextFieldState();
  }
}

class CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: widget.initialValue,
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onSaved: widget.onSaved,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),

      decoration:
          AppDecorations.inputField(
            theme: theme,
            label: widget.label,
            icon: widget.icon,
          ).copyWith(
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black38,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
    );
  }
}
