import 'package:flutter/cupertino.dart';

class Terminal extends StatefulWidget {
  const Terminal({super.key});

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  final List<String> _commandHistory = [];
  final TextEditingController _inputController =
      TextEditingController(); // Controls input field
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus =
      FocusNode(); // A focus node that ensures that the keyboard is active and the cursor is in the input field
  static const String _prompt = r'$ '; // raw string

  final TextStyle _terminalStyle = const TextStyle(
    fontFamily: 'Courier',
    color: CupertinoColors.systemGreen,
    fontSize: 14,
  );

  void _executeCommand(String command) {
    if (command.isEmpty || !mounted) return;

    setState(() {
      _commandHistory.add('$_prompt$command');
      _inputController.clear();
    });

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
                  child: Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CupertinoColors.systemGrey.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _commandHistory.length,
                      itemBuilder: (context, index) {
                        return Text(
                          _commandHistory[index],
                          style: _terminalStyle,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Input line
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CupertinoColors.systemGrey.withOpacity(0.65),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(_prompt, style: _terminalStyle),
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
