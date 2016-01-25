Help features for test driving EPiServer CMS 7, 8 and 9
========

__Note__ - This branch (master) depends on EPiServer CMS version 9 references. Need version 8 support? Clone this repository and checkout the __epi-8-support__ branch.

__Update__ - if you don't want the source code, there is a __NuGet__ package: https://www.nuget.org/packages/FakeMaker/

Unit testing the EPiServer CMS got a whole lot easier with version 7. However, creating fake content to be used when setting up mocked repositories isn't that smooth, right?

When mocking of code is all you see on your screen, this little library may help. A bigger screen probably also would, but is probably more expensive.

Check out the example unit tests, using the FakeMaker class that takes care of mocking a repository and populating the ServiceLocator, and also the FakePage class for creating Pages with the ability to set some of the most common properties.

Let me know what you think about it!

