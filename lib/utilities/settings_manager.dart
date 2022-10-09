import 'package:dome/utilities/app_encryptor.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert' as convert;

import '../devtools/logger.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class SettingsManager {
  static const String _kSettingsFileName = 'dome_settings.json';

  static String _settingsFolder = '';

  static String _lastUser = '';

  // maps a project identifier -> project password
  static Map<String, String> _projectPasswordsCache = {};

  // 0.0=>won't see the background image
  // 1.0=>the background image unmodified
  static const double _defaultScreenBackgroundImageOpacity = 0.8;
  static double _screenBackgroundImageOpacity = _defaultScreenBackgroundImageOpacity;

  static const double _defaultFormScreenBackgroundImageOpacity = 0.5;
  static double _formScreenBackgroundImageOpacity = _defaultFormScreenBackgroundImageOpacity;

  static Future<void> setup() async {
    if (isReady()) return;
    Directory d = await getApplicationDocumentsDirectory();
    _settingsFolder = d.path;
    Logger.print('settings folder: \'$_settingsFolder\' | path: \'${getFilePath()}\'');
    await load();
  }

  static bool isReady() {
    return (_settingsFolder != '');
  }

  static String getFilePath() {
    return '$_settingsFolder/$_kSettingsFileName';
  }

  static String getFolder() {
    return '$_settingsFolder/';
  }

  static void restoreDefaultSettings() {
    _lastUser = '';
  }

  static Map toJson() {
    return {
      '_lastUser': _lastUser,
      '_projectPasswordsCache': _projectPasswordsCache,
      '_screenBackgroundImageOpacity': _screenBackgroundImageOpacity,
      '_formScreenBackgroundImageOpacity': _formScreenBackgroundImageOpacity,
    };
  }

  static void fromJson(dynamic jsonObject) {
    _lastUser = jsonObject['_lastUser'];
    _projectPasswordsCache = Map.castFrom(jsonObject['_projectPasswordsCache']);
    _screenBackgroundImageOpacity = jsonObject.containsKey('_screenBackgroundImageOpacity')
        ? jsonObject['_screenBackgroundImageOpacity']
        : _defaultScreenBackgroundImageOpacity;
    _formScreenBackgroundImageOpacity = jsonObject.containsKey('_formScreenBackgroundImageOpacity')
        ? jsonObject['_formScreenBackgroundImageOpacity']
        : _defaultFormScreenBackgroundImageOpacity;
  }

  static Future<bool> save() async {
    String destFilePath = getFilePath();

    Logger.print('attempting to save settings into \'$destFilePath\' ...');

    try {
      File dest = File(destFilePath);
      await dest.writeAsString(convert.jsonEncode(toJson()), flush: true);
    } catch (e) {
      Logger.print('failed to save settings into \'$destFilePath\' | exception: \'${e.toString()}\'');
      return false;
    }

    Logger.print('saved settings into \'$destFilePath\'');
    return true;
  }

  static Future<bool> load() async {
    String sourceFilePath = getFilePath();

    try {
      File source = File(sourceFilePath);
      String jsonContent = await source.readAsString();
      Logger.print('read settings info from \'$sourceFilePath\' | content:\n$jsonContent\n');

      dynamic decodedJson = convert.jsonDecode(jsonContent);
      // Logger.print('decoded json');

      fromJson(decodedJson);
    } catch (e) {
      Logger.print('failed to load settings info from \'$sourceFilePath\' | exception: \'${e.toString()}\'');
      restoreDefaultSettings();
      return false;
    }

    Logger.print('loaded settings info from \'$sourceFilePath\'');
    return true;
  }

  static String getLastUser() {
    return _lastUser;
  }

  static void setLastUser(String v) {
    _lastUser = v;
  }

  static void storeProjectPassword(String projectId, String projectPassword) {
    if (projectId.isNotEmpty) _projectPasswordsCache[projectId] = AppEncryptor.encryptString(projectPassword);
  }

  static String? getProjectPassword(String projectId) {
    if (projectId.isEmpty) return null;

    try {
      if (_projectPasswordsCache.containsKey(projectId)) {
        return AppEncryptor.decryptString(_projectPasswordsCache[projectId]!);
      }
    } catch (e) {
      // empty
    }

    return null;
  }

  static void setScreenBackgroundImageOpacity(double v) {
    _screenBackgroundImageOpacity = v;
  }

  static double getScreenBackgroundImageOpacity() {
    return _screenBackgroundImageOpacity;
  }

  static void setFormScreenBackgroundImageOpacity(double v) {
    _formScreenBackgroundImageOpacity = v;
  }

  static double getFormScreenBackgroundImageOpacity() {
    return _formScreenBackgroundImageOpacity;
  }
}
