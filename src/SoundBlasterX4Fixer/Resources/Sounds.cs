using System.Globalization;
using System.Resources;

namespace SoundBlasterX4Fixer.Resources
{
    internal static class Sounds
    {
        private static readonly ResourceManager ResourceManager = new(
            "SoundBlasterX4Fixer.Resources.Sounds",
            typeof(Sounds).Assembly
        );

        public static UnmanagedMemoryStream Silence => GetStream(nameof(Silence));

        private static UnmanagedMemoryStream GetStream(string name)
        {
            UnmanagedMemoryStream? stream = ResourceManager.GetStream(name, CultureInfo.InvariantCulture);

            if (stream == null)
            {
                throw new ArgumentException($"Can't find resource: {name}");
            }

            return stream;
        }
    }
}
