import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:repo_batch/cubit/repo_data_cubit.dart';

import 'common_button.dart';

class TabInputWidget extends StatelessWidget {
  final TextEditingController _tagNameController = TextEditingController();
  final TextEditingController _tagCommitInfoController = TextEditingController();

  TabInputWidget({Key? key}) : super(key: key);


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
                margin: const EdgeInsets.only(top: 20, left: 18, right: 18),
                child: _buildTextFormField(_tagNameController, '输入 tag 名字，如： tag_1.0.0'),
              ),
              Container(
                margin: const EdgeInsets.only(top: 12, left: 18, right: 18),
                child: _buildTextFormField(_tagCommitInfoController, '输入提交信息，如： 发布 1.0.0 版本'),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: CommonTextButton(
                  text: '确定',
                  onPressed: () {
                    if (_tagNameController.text.trim().isEmpty) {
                      EasyLoading.showToast('输入 tag 名字，如： tag_1.0.0', dismissOnTap: true);
                      return;
                    }
                    if (_tagCommitInfoController.text.trim().isEmpty) {
                      EasyLoading.showToast('输入提交信息，如： 发布 1.0.0 版本', dismissOnTap: true);
                      return;
                    }
                    RepoDataCubit.getRepoDataCubit(context).pushReposTag(
                      tagName: _tagNameController.text.trim(),
                      tagCommitInfo: _tagCommitInfoController.text.trim(),
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
        child: const Text(
          '🚀 一键打 Tag',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
