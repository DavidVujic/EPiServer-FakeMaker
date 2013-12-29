using System;
using System.Collections.Generic;
using System.Linq;
using EPiServer;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using NUnit.Framework;

namespace FakeMaker.Examples
{
	[TestFixture]
	public class ExampleUnitTests
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
				.IsChildOf(root);

			FakePage
				.Create("About us")
				.IsChildOf(start);

			_fake.AddToRepository(root);

			// Act
			var descendants = ExampleFindPagesHelper.GetDescendantsOf(root.Page.ContentLink, _fake.ContentRepository);

			//Assert
			Assert.That(descendants.Count(), Is.EqualTo(2));
		}

		[Test]
		public void Get_descendants_by_using_ServiceLocator()
		{
			// Arrange
			var root = FakePage
				.Create("Root");

			var start = FakePage
				.Create("Start")
				.IsChildOf(root);

			FakePage
				.Create("About us")
				.IsChildOf(start);

			_fake.AddToRepository(root);

			// Act
			var descendants = ExampleFindPagesHelper.GetDescendantsOf(root.Page.ContentLink);

			//Assert
			Assert.That(descendants.Count(), Is.EqualTo(2));
		}

		[Test]
		public void Get_children_of_first_child()
		{
			// Arrange
			var root = FakePage
				.Create("Root");

			FakePage
				.Create("my page")
				.IsChildOf(root);
			
			var start = FakePage
				.Create("Start")
				.IsChildOf(root);

			FakePage
				.Create("About us")
				.IsChildOf(start);

			FakePage
				.Create("Our services")
				.IsChildOf(start);

			_fake.AddToRepository(root);

			// Act
			var children = ExampleFindPagesHelper.GetDescendantsOf(start.Page.ContentLink, _fake.ContentRepository);

			//Assert
			Assert.That(children.Count(), Is.EqualTo(2));
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
				.IsChildOf(root)
				.PublishedOn(lastWeek);

			FakePage
				.Create("About us")
				.IsChildOf(start)
				.PublishedOn(lastWeek, yesterday);

			FakePage
				.Create("Our services")
				.IsChildOf(start)
				.PublishedOn(lastWeek);

			_fake.AddToRepository(root);

			// Act
			var pages = ExampleFindPagesHelper.GetAllPublishedPages(root.Page.ContentLink, _fake.ContentRepository);

			//Assert
			Assert.That(pages.Count(), Is.EqualTo(2));
		}

		[Test]
		public void Get_pages_visible_in_menu()
		{
			// Arrange
			var root = FakePage.Create("root");

			FakePage.Create("AboutUs").IsChildOf(root).IsVisibleInMenu();
			FakePage.Create("OtherPage").IsChildOf(root).IsHiddenFromMenu();
			FakePage.Create("Contact").IsChildOf(root).IsVisibleInMenu();

			_fake.AddToRepository(root);

			// Act
			var pages = ExampleFindPagesHelper.GetMenu(root.Page.ContentLink, _fake.ContentRepository);

			// Assert
			Assert.That(pages.Count(), Is.EqualTo(2));
		}

		[Test]
		public void Get_pages_of_certain_pagedata_type()
		{
			// Arrange
			var root = FakePage.Create("root");

			FakePage.Create("AboutUs").IsChildOf(root);
			FakePage.Create<CustomPageData>("OtherPage").IsChildOf(root);
			FakePage.Create("Contact").IsChildOf(root);

			_fake.AddToRepository(root);

			// Act
			var pages = ExampleFindPagesHelper.GetDescendantsOf<CustomPageData>(root.Page.ContentLink, _fake.ContentRepository);

			// Assert
			Assert.That(pages.Count(), Is.EqualTo(1));
		}
	}

	public class CustomPageData : PageData
	{
		public string CustomPageName { get; set; }
	}

	/// <summary>
	/// This is an example of a helper class.
	/// The repository is injected to the class.
	/// </summary>
	public static class ExampleFindPagesHelper
	{
		public static IEnumerable<IContent> GetChildrenOf(ContentReference root, IContentRepository repository)
		{
			return repository.GetChildren<IContent>(root);
		}

		public static IEnumerable<ContentReference> GetDescendantsOf(ContentReference root, IContentRepository repository)
		{
			return repository.GetDescendents(root);
		}

		public static IEnumerable<ContentReference> GetDescendantsOf(ContentReference root)
		{
			var repository = ServiceLocator.Current.GetInstance<IContentRepository>();

			return repository.GetDescendents(root);
		}

		public static IEnumerable<IContent> GetDescendantsOf<T>(ContentReference root, IContentRepository repository)
			where T : PageData
		{
			var descendants = GetDescendantsOf(root, repository);
			var pages = descendants
				.Select(repository.Get<IContent>)
				.OfType<T>();

			return pages;
		}

		public static IEnumerable<IContent> GetAllPublishedPages(ContentReference root, IContentRepository repository)
		{
			var descendants = GetDescendantsOf(root, repository);

			var references = descendants
				.Where(item => ToPage(item, repository).CheckPublishedStatus(PagePublishedStatus.Published));

			return references.Select(reference => ToPage(reference, repository)).Cast<IContent>().ToList();
		}

		private static PageData ToPage(ContentReference reference, IContentLoader repository)
		{
			var page = repository.Get<PageData>(reference);

			return page;
		}

		public static IEnumerable<IContent> GetMenu(ContentReference reference, IContentRepository repository)
		{
			var children = repository.GetChildren<PageData>(reference);

			return children.Where(page => page.VisibleInMenu).ToList();
		}
	}
}
