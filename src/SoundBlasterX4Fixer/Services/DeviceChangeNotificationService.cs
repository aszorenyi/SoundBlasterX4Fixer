using NAudio.CoreAudioApi;
using SoundBlasterX4Fixer.Interfaces;

namespace SoundBlasterX4Fixer.Services
{
    internal sealed class DeviceChangeNotificationService : IDeviceChangeNotificationService, IDisposable
    {
        private readonly IDeviceService _deviceService;
        private readonly IPlayerManagementService _playerManagementService;

        private readonly MMDeviceEnumerator _wasapiEnumerator;
        private bool _registered;

        private bool _disposed;

        public DeviceChangeNotificationService(IDeviceService deviceService, IPlayerManagementService playerManagementService)
        {
            _deviceService = deviceService;
            _playerManagementService = playerManagementService;
            _wasapiEnumerator = new MMDeviceEnumerator();
        }

        public void Register()
        {
            if (_registered)
            {
                return;
            }

            _wasapiEnumerator.RegisterEndpointNotificationCallback(this);
            _registered = true;
        }

        public void Unregister()
        {
            if (!_registered)
            {
                return;
            }

            _wasapiEnumerator.UnregisterEndpointNotificationCallback(this);
            _registered = false;
        }

        public void OnDeviceAdded(string deviceId)
        {
            if (_deviceService.IsMatchingDevice(deviceId))
            {
                _playerManagementService.AddPlayer(deviceId);
            }
        }

        public void OnDeviceRemoved(string deviceId)
        {
            if (_deviceService.IsMatchingDevice(deviceId))
            {
                _playerManagementService.RemovePlayer(deviceId);
            }
        }

        public void OnDeviceStateChanged(string deviceId, DeviceState newState)
        {
            if (_deviceService.IsMatchingDevice(deviceId))
            {
                if (newState == DeviceState.Active)
                {
                    _playerManagementService.AddPlayer(deviceId);
                }
                else
                {
                    _playerManagementService.RemovePlayer(deviceId);
                }
            }
        }

        public void OnDefaultDeviceChanged(DataFlow flow, Role role, string defaultDeviceId)
        {
        }

        public void OnPropertyValueChanged(string deviceId, PropertyKey key)
        {

        }

        private void Dispose(bool disposing)
        {
            if (_disposed)
            {
                return;
            }

            if (disposing)
            {
                _wasapiEnumerator.Dispose();
            }

            _disposed = true;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}
