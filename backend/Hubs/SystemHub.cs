namespace backend.Hubs;

using System.Collections.Concurrent;
using backend.Services;
using Microsoft.AspNetCore.SignalR;

public class SystemHub : Hub
{
    private readonly SshService _sshService;
    private static readonly ConcurrentDictionary<string, CancellationTokenSource> _activeCommands = new();

    public SystemHub(SshService sshService)
    {
        _sshService = sshService;
    }
    
    public async Task<string> ExecuteCli(string command, bool useSudo)
    {
        var cts = new CancellationTokenSource();
        _activeCommands[Context.ConnectionId] = cts;

        try
        {
            return await _sshService.RunCommandAsync(command, useSudo, cts.Token);
        }
        catch (OperationCanceledException)
        {
            return "[Terminated]";
        }
        finally
        {
            _activeCommands.TryRemove(Context.ConnectionId, out _);
        }
    }
    
    public void UpdateSudoPassword(string password)
    {
        _sshService.SetSudoPassword(password);
    }
    
    public void UpdateConnectionData(string host, string user, string pass)
    {
        _sshService.SetConnectionData(host, user, pass);
    }
    
    public void StopCurrentCommand()
    {
        if (_activeCommands.TryRemove(Context.ConnectionId, out var cts))
        {
            cts.Cancel();
        }
    }
}