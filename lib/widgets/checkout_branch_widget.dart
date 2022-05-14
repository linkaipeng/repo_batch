import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:repo_batch/cubit/repo_data_cubit.dart';

import 'common_button.dart';

class CheckoutBranchWidget extends StatelessWidget {
  final TextEditingController _branchNameController = TextEditingController();

  CheckoutBranchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 280,
        color: const Color(0XFF2B2B2B),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildTitle(),
              Container(
                margin: const EdgeInsets.only(top: 25, left: 18, right: 18),
                child: _buildTextFormField(_branchNameController, '输入 分支 名字，如：release'),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: CommonTextButton(
                  text: '确定',
                  onPressed: () {
                    if (_branchNameController.text.trim().isEmpty) {
                      EasyLoading.showToast('输入 分支 名字，如：release', dismissOnTap: true);
                      return;
                    }
                    RepoDataCubit.getRepoDataCubit(context).checkoutReposBranch(
                      branchName: _branchNameController.text.trim(),
                      doneCallback: () => Navigator.pop(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String hintTextContent) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 18.0,
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintTextContent,
        hintStyle: const TextStyle(
          fontSize: 18.0,
          color: Colors.white38,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54, width: 1),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38, width: 1),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '🚀 一键切分支',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '没有该分支的仓库会不会执行 checkout 操作',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
