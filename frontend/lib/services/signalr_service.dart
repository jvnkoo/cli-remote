import 'package:signalr_core/signalr_core.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;

  late HubConnection _hubConnection;
  void Function(Map<String, dynamic>)? onDataReceived;
  Function()? onConnectionLost;
  Function()? onConnectionSuccess;

  SignalRService._internal();

  void initConnection(String url) {
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      url,
      HttpConnectionOptions(logging: (level, message) => print(message)),
    )
        .withAutomaticReconnect()
        .build();

    _hubConnection.onclose((error) {
      print("Connection lost. Error: $error");
      onConnectionLost?.call();
    });

    _hubConnection.onreconnecting((error) {
      print("Reconnecting...");
      onConnectionLost?.call();
    });

    _hubConnection.on('receiveStatus', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = Map<String, dynamic>.from(arguments[0]);
        onDataReceived?.call(data);
      }
    });
  }

  Future<void> startConnection() async {
    if (_hubConnection.state == HubConnectionState.disconnected) {
      await _hubConnection.start();
      onConnectionSuccess?.call();
    }
  }
  
  Future<void> stopConnection() async {
    if (_hubConnection.state == HubConnectionState.connected) {
      await _hubConnection.stop();
      onConnectionLost?.call();
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
