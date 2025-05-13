import 'package:lacquer/config/http_client.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_event.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';
import 'package:lacquer/features/auth/data/auth_api_client.dart';
import 'package:lacquer/features/auth/data/auth_local_data_source.dart';
import 'package:lacquer/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/data/flashcard_api_client.dart';
import 'package:lacquer/features/flashcard/data/flashcard_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  final sf = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sf));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create:
          (context) => AuthRepository(
            authApiClient: AuthApiClient(dio),
            authLocalDataSource: AuthLocalDataSource(sharedPreferences),
          ),
      child: Builder(
        builder: (context) {
          final authRepository = context.read<AuthRepository>();
          final authLocalDataSource = AuthLocalDataSource(sharedPreferences);
          final flashcardApiClient = FlashcardApiClient(
            dio,
            authLocalDataSource,
          );
          final flashcardRepository = FlashcardRepository(flashcardApiClient);

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create:
                    (context) =>
                        AuthBloc(authRepository)
                          ..add(AuthAuthenticateStarted()),
              ),
              BlocProvider(
                create:
                    (context) =>
                        FlashcardBloc(repository: flashcardRepository)
                          ..add(const LoadDecksRequested()),
              ),
            ],
            child: const AppContent(),
          );
        },
      ),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthAuthenticateStarted());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthInitial) {
      return Container();
    }
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
