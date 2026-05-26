import 'package:flutter/material.dart';
import 'package:travers_app/core/utils/app_decorations.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final void Function(String?)? onSaved;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.onSaved,
    this.hint,
    this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.isPassword = false,
  }) : assert(
         initialValue == null || controller == null,
         'Не можна передавати initialValue та controller одночасно',
       );

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var decoration = AppDecorations.inputField(
      theme: theme,
      hint: widget.hint ?? '',
      icon: widget.icon,
      alignLabelWithHint: widget.maxLines > 1,
    );

    if (widget.isPassword) {
      decoration = decoration.copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade500,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            widget.label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          onSaved: widget.onSaved,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          obscureText: _obscureText,

          style: theme.textTheme.titleMedium,

          decoration: decoration,
        ),
      ],
    );
  }
}
