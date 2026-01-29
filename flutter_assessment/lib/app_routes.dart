import 'package:get/get.dart';

import 'features/auth/view/page/login_page.dart';
import 'features/auth/view/page/register_page.dart';
import 'features/auth/view/page/reset_password_page.dart';
import 'features/auth/view/page/verify_account_page.dart';
import 'features/home/view/page/home_page.dart';
import 'features/splash/view/page/splash_page.dart';
import 'features/requests/view/page/create_request_page.dart';
import 'features/requests/view/page/request_details_page.dart';
import 'features/requests/view/page/requests_history_page.dart';
import 'features/requests/view/page/requests_list_page.dart';
import 'features/quotations/view/page/quotations_by_request_page.dart';
import 'features/quotations/view/page/quotation_details_page.dart';
import 'features/quotations/view/page/submit_quotation_page.dart';
import 'features/subscriptions/view/page/subscriptions_page.dart';
import 'features/offers/view/page/create_offer_page.dart';
import 'features/offers/view/page/offers_page.dart';
import 'features/offers/view/page/offer_details_page.dart';
import 'features/notifications/view/page/notifications_page.dart';

class AppRoutes {
  static final pages = <GetPage>[
    GetPage(name: SplashPage.route, page: () => const SplashPage()),
    GetPage(name: LoginPage.route, page: () => const LoginPage()),
    GetPage(name: RegisterPage.route, page: () => const RegisterPage()),
    GetPage(
        name: VerifyAccountPage.route, page: () => const VerifyAccountPage()),
    GetPage(
        name: ResetPasswordPage.route, page: () => const ResetPasswordPage()),
    GetPage(name: HomePage.route, page: () => const HomePage()),
    GetPage(name: RequestsListPage.route, page: () => const RequestsListPage()),
    GetPage(
        name: RequestsHistoryPage.route,
        page: () => const RequestsHistoryPage()),
    GetPage(
        name: CreateRequestPage.route, page: () => const CreateRequestPage()),
    GetPage(
        name: RequestDetailsPage.route, page: () => const RequestDetailsPage()),
    GetPage(
        name: QuotationsByRequestPage.route,
        page: () => const QuotationsByRequestPage()),
    GetPage(
        name: QuotationDetailsPage.route,
        page: () => const QuotationDetailsPage()),
    GetPage(
        name: SubmitQuotationPage.route,
        page: () => const SubmitQuotationPage()),
    GetPage(
        name: SubscriptionsPage.route, page: () => const SubscriptionsPage()),
    GetPage(name: OffersPage.route, page: () => const OffersPage()),
    GetPage(name: CreateOfferPage.route, page: () => const CreateOfferPage()),
    GetPage(name: OfferDetailsPage.route, page: () => const OfferDetailsPage()),
    GetPage(
        name: NotificationsPage.route, page: () => const NotificationsPage()),
  ];
}
