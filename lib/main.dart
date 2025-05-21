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
import 'package:lacquer/features/chatbot/bloc/chatbot_bloc.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_event.dart';
import 'package:lacquer/features/chatbot/data/chatbot_api_client.dart';
import 'package:lacquer/features/chatbot/data/chatbot_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lacquer/features/profile/data/profile_repository.dart';
import 'package:lacquer/features/profile/bloc/profile_bloc.dart';
import 'package:lacquer/features/profile/bloc/profile_event.dart';

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create:
              (context) => AuthRepository(
                authApiClient: AuthApiClient(dio),
                authLocalDataSource: AuthLocalDataSource(sharedPreferences),
              ),
        ),
        RepositoryProvider(
          create:
              (context) =>
                  ChatbotRepository(chatbotApiClient: ChatbotApiClient(dio)),
        ),
        RepositoryProvider(create: (context) => ProfileRepository(dio: dio)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => ChatbotBloc(context.read<ChatbotRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    ProfileBloc(context.read<ProfileRepository>())
                      ..add(ProfileLoadRequested()),
          ),
        ],
        child: AppContent(),
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
    context.read<ChatbotBloc>().add(ChatbotEventStarted());
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
