namespace backend.Hubs;

using backend.Services;
using Microsoft.AspNetCore.SignalR;

public class SystemHub : Hub
{
    private readonly SshService _sshService;

    public SystemHub(SshService sshService)
    {
        _sshService = sshService;
    }
    
    public async Task<String> ExecuteCli(string command, bool useSudo)
    {
        string result = await _sshService.RunCommandAsync(command, useSudo);

        return result;
    }
    
    public void UpdateSudoPassword(string password)
    {
        _sshService.SetSudoPassword(password);
    }
}