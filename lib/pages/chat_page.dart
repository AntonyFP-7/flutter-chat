import 'dart:io';

import 'package:chat/models/mensajes_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focuesNode = FocusNode();

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  bool _estaEscribiendo = false;
  final List<ChatMessage> _messages = [];
  @override
  void initState() {
    super.initState();
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    socketService.socket.on('mensaje-personal', _escucharMensaje);
    _cargarHistorial(chatService.usuarioPara.id);
  }

  void _cargarHistorial(String usuarioId) async {
    List<Mensaje> chat = await chatService.getChat(usuarioId);
    final history = chat.map(
      (m) => ChatMessage(
        texto: m.mensaje,
        iud: m.de,
        animationController: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 0),
        )..forward(),
      ),
    );
    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
      texto: payload["mensaje"],
      iud: payload["de"],
      animationController: AnimationController(
        vsync: this,
        duration: Duration(microseconds: 300),
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final usuarioPara = chatService.usuarioPara;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Column(
          children: [
            CircleAvatar(
              //backgroundColor: Colors.blueAccent,
              maxRadius: 14,
              child: Text(
                usuarioPara.nombre.substring(0, 2),
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(height: 3),
            Text(
              usuarioPara.nombre,
              style: TextStyle(color: Colors.black87, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SizedBox(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
              ),
            ),
            Divider(height: 1),
            Container(color: Colors.white, child: _inputChat()),
          ],
        ),
      ),
    );
  }

  _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (String texto) {
                  setState(() {
                    _estaEscribiendo = texto.trim().isNotEmpty;
                  });
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Enviar mensaje',
                ),
                focusNode: _focuesNode,
              ),
            ),
            //boton de enviar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: _estaEscribiendo
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                      child: Text('Enviar'),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: IconTheme(
                        data: IconThemeData(color: Colors.deepPurple),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed: _estaEscribiendo
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                          icon: Icon(Icons.send),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    if (text.isEmpty) return;
    _textController.clear();
    _focuesNode.requestFocus();
    final newMessage = ChatMessage(
      texto: text,
      iud: authService.usuario.id,
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
      ),
    );
    _messages.insert(0, newMessage);
    newMessage.animationController.forward();
    setState(() {
      _estaEscribiendo = false;
    });
    socketService.emit('mensaje-personal', {
      'de': authService.usuario.id,
      'para': chatService.usuarioPara.id,
      'mensaje': text,
    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    //cuando se sale de la pantalla cerramos la conexion de socket
    socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}
