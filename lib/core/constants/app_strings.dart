/// Centralized user-facing strings. Keeping these here makes future
/// localization (intl / .arb files) a drop-in change rather than a
/// find-and-replace across the whole codebase.
class AppStrings {
  AppStrings._();

  static const String appName = 'CampusRide';
  static const String tagline = 'Share rides. Save money. Ride safe.';

  // Auth
  static const String login = 'Log In';
  static const String register = 'Create Account';
  static const String email = 'University Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String studentId = 'Student ID';
  static const String university = 'University';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account? ";
  static const String haveAccount = 'Already have an account? ';

  // Home / Navigation
  static const String home = 'Home';
  static const String search = 'Search';
  static const String myRides = 'My Rides';
  static const String chat = 'Chat';
  static const String profile = 'Profile';

  // Rides
  static const String createRide = 'Post a Ride';
  static const String searchRides = 'Find a Ride';
  static const String startingLocation = 'Starting Location';
  static const String destination = 'Destination';
  static const String departureTime = 'Departure Time';
  static const String availableSeats = 'Available Seats';
  static const String costPerSeat = 'Cost per Seat';
  static const String joinRide = 'Join Ride';
  static const String rideDetails = 'Ride Details';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noInternet = 'No internet connection.';
  static const String noRidesFound = 'No rides found for this route.';
}
