using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using EPiServer;
using EPiServer.Core;
using EPiServer.Web;
using Moq;

namespace EPiFakeMaker
{
    public class FakePage : IFake
    {
        private readonly IList<IFake> _children;
        private Mock<SiteDefinition> _siteDefinitonMock;
        private static readonly Random Randomizer = new Random();

        private FakePage()
        {
            _children = new List<IFake>();
        }

        public virtual IContent Content { get; private set; }
        public virtual IList<IFake> Children { get { return _children; } }

        public void HelpCreatingMockForCurrentType(IFakeMaker maker)
        {
            maker.CreateMockFor<PageData>(this);
            maker.CreateMockFor<PageData>(this, Children);
            maker.CreateMockFor(this, RepoGet);
            maker.CreateMockFor(this, LoaderGet);
        }

        public Expression<Func<IContentRepository, IContent>> RepoGet { get; private set; }
        public Expression<Func<IContentLoader, IContent>> LoaderGet { get; private set; }

        public static FakePage Create(string pageName)
        {
            return Create<PageData>(pageName);
        }

        public static FakePage Create<T>(string pageName) where T : PageData, new()
        {
            var fake = new FakePage { Content = new T() };

            fake.Content.Property["PageName"] = new PropertyString(pageName);

            fake.WithReferenceId(Randomizer.Next(10, 1000));

            fake.VisibleInMenu();

            fake.RepoGet = repo => repo.Get<T>(fake.Content.ContentLink);
            fake.LoaderGet = loader => loader.Get<T>(fake.Content.ContentLink);

            return fake;
        }

        public virtual FakePage ChildOf(FakePage parent)
        {
            parent.Children.Add(this);

            Content.Property["PageParentLink"] = new PropertyPageReference(parent.Content.ContentLink);

            return this;
        }

        public virtual FakePage PublishedOn(DateTime publishDate)
        {
            PublishedOn(publishDate, null);

            return this;
        }

        public virtual FakePage PublishedOn(DateTime publishDate, DateTime? stopPublishDate)
        {
            Content.Property["PageStartPublish"] = new PropertyDate(publishDate);

            WorkStatus(VersionStatus.Published);

            StopPublishOn(stopPublishDate.HasValue ? stopPublishDate.Value : publishDate.AddYears(1));

            return this;
        }

        public virtual FakePage VisibleInMenu()
        {
            return SetMenuVisibility(true);
        }

        public virtual FakePage HiddenFromMenu()
        {
            return SetMenuVisibility(false);
        }

        public virtual FakePage SetMenuVisibility(bool isVisible)
        {
            Content.Property["PageVisibleInMenu"] = new PropertyBoolean(isVisible);

            return this;
        }

        public virtual FakePage WithReferenceId(int referenceId)
        {
            Content.Property["PageLink"] = new PropertyPageReference(new PageReference(referenceId));

            return this;
        }

        public virtual FakePage WithLanguageBranch(string languageBranch)
        {
            Content.Property["PageLanguageBranch"] = new PropertyString(languageBranch);

            return this;
        }

        public virtual FakePage WithProperty(string propertyName, PropertyData propertyData)
        {
            Content.Property[propertyName] = propertyData;

            return this;
        }

        public virtual FakePage WithContentTypeId(int contentTypeId)
        {
            Content.Property["PageTypeID"] = new PropertyNumber(contentTypeId);

            return this;
        }

        public virtual FakePage WithChildren(IEnumerable<FakePage> children)
        {
            children.ToList().ForEach(c => c.ChildOf(this));

            return this;
        }

        public virtual FakePage StopPublishOn(DateTime stopPublishDate)
        {
            Content.Property["PageStopPublish"] = new PropertyDate(stopPublishDate);

            return this;
        }

        public virtual FakePage WorkStatus(VersionStatus status)
        {
            Content.Property["PageWorkStatus"] = new PropertyNumber((int)status);

            return this;
        }

        public virtual FakePage AsStartPage()
        {
            if (_siteDefinitonMock == null)
            {
                _siteDefinitonMock = SetupSiteDefinition();
            }

            _siteDefinitonMock.SetupGet(def => def.StartPage).Returns(Content.ContentLink);

            return this;
        }

        private static Mock<SiteDefinition> SetupSiteDefinition()
        {
            var mock = new Mock<SiteDefinition>();

            mock.SetupGet(def => def.Name).Returns("FakeMakerSiteDefinition");

            SiteDefinition.Current = mock.Object;

            return mock;
        }

        public virtual T To<T>() where T : class, IContent
        {
            return Content as T;
        }
    }
}
