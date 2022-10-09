import 'package:flutter/material.dart';

import '../devtools/logger.dart';

import '../server/server_project.dart';

import 'dome_project.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class DomeProjectList extends ChangeNotifier {
  List<DomeProject> _projects = [];
  bool _processing = false;

  DomeProjectList() {}

  int get length {
    return _projects.length;
  }

  operator [](int index) {
    return _projects[index];
  }

  void add(DomeProject domeProject) {
    _projects.add(domeProject);
    notifyListeners();
  }

  void addAll(List<DomeProject> projects) {
    _projects.addAll(projects);
    notifyListeners();
  }

  void clear() {
    _projects.clear();
    notifyListeners();
  }

  void sortByName() {
    _projects.sort((a, b) {
      return a.getName().compareTo(b.getName());
    });
    notifyListeners();
  }

  String getTotalProjectsDescription() {
    if (length == 1) return '1 project';
    return '$length projects';
  }

  bool isProcessing() {
    return _processing;
  }

  void setProcessing(bool v) {
    if (_processing != v) {
      _processing = v;
      notifyListeners();
    }
  }

  /// this will clear this list and then add all owned and shared projects into this list
  Future<void> setupProjects() async {
    Logger.print('getting info for owned and shared projects ...');

    setProcessing(true);

    Future<List<DomeProject>> ownedProjectsFuture = ServerProject.getOwnedProjects();
    Future<List<DomeProject>> sharedProjectsFuture = ServerProject.getSharedProjects();

    List<DomeProject> ownedProjects = await ownedProjectsFuture;
    List<DomeProject> sharedProjects = await sharedProjectsFuture;

    for (DomeProject domeProject in ownedProjects) {
      await domeProject.updateGraphicImage();
    }

    for (DomeProject domeProject in sharedProjects) {
      await domeProject.updateGraphicImage();
    }

    clear();
    addAll(ownedProjects);
    addAll(sharedProjects);
    sortByName();

    setProcessing(false);

    Logger.print('projects ready');
  }
}
