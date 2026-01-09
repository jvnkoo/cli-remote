import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/action_buttons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  String _displayText = "No data yet";
  bool _isLoading = false;

  void _fetchInfo() async {
    setState(() => _isLoading = true);

    final result = await _apiService.getSystemInfo();

    setState(() {
      _displayText = "OS: ${result['os'] ?? 'N/A'} | CPU: ${result['cpu'] ?? 'N/A'}";
      _isLoading = false;
    });
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