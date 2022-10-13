import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../server/server_auth.dart';

import '../utilities/app_encryptor.dart';

import 'dome_project.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class DomeProjectItem extends ChangeNotifier {
  static const int nameMaxLength = 32;

  late DomeProject _project;
  String _name = '';
  DateTime _createDateTimeUTC = DateTime.now().toUtc();
  int _indexHint = -1;

  String _serverId = '';

  bool _dragging = false;
  bool _detailsVisible = false;

  String _author = '';

  DomeProjectItem({required DomeProject project, String itemName = '', String author = ''}) {
    _project = project;
    _name = itemName;
    _createDateTimeUTC = DateTime.now().toUtc();
    _author = author;
  }

  DomeProjectItem.data(
      {required DomeProject project,
      required Map<String, dynamic> data,
      required String projectPassword,
      String serverId = ''}) {
    _project = project;

    String encryptedName = data['name'] ?? '';
    if (encryptedName.isNotEmpty)
      _name = AppEncryptor.decryptPasswordString(encryptedName, projectPassword);
    else
      _name = '';

    String createDateTimeUTCString = data['createDateTimeUTC'] ?? '';
    if (createDateTimeUTCString.isNotEmpty)
      _createDateTimeUTC = DateTime.parse(createDateTimeUTCString);
    else
      _createDateTimeUTC = DateTime.now().toUtc();

    _indexHint = data['indexHint'] ?? -1;

    _author = data['author'] ?? '';

    _serverId = serverId;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _project.notifyListeners();
  }

  bool isDragging() {
    return _dragging;
  }

  void setDragging(bool v) {
    if (_dragging != v) {
      _dragging = v;
      super.notifyListeners();
    }
  }

  bool isDetailsVisible() {
    return _detailsVisible;
  }

  void setDetailsVisible(bool v) {
    if (_detailsVisible != v) {
      _detailsVisible = v;
      super.notifyListeners();
    }
  }

  void toggleDetailsVisible() {
    setDetailsVisible(!_detailsVisible);
  }

  void setProcessing(bool v) {
    if (isProcessing() != v) {
      _project.setProcessing(v);
      super.notifyListeners();
    }
  }

  bool isProcessing() {
    return _project.isProcessing();
  }

  DomeProject getProject() {
    return _project;
  }

  bool isComplete() {
    return false;
  }

  String getName() {
    return _name;
  }

  String getDescription() {
    return '';
  }

  /// only _name is considered content here
  /// this never updates the server in any way
  /// this method is intended to be overridden
  /// notifyListeners should be called by the derived function, it is not called here
  Future<void> updateContent({required DomeProjectItem source, bool updateServer = false}) async {
    _name = source._name;
  }

  DateTime getCreateDateTimeUTC() {
    return _createDateTimeUTC;
  }

  int getIndexHint() {
    return _indexHint;
  }

  void setIndexHint(int v) {
    _indexHint = v;
  }

  String getCreatedDateTimeLocalDescription() {
    DateTime localDate = _createDateTimeUTC.toLocal();

    DateFormat df = DateFormat();
    df.add_yMMMd();
    df.add_jm();

    return 'created ${df.format(localDate)}';
  }

  bool isOwned() {
    return (ServerAuth.getCurrentUserEmail() == _author);
  }

  bool hasAuthor() {
    return _author.isNotEmpty;
  }

  String getAuthor() {
    return _author;
  }

  void setServerId(String serverId) {
    _serverId = serverId;
  }

  String getServerId() {
    return _serverId;
  }
}
