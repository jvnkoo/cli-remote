namespace backend.Endpoints;

using backend.Services;
using Microsoft.AspNetCore.Http.HttpResults;

public static class Endpoints
{
    public static void MapEndpoints(this IEndpointRouteBuilder app)
    {
        // app.MapGet("/api/cli", async (CliService cliService) => 
        // {
        //     var result = await cliService.RunCommandAsync("ls");
        //     return Results.Ok(result);
        // });
    }
}