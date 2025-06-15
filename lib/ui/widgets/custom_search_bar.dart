import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;
  final IconData prefixIcon;

  const CustomSearchBar({
    Key? key,
    required this.searchText,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'البحث',
    this.prefixIcon = Icons.search,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: searchText);
    controller.selection = TextSelection.collapsed(offset: controller.text.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: theme.colorScheme.primary,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
          suffixIcon: searchText.isEmpty
              ? null
              : IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.primary),
            onPressed: onClear,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
