using System;
using System.Collections.Generic;
using EPiServer.Core;

namespace FakeMaker
{
	public class FakePage : PageData
	{
		private readonly IList<IContent> _children;

		private static readonly Random Randomizer = new Random();

		public IList<IContent> Children { get { return _children; } }

		private FakePage()
		{
			_children = new List<IContent>();
		}

		public static FakePage Create(string pageName)
		{
			var page = new FakePage();

			page.Property["PageName"] = new PropertyString(pageName);

			page.WithReferenceId(Randomizer.Next(10, 1000));

			page.IsVisibleInMenu();

			return page;
		}

		public FakePage WithReferenceId(int referenceId)
		{
			Property["PageLink"] = new PropertyPageReference(new PageReference(referenceId));

			return this;
		}

		public FakePage IsChildOf(ContentReference parentReference)
		{
			Property["PageParentLink"] = new PropertyPageReference(parentReference);

			return this;
		}

		public FakePage IsChildOf(IContent parent)
		{
			var testPage = parent as FakePage;

			if (testPage != null)
			{
				testPage.Children.Add(this);
			}

			return IsChildOf(parent.ContentLink);
		}

		public FakePage PublishedOn(DateTime publishDate)
		{
			return PublishedOn(publishDate, null);
		}

		public FakePage PublishedOn(DateTime publishDate, DateTime? stopPublishDate)
		{
			Property["PageStartPublish"] = new PropertyDate(publishDate);

			HasWorkStatus(VersionStatus.Published);

			StopPublishOn(stopPublishDate.HasValue ? stopPublishDate.Value : publishDate.AddYears(1));

			return this;
		}

		public FakePage StopPublishOn(DateTime stopPublishDate)
		{
			Property["PageStopPublish"] = new PropertyDate(stopPublishDate);

			return this;
		}

		public FakePage HasWorkStatus(VersionStatus status)
		{
			Property["PageWorkStatus"] = new PropertyNumber((int)status);

			return this;
		}

		public FakePage IsVisibleInMenu()
		{
			SetMenuVisibility(true);

			return this;
		}

		public FakePage IsHiddenFromMenu()
		{
			SetMenuVisibility(false);

			return this;
		}

		private void SetMenuVisibility(bool isVisible)
		{
			Property["PageVisibleInMenu"] = new PropertyBoolean(isVisible);
		}

		public T To<T>() where T : PageData
		{
			return this as T;
		}
	}
}
