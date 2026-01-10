namespace backend.Services;

using backend.Hubs;
using Microsoft.AspNetCore.SignalR;

public class SystemMonitorWorker : BackgroundService
{
    private readonly IHubContext<SystemHub> _hubContext;
    private readonly SystemInfoService _infoService;

    public SystemMonitorWorker(IHubContext<SystemHub> hubContext, SystemInfoService infoService)
    {
        _hubContext = hubContext;
        _infoService = infoService;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var data = new
            {
                os = _infoService.GetPrettyOsName(),
                cpu = await _infoService.GetCpuLoadAsync(),
                ram = _infoService.GetRamUsage()
            };

            await _hubContext.Clients.All.SendAsync("receiveStatus", data, stoppingToken);
            await Task.Delay(1000, stoppingToken);
        }
    }
}