import 'package:flutter/cupertino.dart';
import 'package:frontend/services/signalr_service.dart';
import '../services/api_service.dart';
import '../widgets/action_button.dart';
import '../widgets/terminal.dart';

class MainScreen extends StatefulWidget {
  final bool isConnecting;

  const MainScreen({super.key, required this.isConnecting});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  final SignalRService _signalRService = SignalRService();
  final GlobalKey<TerminalState> _terminalKey = GlobalKey<TerminalState>();

  String _displayText = "Server Disconnected.";
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _signalRService.addListener(_onServiceNotify);
  }

  @override
  void dispose() {
    _signalRService.removeListener(_onServiceNotify);
    super.dispose();
  }

  void _onServiceNotify() {
    if (!mounted) return;

    final data = _signalRService.lastData;
    setState(() {
      if (!_signalRService.isConnected) {
        _displayText = "Server Disconnected. Retrying...";
      } else if (data != null) {
        _displayText =
            "OS: ${data['os']} | CPU: ${data['cpu']} | RAM: ${data['ram']}";
      } else {
        _displayText = "Connected. Waiting for data...";
      }
    });
  }

  void _handleStop() async {
    await _signalRService.stopCommand();
    _terminalKey.currentState?.forceUnlock();
  }

  void _clearHistory() {
    _terminalKey.currentState?.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // Added backgroundColor to match terminal look
      backgroundColor: CupertinoColors.black,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "Cli Remote",
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: CupertinoColors.black,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          // Removed Center, it can interfere with Expanded
          children: [
            CupertinoListSection.insetGrouped(
              margin: const EdgeInsets.all(16),
              children: [
                CupertinoListTile(
                  leading: widget.isConnecting
                      ? const CupertinoActivityIndicator()
                      : const Icon(CupertinoIcons.info),
                  title: Text(
                    _displayText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            // Use Expanded so the Terminal takes up all remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Terminal(
                  key: _terminalKey,
                  enabled: !widget.isConnecting,
                ),
              ),
            ),
            // Bottom buttons area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _isLoading
                        ? const CupertinoActivityIndicator()
                        : ActionButton(
                            enabled: !widget.isConnecting,
                            onTap: _handleStop,
                            text: 'Stop',
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _isLoading
                        ? const CupertinoActivityIndicator()
                        : ActionButton(
                            enabled: !widget.isConnecting,
                            onTap: _clearHistory,
                            text: 'Clear',
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
