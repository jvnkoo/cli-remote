import 'package:flutter/cupertino.dart';
import 'package:frontend/services/signalr_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/action_button.dart';
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
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _connect() async {
    final url = _urlController.text;

    if (url.isEmpty) {
      print("Error: URL is empty");
      return;
    }

    try {
      _signalRService.initConnection(url);

      await _signalRService.startConnection();

      await _syncConnectionData();

      print("Successfully connected to $url");
    } catch (e) {
      print("Connection failed: $e");
    }
  }
  
  Future<void> _disconnect() async {
    await _signalRService.stopConnection();
  }

  Future<void> _syncConnectionData() async {
    final host = _hostController.text;
    final user = _userController.text;
    final pass = _passController.text;

    if (host.isNotEmpty && user.isNotEmpty && pass.isNotEmpty) {
      await _signalRService.updateConnectionData(host, user, pass);
    }
  }

  Future<void> _loadAllSettings() async {
    final sudo = await _storage.read(key: 'sudo_password') ?? '';
    final host = await _storage.read(key: 'host_address') ?? '';
    final user = await _storage.read(key: 'username') ?? '';
    final pass = await _storage.read(key: 'password') ?? '';
    final url = await _storage.read(key: 'url') ?? '';

    setState(() {
      _sudoController.text = sudo;
      _hostController.text = host;
      _userController.text = user;
      _passController.text = pass;
      _urlController.text = url;
    });
  }

  Future<void> _saveSudoPassword(String value) async {
    await _storage.write(key: 'sudo_password', value: value);
    _signalRService.updateSudoPassword(value);
  }

  Future<void> _saveHostAddress(String value) async {
    await _storage.write(key: 'host_address', value: value);
  }

  Future<void> _saveURL(String value) async {
    await _storage.write(key: 'url', value: value);
  }

  Future<void> _saveUsername(String value) async {
    await _storage.write(key: 'username', value: value);
  }

  Future<void> _savePassword(String value) async {
    await _storage.write(key: 'password', value: value);
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
              SettingsInputField(
                label: "Host Address",
                controller: _hostController,
                placeholder: "127.0.0.1",
                onChanged: (val) async {
                  await _saveHostAddress(val);
                  _syncConnectionData(); 
                },
              ),
              SettingsInputField(
                label: "URL",
                controller: _urlController,
                placeholder: "http://localhost:5050/systemHub",
                onChanged: (val) => _saveURL(val),
              ),
              SizedBox(height: 12),
              SettingsInputField(
                label: "Linux Username",
                controller: _userController,
                placeholder: "username",
                onChanged: (val) async {
                  await _saveUsername(val);
                  _syncConnectionData();
                },
              ),
              SettingsInputField(
                label: "Linux Password",
                controller: _passController,
                placeholder: "password",
                obscureText: true,
                onChanged: (val) async {
                  await _savePassword(val);
                  _syncConnectionData();
                },
              ),
              SizedBox(height: 12),
              SettingsInputField(
                label: "sudo",
                controller: _sudoController,
                placeholder: "Sudo Password",
                icon: CupertinoIcons.lock_fill,
                obscureText: true,
                onChanged: (val) => _saveSudoPassword(val),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ActionButton(enabled: true, onTap: _connect, text: 'Connect'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ActionButton(enabled: true, onTap: _disconnect, text: 'Disconnect'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
