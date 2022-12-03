import 'package:package_info_plus/package_info_plus.dart';

import '../devtools/logger.dart';

class AppInfo {
  static String _appName = '';
  static String _packageName = '';
  static String _version = '';
  static String _buildNumber = '';
  static String _buildDate = 'Dec 3, 2022';

  static Future<void> setup() async {
    if (_appName.isEmpty) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    }
  }

  static String getAppName() {
    return _appName;
  }

  static String getPackageName() {
    return _packageName;
  }

  static String getVersion() {
    return _version;
  }

  static String getBuildNumber() {
    return _buildNumber;
  }

  static String getDisplayVersion() {
    return '$_version.$_buildNumber';
  }

  static String getBuildDate() {
    return _buildDate;
  }

  static void log() {
    Logger.print('app info | name: $_appName | package: $_packageName | version: $_version | build: $_buildNumber');
  }
}
