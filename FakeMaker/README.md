# Quick Start

Have a look at the __ExampleUnitTests.cs__, containing some basic scenarios for unit testing with the FakeMaker and FakePage classes.

FakeMaker relies on the __Moq__ library and the __EPiServer__ assemblies (currently version 9). The assembly references in the Visual Studio project file are added from both the official NuGet feed and the EPiServer feed.

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
var repository = ServiceLocator.Current.GetRepository<IContentRepository>();
```
or

```cs 
var loader = ServiceLocator.Current.GetInstance<IContentLoader>();
```

as an alternative to Dependency Injection in your code under test.

__Please contact me if you have feedback or questions about FakeMaker!__

