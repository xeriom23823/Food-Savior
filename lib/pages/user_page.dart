import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/app/bloc/app_bloc.dart';
import 'package:food_savior/widgets/avatar.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '使用者頁面',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            key: const Key('UserPage_logout_iconButton'),
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              context.read<AppBloc>().add(const AppLogoutRequested());
            },
          ),
        ],
      ),
      body: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Avatar(photo: user.photo),
            const SizedBox(height: 4),
            Text(user.email ?? '', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(user.name ?? '', style: textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
