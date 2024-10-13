import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
    final String id; //AuthUser hatte vorher keine ID
    final String? email;
    final bool isEmailVerified;
    const AuthUser({ // das ist eine Instanz von AU / Die Instanz hat zwei requierte Elemente
        required this.id,
        required this.email, // mit "this" holt man sich die Elemente der Basisiklasse (AU von "oben")
        required this.isEmailVerified,
    });

    factory AuthUser.fromFirebase(User user) => AuthUser( //Der Kosntruktor akzeptiert ein Aruguemt vom Typ "User" / Dieser "User" repräsentiert einen authentifizierten Benutzer
            id: user.uid, //unique id
            email: user.email!,
            isEmailVerified: user.emailVerified,
        );
}