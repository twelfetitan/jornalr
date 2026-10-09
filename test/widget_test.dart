import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test_app_my/main.dart';
import 'package:flutter_test_app_my/providers/app_state.dart';
import 'package:flutter_test_app_my/services/storage_service.dart';
import 'package:flutter_test_app_my/services/notification_service.dart';
import 'package:flutter_test_app_my/services/holiday_service.dart';
import 'package:flutter_test_app_my/models/holiday.dart';
import 'package:provider/provider.dart';

class MockHolidayService extends HolidayService {
  @override
  Future<List<Holiday>> fetchHolidays(String stateCode, int year) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App builds and mounts smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();
    final notificationService = NotificationService();
    final holidayService = MockHolidayService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>(
            create: (_) => AppState(storageService, notificationService, holidayService),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}

