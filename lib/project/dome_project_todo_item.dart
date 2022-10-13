import 'package:intl/intl.dart';

import '../utilities/app_encryptor.dart';

import '../server/server_project.dart';

import 'dome_project.dart';
import 'dome_project_item.dart';
import 'dome_project_comment.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class DomeProjectTodoItem extends DomeProjectItem {
  static const int descriptionMaxLength = 512;

  String _description = '';
  bool _complete = false;
  DateTime _completeDateTimeUTC = DateTime.now().toUtc();
  List<DomeProjectComment> _comments = [];

  DomeProjectTodoItem(
      {required DomeProject project,
      String itemName = '',
      String itemDescription = '',
      bool itemComplete = false,
      String author = ''})
      : super(project: project, itemName: itemName, author: author) {
    _description = itemDescription;
    _complete = itemComplete;
    _completeDateTimeUTC = DateTime.now().toUtc();
  }

  DomeProjectTodoItem.data(
      {required DomeProject project, required Map<String, dynamic> data, required String projectPassword, String serverId = ''})
      : super.data(project: project, data: data, projectPassword: projectPassword, serverId: serverId) {
    String encryptedDescription = data['description'] ?? '';
    if (encryptedDescription.isNotEmpty)
      _description = AppEncryptor.decryptPasswordString(encryptedDescription, projectPassword);
    else
      _description = '';

    _complete = data['complete'] ?? false;

    String completeDateTimeUTCString = data['completeDateTimeUTC'] ?? '';
    if (completeDateTimeUTCString.isNotEmpty)
      _completeDateTimeUTC = DateTime.parse(completeDateTimeUTCString);
    else
      _completeDateTimeUTC = DateTime.now().toUtc();
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

  Future<bool> appendComment({required DomeProjectComment domeProjectComment, bool updateServer = true}) async {
    if (!(domeProjectComment.isValid())) return false;

    if (updateServer) {
      setProcessing(true);
      if (!(await ServerProject.createComment(this, domeProjectComment))) return false;
      setProcessing(false);
    }

    _comments.add(domeProjectComment);
    sortComments();

    notifyListeners();

    return true;
  }

  void clearComments() {
    _comments.clear();
    notifyListeners();
  }

  /// puts the most recent comment first in the list
  void sortComments() {
    _comments.sort((a, b) {
      if (a.getCreateDateTimeUTC().isAfter(b.getCreateDateTimeUTC())) return -1;
      if (b.getCreateDateTimeUTC().isAfter(a.getCreateDateTimeUTC())) return 1;
      return 0;
    });

    notifyListeners();
  }

  List<DomeProjectComment> getComments() {
    return _comments;
  }

  // TODO: deleteComment
}
