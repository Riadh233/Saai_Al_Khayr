import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final String value;
  final String? errorText;
  final void Function(String) onChanged;
  final IconData icon;
  final bool obscureText;
  final bool passwordMode;
  final void Function()? onHidePassword;

  const CustomTextInput({
    super.key,
    required this.hintText,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.icon = Icons.person,
    this.obscureText = false,
    this.passwordMode = false,
    this.onHidePassword
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    final theme = Theme.of(context);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: TextInputType.text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        suffixIcon: passwordMode ? IconButton(
          onPressed: () {
            onHidePassword!();
          },
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        ) : null,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blueGrey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}
