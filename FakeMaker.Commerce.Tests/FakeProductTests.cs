using EPiServer;
using EPiServer.Commerce.Catalog.ContentTypes;
using EPiServer.ServiceLocation;
using FakeMaker.Commerce;
using NUnit.Framework;

namespace EPiFakeMaker.Commerce.Tests
{
    [TestFixture]
    public class FakeProductTests
    {
        private FakeMaker _fake;

        [SetUp]
        public void Setup()
        {
            _fake = new FakeMaker();
        }

        [Test]
        public void Create_product_with_reference_id()
        {
            var product = FakeProduct.Create<ProductContent>("My Fake Product");

            Assert.IsNotNull(product.Content.ContentLink);
        }

        [Test]
        public void Get_product_by_using_ServiceLocator()
        {
            // Arrange
            var fakePhone = FakeProduct.Create<ProductContent>("My Fake Phone");

            _fake.AddToRepository(fakePhone);

            var repo = ServiceLocator.Current.GetInstance<IContentRepository>();
            var loader = ServiceLocator.Current.GetInstance<IContentLoader>();

            // Act
            var phoneFromLoader = loader.Get<ProductContent>(fakePhone.Content.ContentLink);
            var phoneFromRepo = repo.Get<ProductContent>(fakePhone.Content.ContentLink);

            //Assert
            Assert.IsNotNull(phoneFromLoader);
            Assert.IsNotNull(phoneFromRepo);
        }
    }
}

