﻿using EPiFakeMaker;
using EPiServer;
using EPiServer.Commerce.Catalog.ContentTypes;
using EPiServer.Core;
using System;
using System.Collections.Generic;
using System.Linq.Expressions;

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

            fake.WithReferenceId(Randomizer.Next(10, 1000));

            fake.RepoGet = repo => repo.Get<T>(fake.Content.ContentLink);
            fake.LoaderGet = loader => loader.Get<T>(fake.Content.ContentLink);

            return fake;
        }

        public virtual FakeProduct WithReferenceId(int referenceId)
        {
            Content.ContentLink = new ContentReference(referenceId);

            return this;
        }

        public virtual T To<T>() where T : class, IContent
        {
            return Content as T;
        }

        internal Expression<Func<IContentRepository, IContent>> RepoGet { get; private set; }
        internal Expression<Func<IContentLoader, IContent>> LoaderGet { get; private set; }

        internal override void HelpCreatingMockForCurrentType(IFakeMaker maker)
        {
            maker.CreateMockFor<EntryContentBase>(this);
            maker.CreateMockFor<EntryContentBase>(this, Children);
            maker.CreateMockFor(this, RepoGet);
            maker.CreateMockFor(this, LoaderGet);
        }
    }
}