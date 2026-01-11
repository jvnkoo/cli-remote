import 'package:flutter/cupertino.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.enabled,
    required this.onTap,
  });
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1, 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity, 
            height: 50,
            child: CupertinoButton(
              color: enabled
                ? CupertinoColors.tertiarySystemFill
                : CupertinoColors.quaternarySystemFill,
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.zero,
              onPressed: enabled ? onTap : null,
              child: const Text('Check System Info'),
            ),
          ),
        ],
      ),
    );
  }
}