using Microsoft.Extensions.Hosting;

namespace SoundBlasterX4Fixer.Services
{
    internal class WindowsService : BackgroundService
    {
        public WindowsService()
        {

        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
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
