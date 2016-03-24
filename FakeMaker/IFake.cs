using EPiServer.Core;
using System.Collections.Generic;
using System.Runtime.CompilerServices;

[assembly: InternalsVisibleTo("FakeMaker.Commerce")]

namespace EPiFakeMaker
{
    public interface IFake
    {
        IContent Content { get; }
        IList<IFake> Children { get; }
    }
}
