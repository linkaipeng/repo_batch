import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:repo_batch/git/git_repository.dart';
import 'package:repo_batch/model/recent_commit_log.dart';
import 'package:repo_batch/model/repo.dart';
import 'package:repo_batch/widgets/loading/common_loading.dart';

part 'repo_data_state.dart';

class RepoDataCubit extends Cubit<RepoDataState> {
  RepoDataCubit() : super(RepoDataState().init());

  final GitRepository _gitRepository = GitRepository();

  void init() async {
    List<String> repoUrlList = await _gitRepository.readRepoListFromFile();
    List<Repo> repoList = repoUrlList.map((e) => Repo()..url = e).toList();
    emit(state.init()..repoList = repoList);
  }

  void addRepoList(List<Repo> repoList) {
    emit(state.clone()..repoList = repoList);
  }

  bool isRepoSelected(String? repoUrl) {
    if (repoUrl == null) {
      return false;
    }
    return state.selectedRepoUrlList.contains(repoUrl);
  }

  bool isSelectedEmpty() => state.selectedRepoUrlList.isEmpty;

  bool isContainsHttps() => state.selectedRepoUrlList.any((url) => url.startsWith('https://'));

  void selectRepo(String? repoUrl) {
    if (repoUrl == null) {
      emit(state.clone());
      return;
    }
    List<String> selectedUrlNewList = List.of(state.selectedRepoUrlList);
    if (selectedUrlNewList.contains(repoUrl)) {
      selectedUrlNewList.remove(repoUrl);
    } else {
      selectedUrlNewList.add(repoUrl);
    }
    emit(state.clone()..selectedRepoUrlList = selectedUrlNewList);
  }

  void selectAllRepo(bool selected) {
    List<String> selectedUrlNewList = List.of(state.selectedRepoUrlList);
    selectedUrlNewList.clear();
    if (selected) {
      selectedUrlNewList.addAll(state.repoList.where((element) => element.url != null).map((e) => e.url!));
    }
    emit(state.clone()..selectedRepoUrlList = selectedUrlNewList);
  }

  bool isAllSelected() => state.selectedRepoUrlList.isNotEmpty && state.repoList.length == state.selectedRepoUrlList.length;

  List<Repo> _filterSelectedRepoList(List<Repo> allRepoList) {
    return allRepoList.where((repo) => isRepoSelected(repo.url)).toList();
  }

  void cloneSelectedRepos() async {
    CommonLoading.showLoading();
    List<Repo> newList = state.deepCloneRepoList();
    await _gitRepository.cloneSelectedRepo(
      selectedRepoList: _filterSelectedRepoList(newList),
      fetchBranchInfo: true,
      fetchTagInfo: false,
      updateCallback: () {
        emit(state.clone()..repoList = newList);
      },
    );
    emit(state.clone()..repoList = newList);
    CommonLoading.hideLoading();
  }

  void updateSelectedRepoTags() async {
    CommonLoading.showLoading();
    List<Repo> newList = state.deepCloneRepoList();
    await _gitRepository.cloneSelectedRepo(
      selectedRepoList: _filterSelectedRepoList(newList),
      fetchBranchInfo: false,
      fetchTagInfo: true,
      updateCallback: () {
        emit(state.clone()..repoList = newList);
      },
    );
    emit(state.clone()..repoList = newList);
    CommonLoading.hideLoading();
  }

  void connect() async {
    List<Repo> newList = state.deepCloneRepoList();
    await _gitRepository.connectRepoToLocalDir(
        repoList: newList,
        updateCallback: () {
          emit(state.clone()..repoList = newList);
        }
    );
  }

  void checkoutBranch(Repo repo, String branchName) async {
    CommonLoading.showLoading();
    List<Repo> newList = state.deepCloneRepoList();
    await _gitRepository.checkoutBranch(newList.firstWhere((element) => element.url == repo.url), branchName, newList);
    emit(state.clone()..repoList = newList);
    CommonLoading.hideLoading();
  }

  void checkoutReposBranch({required String branchName, required Function doneCallback}) async {
    CommonLoading.showLoading();
    List<Repo> newList = state.deepCloneRepoList();
    await _gitRepository.checkRepoValidAndUpdate(
        selectedRepoList: _filterSelectedRepoList(newList),
        updateCallback: () {
          emit(state.clone()..repoList = newList);
        }
    );
    await _gitRepository.checkoutReposBranch(
      repoList: newList,
      selectedList: state.selectedRepoUrlList,
      branchName: branchName,
    );
    emit(state.clone()..repoList = newList);
    CommonLoading.hideLoading();
    doneCallback();
  }

  void pushReposTag({required String tagName, required String tagCommitInfo, required Function doneCallback}) async {
    CommonLoading.showLoading();
    List<Repo> newList = state.deepCloneRepoList();
    await _gitRepository.checkRepoValidAndUpdate(
        selectedRepoList: _filterSelectedRepoList(newList),
        updateCallback: () {
          emit(state.clone()..repoList = newList);
        }
    );
    await _gitRepository.pushReposTag(newList, state.selectedRepoUrlList, tagName, tagCommitInfo);
    emit(state.clone()..repoList = newList);
    CommonLoading.hideLoading();
    EasyLoading.showSuccess('Push tag Done', dismissOnTap: true);
    doneCallback();
  }

  Future<List<CommitLog>> fetchReposRecentLog() async {
    CommonLoading.showLoading();
    List<Repo> newList = state.deepCloneRepoList();
    await _gitRepository.checkRepoValidAndUpdate(
      selectedRepoList: _filterSelectedRepoList(newList),
      updateCallback: () {
        emit(state.clone()..repoList = newList);
      }
    );
    List<CommitLog> recentCommitLogList = await _gitRepository.fetchReposRecentLog(newList, state.selectedRepoUrlList);
    CommonLoading.hideLoading();
    return recentCommitLogList;
  }

  void writeRepoListToFile(String contents) async {
    await _gitRepository.writeRepoListToFile(contents);
    init();
  }

  Future<String> readRepoListContentFromFile() async {
    return (await _gitRepository.readRepoListFromFile()).join('\n').trim().toString();
  }

  static RepoDataCubit getRepoDataCubit(BuildContext context) {
    return BlocProvider.of<RepoDataCubit>(context);
  }
}
