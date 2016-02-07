[![Build status](https://ci.appveyor.com/api/projects/status/jk8x396fet3lxu84/branch/master?svg=true)](https://ci.appveyor.com/project/DavidVujic/episerver-fakemaker/branch/master)


﻿Help features for test driving EPiServer CMS
========

__Note__ - This branch depends on EPiServer CMS version 9 references. Need version 8 support? Clone this repository and checkout the __epi-8-support__ branch.

If you don't want the source code, there is a __NuGet__ package: https://www.nuget.org/packages/FakeMaker/

Unit testing the EPiServer CMS got a whole lot easier with version 7. However, creating fake content to be used when setting up mocked repositories isn't that smooth, right?

When mocking of code is all you see on your screen, this little library may help. A bigger screen probably also would, but is probably more expensive.

Check out the example unit tests, using the FakeMaker class that takes care of mocking a repository and populating the ServiceLocator, and also the FakePage class for creating Pages with the ability to set some of the most common properties.

Let me know what you think about it!


## Quick Start

Have a look at __FakeMaker.Examples/ExampleUnitTests.cs__, it contains some basic scenarios for unit testing with the FakeMaker and FakePage classes.

FakeMaker relies on the __Moq__ library and the __EPiServer__ assemblies (currently the version 9). The assembly references in the Visual Studio project file are added from both the official NuGet feed and the EPiServer feed.

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

#### Add it to the mocked repository:

```cs
fake.AddToRepository(page);
```

#### Get the mocked instance of the repository:

```cs
var repository = fake.ContentRepository;
```

#### Cast FakePage to PageData

```cs
var page = FakePage.Create("MyPageName").To<PageData>();
```

You can pass in the fake repository to the code you are about to test, by injecting it to the class (aka Dependency Injection). The examples uses method parameter injection.

You can also use
```cs
ServiceLocator.Current.GetInstance<IContentRepository>();
```
as an alternative to Dependency Injection in your code under test.

__Please contact me if you have feedback or questions about FakeMaker!__
