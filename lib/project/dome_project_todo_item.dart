import 'package:intl/intl.dart';

import '../utilities/app_encryptor.dart';

import '../server/server_project.dart';

import 'dome_project.dart';
import 'dome_project_item.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class DomeProjectTodoItem extends DomeProjectItem {
  static const int descriptionMaxLength = 256;

  String _description = '';
  bool _complete = false;
  DateTime _completeDateTimeUTC = DateTime.now().toUtc();

  DomeProjectTodoItem(
      {required DomeProject project, String itemName = '', String itemDescription = '', bool itemComplete = false})
      : super(project: project, itemName: itemName) {
    _description = itemDescription;
    _complete = itemComplete;
    _completeDateTimeUTC = DateTime.now().toUtc();
  }

  DomeProjectTodoItem.data(
      {required DomeProject project, required Map<String, dynamic> data, required String projectPassword, String serverId = ''})
      : super.data(project: project, data: data, projectPassword: projectPassword, serverId: serverId) {
    _description = AppEncryptor.decryptPasswordString(data['description'], projectPassword);
    _complete = data['complete'];
    _completeDateTimeUTC = DateTime.parse(data['completeDateTimeUTC']);
  }

  @override
  bool isComplete() {
    return _complete;
  }

  Future<void> toggleComplete({bool updateServer = false}) async {
    _complete = !_complete;
    if (_complete) _completeDateTimeUTC = DateTime.now().toUtc();

    if (updateServer) {
      setProcessing(true);
      await ServerProject.updateServerTodoItemCompleteStatus(getProject(), this);
      setProcessing(false);
    }

    notifyListeners();
  }

  @override
  String getDescription() {
    return _description;
  }

  @override
  Future<void> updateContent({required DomeProjectItem source, bool updateServer = false}) async {
    super.updateContent(source: source);

    DomeProjectTodoItem sourceTodoItem = source as DomeProjectTodoItem;

    if (sourceTodoItem != null) {
      _description = sourceTodoItem._description;
    }

    if (updateServer) {
      setProcessing(true);
      await ServerProject.updateServerTodoItemContent(getProject(), this);
      setProcessing(false);
    }

    notifyListeners();
  }

  DateTime getCompleteDateTimeUTC() {
    return _completeDateTimeUTC;
  }

  String getCompleteDateTimeLocalDescription() {
    DateTime localDate = _completeDateTimeUTC.toLocal();

    DateFormat df = DateFormat();
    df.add_yMMMd();
    df.add_jm();

    return 'completed ${df.format(localDate)}';
  }

  Future<bool> deleteTodoItem({bool updateServer = true}) async {
    bool retVal = await getProject().deleteTodoItem(item: this, updateServer: updateServer);
    return retVal;
  }
}
