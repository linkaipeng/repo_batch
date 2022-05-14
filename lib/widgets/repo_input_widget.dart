import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:repo_batch/cubit/menu_cubit.dart';
import 'package:repo_batch/cubit/repo_data_cubit.dart';

import 'common_button.dart';

class RepoInputWidget extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _repoInputController = TextEditingController();

  RepoInputWidget({Key? key}) : super(key: key);

  void _readRepoListContentFromFile(BuildContext context) async {
    String content = await RepoDataCubit.getRepoDataCubit(context).readRepoListContentFromFile();
    if (content.isEmpty) {
      return;
    }
    _repoInputController.value = TextEditingValue(
      text: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) => _readRepoListContentFromFile(context));
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 30, left: 18, right: 18),
              child: TextFormField(
                controller: _repoInputController,
                decoration: const InputDecoration(
                  hintText: '输入仓库地址，多仓库分行即可',
                  hintStyle: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white38,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38, width: 1),
                  ),
                ),
                cursorColor: Colors.white,
                maxLines: 20,
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: CommonTextButton(
                text: '确定',
                onPressed: () {
                  String content = _repoInputController.text.trim();
                  RepoDataCubit.getRepoDataCubit(context).writeRepoListToFile(content);
                  if (content.isEmpty) {
                    EasyLoading.showToast('清除成功', dismissOnTap: true);
                  } else {
                    MenuCubit.getMenuCubit(context).toggleToRepo();
                    EasyLoading.showToast('添加成功', dismissOnTap: true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
