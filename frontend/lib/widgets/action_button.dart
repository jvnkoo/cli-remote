import 'package:flutter/cupertino.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.enabled,
    required this.onTap,
    required this.text
  });
  final bool enabled;
  final VoidCallback onTap;
  final String text;

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
              child: Text(
                text,
                style: TextStyle(
                  color: enabled ? CupertinoColors.white : CupertinoColors.inactiveGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}