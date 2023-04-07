using NAudio.CoreAudioApi;
using SoundBlasterX4Fixer.Interfaces;
using System.Collections.Concurrent;

namespace SoundBlasterX4Fixer.Services
{
    internal sealed class PlayerManagementService : IPlayerManagementService, IDisposable
    {
        private readonly IDeviceService _deviceService;
        private readonly IDictionary<string, IPlayerService> _players;

        private bool _disposed;

        public PlayerManagementService(IDeviceService deviceService)
        {
            _deviceService = deviceService;
            _players = new ConcurrentDictionary<string, IPlayerService>();
            InitializePlayers();
        }

        private void InitializePlayers()
        {
            var devices = _deviceService.GetDevices();

            foreach (var device in devices)
            {
                AddPlayer(device);
            }
        }

        private void AddPlayer(MMDevice device)
        {
            _players.Add(device.ID, new PlayerService(device));
            _players[device.ID].Play();
        }

        private void RemovePlayer(MMDevice device)
        {
            var player = _players[device.ID];
            _players.Remove(device.ID);

            player.Stop();
            player.Dispose();
        }

        public void AddPlayer(string deviceId)
        {
            if (!_players.ContainsKey(deviceId))
            {
                var device = _deviceService.GetDevice(deviceId);
                AddPlayer(device);
            }
        }

        public void RemovePlayer(string deviceId)
        {
            if (_players.ContainsKey(deviceId))
            {
                var device = _deviceService.GetDevice(deviceId);
                RemovePlayer(device);
            }
        }

        public void Start()
        {
            foreach (var player in _players.Values)
            {
                player.Play();
            }
        }

        public void Stop()
        {
            foreach (var player in _players.Values)
            {
                player.Stop();       
            }
        }

        private void Dispose(bool disposing)
        {
            if (_disposed)
            {
                return;
            }

            if (disposing)
            {
                foreach (var player in _players.Values)
                {
                    player.Dispose();
                }
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
