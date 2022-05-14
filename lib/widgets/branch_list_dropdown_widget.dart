import 'package:flutter/material.dart';
import 'package:repo_batch/cubit/repo_data_cubit.dart';
import 'package:repo_batch/model/repo.dart';

class BranchListDropDownWidget extends StatelessWidget {

  final Repo repo;

  const BranchListDropDownWidget({Key? key, required this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: repo.currentBranch ?? '',
      style: const TextStyle(fontSize: 18, color: Colors.white70),
      dropdownColor: const Color(0XFF3C3F41),
      underline: Container(height: 0),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      alignment: AlignmentDirectional.centerEnd,
      onChanged: (String? branchName) {
        if (branchName == null) {
          return;
        }
        RepoDataCubit.getRepoDataCubit(context).checkoutBranch(repo, branchName);
      },
      items: repo.branchList.map((branch) => _buildBranchItemWidget(context, repo, branch)).toList(),
    );
  }

  DropdownMenuItem<String> _buildBranchItemWidget(BuildContext context, Repo repo, String branchName) {
    return DropdownMenuItem<String>(
      value: branchName,
      child: Text(
        branchName,
      ),
    );
  }
}
