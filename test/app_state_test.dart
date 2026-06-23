import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test_app_my/providers/app_state.dart';
import 'package:flutter_test_app_my/services/storage_service.dart';
import 'package:flutter_test_app_my/services/notification_service.dart';

class MockNotificationService extends NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<void> scheduleDailyReminder(int hour, int minute) async {}
  @override
  Future<void> cancelDailyReminder() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState Tests', () {
    late StorageService storageService;
    late MockNotificationService notificationService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'hourly_rate': 20.0,
        'currency': '€',
        'target_hours': 160.0,
        'work_entries': '{"2026-06-15":8.0,"2026-06-16":6.0}',
      });
      storageService = await StorageService.init();
      notificationService = MockNotificationService();
    });

    test('Initial state values are loaded correctly', () {
      final appState = AppState(storageService, notificationService);
      expect(appState.hourlyRate, 20.0);
      expect(appState.currency, '€');
      expect(appState.targetHours, 160.0);
      expect(appState.getHoursForDate(DateTime(2026, 6, 15)), 8.0);
      expect(appState.getHoursForDate(DateTime(2026, 6, 16)), 6.0);
      expect(appState.getHoursForDate(DateTime(2026, 6, 17)), 0.0);
    });

    test('Setting hours updates values and notifies listeners', () async {
      final appState = AppState(storageService, notificationService);
      bool listenerNotified = false;
      appState.addListener(() {
        listenerNotified = true;
      });

      await appState.setHoursForDate(DateTime(2026, 6, 17), 5.5);
      expect(appState.getHoursForDate(DateTime(2026, 6, 17)), 5.5);
      expect(listenerNotified, true);
    });

    test('Calculations of monthly hours and earnings are correct', () {
      final appState = AppState(storageService, notificationService);
      final june2026 = DateTime(2026, 6, 1);
      
      // Initial: 8.0 + 6.0 = 14.0 hours
      expect(appState.getTotalHoursForMonth(june2026), 14.0);
      expect(appState.getEarningsForMonth(june2026), 280.0); // 14.0 * 20.0
      expect(appState.getMonthlyProgress(june2026), 14.0 / 160.0);
    });

    test('Updating currency and hourly rate works correctly', () async {
      final appState = AppState(storageService, notificationService);
      
      await appState.updateHourlyRate(25.0);
      await appState.updateCurrency(r'$');
      
      expect(appState.hourlyRate, 25.0);
      expect(appState.currency, r'$');
      
      final june2026 = DateTime(2026, 6, 1);
      expect(appState.getEarningsForMonth(june2026), 350.0); // 14.0 * 25.0
    });
  });
}
