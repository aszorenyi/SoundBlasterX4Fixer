using Microsoft.Extensions.Hosting;
using SoundBlasterX4Fixer.Interfaces;

namespace SoundBlasterX4Fixer.Services
{
    internal sealed class WindowsService : BackgroundService
    {
        private readonly IPlayerManagementService _playerManagementService;
        private readonly IDeviceChangeNotificationService _deviceChangeNotificationService;
        public WindowsService(IPlayerManagementService playerManagementService, IDeviceChangeNotificationService deviceChangeNotificationService)
        {
            _playerManagementService = playerManagementService;
            _deviceChangeNotificationService = deviceChangeNotificationService;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                _deviceChangeNotificationService.Register();
                _playerManagementService.Start();

                stoppingToken.Register(
                    () =>
                    {
                        _playerManagementService.Stop();
                        _deviceChangeNotificationService.Unregister();
                    }
                );
                await Task.CompletedTask;
            }
            catch (TaskCanceledException)
            {

            }
            catch (Exception)
            {
                Environment.Exit(-1);
            }
        }
    }
}
