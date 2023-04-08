import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:repo_batch/cubit/console_cubit.dart';
import 'package:repo_batch/widgets/repo_list_widget.dart';

import '../cubit/repo_data_cubit.dart';
import 'console.dart';
import 'operate_bar_widget.dart';

class RepoMainWidget extends StatelessWidget {
  const RepoMainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LifecycleWrapper(
      onLifecycleEvent: (event) {
        if (event == LifecycleEvent.visible) {
          RepoDataCubit.getRepoDataCubit(context).connect();
        }
      },
      child: Stack(
        children: [
          Container(
            color: const Color(0XFF2B2B2B),
            child: const RepoListWidget(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const OperateBarWidget(),
                _buildConsoleWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleWidget() {
    return BlocBuilder<ConsoleCubit, ConsoleState>(
      builder: (context, state) {
        if (state.isMinimize) {
          return Container();
        }
        return const ConsoleWidget();
      },
    );
  }
}
