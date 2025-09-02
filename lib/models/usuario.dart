// To parse this JSON data, do
//
//     final usuario = usuarioFromJson(jsonString);

import 'dart:convert';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
    String id;
    String nombre;
    String email;
    bool online;

    Usuario({
        required this.id,
        required this.nombre,
        required this.email,
        required this.online,
    });

    factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json["_id"],
        nombre: json["nombre"],
        email: json["email"],
        online: json["online"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "nombre": nombre,
        "email": email,
        "online": online,
    };
}
