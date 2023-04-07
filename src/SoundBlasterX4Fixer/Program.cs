using Microsoft.Extensions.Hosting;
using SoundBlasterX4Fixer.Dependencies;
using System.Runtime.Versioning;

namespace SoundBlasterX4Fixer
{
    internal class Program
    {
        [SupportedOSPlatform("windows")]
        public static async Task Main(string[] args)
        {
            using var host = CreateHostBuilder().Build();
            await host.RunAsync();
        }

        private static IHostBuilder CreateHostBuilder() => Host.CreateDefaultBuilder().ConfigureServices(
            (serviceCollection) => DependencyRegister.ConfigureServices(serviceCollection)
        ).UseWindowsService();
    }
}