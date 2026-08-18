import 'package:flutter/material.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_shell.dart';
import '../../screens/ride/create_ride_screen.dart';
import '../../screens/ride/search_ride_screen.dart';
import '../../screens/ride/ride_details_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../models/ride_model.dart';

/// Central place for route names and the `onGenerateRoute` handler.
/// Keeping navigation string constants here avoids typo-driven bugs
/// scattered across the codebase.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createRide = '/create-ride';
  static const String searchRide = '/search-ride';
  static const String rideDetails = '/ride-details';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen());
      case login:
        return _page(const LoginScreen());
      case register:
        return _page(const RegisterScreen());
      case home:
        return _page(const HomeShell());
      case createRide:
        return _page(const CreateRideScreen());
      case searchRide:
        return _page(const SearchRideScreen());
      case rideDetails:
        final ride = settings.arguments as RideModel;
        return _page(RideDetailsScreen(ride: ride));
      case chat:
        final args = settings.arguments as Map<String, String>;
        return _page(ChatScreen(
          chatId: args['chatId']!,
          otherUserName: args['otherUserName']!,
        ));
      case profile:
        return _page(const ProfileScreen());
      case editProfile:
        return _page(const EditProfileScreen());
      default:
        return _page(Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ));
    }
  }

  static MaterialPageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
