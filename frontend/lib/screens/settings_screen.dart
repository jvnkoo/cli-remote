import 'package:flutter/cupertino.dart';
import 'package:frontend/services/signalr_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/settings_input_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final SignalRService _signalRService = SignalRService();
  final _storage = const FlutterSecureStorage();

  final TextEditingController _sudoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSudoPassword();
  }

  Future<void> _loadSudoPassword() async {
    String? savedPass = await _storage.read(key: 'sudo_password');
    if (savedPass != null) {
      _sudoController.text = savedPass;
      _signalRService.updateSudoPassword(savedPass);
    }
  }

  Future<void> _saveSudoPassword(String value) async {
    await _storage.write(key: 'sudo_password', value: value);
    _signalRService.updateSudoPassword(value);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Column(
            children: [
              ),
              SettingsInputField(
                label: "Security",
                controller: _sudoController,
                placeholder: "Sudo Password",
                icon: CupertinoIcons.lock_fill,
                obscureText: true,
                onChanged: (val) => _saveSudoPassword(val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
