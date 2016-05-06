# Roadmap

The current scope of FakeMaker is to make it easier to write unit tests for episerver code. The main usage is most likely writing unit tests for mvc controllers or custom helpers that expect to have episerver repositories returning episerver content.

FakeMaker takes care of mocking and a simplifies creating fake content, that you can use when testing your controllers.

This is the current roadmap for FakeMaker: 

#### Feature: Commerce support
* FakeMaker should support creating fake Products and adding them to the repositories.
* Commerce support in a separate NuGet Package.

#### Tech: refactorings
* Rewrite FakeMaker to support features in an "add on"/"modular" style.
* Simplify the unit test examples. Currently they are in fact the unit tests for the FakeMaker code itself. They should be written as examples to help users get started.
* Move, rewrite and add unit tests for the FakeMaker code into separate projects (i.e. "FakeMaker.tests" and "FakeMaker.Commerce.tests" projects)
