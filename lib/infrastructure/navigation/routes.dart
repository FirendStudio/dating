class Routes {
  static Future<String> get initialRoute async {
    return SPLASH;
  }

  static const AUTH_LOGIN = '/auth-login';
  static const AUTH_OTP = '/auth-otp';
  static const AUTH_REGISTER = '/auth-register';
  static const AUTH_VERIFICATION = '/auth-verification';
  static const DASHBOARD = '/dashboard';
  static const DETAIL = '/profile-detail';
  static const DETAILPARTNER = '/profile-detailpartner';
  static const HOME = '/home';
  static const NOTIF = '/notif';
  static const NOTIF_VIEW_CHAT = '/notif-view-chat';
  static const PAYMENT_DETAILS = '/payment-details';
  static const PAYMENT_SUBCRIPTION = '/payment-subcription';
  static const PROFILE = '/profile';
  static const PROFILE_EDIT = '/profile-edit';
  static const PROFILE_REPORT = '/profile-report';
  static const ROOM = '/room';
  static const ROOM_CHAT = '/room-chat';
  static const SETTINGS = '/settings';
  static const SPLASH = '/splash';
  static const Verify_Account = '/verify-account';
  static const Verify_Upload = '/verify-upload';
  static const WELCOME = '/welcome';
  static const SETTINGS_VIEW_VERIFIED_PROFILE =
      '/settings-view-verified-profile';
}
