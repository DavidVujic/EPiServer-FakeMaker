# Roadmap

#### Feature: Commerce support
* FakeMaker should support creating fake Products and adding them to the repositories.
* Commerce support in a separate NuGet Package.

#### Tech: refactorings
* Rewrite FakeMaker to support features in an "add on"/"modular" style.
* Simplify the unit test examples. Currently they are in fact the unit tests for the FakeMaker code itself. They should be written as examples to help users get started.
* Move, rewrite and add unit tests for the FakeMaker code into separate projects (i.e. "FakeMaker.tests" and "FakeMaker.Commerce.tests" projects)
