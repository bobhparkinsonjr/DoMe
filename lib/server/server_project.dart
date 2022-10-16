import 'dart:io';
import 'dart:convert' as convert;
import 'dart:typed_data';
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../devtools/logger.dart';

import '../project/dome_project.dart';
import '../project/dome_project_item.dart';
import '../project/dome_project_todo_item.dart';
import '../project/dome_project_comment.dart';

import '../utilities/password_validator.dart';
import '../utilities/app_encryptor.dart';
import '../utilities/settings_manager.dart';
import '../utilities/ref.dart';
import '../utilities/timestamp_tools.dart';

import 'server_auth.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ServerProject {
  static const String _passwordCheckString = 'DoMe project password check';

  /// on success, a new DomeProject is returned and is stored on the server
  /// on failure, null will be returned
  static Future<DomeProject?> createProject(
      {required String projectName,
      required String projectPassword,
      required DomeProjectType projectType,
      String graphicFilePath = ''}) async {
    try {
      if (projectName.isEmpty) return null;
      if (PasswordValidator.validate(projectPassword) != PasswordValidateType.valid) return null;
      if (projectType == DomeProjectType.none) return null;

      String owner = ServerAuth.getCurrentUserEmail();

      if (owner.isEmpty) return null;

      QuerySnapshot<Map<String, dynamic>> v = await FirebaseFirestore.instance
          .collection('projects')
          .where('owner', isEqualTo: owner)
          .where('projectName', isEqualTo: projectName)
          .limit(1)
          .get();

      if (v.docs.isNotEmpty) return null;

      String projectGraphicPath = '';
      Uint8List projectGraphicBytes = Uint8List(0);

      if (graphicFilePath.isNotEmpty) {
        try {
          File imageFile = File(graphicFilePath);

          int imageFileSizeBytes = await imageFile.length();

          if (imageFileSizeBytes <= DomeProject.graphicMaxSizeBytes) {
            projectGraphicPath = path.basename(graphicFilePath); // name+ext
            String ext = path.extension(graphicFilePath).toLowerCase();

            if (DomeProject.graphicSupportedExtensions.contains(ext)) {
              projectGraphicBytes = await imageFile.readAsBytes();
            } else {
              Logger.print('project graphic uses unsupported file ext: \'$ext\', it will not be uploaded');
            }
          } else {
            Logger.print('graphic too large, it will not be uploaded to server');
          }
        } catch (e) {
          Logger.print('failed to process project graphic | exception: \'${e.toString()}\'');
          return null;
        }
      }

      DateTime dt = DateTime.now().toUtc();

      DomeProject domeProject = DomeProject(
          name: projectName,
          owner: owner,
          type: projectType,
          password: projectPassword,
          graphicBytes: projectGraphicBytes,
          graphicPath: projectGraphicPath);
      domeProject.setCreateDateTimeUTC(dt);

      String projectPasswordCheck = generateProjectPasswordCheck(projectPassword);

      DocumentReference doc = await FirebaseFirestore.instance.collection('projects').add({
        'owner': owner,
        'projectName': projectName,
        'projectPasswordCheck': projectPasswordCheck,
        'projectType': projectType.name,
        'createDateTimeUTC': dt.toString(),
      });

      domeProject.setServerId(doc.id);

      SettingsManager.storeProjectPassword(domeProject.getServerId(), projectPassword);
      await SettingsManager.save();

      // this will update the graphic
      await updateServerProjectContent(domeProject);

      return domeProject;
    } catch (e) {
      Logger.print('failed to create project | exception: \'${e.toString()}\'');
    }

    return null;
  }

  static bool isProjectPasswordValid(DomeProject domeProject) {
    String projectPassword = domeProject.getPassword();
    if (projectPassword.isEmpty) return false;
    String encryptedPasswordCheck = AppEncryptor.encryptPasswordString(_passwordCheckString, projectPassword);
    String projectPasswordCheck = domeProject.getProjectPasswordCheck();
    if (projectPasswordCheck.isEmpty) return false;
    return (projectPasswordCheck == encryptedPasswordCheck);
  }

  static String generateProjectPasswordCheck(String projectPassword) {
    if (projectPassword.isEmpty) return '';
    return AppEncryptor.encryptPasswordString(_passwordCheckString, projectPassword);
  }

  /// projectId is the server generated unique id for the project
  /// ext should include the dot, such as '.png'
  /// on success, returns the path to the graphic on the server, otherwise returns null
  static Future<String?> updateServerGraphicBytes(String projectId, String ext, Uint8List projectGraphicBytes) async {
    if (!(ServerAuth.isLoggedIn())) return null;

    if (projectId.isEmpty) {
      Logger.print('cannot update server graphic bytes | project Id is missing');
      return null;
    }

    if (!(DomeProject.graphicSupportedExtensions.contains(ext))) {
      Logger.print('cannot update server graphic bytes | unsupported ext \'$ext\'');
      return null;
    }

    if (projectGraphicBytes.isEmpty) {
      Logger.print('cannot update server graphic bytes | project graphic bytes is empty');
      return null;
    }

    if (projectGraphicBytes.length > DomeProject.graphicMaxSizeBytes) {
      Logger.print('cannot update server graphic bytes | graphic is too large');
      return null;
    }

    try {
      String graphicLocation = 'ProjectImages/$projectId/projectGraphic$ext';

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child(graphicLocation)
          .putData(projectGraphicBytes, SettableMetadata(contentType: 'image/${ext.substring(1)}'));

      await uploadTask;

      if (uploadTask.snapshot.state == TaskState.success) {
        return graphicLocation;
      } else {
        Logger.print('failed to upload the project graphic | state: ${uploadTask.snapshot.state.name}');
      }
    } catch (e) {
      Logger.print('failed to upload the project graphic | exception: \'${e.toString()}\'');
    }

    return null;
  }

  /// project content includes the following only:
  ///   name
  ///   password
  ///   graphic
  ///   detailsTotalLatestComments
  static Future<bool> updateServerProjectContent(DomeProject domeProject) async {
    if (!(ServerAuth.isLoggedIn())) return false;

    String projectName = domeProject.getName();
    if (projectName.isEmpty) return false;

    String projectPassword = domeProject.getPassword();
    if (projectPassword.isEmpty) return false;

    String projectId = domeProject.getServerId();
    if (projectId.isEmpty) return false;

    int detailsTotalLatestComments = domeProject.getDetailsTotalLatestComments();
    if (detailsTotalLatestComments < 0) detailsTotalLatestComments = 0;

    try {
      Map<String, Object> updateMap = {};

      if (domeProject.getGraphicBytes().isNotEmpty) {
        Logger.print('will try to update project graphic');
        String ext = domeProject.getGraphicExt();
        String? graphicLocation = await updateServerGraphicBytes(projectId, ext, domeProject.getGraphicBytes());
        if (graphicLocation != null) {
          updateMap['projectGraphicPath'] = graphicLocation;
          Logger.print('graphic location: \'$graphicLocation\'');
        } else {
          Logger.print('failed to update graphic on server');
        }
      } else {
        Logger.print('no graphic bytes provided, will not update server');
      }

      updateMap['projectName'] = projectName;

      updateMap['detailsTotalLatestComments'] = detailsTotalLatestComments;

      if (domeProject.isOwned())
        updateMap['projectPasswordCheck'] = AppEncryptor.encryptPasswordString(_passwordCheckString, projectPassword);

      bool retVal = false;

      await FirebaseFirestore.instance.collection('projects').doc(projectId).update(updateMap).then((doc) {
        Logger.print('updated project');
        retVal = true;
      }, onError: (e) {
        Logger.print('failed to update project | error: \'$e\'');
      });

      return retVal;
    } catch (e) {
      Logger.print('problem updating content for project | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> destroyProject(DomeProject domeProject) async {
    if (!(ServerAuth.isLoggedIn())) return false;
    if (!(domeProject.isOwned())) return false;
    if (domeProject.getServerId().isEmpty) return false;

    String projectName = domeProject.getName();
    if (projectName.isEmpty) return false;

    String projectOwner = domeProject.getOwner();
    if (projectOwner.isEmpty) return false;

    try {
      await updateClientProjectItems(domeProject);
      int totalItems = domeProject.getTotalItems();
      Logger.print('found \'$totalItems\' to remove from project \'$projectName\'');

      switch (domeProject.getProjectType()) {
        case DomeProjectType.todo:
          for (int i = 0; i < totalItems; ++i) {
            await deleteTodoItem(domeProject.getItem(i) as DomeProjectTodoItem);
          }
          break;

        // case DomeProjectType.valueCollection:
        // break;

        default:
          return false;
      }

      bool retVal = false;

      await FirebaseFirestore.instance.collection('projects').doc(domeProject.getServerId()).delete().then((doc) {
        Logger.print('delete project callback - success');
        retVal = true;
      }, onError: (e) {
        Logger.print('failed to delete project | error: \'$e\'');
      });

      return retVal;
    } catch (e) {
      // empty
    }

    return true;
  }

  /// the returned projects do not have their items populated, to get the items use the method updateProjectItems
  static Future<List<DomeProject>> getOwnedProjects() async {
    if (!(ServerAuth.isLoggedIn())) return [];

    String userEmail = ServerAuth.getCurrentUserEmail();

    try {
      QuerySnapshot<Map<String, dynamic>> v =
          await FirebaseFirestore.instance.collection('projects').where('owner', isEqualTo: userEmail).get();

      if (v.docs.length > 0) {
        Logger.print('found ${v.docs.length} owned projects');

        List<DomeProject> projects = [];

        for (int i = 0; i < v.docs.length; ++i) {
          Map<String, dynamic> projectData = v.docs[i].data();
          if (projectData != null) {
            DomeProject domeProject = DomeProject.data(data: projectData, serverId: v.docs[i].id);

            if (domeProject.isValid()) {
              projects.add(domeProject);
              Logger.print('added document index \'$i\' with id \'${v.docs[i].id}\'');
            } else {
              Logger.print('skipping invalid dome project at index $i');
            }
          } else {
            Logger.print('project data is null at index $i, will skip');
          }
        }

        return projects;
      }
    } catch (e) {
      Logger.print('failed to get owned projects | exception: \'${e.toString()}\'');
    }

    return [];
  }

  /// the returned projects do not have their items populated, to get the items use the method updateProjectItems
  static Future<List<DomeProject>> getSharedProjects() async {
    if (!(ServerAuth.isLoggedIn())) return [];

    String userEmail = ServerAuth.getCurrentUserEmail();

    try {
      QuerySnapshot<Map<String, dynamic>> v =
          await FirebaseFirestore.instance.collection('shared_projects').where('shareTo', isEqualTo: userEmail).get();

      if (v.docs.length > 0) {
        Logger.print('found ${v.docs.length} shared projects');

        List<DomeProject> projects = [];

        for (int i = 0; i < v.docs.length; ++i) {
          String projectServerId = v.docs[i].data()['projectId'] ?? '';
          if (projectServerId.isNotEmpty) {
            DocumentSnapshot<Map<String, dynamic>> ds =
                await FirebaseFirestore.instance.collection('projects').doc(projectServerId).get();
            if (ds.data() != null) {
              Map<String, dynamic> projectData = ds.data()!;
              projects.add(DomeProject.data(data: projectData, serverId: projectServerId));
            }
          }
        }

        return projects;
      }
    } catch (e) {
      Logger.print('failed to get shared projects | exception: \'${e.toString()}\'');
    }

    return [];
  }

  static Future<List<String>> getShareToEmails(DomeProject domeProject) async {
    if (!(ServerAuth.isLoggedIn())) return [];

    try {
      String projectId = domeProject.getServerId();

      QuerySnapshot<Map<String, dynamic>> v =
          await FirebaseFirestore.instance.collection('shared_projects').where('projectId', isEqualTo: projectId).get();

      if (v.docs.length > 0) {
        List<String> shareToEmails = [];

        for (int i = 0; i < v.docs.length; ++i) {
          String shareTo = v.docs[i].data()['shareTo'] ?? '';
          if (shareTo.isNotEmpty) shareToEmails.add(shareTo);
        }

        return shareToEmails;
      }
    } catch (e) {
      Logger.print('failed to get share-to emails | exception: \'${e.toString()}\'');
    }

    return [];
  }

  static Future<bool> isShared(DomeProject domeProject, String shareToEmail, {Ref<String>? sharedDocId}) async {
    try {
      String projectServerId = domeProject.getServerId();

      QuerySnapshot<Map<String, dynamic>> v = await FirebaseFirestore.instance
          .collection('shared_projects')
          .where('shareTo', isEqualTo: shareToEmail)
          .where('projectId', isEqualTo: projectServerId)
          .limit(1)
          .get();

      if (v.docs.length == 1) {
        if (sharedDocId != null) sharedDocId.value = v.docs[0].id;
        return true;
      }
    } catch (e) {
      Logger.print('failed to check if project is shared | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> shareProject(DomeProject domeProject, String shareToEmail) async {
    if (!(domeProject.isOwned())) return false;
    if (await isShared(domeProject, shareToEmail)) return true;

    try {
      String projectServerId = domeProject.getServerId();

      await FirebaseFirestore.instance.collection('shared_projects').add({
        'shareTo': shareToEmail,
        'projectId': projectServerId,
      });

      return true;
    } catch (e) {
      Logger.print('failed to share project | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> unshareProject(DomeProject domeProject, String shareToEmail) async {
    if (!(domeProject.isOwned())) return false;

    String sharedDocId = '';

    if (!(await isShared(domeProject, shareToEmail,
        sharedDocId: Ref<String>(() {
          return sharedDocId;
        }, (String v) {
          sharedDocId = v;
        })))) return true;

    try {
      bool retVal = false;

      await FirebaseFirestore.instance.collection('shared_projects').doc(sharedDocId).delete().then((doc) {
        retVal = true;
      }, onError: (e) {
        Logger.print('failed to delete shared project association | error: \'$e\'');
      });

      return retVal;
    } catch (e) {
      Logger.print('failed to unshare project | exception: \'${e.toString()}\'');
    }

    return false;
  }

  /// this will remove all existing todo items from the given domeProject, and then populate the given domeProject with whatever items it
  /// finds on the server
  static Future<bool> updateClientProjectItems(DomeProject domeProject) async {
    if (!(ServerAuth.isLoggedIn())) return false;

    String projectPassword = domeProject.getPassword();
    if (projectPassword.isEmpty) return false;

    String projectServerId = domeProject.getServerId();
    if (projectServerId.isEmpty) return false;
    Logger.print('using project server id: \'$projectServerId\' to update items');

    String projectName = domeProject.getName();
    if (projectName.isEmpty) return false;

    String projectOwner = domeProject.getOwner();
    if (projectOwner.isEmpty) return false;

    try {
      switch (domeProject.getProjectType()) {
        case DomeProjectType.todo:
          QuerySnapshot<Map<String, dynamic>> v =
              await FirebaseFirestore.instance.collection('todo_items').where('projectId', isEqualTo: projectServerId).get();

          domeProject.clearItems();

          for (int i = 0; i < v.docs.length; ++i) {
            Map<String, dynamic> itemData = v.docs[i].data();
            domeProject.insertItem(DomeProjectTodoItem.data(
                project: domeProject, data: itemData, projectPassword: projectPassword, serverId: v.docs[i].id));
          }

          domeProject.sortItems();
          break;

        // case DomeProjectType.valueCollection:
        // break;

        default:
          return false;
      }

      Logger.print('all client items updated');
      return true;
    } catch (e) {
      // empty
    }

    return false;
  }

  /// all existing items on the server that exist in the given project will have their index hints updated on the server
  static Future<bool> updateServerTodoItemIndexHints(DomeProject domeProject) async {
    if (!(ServerAuth.isLoggedIn())) return false;
    if (domeProject.getProjectType() != DomeProjectType.todo) return false;

    String projectPassword = domeProject.getPassword();
    if (projectPassword.isEmpty) return false;

    String projectName = domeProject.getName();
    if (projectName.isEmpty) return false;

    String projectOwner = domeProject.getOwner();
    if (projectOwner.isEmpty) return false;

    try {
      int totalItems = domeProject.getTotalItems();

      for (int itemIndex = 0; itemIndex < totalItems; ++itemIndex) {
        DomeProjectTodoItem item = domeProject.getItem(itemIndex) as DomeProjectTodoItem;
        if (item.getServerId().isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('todo_items')
              .doc(item.getServerId())
              .update({'indexHint': item.getIndexHint()});
        }
      }

      return true;
    } catch (e) {
      Logger.print('problem updating index hints on todo items | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> doesTodoItemExists(DomeProject domeProject, DomeProjectTodoItem item) async {
    if (!(ServerAuth.isLoggedIn())) return false;

    String projectServerId = domeProject.getServerId();
    if (projectServerId.isEmpty) return false;

    String projectPassword = domeProject.getPassword();
    if (projectPassword.isEmpty) return false;

    String name = item.getName();
    if (name.isEmpty) return false;

    try {
      QuerySnapshot<Map<String, dynamic>> v = await FirebaseFirestore.instance
          .collection('todo_items')
          .where('projectId', isEqualTo: projectServerId)
          .where('name', isEqualTo: AppEncryptor.encryptPasswordString(name, projectPassword))
          .get();

      if (v.docs.length == 1) return true;
    } catch (e) {
      // empty
    }

    return false;
  }

  /// this method only adds the given item to the server, it does not add the item into the given domeProject
  static Future<bool> createTodoItem(DomeProject domeProject, DomeProjectTodoItem item) async {
    if (!(ServerAuth.isLoggedIn())) return false;

    bool found = await doesTodoItemExists(domeProject, item);
    if (found) return false;

    String projectPassword = domeProject.getPassword();
    if (projectPassword.isEmpty) return false;

    String projectName = domeProject.getName();
    if (projectName.isEmpty) return false;

    String projectOwner = domeProject.getOwner();
    if (projectOwner.isEmpty) return false;

    String name = item.getName();
    if (name.isEmpty) return false;

    bool complete = item.isComplete();
    String description = item.getDescription();
    DateTime createDateTimeUTC = item.getCreateDateTimeUTC();
    DateTime completeDateTimeUTC = item.getCompleteDateTimeUTC();

    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('todo_items').add({
        'projectId': domeProject.getServerId(),
        'name': AppEncryptor.encryptPasswordString(name, projectPassword),
        'complete': complete,
        'description': AppEncryptor.encryptPasswordString(description, projectPassword),
        'createDateTimeUTC': createDateTimeUTC.toString(),
        'completeDateTimeUTC': completeDateTimeUTC.toString(),
        'author': item.getAuthor(),
        'indexHint': item.getIndexHint(),
      });

      item.setServerId(docRef.id);

      return true;
    } catch (e) {
      // empty
    }

    return false;
  }

  /// this only deletes the item from the server, it does not remove it from a dome project
  static Future<bool> deleteTodoItem(DomeProjectTodoItem todoItem) async {
    if (!(ServerAuth.isLoggedIn())) return false;
    if (todoItem.getServerId().isEmpty) return false;

    try {
      bool retVal = false;

      await FirebaseFirestore.instance.collection('todo_items').doc(todoItem.getServerId()).delete().then((doc) {
        Logger.print('delete todo item callback - success');
        retVal = true;
      }, onError: (e) {
        Logger.print('failed to delete document | error: \'$e\'');
      });

      Logger.print('deleted todo item completed | return value: $retVal');
      return retVal;
    } catch (e) {
      Logger.print('problem deleting todo item | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> updateServerTodoItemCompleteStatus(DomeProject domeProject, DomeProjectTodoItem todoItem) async {
    if (!(ServerAuth.isLoggedIn())) return false;
    if (domeProject.getProjectType() != DomeProjectType.todo) return false;
    if (todoItem.getServerId().isEmpty) return false;

    try {
      await FirebaseFirestore.instance.collection('todo_items').doc(todoItem.getServerId()).update({
        'complete': todoItem.isComplete(),
        'completeDateTimeUTC': todoItem.getCompleteDateTimeUTC().toString(),
      });

      // TODO: check the .then onError stuff

      return true;
    } catch (e) {
      Logger.print('problem updating complete status for todo item | exception: \'${e.toString()}\'');
    }

    return false;
  }

  /// todo item content includes the name and description only
  static Future<bool> updateServerTodoItemContent(DomeProject domeProject, DomeProjectTodoItem todoItem) async {
    if (!(ServerAuth.isLoggedIn())) return false;
    if (domeProject.getProjectType() != DomeProjectType.todo) return false;
    if (todoItem.getServerId().isEmpty) return false;

    String projectPassword = domeProject.getPassword();
    if (projectPassword.isEmpty) return false;

    try {
      await FirebaseFirestore.instance.collection('todo_items').doc(todoItem.getServerId()).update({
        'name': AppEncryptor.encryptPasswordString(todoItem.getName(), projectPassword),
        'description': AppEncryptor.encryptPasswordString(todoItem.getDescription(), projectPassword),
      });

      // TODO: check the .then onError stuff

      return true;
    } catch (e) {
      Logger.print('problem updating content for todo item | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<Uint8List> getProjectGraphicImageBytes(String projectGraphicPath) async {
    if (projectGraphicPath.isEmpty) return Uint8List(0);

    try {
      final Uint8List? data =
          await FirebaseStorage.instance.ref().child(projectGraphicPath).getData(DomeProject.graphicMaxSizeBytes);

      if (data != null) {
        return data;
      }
    } catch (e) {
      // empty
    }

    return Uint8List(0);
  }

  /// this method only adds the given comment to the server, it does not add the comment into the given item
  static Future<bool> createComment(DomeProjectTodoItem item, DomeProjectComment comment) async {
    if (!(ServerAuth.isLoggedIn())) return false;

    String projectPassword = item.getProject().getPassword();
    if (projectPassword.isEmpty) return false;

    String commentMessage = comment.getCommentMessage();
    if (commentMessage.isEmpty) return false;

    // DateTime createDateTimeUTC = comment.getCreateDateTimeUTC();
    Timestamp createTimestampUTC =
        TimestampTools.convertDateTimeUTC(comment.getCreateDateTimeUTC()); // Timestamp.fromDate(createDateTimeUTC);

    String author = comment.getAuthor();
    if (author.isEmpty) return false;

    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('comments').add({
        'todoId': item.getServerId(),
        'commentMessage': AppEncryptor.encryptPasswordString(commentMessage, projectPassword),
        // 'createDateTimeUTC': createDateTimeUTC.toString(),
        'createTimestampUTC': createTimestampUTC,
        'author': author,
      });

      if (docRef.id.isEmpty) return false;

      comment.setServerId(docRef.id);

      return true;
    } catch (e) {
      // empty
    }

    return false;
  }

  /// this only deletes the comment from the server, it does not remove it from the todo item
  static Future<bool> deleteComment(DomeProjectTodoItem item, DomeProjectComment comment) async {
    if (!(ServerAuth.isLoggedIn())) return false;
    if (item.getServerId().isEmpty) return false;
    if (comment.getServerId().isEmpty) return false;

    try {
      bool retVal = false;

      await FirebaseFirestore.instance.collection('comments').doc(comment.getServerId()).delete().then((doc) {
        Logger.print('delete comment callback - success');
        retVal = true;
      }, onError: (e) {
        Logger.print('failed to delete comment | error: \'$e\'');
      });

      Logger.print('deleted comment completed | return value: $retVal');
      return retVal;
    } catch (e) {
      Logger.print('problem deleting comment | exception: \'${e.toString()}\'');
    }

    return false;
  }

  static Future<bool> updateClientComments(DomeProjectTodoItem item, {int maxComments = -1}) async {
    if (!(ServerAuth.isLoggedIn())) return false;

    String projectPassword = item.getProject().getPassword();
    if (projectPassword.isEmpty) return false;

    String itemServerId = item.getServerId();
    if (itemServerId.isEmpty) return false;

    try {
      QuerySnapshot<Map<String, dynamic>> v;

      if (maxComments > 0) {
        v = await FirebaseFirestore.instance
            .collection('comments')
            .where('todoId', isEqualTo: itemServerId)
            .orderBy('createTimestampUTC', descending: true)
            .limit(maxComments)
            .get();
        // Logger.print('max comments: $maxComments | found: ${v.docs.length}');
      } else {
        v = await FirebaseFirestore.instance.collection('comments').where('todoId', isEqualTo: itemServerId).get();
        // Logger.print('retrieved all comments');
      }

      item.clearComments();

      for (int i = 0; i < v.docs.length; ++i) {
        Map<String, dynamic> commentData = v.docs[i].data();
        item.appendComment(
            domeProjectComment:
                DomeProjectComment.data(data: commentData, projectPassword: projectPassword, serverId: v.docs[i].id),
            updateServer: false);
      }

      item.sortComments();

      return true;
    } catch (e) {
      // empty
    }

    return false;
  }
}
