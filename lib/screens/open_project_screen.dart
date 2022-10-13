import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../devtools/logger.dart';

import '../server/server_project.dart';

import '../project/dome_project.dart';
import '../project/dome_project_list.dart';
import '../project/dome_project_manager.dart';

import '../cards/project_card.dart';

import '../controls/open_project_frame.dart';

import '../dialogs/app_dialog.dart';

import '../screens/project_password_screen.dart';
import '../screens/share_project_screen.dart';

import 'todo_list_screen.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class OpenProjectScreen extends StatefulWidget {
  const OpenProjectScreen({Key? key}) : super(key: key);

  @override
  State<OpenProjectScreen> createState() => _OpenProjectScreenState();
}

class _OpenProjectScreenState extends State<OpenProjectScreen> {
  DomeProjectList _projects = DomeProjectList();

  @override
  void initState() {
    super.initState();
    _projects.setupProjects();
  }

  @override
  Widget build(BuildContext topContext) {
    return ChangeNotifierProvider.value(
      value: _projects,
      child: Consumer<DomeProjectList>(
        builder: (consumerContext, domeProjectList, child) {
          return OpenProjectFrame(
            processing: domeProjectList.isProcessing(),
            child: ListView.builder(
              itemCount: domeProjectList.length + 2,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0 || index > domeProjectList.length) return Container(height: 80.0);
                return ProjectCard(
                  domeProject: domeProjectList[index - 1],
                  onPressed: () {
                    _onProjectSelected(topContext, index, domeProjectList);
                  },
                  onShare: () async {
                    DomeProject domeProject = domeProjectList[index - 1];
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => ShareProjectScreen(domeProject: domeProject)));
                    // TODO: only need the update if displaying info on this screen about shared emails
                    await domeProjectList.setupProjects();
                  },
                  onDelete: () async {
                    DomeProject domeProject = domeProjectList[index - 1];

                    AppDialogResult? result = await AppDialog.showChoiceDialog(
                        context: context,
                        icon: Icons.warning_amber_rounded,
                        title: 'Delete Project',
                        content: 'Are you sure you want to delete this project?\n\n${domeProject.getName()}',
                        option1: 'Yes',
                        option2: 'No');

                    if (result != null && result == AppDialogResult.option1) {
                      Logger.print('user chose to delete the project');

                      await ServerProject.destroyProject(domeProject);
                      await domeProjectList.setupProjects();
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _onProjectSelected(BuildContext context, int index, DomeProjectList domeProjectList) async {
    DomeProject activeProject = domeProjectList[index - 1];

    if (!(ServerProject.isProjectPasswordValid(activeProject))) {
      bool? passwordValid = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return ProjectPasswordScreen(
              domeProject: activeProject,
            );
          },
        ),
      );

      if (passwordValid == null || !passwordValid) {
        return;
      }
    }

    domeProjectList.setProcessing(true);

    await ServerProject.updateClientProjectItems(activeProject);

    DomeProjectManager.setActiveProject(activeProject);

    switch (activeProject.getProjectType()) {
      case DomeProjectType.todo:
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TodoListScreen()));
        await domeProjectList.setupProjects();
        break;
      default:
        // TODO: error, unknown project type
        break;
    }
  }
}
