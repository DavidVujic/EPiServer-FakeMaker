using EPiFakeMaker;
using EPiServer.Commerce.Catalog.ContentTypes;
using EPiServer.Core;
using System;
using System.Collections.Generic;

namespace FakeMaker.Commerce
{
    public class FakeProduct : Fake
    {
        private readonly IList<IFake> _children;
        private static readonly Random Randomizer = new Random();

        private FakeProduct()
        {
            _children = new List<IFake>();
        }

        /// <summary>
        /// Convenience feature that convert the Content property to EntryContentBase
        /// </summary>
        public virtual EntryContentBase Product
        {
            get
            {
                return To<EntryContentBase>();
            }
        }

        public override IContent Content { get; protected set; }
        public override IList<IFake> Children { get { return _children; } }

        public static FakeProduct Create<T>(string productName) where T : EntryContentBase, new()
        {
            var fake = new FakeProduct { Content = new T() };

            return fake;
        }

        public virtual T To<T>() where T : class, IContent
        {
            return Content as T;
        }

        internal override void HelpCreatingMockForCurrentType(IFakeMaker maker)
        {
            throw new NotImplementedException();
        }
    }
}
