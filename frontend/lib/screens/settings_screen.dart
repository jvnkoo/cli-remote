import 'package:flutter/cupertino.dart';
import 'package:frontend/services/signalr_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final SignalRService _signalRService = SignalRService();
  final _storage = const FlutterSecureStorage();
  final TextEditingController _sudoController = TextEditingController();
  bool _lockSudo = false;

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  _lockSudo
                      ? CupertinoIcons.lock_open_fill
                      : CupertinoIcons.lock_fill,
                  color: _lockSudo
                      ? CupertinoColors.activeGreen
                      : CupertinoColors.systemGrey,
                ),
                onPressed: () => setState(() => _lockSudo = !_lockSudo),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoTextField(
                  controller: _sudoController,
                  placeholder: "Sudo Password",
                  placeholderStyle: TextStyle(
                    fontSize: 14,
                    color: _lockSudo
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey.withValues(alpha: 0.3),
                  ),
                  obscureText: true,
                  enabled: _lockSudo,
                  style: TextStyle(
                    color: _lockSudo ? CupertinoColors.white : CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _lockSudo
                        ? CupertinoColors.darkBackgroundGray
                        : CupertinoColors.quaternarySystemFill, 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onChanged: _saveSudoPassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
