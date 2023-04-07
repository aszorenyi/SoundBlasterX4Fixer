namespace SoundBlasterX4Fixer.Interfaces
{
    internal interface IPlayerService : IDisposable
    {
        bool IsActive();
        void Play();
        void Stop();
    }
}
