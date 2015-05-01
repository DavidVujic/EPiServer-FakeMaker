using System;
using System.Collections.Generic;
using System.Linq;
using EPiServer.Core;
using EPiServer.Web;
using Moq;

namespace EPiFakeMaker
{
	public class FakePage
	{
		public virtual PageData Page { get; private set; }

		private readonly IList<FakePage> _children;

		private Mock<SiteDefinition> _siteDefinitonMock;

		private static readonly Random Randomizer = new Random();

		public virtual IList<FakePage> Children { get { return _children; } }

		private FakePage()
		{
			_children = new List<FakePage>();
		}

		private static Mock<SiteDefinition> SetupSiteDefinition()
		{
			var mock = new Mock<SiteDefinition>();

			mock.SetupGet(def => def.Name).Returns("FakeMakerSiteDefinition");

			SiteDefinition.Current = mock.Object;

			return mock;
		}

		public static FakePage Create(string pageName)
		{
			return Create<PageData>(pageName);
		}

		public static FakePage Create<T>(string pageName) where T : PageData, new()
		{
			var fake = new FakePage {Page = new T()};

			fake.Page.Property["PageName"] = new PropertyString(pageName);

			fake.WithReferenceId(Randomizer.Next(10, 1000));

			fake.VisibleInMenu();

			return fake;
		}

		public virtual FakePage ChildOf(FakePage parent)
		{
			parent.Children.Add(this);

			Page.Property["PageParentLink"] = new PropertyPageReference(parent.Page.ContentLink);

			return this;
		}

		public virtual FakePage PublishedOn(DateTime publishDate)
		{
			 PublishedOn(publishDate, null);

			return this;
		}

		public virtual FakePage PublishedOn(DateTime publishDate, DateTime? stopPublishDate)
		{
			Page.Property["PageStartPublish"] = new PropertyDate(publishDate);

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
			Page.Property["PageVisibleInMenu"] = new PropertyBoolean(isVisible);

			return this;
		}

		public virtual FakePage WithReferenceId(int referenceId)
		{
			Page.Property["PageLink"] = new PropertyPageReference(new PageReference(referenceId));

			return this;
		}

		public virtual FakePage WithLanguageBranch(string languageBranch)
		{
			Page.Property["PageLanguageBranch"] = new PropertyString(languageBranch);

			return this;
		}

		public virtual FakePage WithProperty(string propertyName, PropertyData propertyData)
		{
			Page.Property[propertyName] = propertyData;

			return this;
		}

		public virtual FakePage WithContentTypeId(int contentTypeId)
		{
			Page.Property["PageTypeID"] = new PropertyNumber(contentTypeId);

			return this;
		}

		public virtual FakePage WithChildren(IEnumerable<FakePage> children)
		{
			children.ToList().ForEach(c => c.ChildOf(this));

			return this;
		}

		public virtual FakePage StopPublishOn(DateTime stopPublishDate)
		{
			Page.Property["PageStopPublish"] = new PropertyDate(stopPublishDate);

			return this;
		}

		public virtual FakePage WorkStatus(VersionStatus status)
		{
			Page.Property["PageWorkStatus"] = new PropertyNumber((int)status);

			return this;
		}

		public virtual FakePage AsStartPage()
		{
			if (_siteDefinitonMock == null)
			{
				_siteDefinitonMock = SetupSiteDefinition();
			}

			_siteDefinitonMock.SetupGet(def => def.StartPage).Returns(Page.ContentLink);

			return this;
		}

		public virtual T To<T>() where T : PageData
		{
			return Page as T;
		}
	}
}
