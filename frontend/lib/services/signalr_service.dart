import 'package:signalr_core/signalr_core.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;

  late HubConnection _hubConnection;
  void Function(Map<String, dynamic>)? onDataReceived;
  
  SignalRService._internal() {
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      "http://localhost:5050/systemHub",
      HttpConnectionOptions(logging: (level, message) => print(message)),
    )
        .build();

    _hubConnection.on('receiveStatus', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = Map<String, dynamic>.from(arguments[0]);
        onDataReceived?.call(data);
      }
    });
    _hubConnection.onclose((error) => print("Connection Closed"));
  }
  
  Future<void> startConnection() async {
    if (_hubConnection.state == HubConnectionState.disconnected) {
      await _hubConnection.start();
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
  
  Future<void> updateSudoPassword(String password) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      await _hubConnection.invoke("UpdateSudoPassword", args: [password]);
    }
  }
}
