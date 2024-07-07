import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
    final String? email;
    final bool isEmailVerified;
    const AuthUser({
        required this.email,
        required this.isEmailVerified,
    });

    factory AuthUser.fromFirebase(User user) => AuthUser( //Der Kosntruktor akzeptiert ein Aruguemt vom Typ "User" / Dieser "User" repräsentiert einen authentifizierten Benutzer
            email: user.email,
            isEmailVerified: user.emailVerified,
        );
}
