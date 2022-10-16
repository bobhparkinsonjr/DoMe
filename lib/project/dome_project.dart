import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert' as convert;
import 'dart:typed_data';
import 'package:path/path.dart' as path;

import '../devtools/logger.dart';

import '../utilities/settings_manager.dart';

import '../server/server_auth.dart';
import '../server/server_project.dart';

import 'dome_project_item.dart';
import 'dome_project_todo_item.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

enum DomeProjectType {
  none,
  todo,
  // valueCollection,
}

///////////////////////////////////////////////////////////////////////////////////////////////////

class DomeProject extends ChangeNotifier {
  static const int nameMaxLength = 32;
  static const int graphicMaxSizeBytes = 1024 * 1024 * 5; // 5 MB

  /// the min comments to show in details should be zero
  static const int maxDetailsTotalLatestComments = 10;

  /// all extensions listed here are in all lower case, and always start with a dot
  static const List<String> graphicSupportedExtensions = ['.jpg', '.png'];

  String _name = '';
  String _owner = '';
  DomeProjectType _type = DomeProjectType.none;
  String _password = '';
  Uint8List _graphicBytes = Uint8List(0);
  String _graphicPath = '';
  DateTime _createDateTimeUTC = DateTime.now().toUtc();
  List<DomeProjectItem> _items = [];
  int _detailsTotalLatestComments = 0;

  String _projectPasswordCheck = '';

  String _serverId = '';

  bool _processing = false;

  DomeProject(
      {String name = '',
      String owner = '',
      DomeProjectType type = DomeProjectType.none,
      String password = '',
      Uint8List? graphicBytes,
      String graphicPath = '',
      String projectPasswordCheck = '',
      int detailsTotalLatestComments = 0}) {
    _name = name;
    _owner = owner;
    _type = type;
    _password = password;
    if (graphicBytes != null) _graphicBytes = graphicBytes;
    _graphicPath = graphicPath;
    _projectPasswordCheck = projectPasswordCheck;
    _detailsTotalLatestComments = detailsTotalLatestComments;
  }

  DomeProject.data({required Map<String, dynamic> data, String serverId = ''}) {
    _name = data['projectName'] ?? '';
    _owner = data['owner'] ?? '';

    String projectTypeName = data['projectType'] ?? '';
    if (projectTypeName.isNotEmpty)
      _type = DomeProjectType.values.firstWhere((e) => e.name == projectTypeName);
    else
      _type = DomeProjectType.none;

    _graphicPath = data['projectGraphicPath'] ?? '';
    _projectPasswordCheck = data['projectPasswordCheck'] ?? '';

    _detailsTotalLatestComments = data['detailsTotalLatestComments'] ?? 0;

    String createDateTimeUTCString = data['createDateTimeUTC'] ?? '';
    if (createDateTimeUTCString.isNotEmpty)
      _createDateTimeUTC = DateTime.parse(createDateTimeUTCString);
    else
      _createDateTimeUTC = DateTime.now().toUtc();

    String? projectPassword = SettingsManager.getProjectPassword(serverId);

    if (projectPassword != null) {
      _password = projectPassword;
    } else {
      Logger.print('project password for project \'$_name\' not found');
    }

    // Logger.print('create date time utc: ${_createDateTimeUTC.toString()} | is utc: ${(_createDateTimeUTC.isUtc ? "true" : "false")}');

    _serverId = serverId;
  }

  bool isValid() {
    if (_name.isEmpty) return false;
    if (_owner.isEmpty) return false;
    if (_type == DomeProjectType.none) return false;
    if (_projectPasswordCheck.isEmpty) return false;

    return true;
  }

  /// only the following are considered content here:
  ///   name
  ///   password
  ///   graphic
  ///   detailsTotalLatestComments
  Future<bool> updateContent({required DomeProject source, bool updateServer = false}) async {
    bool modified = false;

    if (source._name.isNotEmpty) {
      _name = source._name;
      modified = true;
    }

    if (source._password.isNotEmpty) {
      _password = source._password;
      _projectPasswordCheck = ServerProject.generateProjectPasswordCheck(_password);
      modified = true;
    }

    if (source._graphicBytes.isNotEmpty && source._graphicPath.isNotEmpty) {
      _graphicBytes = source._graphicBytes;
      _graphicPath = source._graphicPath;
      modified = true;
    }

    if (source._detailsTotalLatestComments >= 0 && source._detailsTotalLatestComments != _detailsTotalLatestComments) {
      _detailsTotalLatestComments = source._detailsTotalLatestComments;
      modified = true;
    }

    bool retVal = true;

    if (modified) {
      if (updateServer) {
        retVal = await ServerProject.updateServerProjectContent(this);
      }

      notifyListeners();
    }

    return retVal;
  }

  void setProcessing(bool v) {
    if (_processing != v) {
      _processing = v;
      notifyListeners();
    }
  }

  bool isProcessing() {
    return _processing;
  }

  int getDetailsTotalLatestComments() {
    return _detailsTotalLatestComments;
  }

  void setDetailsTotalLatestComments(int v) {
    if (_detailsTotalLatestComments != v) {
      _detailsTotalLatestComments = v;
      notifyListeners();
    }
  }

  void setCreateDateTimeUTC(DateTime dt) {
    _createDateTimeUTC = dt;
    if (!(_createDateTimeUTC.isUtc)) _createDateTimeUTC = _createDateTimeUTC.toUtc();
  }

  /// this method does not update the server
  void appendItem(DomeProjectItem item) {
    _items.add(item);
    item.setIndexHint(_items.length - 1);

    notifyListeners();
  }

  /// this will insert the item using the item's index hint
  /// this method does not update the server
  /// a new index hint will only be generated for item if item currently doesn't have a valid index hint
  void insertItem(DomeProjectItem item) {
    int indexHint = item.getIndexHint();

    // Logger.print('inserting item \'${item.getName()}\' with index hint $indexHint');

    if (indexHint < 0) {
      appendItem(item);
      return;
    }

    if (indexHint >= _items.length) {
      _items.add(item);
    } else {
      _items.insert(indexHint, item);
    }

    notifyListeners();
  }

  /// sort items using the index hints
  /// this method does not update the server
  void sortItems() {
    // Logger.print('sorting items in project using index hints');

    int total = _items.length;

    _items.sort((a, b) {
      int ai = a.getIndexHint();
      int bi = b.getIndexHint();
      if (ai < 0 || ai >= total) return 1;
      if (bi < 0 || bi >= total) return 1;
      return (ai - bi);
    });

    /*
    for (int i = 0; i < total; ++i) {
      Logger.print('todo item \'${_items[i].getName()}\' at index \'$i\' with index hint \'${_items[i].getIndexHint()}\'');
    }
    */

    // Logger.print('done sorting items in project');

    notifyListeners();
  }

  Future<void> moveItem({required int oldIndex, required int newIndex, bool updateServer = false}) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Logger.print('move item | old index: $oldIndex | new index: $newIndex');

    DomeProjectItem item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    item.setIndexHint(newIndex);

    for (int i = oldIndex; i < _items.length; ++i) {
      _items[i].setIndexHint(i);
    }

    if (updateServer) {
      setProcessing(true);
      await ServerProject.updateServerTodoItemIndexHints(this);
      setProcessing(false);
    }

    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    notifyListeners();
  }

  void clearDragging() {
    for (DomeProjectItem item in _items) item.setDragging(false);
  }

  Future<bool> appendTodoItem({required DomeProjectTodoItem item, bool updateServer = true}) async {
    item.setIndexHint(_items.length);

    if (updateServer) {
      setProcessing(true);
      if (!(await ServerProject.createTodoItem(this, item))) {
        return false;
      }

      // Logger.print('updated server with new item');
      setProcessing(false);
    }

    // Logger.print('adding new item to project');
    _items.add(item);
    notifyListeners();
    return true;
  }

  Future<bool> deleteTodoItem({required DomeProjectTodoItem item, bool updateServer = true}) async {
    int itemIndex = findItemIndex(item);

    if (itemIndex < 0) return false;

    _items.removeAt(itemIndex);

    bool retVal = true;

    if (updateServer) {
      setProcessing(true);

      if (!(await ServerProject.deleteTodoItem(item))) {
        retVal = false;
      }

      setProcessing(false);
    }

    notifyListeners();
    return retVal;
  }

  DomeProjectItem getItem(int index) {
    return _items[index];
  }

  DomeProjectItem? getItemByName(String name) {
    for (DomeProjectItem item in _items) {
      if (name == item.getName()) return item;
    }

    return null;
  }

  int findItemIndex(DomeProjectItem item) {
    for (int i = 0; i < _items.length; ++i) {
      if (_items[i] == item) return i;
    }

    return -1;
  }

  int getTotalItems() {
    return _items.length;
  }

  String getName() {
    return _name;
  }

  String getOwner() {
    return _owner;
  }

  /// returns true if current auth user owns this project
  bool isOwned() {
    return (ServerAuth.getCurrentUserEmail() == _owner);
  }

  String getPassword() {
    return _password;
  }

  Future<bool> setPassword(String password) async {
    if (_projectPasswordCheck.isNotEmpty) {
      String origPassword = _password;
      _password = password;

      if (ServerProject.isProjectPasswordValid(this)) {
        SettingsManager.storeProjectPassword(getServerId(), _password);
        await SettingsManager.save();

        return true;
      }

      _password = origPassword;
    }

    return false;
  }

  String getProjectPasswordCheck() {
    return _projectPasswordCheck;
  }

  DateTime getCreateDateTimeUTC() {
    return _createDateTimeUTC;
  }

  String getCreatedDateTimeLocalDescription() {
    DateTime localDate = _createDateTimeUTC.toLocal();

    DateFormat df = DateFormat();
    df.add_yMMMd();
    df.add_jm();

    return 'created ${df.format(localDate)}';
  }

  DomeProjectType getProjectType() {
    return _type;
  }

  int getTotalCompleteItems() {
    int count = 0;

    for (DomeProjectItem item in _items) {
      if (item.isComplete()) ++count;
    }

    return count;
  }

  String getProjectCountStatus() {
    switch (_type) {
      case DomeProjectType.todo:
        return '${getTotalCompleteItems()}/${getTotalItems()} complete';

      default:
        // empty
        break;
    }

    int total = getTotalItems();

    if (total == 1) return '1 item';

    return '$total items';
  }

  /// this will grab the latest graphic from the server
  Future<bool> updateGraphicImage({bool forceUpdate = false}) async {
    if (!forceUpdate && _graphicBytes.isNotEmpty) return true;
    if (_graphicPath.isEmpty) return false;
    _graphicBytes = await ServerProject.getProjectGraphicImageBytes(_graphicPath);
    return _graphicBytes.isNotEmpty;
  }

  /// includes dir+name+ext
  /// the dir is the server style directory (doesn't necessarily include a volume/drive)
  String getGraphicPath() {
    return _graphicPath;
  }

  /// name+ext
  String getGraphicName() {
    return path.basename(_graphicPath);
  }

  /// includes dot, always in all lower case
  String getGraphicExt() {
    return path.extension(_graphicPath).toLowerCase();
  }

  Uint8List getGraphicBytes() {
    return _graphicBytes;
  }

  MemoryImage? getGraphicImage() {
    if (_graphicBytes.isEmpty) return null;

    try {
      return MemoryImage(_graphicBytes);
    } catch (e) {
      // empty
    }

    return null;
  }

  void toggleDetailsVisible() {
    if (_type == DomeProjectType.todo) {
      int total = _items.length;

      if (total > 0) {
        DomeProjectTodoItem firstItem = _items[0] as DomeProjectTodoItem;
        firstItem.toggleDetailsVisible();
        bool detailsVisible = firstItem.isDetailsVisible();

        for (int i = 1; i < total; ++i) {
          DomeProjectTodoItem item = _items[i] as DomeProjectTodoItem;
          item.setDetailsVisible(detailsVisible);
        }
      }
    }
  }

  void setServerId(String serverId) {
    _serverId = serverId;
  }

  String getServerId() {
    return _serverId;
  }

  static String getProjectTypeName(DomeProjectType v) {
    switch (v) {
      case DomeProjectType.todo:
        return "Todo List";

      // case DomeProjectType.valueCollection:
      //   return "Value Collection List";

      default:
        // empty
        break;
    }

    return '';
  }

  static String getProjectTypeDescription(DomeProjectType v) {
    switch (v) {
      case DomeProjectType.todo:
        return "A simple list of things to do.";

      // case DomeProjectType.valueCollection:
      //   return "This is a list of items, where each item is a collection of numerical values you wish to track over time.  For example, you could track a balance owed.  Another example, you could track your body weight.";

      default:
        // empty
        break;
    }

    return '';
  }
}
