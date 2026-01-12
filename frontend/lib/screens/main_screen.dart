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
  String _displayText = "Connecting to Linux Server...";
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _signalRService.onDataReceived = (data) {
      if (mounted) {
        // Checking whether the user has closed the screen
        setState(() {
          _displayText =
              "OS: ${data['os']} | CPU: ${data['cpu']} | RAM: ${data['ram']}";
        });
      }
    };

    _signalRService.startConnection();
  }

  void _fetchInfo() async {}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Linux Remote"),
        backgroundColor: CupertinoColors.black,
        border: null, 
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              CupertinoListSection.insetGrouped(
                margin: const EdgeInsets.all(16),
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.info),
                    title: Text(
                      _displayText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        Terminal(),
                        const SizedBox(height: 10),
                        Row (
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _isLoading
                                  ? const CupertinoActivityIndicator()
                                  : ActionButton(enabled: true, onTap: _fetchInfo, text: 'stop'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _isLoading
                                  ? const CupertinoActivityIndicator()
                                  : ActionButton(enabled: true, onTap: _fetchInfo, text: 'clear'),
                            ),
                          ],
                        )
                      ]
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
