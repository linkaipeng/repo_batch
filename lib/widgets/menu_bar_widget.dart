import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repo_batch/cubit/menu_cubit.dart';
import 'package:repo_batch/widgets/common_button.dart';

class MenuBarWidget extends StatelessWidget {
  const MenuBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: double.infinity,
      color: const Color(0XFF3C3F41),
      child: BlocBuilder<MenuCubit, MenuState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: state.menu == Menu.REPO ? 1 : 0.3,
                child: CommonImageButton(
                  width: 26,
                  imgPath: 'assets/images/menu_git.png',
                  onTap: () => MenuCubit.getMenuCubit(context).toggleToRepo(),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 25, top: 15),
                child: Opacity(
                  opacity: state.menu == Menu.SETTINGS ? 1 : 0.3,
                  child: CommonImageButton(
                    width: 26,
                    imgPath: 'assets/images/menu_settings.png',
                    onTap: () => MenuCubit.getMenuCubit(context).toggleToSetting(),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
