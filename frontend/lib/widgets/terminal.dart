import 'package:flutter/cupertino.dart';
import '../services/signalr_service.dart';

// Simple model to keep history structured
class TerminalEntry {
  final String timestamp;
  final String content;
  TerminalEntry(this.timestamp, this.content);
}

class Terminal extends StatefulWidget {
  const Terminal({super.key});

  @override
  State<Terminal> createState() => TerminalState();
}

class TerminalState extends State<Terminal> {
  final SignalRService _signalRService = SignalRService();
  final List<TerminalEntry> history = [];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

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
    if (command.trim().isEmpty) return;

    _addLog('$_prompt$command');
    _inputController.clear();

    final response = await _signalRService.sendCommand(command, command.startsWith("sudo"));
    if (mounted) _addLog('$_prompt$response');
    _inputFocus.requestFocus();
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
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('> ', style: _terminalStyle),
          Expanded(
            child: CupertinoTextField(
              controller: _inputController,
              focusNode: _inputFocus,
              onSubmitted: _executeCommand,
              decoration: null,
              style: _terminalStyle,
              cursorColor: CupertinoColors.systemGreen,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}