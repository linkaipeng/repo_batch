part of 'repo_data_cubit.dart';

class  RepoDataState {

  List<Repo> repoList = [];
  List<String> selectedRepoUrlList = [];

  RepoDataState init() {
    return RepoDataState()
      ..repoList = []
      ..selectedRepoUrlList = [];
  }

  RepoDataState clone() {
    return RepoDataState()
      ..selectedRepoUrlList = selectedRepoUrlList
      ..repoList = repoList;
  }

  List<Repo> deepCloneRepoList() {
    List<Repo> newList = [];
    for(Repo repo in repoList) {
      newList.add(repo.clone());
    }
    return newList;
  }
}
