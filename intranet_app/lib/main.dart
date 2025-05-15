import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/group_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/home/feed_screen.dart';
import 'views/home/post_creation_screen.dart';
import 'views/home/notification_screen.dart';
import 'views/group/group_list_screen.dart';
import 'views/group/group_detail_screen.dart';
import 'views/profile/user_profile_screen.dart';
import 'views/profile/edit_profile_screen.dart';
import 'views/chat/chat_list_screen.dart';
import 'views/chat/chat_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Enterprise Social',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(key: UniqueKey()),
          '/signup': (context) => SignupScreen(key: UniqueKey()),
          '/home': (context) => FeedScreen(key: UniqueKey()),
          '/create_post': (context) => PostCreationScreen(key: UniqueKey()),
          '/notifications': (context) => NotificationScreen(key: UniqueKey()),
          '/groups': (context) => GroupListScreen(key: UniqueKey()),
          '/group_detail': (context) => GroupDetailScreen(key: UniqueKey()),
          '/profile': (context) => UserProfileScreen(key: UniqueKey()),
          '/edit_profile': (context) => EditProfileScreen(key: UniqueKey()),
          '/chat': (context) => ChatListScreen(),
          '/chat_detail': (context) => ChatDetailScreen(key: UniqueKey()),
        },
      ),
    );
  }
}
