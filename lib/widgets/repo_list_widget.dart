import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repo_batch/common/color.dart';
import 'package:repo_batch/cubit/repo_data_cubit.dart';
import 'package:repo_batch/model/repo.dart';

import 'branch_list_dropdown_widget.dart';

class RepoListWidget extends StatelessWidget {
  const RepoListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepoDataCubit, RepoDataState>(
      builder: (context, state) {
        return ListView.separated(
          itemCount: state.repoList.length,
          padding: const EdgeInsets.only(bottom: 80 + 200),
          separatorBuilder: (BuildContext context, int index) => const Padding(
            padding: EdgeInsets.only(left: 58),
            child: Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
          itemBuilder: (context, index) {
            return _buildItemWidget(context, state.repoList[index]);
          },
        );
      },
    );
  }

  Widget _buildItemWidget(BuildContext context, Repo repo) {
    return Stack(
      children: [
        _buildRepoInfoWidget(repo),
        _buildBranchInfoWidget(context, repo),
        _buildCheckbox(context, repo),
      ],
    );
  }

  Widget _buildRepoInfoWidget(Repo repo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const SizedBox(width: 60),
          Image.asset(
            'assets/images/git.png',
            width: 30,
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                repo.name ?? '/',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                width: 600,
                margin: const EdgeInsets.only(top: 6),
                child: Text(
                  repo.url ?? 'no find url',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildTagsWidget(repo),
              Container(
                width: 600,
                margin: const EdgeInsets.only(top: 6),
                child: Text(
                  repo.dirPath ?? 'local path not found',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranchInfoWidget(BuildContext context, Repo repo) {
    if (repo.branchList.isEmpty) {
      return Container();
    }
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.only(top: 10, right: 25),
        child: BranchListDropDownWidget(repo: repo),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, Repo repo) {
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

    return Positioned(
      top: repo.tagList.isEmpty ? 35 : 46,
      left: 15,
      child: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith(getColor),
        shape: const CircleBorder(),
        value: RepoDataCubit.getRepoDataCubit(context).isRepoSelected(repo.url),
        onChanged: (bool? value) {
          RepoDataCubit.getRepoDataCubit(context).selectRepo(repo.url);
        },
      ),
    );
  }

  Widget _buildTagsWidget(Repo repo) {
    if (repo.tagList.isEmpty) {
      return Container();
    }
    return Container(
      width: 600,
      margin: const EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: repo.tagList.map((tag) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.green.withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
