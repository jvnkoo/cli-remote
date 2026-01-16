import 'package:flutter/cupertino.dart';
import '../services/signalr_service.dart';

// Simple model to keep history structured
class TerminalEntry {
  final String timestamp;
  final String content;
  TerminalEntry(this.timestamp, this.content);
}

class Terminal extends StatefulWidget {
  final bool enabled;
  const Terminal({super.key, required this.enabled});

  @override
  State<Terminal> createState() => TerminalState();
}

class TerminalState extends State<Terminal> {
  final SignalRService _signalRService = SignalRService();
  final List<TerminalEntry> history = [];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  bool _isProcessing = false;

  static const _prompt = '\n~ ❯ ';
  static const _terminalStyle = TextStyle(
    fontFamily: 'Courier',
    color: CupertinoColors.systemGreen,
    fontSize: 14,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inputFocus.requestFocus());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void clearHistory() {
    setState(() {
      history.clear();
    });
  }

  void _addLog(String text) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    setState(() {
      history.add(TerminalEntry(timeStr, text));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _executeCommand(String command) async {
    if (command.trim().isEmpty || _isProcessing) return;

    setState(() => _isProcessing = true);
    _addLog('$_prompt$command');
    _inputController.clear();

    try {
      final response = await _signalRService.sendCommand(command, command.startsWith("sudo"));

      if (mounted && _isProcessing) {
        _addLog('$_prompt$response');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        _inputFocus.requestFocus();
      }
    }
  }

  void forceUnlock() {
    if (!_isProcessing) return;

    setState(() => _isProcessing = false);
    _addLog('\n[Terminated]');

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _inputFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.black,
      child: GestureDetector(
        onTap: () => _inputFocus.requestFocus(),
        child: Column(
          children: [
            Expanded(child: _buildHistoryList()),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: history.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${history[i].timestamp} ',
                style: _terminalStyle.copyWith(fontSize: 10, color: CupertinoColors.systemGrey),
              ),
              TextSpan(text: history[i].content, style: _terminalStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    final Color currentColor = widget.enabled
        ? CupertinoColors.systemGreen
        : CupertinoColors.systemGrey;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: currentColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('> ', style: _terminalStyle.copyWith(color: currentColor)),
          Expanded(
            child: CupertinoTextField(
              enabled: widget.enabled && !_isProcessing,
              controller: _inputController,
              focusNode: _inputFocus,
              onSubmitted: _executeCommand,
              decoration: null,
              style: _terminalStyle.copyWith(color: currentColor),
              cursorColor: currentColor,
              padding: EdgeInsets.zero,
              placeholder: widget.enabled ? null : "Connecting...",
              placeholderStyle: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontFamily: 'Courier',
                  fontSize: 14
              ),
            ),
          ),
        ],
      ),
    );
  }
}