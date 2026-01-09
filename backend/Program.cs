namespace backend;

using backend.Endpoints;

public class program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        var app = builder.Build();

        ConfigureEndpoints(app);
        
        app.Run();
    }

    private static void ConfigureEndpoints(WebApplication app)
    {
        app.MapEndpoints();
    }
}