﻿using Microsoft.Extensions.DependencyInjection;
using SoundBlasterX4Fixer.Services;

namespace SoundBlasterX4Fixer.Dependencies
{
    internal static class DependencyRegister
    {
        public static void ConfigureServices(IServiceCollection serviceCollection)
        {
            RegisterServices(serviceCollection);
            RegisterHostedService(serviceCollection);
        }

        private static void RegisterServices(IServiceCollection serviceCollection)
        {

        }

        private static void RegisterHostedService(IServiceCollection serviceCollection)
            => serviceCollection.AddHostedService<WindowsService>();
    }
}
