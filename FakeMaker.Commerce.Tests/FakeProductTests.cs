﻿using EPiServer;
using EPiServer.Commerce.Catalog.ContentTypes;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using NUnit.Framework;
using System.Linq;

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
        public void Create_product_with_default_property_values()
        {
            const string name = "My Fake Product";
            var product = FakeProduct.Create<ProductContent>(name);

            Assert.AreEqual(product.Product.Name, name);
            Assert.AreEqual(product.Product.DisplayName, name);
            Assert.AreEqual(product.Product.Code, name);
        }

        [Test]
        public void Get_product_by_using_ServiceLocator()
        {
            // Arrange
            var fakePhone = FakeProduct.Create<ProductContent>("My Fake Phone");

            _fake.AddToRepository(fakePhone);

            var loader = ServiceLocator.Current.GetInstance<IContentLoader>();
            var repo = ServiceLocator.Current.GetInstance<IContentRepository>();

            // Act
            var phoneFromLoader = loader.Get<ProductContent>(fakePhone.Content.ContentLink);
            var phoneFromRepo = repo.Get<ProductContent>(fakePhone.Content.ContentLink);

            //Assert
            Assert.IsNotNull(phoneFromLoader);
            Assert.IsNotNull(phoneFromRepo);
        }

        [Test]
        public void Set_property_values_to_fake_product()
        {
            // Arrange
            var tomorrow = System.DateTime.Today.AddDays(1);

            var fakePhone = FakeProduct.Create<ProductContent>("My Fake Phone");
            fakePhone.Product.StopPublish = tomorrow;

            _fake.AddToRepository(fakePhone);

            var repo = _fake.ContentLoader;

            // Act
            var phone = repo.Get<ProductContent>(fakePhone.Content.ContentLink);

            //Assert
            Assert.AreEqual(phone.StopPublish, tomorrow);
        }

        [Test]
        public void Get_children()
        {
            var phones = FakeProduct.Create<VariationContent>("phones");

            var phone1 = FakeProduct
                .Create<ProductContent>("iphone standard")
                .ChildOf(phones);

            var phone2 = FakeProduct
                .Create<ProductContent>("iphone gold")
                .ChildOf(phones);

            _fake.AddToRepository(phones);

            // Act
            var products = _fake.ContentRepository.GetChildren<IContent>(phones.Content.ContentLink);

            // Assert
            Assert.That(products.Count(), Is.EqualTo(2));
        }
    }
}

