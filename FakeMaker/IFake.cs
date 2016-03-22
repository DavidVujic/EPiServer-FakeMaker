using EPiServer.Core;
using System.Collections.Generic;
using System;

namespace EPiFakeMaker
{
    public interface IFake
    {
        IContent Content { get; }
        IList<IFake> Children { get; }
    }

    public abstract class Fake : IFake
    {
        public abstract IList<IFake> Children { get; }
        public abstract IContent Content { get; protected set; }

        internal abstract void HelpCreatingMockForCurrentType(IFakeMaker maker);
    }
}
