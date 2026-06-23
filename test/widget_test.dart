import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test_app_my/main.dart';
import 'package:flutter_test_app_my/providers/app_state.dart';
import 'package:flutter_test_app_my/services/storage_service.dart';
import 'package:flutter_test_app_my/services/notification_service.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App builds and mounts smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();
    final notificationService = NotificationService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>(
            create: (_) => AppState(storageService, notificationService),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
