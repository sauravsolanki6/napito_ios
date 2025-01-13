// lib/round_checkbox.dart

import 'package:flutter/material.dart';

class RoundCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  RoundCheckbox({required this.value, required this.onChanged});

  @override
  _RoundCheckboxState createState() => _RoundCheckboxState();
}

class _RoundCheckboxState extends State<RoundCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.value ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: widget.value
            ? Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
