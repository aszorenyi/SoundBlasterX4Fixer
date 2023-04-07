using System.Runtime.Versioning;

namespace SoundBlasterX4Fixer
{
    internal class Program
    {
        [SupportedOSPlatform("windows")]
        public static void Main(string[] args)
        {
            Console.WriteLine("Hello, World!");
        }
    }
}