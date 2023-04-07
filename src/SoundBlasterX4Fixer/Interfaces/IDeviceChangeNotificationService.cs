using NAudio.CoreAudioApi.Interfaces;

namespace SoundBlasterX4Fixer.Interfaces
{
    internal interface IDeviceChangeNotificationService : IMMNotificationClient
    {
        void Register();
        void Unregister();
    }
}
