import '../core/feedback/feedback_service.dart';
import '../core/storage/key_value_store.dart';
import '../features/game_setup/setup_memory.dart';
import '../features/profile/profile_controller.dart';
import '../features/settings/settings_controller.dart';

/// App-wide services, created once and shared through [AppScope].
class AppServices {
  AppServices({KeyValueStore? store}) : _injectedStore = store {
    feedback = FeedbackService(settings);
  }

  final KeyValueStore? _injectedStore;
  final SettingsController settings = SettingsController();
  final ProfileController profile = ProfileController();
  final SetupMemory setupMemory = SetupMemory();
  late final FeedbackService feedback;

  bool _loaded = false;
  bool _storageFailed = false;

  bool get isLoaded => _loaded;

  /// True when the platform store failed and data will not survive a restart.
  bool get storageFailed => _storageFailed;

  /// Loads preferences and the local profile. Safe to call more than once.
  Future<void> load() async {
    if (_loaded) {
      return;
    }
    KeyValueStore store;
    final injected = _injectedStore;
    if (injected != null) {
      store = injected;
    } else {
      try {
        store = await SharedPrefsStore.open();
      } on Exception {
        store = MemoryStore();
        _storageFailed = true;
      }
    }
    settings.attach(store);
    profile.attach(store, defaultName: settings.strings.you);
    setupMemory.attach(store);
    _loaded = true;
  }
}
