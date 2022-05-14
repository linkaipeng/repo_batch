import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit() : super(MenuState().init());
  
  void toggleToRepo() => _toggleMenu(Menu.REPO);
  void toggleToSetting() => _toggleMenu(Menu.SETTINGS);
  
  void _toggleMenu(Menu menu) => emit(state.clone()..menu = menu);

  static MenuCubit getMenuCubit(BuildContext context) {
    return BlocProvider.of<MenuCubit>(context);
  }
}
