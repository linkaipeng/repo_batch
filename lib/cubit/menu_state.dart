part of 'menu_cubit.dart';

class MenuState {

  Menu menu = Menu.REPO;

  MenuState init() {
    return MenuState()
      ..menu = Menu.REPO;
  }

  MenuState clone() {
    return MenuState()
      ..menu = menu;
  }
}

enum Menu {
  REPO, SETTINGS,
}
