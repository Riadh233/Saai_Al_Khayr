import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterChips extends StatefulWidget {
  final List<String> chipLabels;
  final String? initialSelected;
  final ValueChanged<String> onSelected;

  const FilterChips({
    super.key,
    required this.chipLabels,
    required this.onSelected,
    this.initialSelected,
  });

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  late String selectedChip;

  @override
  void initState() {
    super.initState();
    selectedChip = widget.initialSelected ?? widget.chipLabels.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.chipLabels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 5),
          itemBuilder: (_, index) {
            final label = widget.chipLabels[index];
            return InputChip(
              label: Text(label),
              showCheckmark: true,
              selected: selectedChip == label,
              onSelected: (bool selected) {
                setState(() {
                  selectedChip = label;
                });
                widget.onSelected(label);
              },
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }
}
