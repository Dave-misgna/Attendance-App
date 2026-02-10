import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String name;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;
  final VoidCallback? onTap;

  const AttendanceCard({
    super.key,
    required this.name,
    this.selected = false,
    this.onSelectedChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(color: Colors.green.shade500, width: 2)
            : BorderSide(color: Colors.grey.shade300),
      ),
      elevation: selected ? 6 : 2,
      color: selected ? Colors.green.shade50 : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: selected,
                onChanged: onSelectedChanged != null
                    ? (value) {
                        if (value != null) {
                          onSelectedChanged!(value);
                        }
                      }
                    : null,
                activeColor: Colors.green,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Employee name
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.green.shade800 : Colors.black87,
                  ),
                ),
              ),
              
              // Optional green check icon
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
