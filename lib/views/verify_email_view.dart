import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: SingleChildScrollView( //Sorgt dafür, dass man scrollen kann
        child: Column(
          children: [
            const Text("We've sent you an email verification. Please open it to verify your account."),
            const Text("If you haven't received email yet, press the button below."),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
                },
                child: const Text('Send email verification')
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                    const AuthEventLogOut(),
                  );
                },
              child: const Text('Restart'),
            )
          ],
        ),
      ),
    );
  }
}