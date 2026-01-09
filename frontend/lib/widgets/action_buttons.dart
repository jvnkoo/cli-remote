import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.enabled,
    required this.onTap
  });
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5, 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity, 
            height: 50,
            child: ElevatedButton(
              onPressed: enabled ? onTap : null,
              child: const Text('Check System Info'),
            ),
          ),
        ],
      ),
    );
  }
}