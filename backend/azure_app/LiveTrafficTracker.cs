namespace azure_app
{
    using System.Collections.Concurrent;

    public static class LiveTrafficTracker
    {
        private static readonly ConcurrentDictionary<string, bool> ActiveConnections = new();

        public static int GetActiveUserCount()
        {
            return ActiveConnections.Count;
        }

        public static void AddConnection(string connectionId)
        {
            ActiveConnections.TryAdd(connectionId, true);
        }

        public static void RemoveConnection(string connectionId)
        {
            ActiveConnections.TryRemove(connectionId, out _);
        }
    }

}
