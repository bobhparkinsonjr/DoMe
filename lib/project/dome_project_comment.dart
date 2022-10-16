import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../devtools/logger.dart';

import '../utilities/app_encryptor.dart';
import '../utilities/timestamp_tools.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class DomeProjectComment extends ChangeNotifier {
  static const int messageMaxLength = 512;

  String _commentMessage = '';
  DateTime _createDateTimeUTC = DateTime.now().toUtc();
  String _author = '';

  String _serverId = '';

  DomeProjectComment({required String commentMessage, required String author}) {
    _commentMessage = commentMessage;
    _createDateTimeUTC = DateTime.now().toUtc();
    _author = author;
  }

  DomeProjectComment.data({required Map<String, dynamic> data, required String projectPassword, String serverId = ''}) {
    _commentMessage = data['commentMessage'] ?? '';
    if (_commentMessage.isNotEmpty) _commentMessage = AppEncryptor.decryptPasswordString(_commentMessage, projectPassword);

    _createDateTimeUTC = TimestampTools.convertTimestampUTC(data['createTimestampUTC'] ?? Timestamp.now());

    _author = data['author'] ?? '';

    _serverId = serverId;
  }

  bool isValid() {
    return (_commentMessage.isNotEmpty && _author.isNotEmpty);
  }

  String getCommentMessage() {
    return _commentMessage;
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
