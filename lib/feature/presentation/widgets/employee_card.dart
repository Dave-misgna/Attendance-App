import 'package:flutter/material.dart';

class EmployeeCard extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;
  const EmployeeCard({super.key, required this.name, this.onTap,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          
        ),
        elevation: 4,
        color:  Colors.green.shade50 ,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 12),
                
                // Employee name
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
