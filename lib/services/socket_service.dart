import 'package:chat/global/environment.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  Function get emit => _socket.emit;

  IO.Socket get socket => _socket;

  void connect() {
    _socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
    });
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    //socket.on('emitir-mensaje', (payload) {
    // print('nuevo-mensaje');
    // print('nombre:' + payload['nombre']);
    // print(payload.containsKey('mensaje'? payload['mensaje']:'no hay mensaje'))
    //});
  }

  void disconnect() {
    _socket.disconnect();
  }
}
