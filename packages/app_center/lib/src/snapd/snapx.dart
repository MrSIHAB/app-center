import 'package:collection/collection.dart';
import 'package:snapd/snapd.dart';

extension SnapX on Snap {
  String? get iconUrl => media.firstWhereOrNull((m) => m.type == 'icon')?.url;
  bool get verifiedPublisher => publisher?.validation == 'verified';
  List<String> get screenshotUrls =>
      media.where((m) => m.type == 'screenshot').map((m) => m.url).toList();
  bool get starredPublisher => publisher?.validation == 'starred';
  String get titleOrName => title?.orIfEmpty(name) ?? name;
  String? get videoUrl => media.firstWhereOrNull((m) => m.type == 'video')?.url;
}

extension on String {
  String orIfEmpty(String other) => isEmpty ? other : this;
}
