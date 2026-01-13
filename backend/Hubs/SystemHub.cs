namespace backend.Hubs;

using backend.Services;
using Microsoft.AspNetCore.SignalR;

public class SystemHub : Hub
{
    private readonly CliService _cliService;

    public SystemHub(CliService cliService)
    {
        _cliService = cliService;
    }
    
    public async Task<String> ExecuteCli(string command, bool useSudo)
    {
        string result = await _cliService.RunCommandAsync(command, useSudo);

        return result;
    }
    
    public void UpdateSudoPassword(string password)
    {
        _cliService.SetSudoPassword(password);
    }
}