import 'package:signalr_core/signalr_core.dart';

class SignalRService {
  late HubConnection _hubConnection;
  void Function(Map<String, dynamic>)? onDataReceived;

  SignalRService() {
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
}
