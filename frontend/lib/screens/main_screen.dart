import 'package:flutter/cupertino.dart';
import 'package:frontend/services/signalr_service.dart';
import '../services/api_service.dart';
import '../widgets/action_button.dart';
import '../widgets/terminal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  final SignalRService _signalRService = SignalRService();
  final GlobalKey<TerminalState> _terminalKey = GlobalKey<TerminalState>();

  String _displayText = "Server Disconnected.";
  bool _isConnecting = true;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _signalRService.onDataReceived = (data) {
      if (mounted) {
        // Checking whether the user has closed the screen
        setState(() {
          _isConnecting = false;
          _displayText =
              "OS: ${data['os']} | CPU: ${data['cpu']} | RAM: ${data['ram']}";
        });
      }
    };

    _signalRService.onConnectionSuccess = () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _displayText = "Connected. Waiting for data...";
        });
      }
    };

    _signalRService.onConnectionLost = () {
      if (mounted) {
        setState(() {
          _isConnecting = true;
          _displayText = "Server Disconnected. Retrying...";
        });
      }
    };
  }

  void _fetchInfo() async {}

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
        child: Expanded(
          child: Column(
            // Removed Center, it can interfere with Expanded
            children: [
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsets.all(16),
                children: [
                  CupertinoListTile(
                    leading: _isConnecting
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
                  child: Terminal(key: _terminalKey),
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
                              enabled: true,
                              onTap: _fetchInfo,
                              text: 'stop',
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _isLoading
                          ? const CupertinoActivityIndicator()
                          : ActionButton(
                              enabled: true,
                              onTap: _clearHistory,
                              text: 'clear',
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
