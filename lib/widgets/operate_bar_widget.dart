import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:repo_batch/common/color.dart';
import 'package:repo_batch/cubit/console_cubit.dart';
import 'package:repo_batch/cubit/repo_data_cubit.dart';
import 'package:repo_batch/model/recent_commit_log.dart';
import 'package:repo_batch/widgets/checkout_branch_widget.dart';
import 'package:repo_batch/widgets/commit_log_dialog.dart';
import 'package:repo_batch/widgets/tag_input_widget.dart';

import 'common_button.dart';

class OperateBarWidget extends StatelessWidget {

  const OperateBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildOperateBarWidget(context);
  }

  Widget _buildOperateBarWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 35,
      color: const Color(0XFF3C3F41),
      child: Stack(
        children: [
          _buildCheckbox(context),
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonImageButton(
            width: 20,
            imgPath: 'assets/images/refresh.png',
            toolTipMsg: '刷新仓库',
            onTap: () {
              if (RepoDataCubit.getRepoDataCubit(context).isSelectedEmpty()) {
                EasyLoading.showError('请勾选仓库', dismissOnTap: true);
                return;
              }
              RepoDataCubit.getRepoDataCubit(context).cloneSelectedRepos();
            },
          ),
          const SizedBox(width: 15),
          CommonImageButton(
            width: 20,
            imgPath: 'assets/images/checkout_branch.png',
            toolTipMsg: '切分支',
            onTap: () async {
              if (RepoDataCubit.getRepoDataCubit(context).isSelectedEmpty()) {
                EasyLoading.showError('请勾选仓库', dismissOnTap: true);
                return;
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CheckoutBranchWidget();
                },
              );
            },
          ),
          const SizedBox(width: 15),
          CommonImageButton(
            width: 20,
            imgPath: 'assets/images/log.png',
            toolTipMsg: '提交日志',
            onTap: () async {
              if (RepoDataCubit.getRepoDataCubit(context).isSelectedEmpty()) {
                EasyLoading.showError('请勾选仓库', dismissOnTap: true);
                return;
              }
              List<CommitLog> recentCommitLogList = await RepoDataCubit.getRepoDataCubit(context).fetchReposRecentLog();
              if (recentCommitLogList.isEmpty) {
                EasyLoading.showToast('查无日志', dismissOnTap: true);
                return;
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CommitLogDialog(recentCommitLogList: recentCommitLogList);
                },
              );
            },
          ),
          const SizedBox(width: 15),
          CommonImageButton(
            width: 20,
            imgPath: 'assets/images/tag.png',
            toolTipMsg: '打 Tag',
            onTap: () {
              if (RepoDataCubit.getRepoDataCubit(context).isSelectedEmpty()) {
                EasyLoading.showError('请勾选需要打 tag 的仓库', dismissOnTap: true);
                return;
              }
              if (RepoDataCubit.getRepoDataCubit(context).isContainsHttps()) {
                EasyLoading.showError('打 tag 目前仅支持 ssh 仓库', dismissOnTap: true);
                return;
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TabInputWidget();
                },
              );
            },
          ),
          const SizedBox(width: 15),
          BlocBuilder<ConsoleCubit, ConsoleState>(
            builder: (context, state) {
              return CommonImageButton(
                width: 20,
                imgPath: state.isMinimize ? 'assets/images/maximize.png' : 'assets/images/minimize.png',
                onTap: () => ConsoleCubit.getConsoleCubit(context).toggleConsole(),
              );
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return AppColors.buttonColor.withOpacity(0.5);
      }
      return AppColors.buttonColor;
    }

    return BlocBuilder<RepoDataCubit, RepoDataState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith(getColor),
                  value: RepoDataCubit.getRepoDataCubit(context).isAllSelected(),
                  shape: const CircleBorder(),
                  onChanged: (bool? value) {
                    RepoDataCubit.getRepoDataCubit(context).selectAllRepo(value ?? false);
                  },
                ),
                const Text(
                  '全选',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0XFFE6E6E6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
