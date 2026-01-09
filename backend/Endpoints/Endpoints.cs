namespace backend.Endpoints;

using Microsoft.AspNetCore.Http.HttpResults;

public static class Endpoints
{
    public static void MapEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/system", () => new
        {
            os = "Arch Linux", 
            cpu = "15%"
        });
    }
}