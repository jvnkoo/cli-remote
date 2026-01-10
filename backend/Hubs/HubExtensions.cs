namespace backend.Hubs;

public static class HubExtensions
{
    public static void MapProjectHubs(this IEndpointRouteBuilder app)
    {
        app.MapHub<SystemHub>("/systemHub");
    }
}