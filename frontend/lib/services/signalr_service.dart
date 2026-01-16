import 'package:signalr_core/signalr_core.dart';
import 'package:flutter/foundation.dart';

class SignalRService with ChangeNotifier {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;

  late HubConnection _hubConnection;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Map<String, dynamic>? _lastData;
  Map<String, dynamic>? get lastData => _lastData;

  SignalRService._internal();

  void initConnection(String url) {
    _hubConnection = HubConnectionBuilder()
        .withUrl(url, HttpConnectionOptions(logging: (level, message) => print(message)))
        .withAutomaticReconnect()
        .build();

    _hubConnection.onclose((error) {
      _isConnected = false;
      notifyListeners();
    });

    _hubConnection.onreconnecting((error) {
      _isConnected = false;
      notifyListeners();
    });

    _hubConnection.on('receiveStatus', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _lastData = Map<String, dynamic>.from(arguments[0]);
        notifyListeners();
      }
    });
  }

  Future<void> startConnection() async {
    if (_hubConnection.state == HubConnectionState.disconnected) {
      await _hubConnection.start();
      _isConnected = true;
      notifyListeners();
    }
  }

  Future<void> stopConnection() async {
    if (_hubConnection.state == HubConnectionState.connected) {
      await _hubConnection.stop();
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<String> sendCommand(String commandText, bool useSudo) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      try {
        final String result = await _hubConnection.invoke("ExecuteCli", args: [commandText, useSudo]);
        return result;
      } catch (e) {
        return e.toString();
      }
    }
    return "Connection is not open";
  }

  Future<void> stopCommand() async {
    if (_hubConnection.state == HubConnectionState.connected) {
      try {
        await _hubConnection.invoke("StopCurrentCommand");
      } catch (e) {
        print("Error stopping command: $e");
      }
    }
  }

  Future<void> updateSudoPassword(String password) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      await _hubConnection.invoke("UpdateSudoPassword", args: [password]);
    }
  }

  Future<void> updateConnectionData(String host, String user, String pass) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      await _hubConnection.invoke("UpdateConnectionData", args: [host, user, pass]);
    }
  }
}
