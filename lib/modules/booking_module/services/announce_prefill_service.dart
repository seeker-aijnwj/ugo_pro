// lib/services/announce_prefill_service.dart
import 'package:u_go/modules/booking_module/models/announce_draft.dart';

class AnnouncePrefillService {
  AnnounceDraft? _draft;
  int? _pendingTabIndex;

  static final AnnouncePrefillService _i = AnnouncePrefillService._();
  AnnouncePrefillService._();
  factory AnnouncePrefillService() => _i;

  void setDraft(AnnounceDraft d) {
    _draft = d;
  }

  AnnounceDraft? takeDraft() {
    final d = _draft;
    _draft = null;
    return d;
  }

  void requestTab(int index) {
    _pendingTabIndex = index;
  }

  int? takePendingTab() {
    final t = _pendingTabIndex;
    _pendingTabIndex = null;
    return t;
  }
}
