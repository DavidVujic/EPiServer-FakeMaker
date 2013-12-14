using System;
using System.Collections.Generic;
using System.Linq;
using EPiServer;
using EPiServer.BaseLibrary;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using Moq;

namespace FakeMaker
{
	public class FakeMaker
	{
		private readonly Mock<IContentRepository> _contentRepo;

		public IContentRepository ContentRepository { get { return _contentRepo.Object; } }

		public FakeMaker(bool prepareServiceLocatorWithFakeRepository = true)
		{
			SetupMocksForClassFactory();

			_contentRepo = new Mock<IContentRepository>();

			if (!prepareServiceLocatorWithFakeRepository)
			{
				return;
			}

			PrepareServiceLocatorWith(_contentRepo.Object);
		}

		public Mock<IContentRepository> GetMockForFakeContentRepository()
		{
			return _contentRepo;
		}

		public void AddToRepository(IContent content)
		{
			_contentRepo
				.Setup(repo => repo.Get<IContent>(content.ContentLink))
				.Returns(content);

			_contentRepo
				.Setup(repo => repo.Get<PageData>(content.ContentLink))
				.Returns(content as PageData);

			var testPage = content as FakePage;

			if (testPage == null)
			{
				return;
			}

			AddToRepository(testPage.Children, testPage);
		}

		private static void SetupMocksForClassFactory()
		{
			var fakeEpiBaseLibraryContext = new Mock<IContext>();
			fakeEpiBaseLibraryContext
				.Setup(fake => fake.RequestTime)
				.Returns(DateTime.Now);

			var fakeBaseFactory = new Mock<IBaseLibraryFactory>();
			fakeBaseFactory
				.Setup(factory => factory.CreateContext())
				.Returns(fakeEpiBaseLibraryContext.Object);

			ClassFactory.Instance = fakeBaseFactory.Object;
		}

		private static void PrepareServiceLocatorWith<T>(T repository)
		{
			var serviceLocator = new Mock<IServiceLocator>();

			serviceLocator
				.Setup(locator => locator.GetInstance<T>())
				.Returns(repository);

			ServiceLocator.SetLocator(serviceLocator.Object);
		}

		private void AddToRepository(IList<IContent> contentList, IContent parent)
		{
			_contentRepo
				.Setup(repo => repo.GetChildren<IContent>(parent.ContentLink))
				.Returns(contentList);


			var pageDataList = contentList.Select(content => content as PageData).ToList();

			_contentRepo
				.Setup(repo => repo.GetChildren<PageData>(parent.ContentLink))
				.Returns(pageDataList);

			var parentDescendants = GetDescendantsOf(parent, new List<IContent>());

			_contentRepo
				.Setup(repo => repo.GetDescendents(parent.ContentLink))
				.Returns(parentDescendants);

			foreach (var content in contentList)
			{
				var page = content as FakePage;

				if (page == null)
				{
					continue;
				}

				_contentRepo
					.Setup(repo => repo.Get<IContent>(page.ContentLink))
					.Returns(content);

				_contentRepo
					.Setup(repo => repo.Get<PageData>(page.ContentLink))
					.Returns(content as PageData);

				var pageDescendants = GetDescendantsOf(page, new List<IContent>());

				_contentRepo
					.Setup(repo => repo.GetDescendents(page.ContentLink))
					.Returns(pageDescendants);

				AddToRepository(page.Children, page);
			}
		}

		private static IEnumerable<ContentReference> GetDescendantsOf(IContent content, ICollection<IContent> descendants)
		{
			var page = content as FakePage;

			if (page == null)
			{
				return new List<ContentReference>();
			}

			foreach (var child in page.Children)
			{
				var testPage = child as FakePage;

				if (testPage == null)
				{
					continue;
				}

				descendants.Add(child);

				GetDescendantsOf(testPage, descendants);
			}

			return descendants.Select(descendant => descendant.ContentLink).ToList();
		}
	}
}
