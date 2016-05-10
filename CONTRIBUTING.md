# Contributing to the development of FakeMaker

Fork this repo, write code and send a pull request to this repo. Easy!

### Guidelines
* Create a branch for the feature you are about to write.
* If possible, isolate the changes in the branch to the feature only. Merges will be easier if general refactorings, that are not specific to the feature, are made in separate branches.
* If possible, avoid dependency updates (like NuGet packages) in the feature branch. The Visual Studio project files quickly get messy and probably will make merging more difficult.
* If possible, send a pull requests early. Don't wait too long, even if the feature is not completely done. The new code can very likely be merged without causing any problems (if the code changes are not of type breaking features). Think of it as "silent releases".
* If you think it is relevant and add value: write unit test(s). They could also be valuable as description of features.
