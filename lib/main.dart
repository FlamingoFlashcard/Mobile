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
import 'package:lacquer/features/dictionary/bloc/dictionary_bloc.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_event.dart';
import 'package:lacquer/features/dictionary/data/dictionary_api_clients.dart';
import 'package:lacquer/features/dictionary/data/dictionary_local_data_source.dart';
import 'package:lacquer/features/dictionary/data/dictionary_repository.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/data/flashcard_api_client.dart';
import 'package:lacquer/features/flashcard/data/flashcard_repository.dart';
import 'package:lacquer/features/friendship/bloc/friendship_bloc.dart';
import 'package:lacquer/features/friendship/bloc/friendship_event.dart';
import 'package:lacquer/features/friendship/data/friendship_repository.dart';
import 'package:lacquer/features/post/bloc/post_bloc.dart';
import 'package:lacquer/features/post/bloc/post_event.dart';
import 'package:lacquer/features/post/data/post_repository.dart';
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
        RepositoryProvider(
          create:
              (context) => DictionaryRepository(
                dictionaryApiClients: DictionaryApiClients(dio),
                dictionaryLocalDataSource: DictionaryLocalDataSource(sharedPreferences),
              ), 
        ),
        RepositoryProvider(
          create:
              (context) => FlashcardRepository(
                FlashcardApiClient(dio, AuthLocalDataSource(sharedPreferences)),
              ),
        ),
        RepositoryProvider(create: (context) => FriendshipRepository()),
        RepositoryProvider(create: (context) => PostRepository()),
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
            create: (context) =>
                DictionaryBloc(context.read<DictionaryRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    FriendshipBloc(context.read<FriendshipRepository>()),
          ),
          BlocProvider(
            create: (context) => PostBloc(context.read<PostRepository>()),
          ),
          BlocProvider(
            create:
                (context) => FlashcardBloc(
                  repository: context.read<FlashcardRepository>(),
                )..add(LoadDecksRequested()),
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
    context.read<DictionaryBloc>().add(DictionaryEventStarted());
    context.read<FriendshipBloc>().add(FriendshipEventStarted());
    context.read<PostBloc>().add(PostEventStarted());
    context.read<FlashcardBloc>().add(LoadDecksRequested());
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
