using EPiServer;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using Moq;
using System.Collections.Generic;
using System.Linq;

namespace EPiFakeMaker
{
    public class FakeMaker
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

        public void AddToRepository(FakePage fake)
        {
            CreateMockFor<IContent>(fake);
            CreateMockFor<IContentData>(fake);

            CreateMockFor<PageData>(fake);
            CreateMockFor<ContentData>(fake);

            _contentRepo
                .Setup(fake.RepoGet)
                .Returns(fake.Page);

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

        private void AddToRepository(IList<FakePage> fakeList, FakePage parent)
        {
            CreateMockFor<IContent>(parent, fakeList);
            CreateMockFor<IContentData>(parent, fakeList);

            CreateMockFor<PageData>(parent, fakeList);
            CreateMockFor<ContentData>(parent, fakeList);

            var parentDescendants = GetDescendantsOf(parent, new List<IContent>());

            _contentRepo
                .Setup(repo => repo.GetDescendents(parent.Page.ContentLink))
                .Returns(parentDescendants);

            _contentLoader
                .Setup(repo => repo.GetDescendents(parent.Page.ContentLink))
                .Returns(parentDescendants);

            foreach (var fake in fakeList)
            {
                var item = fake;

                CreateMockFor<IContent>(item);

                _contentRepo
                    .Setup(item.RepoGet)
                    .Returns(item.Page);

                var pageDescendants = GetDescendantsOf(item, new List<IContent>());

                _contentRepo
                    .Setup(repo => repo.GetDescendents(item.Page.ContentLink))
                    .Returns(pageDescendants);

                AddToRepository(item.Children, item);
            }
        }

        private void CreateMockFor<T>(FakePage item) where T : class, IContentData
        {
            _contentRepo
                .Setup(repo => repo.Get<T>(item.Page.ContentLink))
                .Returns(item.Page as T);

            _contentLoader
                .Setup(repo => repo.Get<T>(item.Page.ContentLink))
                .Returns(item.Page as T);
        }

        private void CreateMockFor<T>(FakePage parent, IList<FakePage> fakeList) where T : class, IContentData
        {
            var contentList = fakeList.Select(fake => fake.Page as T).ToList();

            _contentRepo
                .Setup(repo => repo.GetChildren<T>(parent.Page.ContentLink))
                .Returns(contentList);

            _contentLoader
                .Setup(repo => repo.GetChildren<T>(parent.Page.ContentLink))
                .Returns(contentList);
        }

        private static IEnumerable<ContentReference> GetDescendantsOf(FakePage fake, ICollection<IContent> descendants)
        {
            foreach (var child in fake.Children)
            {
                descendants.Add(child.Page);

                GetDescendantsOf(child, descendants);
            }

            return descendants.Select(descendant => descendant.ContentLink).ToList();
        }
    }
}
