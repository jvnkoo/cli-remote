import 'package:flutter/material.dart';
import 'package:frontend/services/signalr_service.dart';
import '../services/api_service.dart';
import '../widgets/action_buttons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  final SignalRService _signalRService = SignalRService();
  String _displayText = "Connecting to Linux";
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _signalRService.onDataReceived = (data) {
      if (mounted) { // Checking whether the user has closed the screen
        setState(() {
          _displayText =
          "OS: ${data['os']} | CPU: ${data['cpu']} | RAM: ${data['ram']}";
        });
      }
    };

    _signalRService.startConnection();
  }
  
  void _fetchInfo() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Linux Remote")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_displayText, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ActionButtons(
              enabled: true,
              onTap: _fetchInfo,
            ),
          ],
        ),
      ),
    );
  }
}