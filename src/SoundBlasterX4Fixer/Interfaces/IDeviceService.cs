using NAudio.CoreAudioApi;

namespace SoundBlasterX4Fixer.Interfaces
{
    internal interface IDeviceService
    {
        bool IsMatchingDevice(string deviceId);
        bool IsMatchingDevice(MMDevice device);
        MMDevice GetDevice(string deviceId);
        ICollection<MMDevice> GetDevices();
    }
}
