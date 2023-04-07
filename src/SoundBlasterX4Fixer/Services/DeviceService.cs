using NAudio.CoreAudioApi;
using SoundBlasterX4Fixer.Interfaces;
using System.Collections.Immutable;

namespace SoundBlasterX4Fixer.Services
{
    internal class DeviceService : IDeviceService
    {
        private const string DeviceName = "Sound Blaster X4";

        public bool IsMatchingDevice(string deviceId)
        {
            var device = GetDevice(deviceId);
            return string.Equals(
                device.DeviceFriendlyName,
                DeviceName,
                StringComparison.InvariantCultureIgnoreCase
            );
        }

        public bool IsMatchingDevice(MMDevice device)
        {
            return string.Equals(
                device.DeviceFriendlyName,
                DeviceName,
                StringComparison.InvariantCultureIgnoreCase
            );
        }

        public MMDevice GetDevice(string deviceId)
        {
            using var wasapiEnumerator = new MMDeviceEnumerator();
            return wasapiEnumerator.GetDevice(deviceId);
        }

        public ICollection<MMDevice> GetDevices()
        {
            using var wasapiEnumerator = new MMDeviceEnumerator();
            var devices = wasapiEnumerator.EnumerateAudioEndPoints(
                DataFlow.Render,
                DeviceState.Active
            ).Where(
                wasapiDevice => string.Equals(
                    wasapiDevice.DeviceFriendlyName,
                    DeviceName,
                    StringComparison.InvariantCultureIgnoreCase
                )
            );

            return devices.ToImmutableList();
        }
    }
}
