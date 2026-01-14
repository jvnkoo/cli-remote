import 'package:flutter/cupertino.dart';

class SettingsInputField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final String? label; // Optional label text
  final bool obscureText;
  final IconData? icon;
  final Function(String)? onChanged;

  const SettingsInputField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.label,
    this.obscureText = false,
    this.icon,
    this.onChanged,
  });

  @override
  State<SettingsInputField> createState() => _SettingsInputFieldState();
}

class _SettingsInputFieldState extends State<SettingsInputField> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    // Always enabled if no icon provided
    _isEnabled = widget.icon == null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label display
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 6),
              child: Text(
                widget.label!,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            children: [
              if (widget.icon != null) ...[
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _isEnabled = !_isEnabled),
                  child: Icon(
                    widget.icon,
                    color: _isEnabled ? CupertinoColors.activeGreen : CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: CupertinoTextField(
                  controller: widget.controller,
                  placeholder: widget.placeholder,
                  obscureText: widget.obscureText,
                  enabled: _isEnabled,
                  onChanged: widget.onChanged,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  placeholderStyle: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey.withValues(alpha: 0.5),
                  ),
                  style: TextStyle(
                    color: _isEnabled ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _isEnabled
                        ? CupertinoColors.darkBackgroundGray
                        : CupertinoColors.quaternarySystemFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}