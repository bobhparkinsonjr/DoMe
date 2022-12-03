import 'package:intl/intl.dart';

import '../devtools/logger.dart';

import '../utilities/app_encryptor.dart';

import '../server/server_project.dart';

import 'dome_project.dart';
import 'dome_project_item.dart';
import 'dome_project_comment.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class DomeProjectTodoItem extends DomeProjectItem {
  static const int descriptionMaxLength = 2048;

  String _description = '';
  bool _complete = false;
  DateTime _completeDateTimeUTC = DateTime.now().toUtc();
  List<DomeProjectComment> _comments = [];

  DateTime _lastCommentCheck = DateTime.utc(2000);
  bool _lastCommentCheckSet = false;

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

    bool retVal = true;

    if (updateServer) {
      setProcessing(true);
      retVal = await ServerProject.createComment(this, domeProjectComment);
      setProcessing(false);
    }

    if (retVal) {
      _comments.add(domeProjectComment);
      sortComments();

      notifyListeners();
    }

    return retVal;
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

  int _getLastCommentCheckElapsedMS() {
    if (!_lastCommentCheckSet) return -1;

    DateTime currentDT = DateTime.now().toUtc();
    Duration elapsed = currentDT.difference(_lastCommentCheck);
    return elapsed.inMilliseconds;
  }

  void _setLastCommentCheckNow() {
    _lastCommentCheck = DateTime.now().toUtc();
    _lastCommentCheckSet = true;
  }

  /// returns true if checked the server and potentially found changes to the comments
  Future<bool> updateClientComments({int maxComments = -1, bool forceUpdate = false}) async {
    if (!forceUpdate && _lastCommentCheckSet && _getLastCommentCheckElapsedMS() < (1000 * 60 * 60 * 1)) {
      // Logger.print('updating client comments | leaving early');
      return false;
    }

    /*
    if (!forceUpdate) {
      Logger.print(
          'updating client comments | _lastCommentCheckSet: ${_lastCommentCheckSet.toString()} | elapsed: ${_getLastCommentCheckElapsedMS()}');
    } else {
      Logger.print('updating client comments | force update is true');
    }
    */

    await ServerProject.updateClientComments(this, maxComments: maxComments);
    _setLastCommentCheckNow();

    notifyListeners();

    return true;
  }

  Future<bool> deleteComment({required DomeProjectComment domeProjectComment, bool updateServer = true}) async {
    String commentId = domeProjectComment.getServerId();

    if (commentId.isEmpty) return false;

    int origLength = _comments.length;
    int i = 0;

    while (i < _comments.length) {
      if (commentId == _comments[i].getServerId()) {
        _comments.removeAt(i);
      } else {
        ++i;
      }
    }

    bool retVal = true;

    if (origLength != _comments.length) {
      if (updateServer) {
        setProcessing(true);
        retVal = await ServerProject.deleteComment(this, domeProjectComment);
        setProcessing(false);
      }

      notifyListeners();
    }

    return retVal;
  }
}
