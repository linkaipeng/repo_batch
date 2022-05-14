import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repo_batch/cubit/console_cubit.dart';
import 'package:repo_batch/git/git_repository.dart';
import 'package:repo_batch/model/console_log.dart';

class ConsoleWidget extends StatefulWidget {
  const ConsoleWidget({Key? key}) : super(key: key);

  @override
  State<ConsoleWidget> createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  @override
  Widget build(BuildContext context) {
    GitRepository.logCallback = (consoleLog) {
      if (!mounted) {
        return;
      }
      ConsoleCubit.getConsoleCubit(context).appendLog(consoleLog);
    };
    ScrollController controller = ScrollController();
    return Container(
      width: double.infinity,
      height: 200,
      color: const Color(0XFF2B2B2B),
      child: BlocConsumer<ConsoleCubit, ConsoleState>(
        listener: (context, state) {
          Future.delayed(const Duration(milliseconds: 100), () {
            controller.jumpTo(controller.position.maxScrollExtent);
          });
        },
        builder: (context, state) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            controller: controller,
            itemCount: state.logList.length,
            itemBuilder: (context, index) => _buildConsoleLogItem(state.logList[index]),
          );
        },
      ),
    );
  }

  Widget _buildConsoleLogItem(ConsoleLog consoleLog) {
    return Text(
      consoleLog.log,
      style: TextStyle(
        color: consoleLog.logLevel == LogLevel.VERBOSE ? Colors.white : (consoleLog.logLevel == LogLevel.INFO ? Colors.green : Colors.red),
        fontSize: 15,
      ),
    );
  }
}
