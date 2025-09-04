import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatMessage extends StatelessWidget {
  final String texto;
  final String iud;
  final AnimationController animationController;
  const ChatMessage({
    super.key,
    required this.texto,
    required this.iud,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final authServide = Provider.of<AuthService>(context);
    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
        child: Container(
          child: iud == authServide.usuario.id
              ? _myMessage()
              : _notMayMessage(),
        ),
      ),
    );
  }

  _myMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 5, left: 50, right: 5),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xff4D9EF6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(texto, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  _notMayMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 5, left: 5, right: 50),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xffE4E5E8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(texto, style: TextStyle(color: Colors.black87)),
      ),
    );
  }
}
