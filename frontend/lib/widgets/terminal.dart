import 'package:flutter/cupertino.dart';
import '../services/signalr_service.dart';

class Terminal extends StatefulWidget {
  const Terminal({super.key});

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  final SignalRService _signalRService = SignalRService();
  final List<String> _commandHistory = [];
  final TextEditingController _inputController =
      TextEditingController(); // Controls input field
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus =
      FocusNode(); // A focus node that ensures that the keyboard is active and the cursor is in the input field
  static const String _prompt = '\n~ ❯ ';
  static const String _inputPrompt = r'> ';

  final TextStyle _terminalStyle = const TextStyle(
    fontFamily: 'Courier',
    color: CupertinoColors.systemGreen,
    fontSize: 14,
  );

  void _executeCommand(String command) async {
    if (command.isEmpty || !mounted) return;
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    setState(() {
      // Save with separator for better parse
      _commandHistory.add('$timeStr|$_prompt$command');
      _inputController.clear();
    });
    
    final String result = await _signalRService.sendCommand(command);
    
    if (mounted) {
      setState(() {
        _commandHistory.add('$timeStr|$_prompt$result');
      });
    }

    // Wait for the frame with the new line to finish rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      _inputFocus.requestFocus();
    });
  }

  @override
  void initState() {
    super.initState();
    // Ensure initial focus happens safely
    Future.microtask(() {
      if (mounted) {
        _inputFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    // Clear any pending async operations
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight.isInfinite
              ? 550
              : constraints.maxHeight,
          color: CupertinoColors.black,
          child: GestureDetector(
            onTap: () {
              if (mounted) {
                _inputFocus.requestFocus();
              }
            },
            child: Column(
              children: [
                // Command history display
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _commandHistory.length,
                    itemBuilder: (context, index) {
                      final entry = _commandHistory[index];
                      final parts = entry.split('|');
                      final time = parts[0];
                      final command = parts.length > 1 ? parts[1] : '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              // time
                              TextSpan(
                                text: '$time ',
                                style: _terminalStyle.copyWith(
                                  fontSize: 10, 
                                  color: CupertinoColors.systemGrey, 
                                ),
                              ),
                              // main command
                              TextSpan(
                                text: command,
                                style: _terminalStyle, 
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Input line
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CupertinoColors.systemGrey.withValues(alpha: 0.65),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(_inputPrompt, style: _terminalStyle),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _inputController,
                          focusNode: _inputFocus,
                          autofocus: false,
                          // We handle focus manually
                          onSubmitted: _executeCommand,
                          decoration: null,
                          style: _terminalStyle,
                          cursorColor: CupertinoColors.systemGreen,
                          padding: EdgeInsets.zero,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
