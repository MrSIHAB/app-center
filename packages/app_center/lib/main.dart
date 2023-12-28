import 'dart:async';
import 'dart:io';

import 'package:app_center/appstream.dart';
import 'package:app_center/config.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/packagekit.dart';
import 'package:app_center/ratings.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/store.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:packagekit/packagekit.dart';
import 'package:path/path.dart' as p;
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;
import 'package:yaru_widgets/yaru_widgets.dart';

Future<void> main(List<String> args) async {
  await YaruWindowTitleBar.ensureInitialized();
  MediaKit.ensureInitialized();

  final binaryName = p.basename(Platform.resolvedExecutable);
  Logger.setup(
    path: p.join(
      xdg.dataHome.path,
      binaryName,
      '$binaryName.log',
    ),
  );

  final snapd = SnapdService();
  await snapd.loadAuthorization();
  registerServiceInstance(snapd);

  final launcher = PrivilegedDesktopLauncher();
  await launcher.connect();
  registerServiceInstance(launcher);

  final config = ConfigService();
  config.load();

  final ratings = RatingsService(
    RatingsClient(
      config.ratingServiceUrl,
      config.ratingsServicePort,
    ),
  );
  registerServiceInstance(config);
  registerServiceInstance(ratings);

  registerService(GitHub.new);
  registerService(() => GtkApplicationNotifier(args));

  final appstream = AppstreamService();
  // Explicitly ignore the future to continue while appstream is reading the
  // metadata from the disk.
  unawaited(appstream.init());
  registerServiceInstance(appstream);

  registerService(PackageKitClient.new);
  registerService(PackageKitService.new,
      dispose: (service) => service.dispose());

  await initDefaultLocale();

  runApp(const ProviderScope(child: StoreApp()));
}
