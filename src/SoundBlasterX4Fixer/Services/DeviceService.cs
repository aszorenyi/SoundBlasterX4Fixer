using NAudio.CoreAudioApi;
using SoundBlasterX4Fixer.Interfaces;
using System.Collections.Immutable;

namespace SoundBlasterX4Fixer.Services
{
    internal class DeviceService : IDeviceService
    {
        private readonly string[] DeviceNames = new[] { "Sound Blaster X3", "Sound Blaster X4" };

        public bool IsMatchingDevice(string deviceId)
        {
            var device = GetDevice(deviceId);
            return DeviceNames.Any(
                deviceName => string.Equals(
                    device.DeviceFriendlyName,
                    deviceName,
                    StringComparison.InvariantCultureIgnoreCase
                )
            );
        }

        public bool IsMatchingDevice(MMDevice device)
        {
            return DeviceNames.Any(
                deviceName => string.Equals(
                    device.DeviceFriendlyName,
                    deviceName,
                    StringComparison.InvariantCultureIgnoreCase
                )
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
                wasapiDevice => DeviceNames.Any(
                    deviceName => string.Equals(
                        wasapiDevice.DeviceFriendlyName,
                        deviceName,
                        StringComparison.InvariantCultureIgnoreCase
                    )
                )
            );

            return devices.ToImmutableList();
        }
    }
}
