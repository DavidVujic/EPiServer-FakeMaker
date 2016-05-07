using System;
using System.Collections.Generic;
using System.Linq;
using EPiServer.Core;
using NUnit.Framework;
using EPiServer.ServiceLocation;
using EPiServer;

namespace EPiFakeMaker.Tests
{
    [TestFixture]
    public class FakeMakerTests
    {
        private FakeMaker _fake;

        [SetUp]
        public void Setup()
        {
            _fake = new FakeMaker();
        }

        [Test]
        public void Get_descendants()
        {
            // Arrange
            var root = FakePage
                .Create("Root");

            var start = FakePage
                .Create("Start")
                .ChildOf(root);

            FakePage
                .Create("About us")
                .ChildOf(start);

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var descendants_from_repo = repository.GetDescendents(root.Content.ContentLink);
            var descendants_from_loader = loader.GetDescendents(root.Content.ContentLink);

            //Assert
            Assert.That(descendants_from_repo.Count(), Is.EqualTo(2));
            Assert.That(descendants_from_loader.Count(), Is.EqualTo(2));
        }

        [Test]
        public void Get_descendants_by_using_ServiceLocator()
        {
            // Arrange
            var root = FakePage
                .Create("Root");

            var start = FakePage
                .Create("Start")
                .ChildOf(root);

            FakePage
                .Create("About us")
                .ChildOf(start);

            _fake.AddToRepository(root);

            var repository = ServiceLocator.Current.GetInstance<IContentRepository>();
            var loader = ServiceLocator.Current.GetInstance<IContentLoader>();

            // Act
            var descendants_from_repo = repository.GetDescendents(root.Content.ContentLink);
            var descendants_from_loader = loader.GetDescendents(root.Content.ContentLink);

            //Assert
            Assert.That(descendants_from_repo.Count(), Is.EqualTo(2));
            Assert.That(descendants_from_loader.Count(), Is.EqualTo(2));
        }

        [Test]
        public void Get_published_only_pages()
        {
            // Arrange
            var lastWeek = DateTime.Today.AddDays(-7);
            var yesterday = DateTime.Today.AddDays(-1);

            var root = FakePage
                .Create("Root");

            var start = FakePage
                .Create("Start")
                .ChildOf(root)
                .PublishedOn(lastWeek);

            FakePage
                .Create("About us")
                .ChildOf(start)
                .PublishedOn(lastWeek, yesterday);

            FakePage
                .Create("Our services")
                .ChildOf(start)
                .PublishedOn(lastWeek);

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var pages_from_repo = GetAllPublishedPages(root.Content.ContentLink, repository);
            var pages_from_loader = GetAllPublishedPages(root.Content.ContentLink, loader);

            //Assert
            Assert.That(pages_from_repo.Count(), Is.EqualTo(2));
            Assert.That(pages_from_loader.Count(), Is.EqualTo(2));
        }

        [Test]
        public void Get_pages_visible_in_menu()
        {
            // Arrange
            var root = FakePage.Create("root");

            FakePage
                .Create("AboutUs")
                .ChildOf(root)
                .VisibleInMenu();

            FakePage
                .Create("OtherPage")
                .ChildOf(root)
                .HiddenFromMenu();

            FakePage
                .Create("Contact")
                .ChildOf(root)
                .VisibleInMenu();

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var pages_from_repo = GetMenu(root.Content.ContentLink, repository);
            var pages_from_loader = GetMenu(root.Content.ContentLink, repository);

            // Assert
            Assert.That(pages_from_repo.Count(), Is.EqualTo(2));
            Assert.That(pages_from_loader.Count(), Is.EqualTo(2));
        }

        private static IEnumerable<IContent> GetMenu(ContentReference reference, IContentRepository repository)
        {
            var children = repository.GetChildren<PageData>(reference);

            return children.Where(page => page.VisibleInMenu).ToList();
        }

        [Test]
        public void Get_pages_of_certain_pagedata_type()
        {
            // Arrange
            var root = FakePage
                .Create("root");

            FakePage
                .Create("AboutUs")
                .ChildOf(root);

            FakePage
                .Create<CustomPageData>("OtherPage")
                .ChildOf(root);

            FakePage
                .Create("Contact")
                .ChildOf(root);

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var pages_from_repo = GetDescendantsOf<CustomPageData>(root.Content.ContentLink, repository);
            var pages_from_loader = GetDescendantsOf<CustomPageData>(root.Content.ContentLink, loader);

            // Assert
            Assert.That(pages_from_repo.Count(), Is.EqualTo(1));
            Assert.That(pages_from_loader.Count(), Is.EqualTo(1));
        }

        [Test]
        public void Get_pages_with_certain_pagetypeid()
        {
            // Arrange
            var root = FakePage.Create("root");

            FakePage
                .Create("AboutUs")
                .ChildOf(root)
                .WithContentTypeId(1);

            FakePage
                .Create("OtherPage")
                .ChildOf(root)
                .WithContentTypeId(2);

            FakePage
                .Create("Contact")
                .ChildOf(root)
                .WithContentTypeId(3);

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act

            var pages_from_repo = repository.GetChildren<IContent>(root.Content.ContentLink).Where(p => p.ContentTypeID == 2);
            var pages_from_loader = loader.GetChildren<IContent>(root.Content.ContentLink).Where(p => p.ContentTypeID == 2);

            // Assert
            Assert.That(pages_from_repo.Count(), Is.EqualTo(1));
            Assert.That(pages_from_loader.Count(), Is.EqualTo(1));
        }

        [Test]
        public void Get_pages_with_custom_property()
        {
            // Arrange
            var root = FakePage.Create("root");

            FakePage
                .Create("AboutUs")
                .ChildOf(root);

            FakePage
                .Create("OtherPage")
                .ChildOf(root)
                .WithProperty("CustomProperty", new PropertyString("Custom value"));

            FakePage
                .Create("Contact")
                .ChildOf(root);

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var pages_from_repo =
                repository.GetChildren<IContent>(root.Content.ContentLink)
                    .Where(content => content.Property["CustomProperty"] != null && content.Property["CustomProperty"].Value.ToString() == "Custom value");

            var pages_from_loader =
                loader.GetChildren<IContent>(root.Content.ContentLink)
                    .Where(content => content.Property["CustomProperty"] != null && content.Property["CustomProperty"].Value.ToString() == "Custom value");

            // Assert
            Assert.That(pages_from_repo.Count(), Is.EqualTo(1));
            Assert.That(pages_from_loader.Count(), Is.EqualTo(1));
        }

        [Test]
        public void Get_pages_with_certain_languagebranch()
        {
            // Arrange
            var root = FakePage.Create("root").WithLanguageBranch("en");

            FakePage
                .Create("AboutUs")
                .ChildOf(root)
                .WithLanguageBranch("en");

            FakePage
                .Create("OtherPage")
                .ChildOf(root)
                .WithLanguageBranch("sv");

            FakePage.
                Create("Contact")
                .ChildOf(root)
                .WithLanguageBranch("en");

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var pages_from_repo =
                repository.GetChildren<IContent>(root.Content.ContentLink)
                    .Where(content => content is PageData && ((PageData)content).LanguageBranch == "sv");

            var pages_from_loader =
                loader.GetChildren<IContent>(root.Content.ContentLink)
                    .Where(content => content is PageData && ((PageData)content).LanguageBranch == "sv");

            // Assert
            Assert.That(pages_from_repo.Count(), Is.EqualTo(1));
            Assert.That(pages_from_loader.Count(), Is.EqualTo(1));
        }

        [Test]
        public void Get_descendants_from_with_children()
        {
            // Arrange
            var root =
                FakePage.Create("root")
                    .WithChildren(
                        new List<FakePage>
                            {
                                FakePage.Create("AboutUs"),
                                FakePage.Create("News").WithChildren(new List<FakePage>
                                        {
                                            FakePage.Create("News item 1"),
                                            FakePage.Create("News item 2")
                                        }),
                                FakePage.Create("Contact")
                            });


            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var pages_from_repo = repository.GetDescendents(root.Content.ContentLink);
            var pages_from_loader = loader.GetDescendents(root.Content.ContentLink);

            // Assert
            Assert.That(pages_from_repo.Count(), Is.EqualTo(5));
            Assert.That(pages_from_loader.Count(), Is.EqualTo(5));
        }

        [Test]
        public void Set_a_page_as_start_page()
        {
            var root = FakePage
                .Create<PageData>("Root");

            var start = FakePage
                .Create<PageData>("Start")
                .ChildOf(root)
                .AsStartPage();

            FakePage
                .Create<PageData>("Child")
                .ChildOf(start);

            _fake.AddToRepository(root);

            Assert.That(ContentReference.StartPage, Is.EqualTo(start.Content.ContentLink));
        }

        [Test]
        public void Get_page_of_explicit_page_type()
        {
            // Arrange
            var customPage = FakePage
                .Create<CustomPageData>("MyCustomPage");

            _fake.AddToRepository(customPage);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var result_from_repo = repository.Get<CustomPageData>(customPage.Content.ContentLink);
            var result_from_loader = loader.Get<CustomPageData>(customPage.Content.ContentLink);

            // Assert
            Assert.IsNotNull(result_from_repo);
            Assert.IsNotNull(result_from_loader);
        }

        [Test]
        public void Get_page_of_explicit_base_page_type()
        {
            // Arrange
            var fakePage = FakePage
                .Create<InteritsCustomPageData>("MyInheritedCustomPage");

            _fake.AddToRepository(fakePage);

            // Custom mocking that is not handled by FakeMaker
            _fake.GetMockForFakeContentRepository()
                .Setup(repo => repo.Get<CustomPageData>(fakePage.Content.ContentLink))
                .Returns(fakePage.To<CustomPageData>());

            // Act
            var result = _fake.ContentRepository.Get<CustomPageData>(fakePage.Content.ContentLink);

            // Assert
            Assert.IsNotNull(result);
            Assert.That(result is InteritsCustomPageData);
        }

        [Test]
        public void Get_children_as_explicit_page_type()
        {
            // Arrange
            var root = FakePage
                .Create("Root");

            var start = FakePage
                .Create("Start")
                .ChildOf(root).AsStartPage();

            var aboutUs = FakePage
                .Create<CustomPageData>("About us")
                .ChildOf(start);

            _fake.AddToRepository(root);

            var customPageDataList = new List<CustomPageData> { aboutUs.To<CustomPageData>() };

            // Custom mocking that is not handled by FakeMaker
            _fake.GetMockForFakeContentRepository()
                .Setup(repo => repo.GetChildren<CustomPageData>(ContentReference.StartPage))
                .Returns(customPageDataList);

            // Act
            var children = _fake.ContentRepository.GetChildren<CustomPageData>(ContentReference.StartPage);

            // Assert
            Assert.That(children.Count(), Is.EqualTo(1));
        }

        [Test]
        public void Get_instance_of_base_type()
        {
            // Arrange
            var fakePage = FakePage.Create("MyPage");

            _fake.AddToRepository(fakePage);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var result_from_repo = repository.Get<ContentData>(fakePage.Content.ContentLink);
            var result_from_loader = loader.Get<ContentData>(fakePage.Content.ContentLink);

            // Assert
            Assert.IsNotNull(result_from_repo);
            Assert.That(result_from_repo is ContentData);

            Assert.IsNotNull(result_from_loader);
            Assert.That(result_from_loader is ContentData);
        }

        [Test]
        public void Get_instance_of_base_interface_type()
        {
            // Arrange
            var fakePage = FakePage.Create("MyPage");

            _fake.AddToRepository(fakePage);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var result_from_repo = repository.Get<IContentData>(fakePage.Content.ContentLink);
            var result_from_loader = loader.Get<IContentData>(fakePage.Content.ContentLink);

            // Assert
            Assert.IsNotNull(result_from_repo);
            Assert.That(result_from_repo is IContentData);

            Assert.IsNotNull(result_from_loader);
            Assert.That(result_from_loader is IContentData);
        }

        [Test]
        public void Get_instance_of_pagedata_with_derived_class()
        {
            // Arrange
            var fakePage = FakePage.Create<CustomPageData>("MyPage");

            _fake.AddToRepository(fakePage);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var result_from_repo = repository.Get<PageData>(fakePage.Content.ContentLink);
            var result_from_loader = loader.Get<PageData>(fakePage.Content.ContentLink);

            // Assert
            Assert.IsNotNull(result_from_repo);
            Assert.That(result_from_repo is PageData);

            Assert.IsNotNull(result_from_loader);
            Assert.That(result_from_loader is PageData);
        }

        [Test]
        public void Get_children_as_base_content_type()
        {
            // Arrange
            var root = FakePage
                .Create("Root");

            var start = FakePage
                .Create("Start")
                .ChildOf(root).AsStartPage();

            var aboutUs = FakePage
                .Create("About us")
                .ChildOf(start);

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var children_from_repo = repository.GetChildren<ContentData>(ContentReference.StartPage);
            var children_from_loader = loader.GetChildren<ContentData>(ContentReference.StartPage);

            // Assert
            Assert.That(children_from_repo.Count(), Is.EqualTo(1));
            Assert.That(children_from_loader.Count(), Is.EqualTo(1));
        }

        [Test]
        public void Get_children_as_base_content_interface_type()
        {
            // Arrange
            var root = FakePage
                .Create("Root");

            var start = FakePage
                .Create("Start")
                .ChildOf(root).AsStartPage();

            var aboutUs = FakePage
                .Create("About us")
                .ChildOf(start);

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var children_from_repo = repository.GetChildren<IContentData>(ContentReference.StartPage);
            var children_from_loader = loader.GetChildren<IContentData>(ContentReference.StartPage);

            // Assert
            Assert.That(children_from_repo.Count(), Is.EqualTo(1));
            Assert.That(children_from_loader.Count(), Is.EqualTo(1));
        }

        [Test]
        public void Get_children()
        {
            // Arrange
            var root = FakePage.Create("root");

            FakePage
                .Create("AboutUs")
                .ChildOf(root);

            FakePage
                .Create("OtherPage")
                .ChildOf(root);

            FakePage
                .Create("Contact")
                .ChildOf(root);

            _fake.AddToRepository(root);

            // An instance of IContentRepository that you can use for Dependency Injection
            var repository = _fake.ContentRepository;

            // Or, an instance of IContentLoader that you can use for Dependency Injection
            var loader = _fake.ContentLoader;

            // Act
            var pages_from_repo = repository.GetChildren<IContent>(root.Content.ContentLink);
            var pages_from_loader = loader.GetChildren<IContent>(root.Content.ContentLink);

            // Assert
            Assert.That(pages_from_repo.Count(), Is.EqualTo(3));
            Assert.That(pages_from_loader.Count(), Is.EqualTo(3));
        }

        [Test]
        public void Get_content_as_page()
        {
            var fake = FakePage.Create("MyPage");

            Assert.That(fake.Page, Is.Not.Null);
        }

        private static IEnumerable<IContent> GetAllPublishedPages(ContentReference root, IContentLoader repository)
        {
            var descendants = GetDescendantsOf(root, repository);

            var references = descendants
                .Where(item => ToPage(item, repository).CheckPublishedStatus(PagePublishedStatus.Published));

            return references.Select(reference => ToPage(reference, repository)).Cast<IContent>().ToList();
        }

        private static IEnumerable<IContent> GetDescendantsOf<T>(ContentReference root, IContentLoader repository)
            where T : PageData
        {
            var descendants = GetDescendantsOf(root, repository);
            var pages = descendants
                .Select(repository.Get<IContent>)
                .OfType<T>();

            return pages;
        }

        private static IEnumerable<ContentReference> GetDescendantsOf(ContentReference root, IContentLoader repository)
        {
            return repository.GetDescendents(root);
        }

        private static PageData ToPage(ContentReference reference, IContentLoader repository)
        {
            var page = repository.Get<PageData>(reference);

            return page;
        }
    }

    public class CustomPageData : PageData
    {
        public string CustomPageName { get; set; }
    }

    public class InteritsCustomPageData : CustomPageData
    {
    }
}
