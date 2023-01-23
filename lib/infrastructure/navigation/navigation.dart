import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:hookup4u/presentation/settings/view/verifyaccount_widget.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import '../../presentation/settings/view/verifyuploadimage_widget.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  EnvironmentsBadge({required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeScreen(),
      binding: WelcomeControllerBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashControllerBinding(),
    ),
    GetPage(
      name: Routes.AUTH_LOGIN,
      page: () => const AuthLoginScreen(),
      binding: AuthLoginControllerBinding(),
    ),
    GetPage(
      name: Routes.AUTH_REGISTER,
      page: () => const AuthRegisterScreen(),
      binding: AuthRegisterControllerBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardScreen(),
      binding: DashboardControllerBinding(),
    ),
    GetPage(
      name: Routes.DETAILPARTNER,
      page: () => const DetailPartnerScreen(),
      binding: ProfileDetailpartnerControllerBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      binding: ProfileControllerBinding(),
    ),
    GetPage(
      name: Routes.DETAIL,
      page: () => const DetailScreen(),
      binding: ProfileDetailControllerBinding(),
    ),
    GetPage(
      name: Routes.NOTIF,
      page: () => const NotifScreen(),
      binding: NotifControllerBinding(),
    ),
    GetPage(
      name: Routes.AUTH_OTP,
      page: () => const AuthOtpScreen(),
      binding: AuthOtpControllerBinding(),
    ),
    GetPage(
      name: Routes.AUTH_VERIFICATION,
      page: () => AuthVerificationScreen(),
      binding: AuthOtpControllerBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
      binding: SettingsControllerBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_EDIT,
      page: () => ProfileEditScreen(),
      binding: ProfileEditControllerBinding(),
    ),
    GetPage(
      name: Routes.Verify_Upload,
      page: () => const VerifyUploadImageWidget(),
      binding: SettingsControllerBinding(),
    ),
    GetPage(
      name: Routes.Verify_Account,
      page: () => VerifyAccountwidget(),
      binding: SettingsControllerBinding(),
    ),
    GetPage(
      name: Routes.PAYMENT_DETAILS,
      page: () => const PaymentDetailsScreen(),
      binding: PaymentDetailsControllerBinding(),
    ),
    GetPage(
      name: Routes.PAYMENT_SUBCRIPTION,
      page: () => const PaymentSubcriptionScreen(),
      binding: PaymentSubcriptionControllerBinding(),
    ),
    // GetPage(
    //   name: Routes.ROOM,
    //   page: () => const RoomScreen(),
    //   binding: NotifControllerBinding(),
    // ),
    // GetPage(
    //   name: Routes.ROOM_CHAT,
    //   page: () => const RoomChatScreen(),
    //   binding: NotifControllerBinding(),
    // ),
    GetPage(
      name: Routes.NOTIF_VIEW_CHAT,
      page: () => const NotifViewChatScreen(),
      binding: NotifViewChatControllerBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS_VIEW_VERIFIED_PROFILE,
      page: () => const SettingsViewVerifiedProfileScreen(),
      binding: SettingsViewVerifiedProfileControllerBinding(),
    ),
  ];
}
