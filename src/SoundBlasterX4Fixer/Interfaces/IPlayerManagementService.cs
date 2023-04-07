using NAudio.CoreAudioApi;

namespace SoundBlasterX4Fixer.Interfaces
{
    internal interface IPlayerManagementService
    {
        void Start();
        void Stop();
        void AddPlayer(string deviceId);
        void RemovePlayer(string deviceId);
    }
}
