import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/auth_bloc.dart';
import 'app/app_bloc.dart';

export 'auth/auth_bloc.dart';
export 'app/app_bloc.dart';

class ProviderBlocs extends StatelessWidget {
  
  final Widget child;

  const ProviderBlocs({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppBloc()),
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: child
    );
  }
}