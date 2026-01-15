namespace backend;

using backend.Hubs;
using backend.Endpoints;
using backend.Services;

public class program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        builder.Services.AddSingleton<SystemInfoService>();
        builder.Services.AddSingleton<SshService>();
        builder.Services.AddSingleton<CliService>();
        builder.Services.AddHostedService<SystemMonitorWorker>();
        builder.Services.AddSignalR();

        var app = builder.Build();

        ConfigureEndpoints(app);
        ConfigureMapExtensions(app);
        
        app.Run();
    }

    private static void ConfigureEndpoints(WebApplication app)
    {
        app.MapEndpoints();
    }

    private static void ConfigureMapExtensions(WebApplication app)
    {
        app.MapProjectHubs();
    }
}