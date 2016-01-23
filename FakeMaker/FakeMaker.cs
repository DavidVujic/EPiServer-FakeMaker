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

        public IContentRepository ContentRepository { get { return _contentRepo.Object; } }

        public FakeMaker(bool prepareServiceLocatorWithFakeRepository = true)
        {
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

        public void AddToRepository(FakePage fake)
        {
            _contentRepo
                .Setup(repo => repo.Get<IContent>(fake.Page.ContentLink))
                .Returns(fake.Page);

            _contentRepo
                .Setup(repo => repo.Get<PageData>(fake.Page.ContentLink))
                .Returns(fake.Page);

            _contentRepo
                .Setup(fake.RepoGet)
                .Returns(fake.Page);

            AddToRepository(fake.Children, fake);
        }

        private static void PrepareServiceLocatorWith<T>(T repository)
        {
            var serviceLocator = new Mock<IServiceLocator>();

            serviceLocator
                .Setup(locator => locator.GetInstance<T>())
                .Returns(repository);

            ServiceLocator.SetLocator(serviceLocator.Object);
        }

        private void AddToRepository(IList<FakePage> fakeList, FakePage parent)
        {
            var contentList = fakeList.Select(fake => fake.Page).ToList();

            _contentRepo
                .Setup(repo => repo.GetChildren<IContent>(parent.Page.ContentLink))
                .Returns(contentList);

            _contentRepo
                .Setup(repo => repo.GetChildren<PageData>(parent.Page.ContentLink))
                .Returns(contentList);

            var parentDescendants = GetDescendantsOf(parent, new List<IContent>());

            _contentRepo
                .Setup(repo => repo.GetDescendents(parent.Page.ContentLink))
                .Returns(parentDescendants);

            foreach (var fake in fakeList)
            {
                var item = fake;

                _contentRepo
                    .Setup(repo => repo.Get<IContent>(item.Page.ContentLink))
                    .Returns(item.Page);

                _contentRepo
                    .Setup(repo => repo.Get<PageData>(item.Page.ContentLink))
                    .Returns(item.Page);

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
