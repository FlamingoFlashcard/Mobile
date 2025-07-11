import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_bloc.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_event.dart';
import 'package:lacquer/presentation/pages/auth/forgot_password_page.dart';
import 'package:lacquer/presentation/pages/auth/login_page.dart';
import 'package:lacquer/presentation/pages/auth/verify_page.dart';
import 'package:lacquer/presentation/pages/camera/camera_page.dart';
import 'package:lacquer/presentation/pages/camera/about_screen.dart';
import 'package:lacquer/presentation/pages/home/revise_flashcard_page.dart';
import 'package:lacquer/services/ai_service.dart';
import 'package:lacquer/presentation/pages/home/add_new_word_page.dart';
import 'package:lacquer/presentation/pages/home/edit_card_list_page.dart';
import 'package:lacquer/presentation/pages/home/dictionary_page.dart';
import 'package:lacquer/presentation/pages/home/quiz_page.dart';
import 'package:lacquer/presentation/pages/profile/profile_page.dart';
import 'package:lacquer/presentation/pages/home/flashcard_page.dart';
import 'package:lacquer/presentation/pages/home/learning_flashcard_page.dart';
import 'package:lacquer/presentation/pages/friends/friends_page.dart';
import 'package:lacquer/features/profile/bloc/profile_bloc.dart';
import 'package:lacquer/features/profile/bloc/profile_event.dart';
import 'package:lacquer/presentation/pages/home/translator_page.dart';
import 'package:lacquer/presentation/pages/chat/chat_screen.dart';
import 'package:lacquer/presentation/pages/profile/badge_collection_page_simple.dart';

import 'package:lacquer/presentation/pages/mainscreen.dart';
import 'package:flutter/widgets.dart';

class RouteName {
  static const String home = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String verify = '/verify';
  static const String register = '/register';
  static const String camera = '/camera';
  static const String about = '/about';
  static const String profile = '/profile';
  static const String flashcards = '/flashcards';
  static String learn(String deckId) => '/learn/$deckId';
  static String revise(String deckId) => '/revise/$deckId';
  static String edit(String deckId) => '/edit/$deckId';
  static const String dictionary = '/dictionary';
  static const String translator = '/translator';
  static const String friends = '/friends';
  static const String quiz = '/quiz';
  static String addNewWord(String deckId) => '/add-new-word/$deckId';
  static const String chat = '/chat';
  static const String badges = '/badges';

  static const publicRoutes = [login, forgotPassword, verify, register];
}

GoRoute noTransitionRoute({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
}) {
  return GoRoute(
    path: path,
    pageBuilder:
        (context, state) => NoTransitionPage(child: builder(context, state)),
  );
}

late String? userId;

final router = GoRouter(
  redirect: (context, state) {
    if (RouteName.publicRoutes.contains(state.fullPath)) {
      return null;
    }
    if (context.read<AuthBloc>().state is AuthAuthenticatedSuccess) {
      userId =
          (context.read<AuthBloc>().state as AuthAuthenticatedSuccess).userId;
      context.read<ChatbotBloc>().add(
        ChatbotEventGetHistory(userId: userId ?? ''),
      );
      context.read<ProfileBloc>().add(ProfileLoadRequested());
      return null;
    }
    return RouteName.login;
  },
  routes: [
    noTransitionRoute(
      path: RouteName.home,
      builder: (context, state) => MainScreen(userId: userId ?? ''),
    ),
    noTransitionRoute(
      path: RouteName.login,
      builder: (context, state) => LoginPage(),
    ),
    noTransitionRoute(
      path: RouteName.forgotPassword,
      builder: (context, state) => ForgotPasswordPage(),
    ),
    noTransitionRoute(
      path: RouteName.verify,
      builder: (context, state) => VerifyEmailPage(),
    ),
    noTransitionRoute(
      path: RouteName.camera,
      builder: (context, state) => const CameraPage(),
    ),
    noTransitionRoute(
      path: RouteName.about,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final imagePath = extra['imagePath'] as String;
        final aiResult = extra['aiResult'] as AIResult?;
        return AboutScreen(imagePath: imagePath, aiResult: aiResult);
      },
    ),
    noTransitionRoute(
      path: RouteName.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    noTransitionRoute(
      path: RouteName.flashcards,
      builder: (context, state) => const FlashcardPage(),
    ),
    noTransitionRoute(
      path: RouteName.dictionary,
      builder: (context, state) => const Dictionarypage(),
    ),
    noTransitionRoute(
      path: RouteName.quiz,
      builder: (context, state) => const QuizPage(),
    ),
    noTransitionRoute(
      path: RouteName.friends,
      builder: (context, state) => const FriendsPage(),
    ),
    noTransitionRoute(
      path: '/learn/:deckId',
      builder: (context, state) {
        final deckId = state.pathParameters['deckId']!;
        return LearningFlashcardPage(deckId: deckId);
      },
    ),
    noTransitionRoute(
      path: '/revise/:deckId',
      builder: (context, state) {
        final deckId = state.pathParameters['deckId']!;
        return ReviseFlashcardPage(deckId: deckId);
      },
    ),
    noTransitionRoute(
      path: RouteName.translator,
      builder: (context, state) => const TranslatorScreen(),
    ),
    noTransitionRoute(
      path: '/edit/:deckId',
      builder: (context, state) {
        final deckId = state.pathParameters['deckId']!;
        return EditCardListPage(deckId: deckId);
      },
    ),
    noTransitionRoute(
      path: '/add-new-word/:deckId',
      builder: (context, state) {
        final deckId = state.pathParameters['deckId']!;
        return AddNewWordPage(deckId: deckId);
      },
    ),
    noTransitionRoute(
      path: RouteName.chat,
      builder: (context, state) => const ChatScreen(),
    ),
    noTransitionRoute(
      path: RouteName.badges,
      builder: (context, state) => const BadgeCollectionPage(),
    ),
  ],
);
