using EPiServer;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;

namespace EPiFakeMaker
{
    public interface IFakeMaker
    {
        void CreateMockFor<T>(IFake item) where T : class, IContentData;
        void CreateMockFor<T>(IFake parent, IList<IFake> fakeList) where T : class, IContentData;

        void CreateMockFor(IFake fake, Expression<Func<IContentRepository, IContent>> expression);
        void CreateMockFor(IFake fake, Expression<Func<IContentLoader, IContent>> expression);
    }

    public class FakeMaker : IFakeMaker
    {
        private readonly Mock<IContentRepository> _contentRepo;
        private readonly Mock<IContentLoader> _contentLoader;

        public IContentRepository ContentRepository { get { return _contentRepo.Object; } }
        public IContentLoader ContentLoader { get { return _contentLoader.Object; } }

        public FakeMaker(bool prepareServiceLocatorWithFakeRepository = true)
        {
            _contentRepo = new Mock<IContentRepository>();
            _contentLoader = new Mock<IContentLoader>();

            if (!prepareServiceLocatorWithFakeRepository)
            {
                return;
            }

            PrepareServiceLocatorWith(_contentRepo.Object, _contentLoader.Object);
        }

        public Mock<IContentRepository> GetMockForFakeContentRepository()
        {
            return _contentRepo;
        }

        public Mock<IContentLoader> GetMockForFakeContentLoader()
        {
            return _contentLoader;
        }

        public void AddToRepository(IFake fake)
        {
            CreateMockFor<IContent>(fake);
            CreateMockFor<IContentData>(fake);
            CreateMockFor<ContentData>(fake);

            (fake as Fake).HelpCreatingMockForCurrentType(this);

            AddToRepository(fake.Children, fake);
        }

        private static void PrepareServiceLocatorWith<T, T2>(T repo, T2 loader)
        {
            var serviceLocator = new Mock<IServiceLocator>();

            serviceLocator
                .Setup(locator => locator.GetInstance<T>())
                .Returns(repo);

            serviceLocator
                .Setup(locator => locator.GetInstance<T2>())
                .Returns(loader);

            ServiceLocator.SetLocator(serviceLocator.Object);
        }

        private void AddToRepository(IList<IFake> fakeList, IFake parent)
        {
            CreateMockFor<IContent>(parent, fakeList);
            CreateMockFor<IContentData>(parent, fakeList);
            CreateMockFor<ContentData>(parent, fakeList);

            var parentDescendants = GetDescendantsOf(parent, new List<IContent>());

            _contentRepo
                .Setup(repo => repo.GetDescendents(parent.Content.ContentLink))
                .Returns(parentDescendants);

            _contentLoader
                .Setup(repo => repo.GetDescendents(parent.Content.ContentLink))
                .Returns(parentDescendants);

            foreach (var fake in fakeList)
            {
                var item = fake;

                CreateMockFor<IContent>(fake);
                CreateMockFor<IContentData>(fake);
                CreateMockFor<ContentData>(fake);

                (fake as Fake).HelpCreatingMockForCurrentType(this);

                var pageDescendants = GetDescendantsOf(item, new List<IContent>());

                _contentRepo
                    .Setup(repo => repo.GetDescendents(item.Content.ContentLink))
                    .Returns(pageDescendants);

                AddToRepository(item.Children, item);
            }
        }

        public void CreateMockFor<T>(IFake item) where T : class, IContentData
        {
            _contentRepo
                .Setup(repo => repo.Get<T>(item.Content.ContentLink))
                .Returns(item.Content as T);

            _contentLoader
                .Setup(repo => repo.Get<T>(item.Content.ContentLink))
                .Returns(item.Content as T);
        }

        public void CreateMockFor<T>(IFake parent, IList<IFake> fakeList) where T : class, IContentData
        {
            var contentList = fakeList.Select(fake => fake.Content as T).ToList();

            _contentRepo
                .Setup(repo => repo.GetChildren<T>(parent.Content.ContentLink))
                .Returns(contentList);

            _contentLoader
                .Setup(repo => repo.GetChildren<T>(parent.Content.ContentLink))
                .Returns(contentList);
        }

        public void CreateMockFor(IFake fake, Expression<Func<IContentRepository, IContent>> expression)
        {
            _contentRepo
                .Setup(expression)
                .Returns(fake.Content);
        }

        public void CreateMockFor(IFake fake, Expression<Func<IContentLoader, IContent>> expression)
        {
            _contentLoader
                .Setup(expression)
                .Returns(fake.Content);
        }

        private static IEnumerable<ContentReference> GetDescendantsOf(IFake fake, ICollection<IContent> descendants)
        {
            foreach (var child in fake.Children)
            {
                descendants.Add(child.Content);

                GetDescendantsOf(child, descendants);
            }

            return descendants.Select(descendant => descendant.ContentLink).ToList();
        }
    }
}
