import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../devtools/logger.dart';

import '../controls/view_project_frame.dart';
import '../controls/todo_card.dart';

import '../project/dome_project_manager.dart';
import '../project/dome_project.dart';
import '../project/dome_project_todo_item.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late DomeProject _domeProject;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _domeProject = DomeProjectManager.getActiveProject();
    _scrollController = ScrollController();
  }

  final Color draggableItemColor = Color(0x00000000);
  final Color draggableItemShadowColor = Color(0xC0000000);

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: draggableItemColor,
          shadowColor: draggableItemShadowColor,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _domeProject,
      builder: (context, child) {
        return ViewProjectFrame(
          processing: Provider.of<DomeProject>(context).isProcessing(),
          child: ReorderableListView.builder(
            scrollController: _scrollController,
            key: PageStorageKey(0),
            proxyDecorator: _proxyDecorator,
            itemCount: Provider.of<DomeProject>(context).getTotalItems() + 2,
            onReorderStart: (int index) {
              _domeProject.getItem(index - 1).setDragging(true);
            },
            onReorderEnd: (int index) {
              _domeProject.clearDragging();
            },
            onReorder: (int oldIndex, int newIndex) async {
              if (oldIndex > 0 && oldIndex <= _domeProject.getTotalItems()) {
                await _domeProject.moveItem(oldIndex: oldIndex - 1, newIndex: newIndex - 1, updateServer: true);
              }
            },
            itemBuilder: (BuildContext context, int index) {
              if (index == 0 || index > Provider.of<DomeProject>(context).getTotalItems()) {
                return IgnorePointer(
                  ignoring: true,
                  key: Key('$index'),
                  child: Container(
                    height: 90.0,
                  ),
                );
              }

              return TodoCard(
                  todoItem: Provider.of<DomeProject>(context).getItem(index - 1) as DomeProjectTodoItem, key: Key('$index'));
            },
          ),
        );
      },
    );
  }
}
