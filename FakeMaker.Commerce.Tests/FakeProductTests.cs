using EPiServer.Commerce.Catalog.ContentTypes;
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
    }
}

