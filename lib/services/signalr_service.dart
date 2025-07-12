// lib/services/signalr_service.dart
import 'package:flutter/foundation.dart';
import 'package:signalr_core/signalr_core.dart';

/// A service to manage SignalR connection and real-time messaging.
class SignalRService {
  late HubConnection _hubConnection;
  final String _hubUrl; // The URL of your SignalR hub (e.g., "http://your-backend-ip/chatHub")

  // Stream to broadcast incoming messages to listeners
  final ValueNotifier<Map<String, dynamic>?> _incomingMessage = ValueNotifier(null);
  ValueListenable<Map<String, dynamic>?> get incomingMessage => _incomingMessage;

  SignalRService(this._hubUrl) {
    _hubConnection = HubConnectionBuilder().withUrl(_hubUrl).build();

    // Listen for connection state changes
    _hubConnection.onclose((error) {
      if (kDebugMode) {
        print("SignalR Connection Closed: $error");
      }
      // You might want to implement auto-reconnect logic here
    });

    // Register a handler for a specific method from the hub (e.g., "ReceiveMessage")
    // This method name must match what your SignalR backend sends.
    _hubConnection.on("ReceiveMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final sender = arguments[0] as String;
        final message = arguments[1] as String;
        final timestamp = arguments[2] as String; // Assuming time is sent as string
        _incomingMessage.value = {
          'sender': sender,
          'message': message,
          'time': timestamp,
        };
        if (kDebugMode) {
          print("Received message: $sender - $message ($timestamp)");
        }
      }
    });
  }

  /// Starts the SignalR connection.
  Future<void> startConnection() async {
    try {
      if (_hubConnection.state != HubConnectionState.connected) {
        await _hubConnection.start();
        if (kDebugMode) {
          print("SignalR Connection Started.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error starting SignalR connection: $e");
      }
    }
  }

  /// Stops the SignalR connection.
  Future<void> stopConnection() async {
    try {
      if (_hubConnection.state == HubConnectionState.connected) {
        await _hubConnection.stop();
        if (kDebugMode) {
          print("SignalR Connection Stopped.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error stopping SignalR connection: $e");
      }
    }
  }

  /// Sends a message to the SignalR hub.
  /// The method name "SendMessage" must match a method on your SignalR backend hub.
  Future<void> sendMessage(String user, String message) async {
    try {
      if (_hubConnection.state == HubConnectionState.connected) {
        await _hubConnection.invoke("SendMessage", args: [user, message, DateTime.now().toIso8601String()]);
        if (kDebugMode) {
          print("Message sent: $user - $message");
        }
      } else {
        if (kDebugMode) {
          print("SignalR not connected. Cannot send message.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
    }
  }

  /// Disposes the hub connection.
  void dispose() {
    _hubConnection.stop();
    _incomingMessage.dispose();
  }
}
