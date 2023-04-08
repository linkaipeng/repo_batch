import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:repo_batch/cubit/console_cubit.dart';
import 'package:repo_batch/cubit/menu_cubit.dart';
import 'package:repo_batch/widgets/menu_bar_widget.dart';
import 'package:repo_batch/widgets/repo_input_widget.dart';
import 'package:repo_batch/widgets/repo_main_widget.dart';

import 'cubit/repo_data_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RepoDataCubit>(
          create: (BuildContext context) => RepoDataCubit(),
        ),
        BlocProvider<ConsoleCubit>(
          create: (BuildContext context) => ConsoleCubit(),
        ),
        BlocProvider<MenuCubit>(
          create: (BuildContext context) => MenuCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        builder: EasyLoading.init(),
        navigatorObservers: [defaultLifecycleObserver],
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage() : super(key: UniqueKey());

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    RepoDataCubit.getRepoDataCubit(context).init();
    return Scaffold(
      body: Container(
        color: const Color(0XFF2B2B2B),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 50),
                child: _buildContentWidget(),
              ),
              const MenuBarWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        if (state.menu == Menu.SETTINGS) {
          return RepoInputWidget();
        }
        return BlocConsumer<RepoDataCubit, RepoDataState>(
          listenWhen: (previous, current) => previous.repoList.isEmpty && current.repoList.isEmpty,
          listener: (context, state) {
            if (state.repoList.isEmpty) {
              MenuCubit.getMenuCubit(context).toggleToSetting();
            }
          },
          builder: (context, state) {
            if (state.repoList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Image(
                      width: 60,
                      image: AssetImage('assets/images/empty.png'),
                    ),
                    SizedBox(height: 18),
                    Text(
                      '点击设置添加仓库',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  ],
                ),
              );
            }
            return const RepoMainWidget();
          },
        );
      },
    );
  }
}
