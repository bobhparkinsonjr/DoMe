import 'dome_project.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class DomeProjectManager {
  static DomeProject? _activeProject;

  static void setActiveProject(DomeProject domeProject) {
    _activeProject = domeProject;
  }

  static DomeProject getActiveProject() {
    return _activeProject!;
  }

  static bool hasActiveProject() {
    return (_activeProject != null);
  }

  static void clearActiveProject() {
    _activeProject = null;
  }
}
