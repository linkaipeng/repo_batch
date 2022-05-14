class Repo {

  String? name;
  String? url;
  String? currentBranch;
  String? dirPath;
  List<String> branchList = [];
  List<String> tagList = [];

  Repo();

  Repo clone() {
    List<String> newBranchList = List.of(branchList);
    List<String> newTagList = List.of(tagList);
    return Repo()
      ..name = name
      ..url = url
      ..currentBranch = currentBranch
      ..dirPath = dirPath
      ..tagList = newTagList
      ..branchList = newBranchList;
  }

  @override
  String toString() {
    return 'Repo{name: $name, url: $url, currentBranch: $currentBranch, dirPath: $dirPath, branchList: $branchList, tagList: $tagList}';
  }
}