import 'package:flutter/material.dart';

String capitalize(String s) =>
    s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}' : s;

enum FilterType { distance, priceLowToHigh, priceHighToLow, rating }

class FilterBar extends StatelessWidget {
  final Set<FilterType> selectedFilters;
  final ValueChanged<FilterType> onFilterToggled;

  const FilterBar({
    Key? key,
    required this.selectedFilters,
    required this.onFilterToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FilterType.values.map((filter) {
          final isSelected = selectedFilters.contains(filter);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                capitalize(filter.toString().split('.').last),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.primaryColor,
              onSelected: (_) => onFilterToggled(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
