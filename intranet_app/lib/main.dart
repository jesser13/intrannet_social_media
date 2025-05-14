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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
          '/login': (_) => LoginScreen(),
          '/signup': (_) => SignupScreen(),
          '/home': (_) => FeedScreen(),
          '/create_post': (_) => PostCreationScreen(),
          '/notifications': (_) => NotificationScreen(),
          '/groups': (_) => GroupListScreen(),
          '/group_detail': (_) => GroupDetailScreen(),
          '/profile': (_) => UserProfileScreen(),
          '/edit_profile': (_) => EditProfileScreen(),
          '/chat': (_) => ChatListScreen(),
          '/chat_detail': (_) => ChatDetailScreen(),
        },
      ),
    );
  }
}