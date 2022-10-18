import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:path/path.dart' as path;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../devtools/logger.dart';

import '../utilities/ref.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ServerAuth {
  /// all extensions listed here are in all lower case, and always start with a dot
  /// this list can be used for the avatar and background images
  static const List<String> graphicSupportedExtensions = ['.jpg', '.png'];

  /// can be used for the avatar and background images
  static const int graphicMaxSizeBytes = 1024 * 1024 * 5; // 5 MB

  static Uint8List _avatarImageBytes = Uint8List(0);
  static Uint8List _backgroundImageBytes = Uint8List(0);

  /// these are paths on the server to the graphic, they end with the graphic name+ext
  static String _avatarImagePath = '';
  static String _backgroundImagePath = '';

  static String _uid = '';
  static String _serverId = '';

  static bool isLoggedIn() {
    if (_uid.isEmpty) return false;
    final user = FirebaseAuth.instance.currentUser;
    return (user != null && user.email != null);
  }

  static String getCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null && user.email != null) return user.email!;
    } catch (e) {
      // empty
    }

    return '';
  }

  static MemoryImage? getCurrentUserAvatar() {
    if (_avatarImageBytes.isEmpty) return null;

    try {
      return MemoryImage(_avatarImageBytes);
    } catch (e) {
      // empty
    }

    return null;
  }

  static MemoryImage? getCurrentUserBackground() {
    if (_backgroundImageBytes.isEmpty) return null;

    try {
      return MemoryImage(_backgroundImageBytes);
    } catch (e) {
      // empty
    }

    return null;
  }

  static Future<Uint8List?> _updateClientImage(String serverImagePath) async {
    if (!(isLoggedIn())) return null;
    if (serverImagePath.isEmpty) return null;

    try {
      final Uint8List? data = await FirebaseStorage.instance.ref().child(serverImagePath).getData(graphicMaxSizeBytes);

      if (data != null) {
        return data;
        // TODO: cache the image to a local file
      }
    } catch (e) {
      // empty
    }

    return null;
  }

  static Future<void> updateClientUserAvatar() async {
    Uint8List? data = await _updateClientImage(_avatarImagePath);
    if (data != null) _avatarImageBytes = data;
  }

  static Future<void> updateClientUserBackground() async {
    Uint8List? data = await _updateClientImage(_backgroundImagePath);
    if (data != null) _backgroundImageBytes = data;
  }

  static Future<void> logOut() async {
    if (!(isLoggedIn())) return;

    Logger.print('attempting to log out');

    try {
      await FirebaseAuth.instance.signOut();
      _uid = '';

      Logger.print('user has been logged out');
    } catch (e) {
      Logger.print('problem signing out | exception: \'${e.toString()}\'');
    }
  }

  /// begins the password reset process, if this returns true then
  /// need to prompt user for code and new password and then call
  /// confirmResetPassword defined below
  static Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      // empty
    }

    return false;
  }

  static Future<bool> confirmResetPassword(String code, String newPassword) async {
    try {
      await FirebaseAuth.instance.confirmPasswordReset(code: code, newPassword: newPassword);
      return true;
    } catch (e) {
      // empty
    }

    return false;
  }

  static Future<bool> createAccount(String email, String password, String avatarFilePath) async {
    try {
      UserCredential uc = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (uc.user == null) return false;
      _uid = uc.user!.uid;
      if (_uid.isEmpty) return false;

      _avatarImagePath = '';

      if (avatarFilePath.isNotEmpty) {
        File imageFile = File(avatarFilePath);
        _avatarImageBytes = await imageFile.readAsBytes();

        String? avatarImagePath =
            await _updateServerGraphicBytes('avatar', path.extension(avatarFilePath).toLowerCase(), _avatarImageBytes);
        if (avatarImagePath != null) _avatarImagePath = avatarImagePath;
      }

      DateTime dt = DateTime.now().toUtc();

      DocumentReference doc = await FirebaseFirestore.instance.collection('users').add({
        'uid': _uid,
        'avatarImagePath': _avatarImagePath,
        'createDateTimeUTC': dt.toString(),
      });

      _serverId = doc.id;

      return true;
    } catch (e) {
      Logger.print('failed to create account | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> logIn(String email, String password) async {
    try {
      UserCredential uc = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (uc.user == null) return false;
      _uid = uc.user!.uid;
      if (_uid.isEmpty) return false;

      return await updateUserInfo();
    } catch (e) {
      Logger.print('failed to log in user | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> updateUserInfo() async {
    if (!(isLoggedIn())) return false;

    try {
      QuerySnapshot<Map<String, dynamic>> v =
          await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: _uid).get();

      if (v.docs.length != 1) return false;

      _serverId = v.docs[0].id;
      _avatarImagePath = v.docs[0].data()['avatarImagePath'] ?? '';
      _backgroundImagePath = v.docs[0].data()['backgroundImagePath'] ?? '';

      await updateClientUserAvatar();
      await updateClientUserBackground();

      return true;
    } catch (e) {
      Logger.print('failed to update user info | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> updateServerUserAvatar(String avatarFilePath) async {
    return await _updateServerUserImage(
        graphicTag: 'avatar',
        imageFilePath: avatarFilePath,
        imageBytes: Ref<Uint8List>(() {
          return _avatarImageBytes;
        }, (Uint8List v) {
          _avatarImageBytes = v;
        }),
        imagePath: Ref<String>(() {
          return _avatarImagePath;
        }, (String v) {
          _avatarImagePath = v;
        }),
        imageFieldName: 'avatarImagePath');
  }

  static Future<bool> updateServerUserBackground(String backgroundFilePath) async {
    return await _updateServerUserImage(
        graphicTag: 'background',
        imageFilePath: backgroundFilePath,
        imageBytes: Ref<Uint8List>(() {
          return _backgroundImageBytes;
        }, (Uint8List v) {
          _backgroundImageBytes = v;
        }),
        imagePath: Ref<String>(() {
          return _backgroundImagePath;
        }, (String v) {
          _backgroundImagePath = v;
        }),
        imageFieldName: 'backgroundImagePath');
  }

  static Future<bool> _updateServerUserImage(
      {required String graphicTag,
      required String imageFilePath,
      required Ref<Uint8List> imageBytes,
      required Ref<String> imagePath,
      required String imageFieldName}) async {
    if (!(isLoggedIn())) return false;
    if (imageFilePath.isEmpty) return false;
    if (_serverId.isEmpty) return false;

    try {
      File imageFile = File(imageFilePath);
      imageBytes.value = await imageFile.readAsBytes();

      String? serverImagePath =
          await _updateServerGraphicBytes(graphicTag, path.extension(imageFilePath).toLowerCase(), imageBytes.value);
      if (serverImagePath == null) return false;

      imagePath.value = serverImagePath;

      bool retVal = false;

      await FirebaseFirestore.instance.collection('users').doc(_serverId).update({imageFieldName: serverImagePath}).then((doc) {
        retVal = true;
      }, onError: (e) {
        Logger.print('failed to update $graphicTag image path | error: ${e.toString()}');
      });

      return retVal;
    } catch (e) {
      Logger.print('failed to update $graphicTag on server | exception: \'${e.toString()}\'');
    }

    return false;
  }

  /// projectId is the server generated unique id for the project
  /// ext should include the dot, such as '.png'
  /// on success, returns the path to the graphic on the server, otherwise returns null
  static Future<String?> _updateServerGraphicBytes(String graphicTag, String ext, Uint8List graphicBytes) async {
    if (!(ServerAuth.isLoggedIn())) return null;
    if (_uid.isEmpty) return null;
    if (!(graphicSupportedExtensions.contains(ext))) return null;
    if (graphicBytes.isEmpty) return null;
    if (graphicBytes.length > graphicMaxSizeBytes) return null;

    try {
      String graphicLocation = 'ProjectImages/$_uid/$graphicTag$ext';

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child(graphicLocation)
          .putData(graphicBytes, SettableMetadata(contentType: 'image/${ext.substring(1)}'));

      await uploadTask;

      if (uploadTask.snapshot.state == TaskState.success) {
        return graphicLocation;
      } else {
        Logger.print('failed to upload the auth graphic | state: ${uploadTask.snapshot.state.name}');
      }
    } catch (e) {
      Logger.print('failed to upload the auth graphic | exception: \'${e.toString()}\'');
    }

    return null;
  }
}
