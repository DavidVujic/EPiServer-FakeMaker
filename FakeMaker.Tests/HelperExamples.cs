using System.Collections.Generic;
using System.Linq;
using EPiServer;
using EPiServer.Core;

namespace EPiFakeMaker.Tests
{
    /// <summary>
    /// This is an example of a helper class.
    /// The repository is injected to the methods of the class.
    /// </summary>
    public static class HelperExamples
    {
        public static IEnumerable<IContent> GetChildrenOf(ContentReference root, IContentLoader repository)
        {
            return repository.GetChildren<IContent>(root);
        }

        private static IEnumerable<ContentReference> GetDescendantsOf(ContentReference root, IContentLoader repository)
        {
            return repository.GetDescendents(root);
        }

        public static IEnumerable<IContent> GetDescendantsOf<T>(ContentReference root, IContentLoader repository)
            where T : PageData
        {
            var descendants = GetDescendantsOf(root, repository);
            var pages = descendants
                .Select(repository.Get<IContent>)
                .OfType<T>();

            return pages;
        }

        public static IEnumerable<IContent> GetAllPublishedPages(ContentReference root, IContentLoader repository)
        {
            var descendants = GetDescendantsOf(root, repository);

            var references = descendants
                .Where(item => ToPage(item, repository).CheckPublishedStatus(PagePublishedStatus.Published));

            return references.Select(reference => ToPage(reference, repository)).Cast<IContent>().ToList();
        }

        private static PageData ToPage(ContentReference reference, IContentLoader repository)
        {
            var page = repository.Get<PageData>(reference);

            return page;
        }

        public static IEnumerable<IContent> GetMenu(ContentReference reference, IContentRepository repository)
        {
            var children = repository.GetChildren<PageData>(reference);

            return children.Where(page => page.VisibleInMenu).ToList();
        }
    }
}
