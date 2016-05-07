using System;
using System.Linq;
using EPiServer.Core;
using NUnit.Framework;
using EPiServer.ServiceLocation;
using EPiServer;

namespace EPiFakeMaker.Examples
{
    [TestFixture]
    public class ExampleUnitTests
    {
        private FakeMaker _fake;
        private FakePage _root;

        [SetUp]
        public void Setup()
        {
            _fake = new FakeMaker();

            // Arrange: create a page tree
            _root = FakePage.Create("root");

            var start = FakePage
                .Create("Start")
                .ChildOf(_root)
                .AsStartPage();

            FakePage
                .Create("AboutUs")
                .ChildOf(_root);

            FakePage
                .Create<CustomPageData>("OtherPage")
                .ChildOf(_root)
                .HiddenFromMenu();

            FakePage
                .Create("Contact")
                .ChildOf(_root);

            FakePage
                .Create("Our sub page")
                .ChildOf(start);

            // Arrange: add the entire page tree to the episerver repository.
            _fake.AddToRepository(_root);
        }

        [Test]
        public void Get_children()
        {
            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Act
            var pages = repository.GetChildren<IContent>(_root.Content.ContentLink);

            // Assert
            Assert.That(pages.Count(), Is.EqualTo(4));
        }

        [Test]
        public void Get_descendants()
        {
            var repository = _fake.ContentRepository;

            // Act
            var descendants = repository.GetDescendents(_root.Content.ContentLink);

            Assert.That(descendants.Count(), Is.EqualTo(5));
        }

        [Test]
        public void Get_descendants_by_using_ServiceLocator()
        {
            var repository = ServiceLocator.Current.GetInstance<IContentRepository>();

            // Act
            var descendants = repository.GetDescendents(_root.Content.ContentLink);

            //Assert
            Assert.That(descendants.Count(), Is.EqualTo(5));
        }

        [Test]
        public void Get_pages_visible_in_menu()
        {
            var repository = _fake.ContentRepository;

            // Act
            var children = repository.GetChildren<PageData>(_root.Content.ContentLink);

            var pages = children.Where(page => page.VisibleInMenu).ToList();

            // Assert
            Assert.That(pages.Count(), Is.EqualTo(3));
        }

        [Test]
        public void Get_pages_of_certain_pagedata_type()
        {
            var repository = _fake.ContentRepository;

            // Act
            var descendants = repository.GetDescendents(_root.Content.ContentLink);
            var pages = descendants
                .Select(repository.Get<IContent>)
                .OfType<CustomPageData>();

            // Assert
            Assert.That(pages.Count(), Is.EqualTo(1));
        }
    }

    public class CustomPageData : PageData
    {
        public string CustomPageName { get; set; }
    }
}
