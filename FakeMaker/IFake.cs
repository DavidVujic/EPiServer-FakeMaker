using EPiServer.Core;
using System.Collections.Generic;

namespace EPiFakeMaker
{
    public interface IFake
    {
        IContent Content { get; }
        IList<IFake> Children { get; }
    }
}
