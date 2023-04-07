using NAudio.CoreAudioApi;
using NAudio.Extras;
using NAudio.Wave;
using SoundBlasterX4Fixer.Interfaces;
using SoundBlasterX4Fixer.Resources;

namespace SoundBlasterX4Fixer.Services
{
    internal sealed class PlayerService : IPlayerService, IDisposable
    {
        private readonly MMDevice _device;
        private readonly UnmanagedMemoryStream _soundStream;
        private readonly WaveStream _waveStream;
        private readonly LoopStream _loopStream;
        private readonly WasapiOut _wasapiOut;

        private bool _disposed;

        public MMDevice Device => _device;

        public PlayerService(MMDevice device)
        {
            _device = device;

            _soundStream = Sounds.Silence;
            _waveStream = new WaveFileReader(_soundStream);
            _loopStream = new LoopStream(_waveStream);
            _wasapiOut = new WasapiOut(device, AudioClientShareMode.Shared, true, 200);
            _wasapiOut.Init(_loopStream);
        }

        public bool IsActive()
        {
            return _wasapiOut.PlaybackState == PlaybackState.Playing;
        }
        public void Play()
        {
            if (!IsActive())
            {
                _wasapiOut.Play();
            }
        }

        public void Stop()
        {
            if (IsActive())
            {
                _wasapiOut.Stop();
            }
        }
        
        ~PlayerService() => Dispose(false);

        private void Dispose(bool disposing)
        {
            if (_disposed)
            {
                return;
            }

            if (disposing)
            {
                Stop();
                _loopStream.Dispose();
                _waveStream.Dispose();
                _wasapiOut.Dispose();
            }

            _soundStream.Dispose();
            _disposed = true;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}
