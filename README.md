[![Build status](https://ci.appveyor.com/api/projects/status/jk8x396fet3lxu84/branch/master?svg=true)](https://ci.appveyor.com/project/DavidVujic/episerver-fakemaker/branch/master)


﻿Help features for test driving EPiServer CMS
========

There is also a __NuGet__ package: https://www.nuget.org/packages/FakeMaker/

___New!___ There is also a NuGet package for FakeMaker.Commerce:
https://www.nuget.org/packages/FakeMaker.Commerce/

## What is FakeMaker?
FakeMaker takes care of mocking and a simplifies creating fake content, that you can use when testing your code.

Unit testing the EPiServer CMS got a whole lot easier with version 7. However, creating fake content to be used when setting up mocked repositories isn't that smooth, right?

When mocking of code is all you see on your screen, this little library may help. A bigger screen probably also would, but is probably more expensive. FakeMaker make it easier to write unit tests for mvc controllers and helpers that expect the episerver repositories to return content.

__What about Commerce?__
Yes! FakeMaker now have support for Commerce. Check out the source code or install FakeMaker.Commerce plugin from NuGet. The package currently suppport basic unit testing scenarios. What kind of features are missing? Create an issue here on GitHub and share your feedback, thoughts & ideas!

# Quick Start

## Setup
Just add the FakeMaker NuGet package (there is also a FakeMaker.Commerce package for Commerce projects) to your test project and you are ready. To avoid dependency version issues, make sure your test project has the references set up like the project under test. FakeMaker will use the existing references, otherwise install the version it is built with.

If you prefer using the source code, create a folder called "EPiFakeMaker" in your test project and drop the files _FakeMaker.cs_, _FakePage.cs_, _Fake.cs_ and _IFake.cs_ from the FakeMaker project in there. Also, drop the file _FakeProduct.cs_ if you want the source code for Commerce.

FakeMaker relies on the __Moq__ library and the __EPiServer__ assemblies (currently version 9). The assembly references in the Visual Studio project file are added from both the official NuGet feed and the EPiServer feed if missing in the current project.

## Usage
Have a look at the [Example unit tests](FakeMaker.Examples/ExampleUnitTests.cs), containing some basic scenarios for unit testing with the FakeMaker and FakePage classes. If you want more scenarios, check out the __FakeMaker.Tests__ and ___FakeMaker.Commerce.Tests___ library.

__Roadmap?__
Here is the current [roadmap](ROADMAP.md).

__EPiServer 8 support?__
This branch depends on EPiServer CMS version 9 references. Need version 8 support? Clone this repository and checkout the __epi-8-support__ branch.

#### Create an instance of FakeMaker:

```cs
var fake = new FakeMaker();
```

#### Create the pages you need:

```cs
var page = FakePage.Create("MyPageName");
```

or a page of a specific page type:

```cs
FakePage.Create<CustomPageData>("MyOtherPageName");
```

#### Add it to the mocked repository (will be added to both IContentRepository and IContentLoader):

```cs
fake.AddToRepository(page);
```

#### Get the mocked instance of the repository:

```cs
var repository = fake.ContentRepository;
```
or

```cs
var loader = fake.ContentLoader;
```

#### Cast FakePage to PageData

```cs
var page = FakePage.Create("MyPageName").To<PageData>();
```

You can pass in the fake repository to the code you are about to test, by injecting it to the class (aka Dependency Injection).

You can also use
```cs
var repository = ServiceLocator.Current.GetInstance<IContentRepository>();
```
or

```cs
var loader = ServiceLocator.Current.GetInstance<IContentLoader>();
```

as an alternative to Dependency Injection in your code under test.

#### Create fake Commerce products

```cs
var product = FakeProduct.Create<ProductContent>("My Fake Product");
```
and add it to the repository, just like with pages.

```cs
fake.AddToRepository(product);
```

__Please contact me if you have feedback or questions!__
